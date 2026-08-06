import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/site.dart";
import "../core/theme.dart";
import "atmosphere.dart";

/// Becomes `true` after the launch splash finishes exiting.
final splashDoneProvider = StateProvider<bool>((ref) => false);

/// First-paint branded splash that fades into [child].
///
/// Keeps a cool Clear Day surface so the native launch color → Flutter
/// handoff stays seamless, then exits with a short dissolve.
class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate>
    with SingleTickerProviderStateMixin {
  static const _minVisible = Duration(milliseconds: 1100);
  static const _exitDuration = Duration(milliseconds: 520);

  late final AnimationController _exit;
  late final Animation<double> _fade;
  late final Animation<double> _lift;
  var _showSplash = true;
  var _exitStarted = false;

  @override
  void initState() {
    super.initState();
    _exit = AnimationController(vsync: this, duration: _exitDuration);
    _fade = CurvedAnimation(parent: _exit, curve: Curves.easeOutCubic);
    _lift = Tween<double>(begin: 0, end: -18).animate(
      CurvedAnimation(parent: _exit, curve: Curves.easeInOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleExit());
  }

  Future<void> _scheduleExit() async {
    await Future<void>.delayed(_minVisible);
    if (!mounted || _exitStarted) return;
    _exitStarted = true;
    await _exit.forward();
    if (!mounted) return;
    ref.read(splashDoneProvider.notifier).state = true;
    setState(() => _showSplash = false);
  }

  @override
  void dispose() {
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_showSplash)
          AnimatedBuilder(
            animation: _exit,
            builder: (context, child) {
              return IgnorePointer(
                ignoring: _exit.isAnimating || _exit.isCompleted,
                child: Opacity(
                  opacity: 1 - _fade.value,
                  child: Transform.translate(
                    offset: Offset(0, _lift.value),
                    child: child,
                  ),
                ),
              );
            },
            child: const _SplashSurface(),
          ),
      ],
    );
  }
}

class _SplashSurface extends StatelessWidget {
  const _SplashSurface();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AtmosphereBackdrop(
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Mark()
                  .animate()
                  .fadeIn(duration: 420.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.86, 0.86),
                    end: const Offset(1, 1),
                    duration: 560.ms,
                    curve: Curves.easeOutCubic,
                  ),
              const SizedBox(height: 28),
              Text(
                    Site.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: SundayColors.ink,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      height: 1.1,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 420.ms)
                  .slideY(
                    begin: 0.18,
                    end: 0,
                    delay: 120.ms,
                    duration: 480.ms,
                    curve: Curves.easeOutCubic,
                  ),
              const SizedBox(height: 10),
              Text(
                    Site.jobTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: SundayColors.accent,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 220.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cool ring mark — matches Clear Day accent, not the old copper glyph.
class _Mark extends StatelessWidget {
  const _Mark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: CustomPaint(painter: _MarkPainter()),
    );
  }
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    final ring = Paint()
      ..color = SundayColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Open ring (gap at ~1 o'clock) — quiet identity, not a logo dump.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -0.9,
      5.4,
      false,
      ring,
    );

    final chevron = Paint()
      ..color = SundayColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(center.dx - 10, center.dy - 2)
      ..lineTo(center.dx - 1, center.dy + 8)
      ..lineTo(center.dx + 14, center.dy - 10);
    canvas.drawPath(path, chevron);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
