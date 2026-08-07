import "dart:async";
import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../core/di.dart";
import "../core/site.dart";
import "../core/theme.dart";
import "atmosphere.dart";

/// Becomes `true` after the launch splash finishes exiting.
final splashDoneProvider = StateProvider<bool>((ref) => false);

const _splashEnabledKey = "splash_animation_enabled";

/// 3s branded splash with skip + permanent disable.
///
/// Native launch (same Clear Day wash + mark) hands off into this surface so
/// the engine warm-up never looks like a blank white screen.
class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key, required this.child});

  final Widget child;

  /// Full intro length before auto-dismiss (unless skipped).
  static const animationDuration = Duration(seconds: 3);
  static const exitDuration = Duration(milliseconds: 480);

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _exit;
  late final Animation<double> _fadeOut;
  late final Animation<double> _liftOut;

  var _showSplash = true;
  var _exitStarted = false;
  var _prefsLoaded = false;
  var _animationEnabled = true;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: SplashGate.animationDuration,
    );
    _exit = AnimationController(vsync: this, duration: SplashGate.exitDuration);
    _fadeOut = CurvedAnimation(parent: _exit, curve: Curves.easeOutCubic);
    _liftOut = Tween<double>(
      begin: 0,
      end: -22,
    ).animate(CurvedAnimation(parent: _exit, curve: Curves.easeInOutCubic));

    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_splashEnabledKey) ?? true;
    if (!mounted) return;

    setState(() {
      _prefsLoaded = true;
      _animationEnabled = enabled;
    });

    if (!enabled) {
      await _finish();
      return;
    }

    unawaited(
      _intro.forward().then((_) {
        if (mounted) unawaited(_finish());
      }),
    );
  }

  Future<void> _finish() async {
    if (_exitStarted) return;
    _exitStarted = true;

    // Don't drop into the app before DI is ready (skip can be early).
    try {
      await bootstrapReady.timeout(const Duration(seconds: 8));
    } catch (_) {
      // Prefer entering the shell over hanging on splash forever.
    }
    if (!mounted) return;

    // Short dissolve even when skipped, so the handoff stays soft.
    if (_showSplash) {
      await _exit.forward();
    }
    if (!mounted) return;
    ref.read(splashDoneProvider.notifier).state = true;
    setState(() => _showSplash = false);
  }

  Future<void> _skip() async {
    HapticFeedback.selectionClick();
    _intro.stop();
    await _finish();
  }

  Future<void> _disableAndSkip() async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_splashEnabledKey, false);
    _intro.stop();
    await _finish();
  }

  @override
  void dispose() {
    _intro.dispose();
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
            animation: Listenable.merge([_intro, _exit]),
            builder: (context, child) {
              final exiting = _exit.value;
              return IgnorePointer(
                ignoring: _exitStarted && exiting > 0.85,
                child: Opacity(
                  opacity: 1 - _fadeOut.value,
                  child: Transform.translate(
                    offset: Offset(0, _liftOut.value),
                    child: child,
                  ),
                ),
              );
            },
            child: _SplashSurface(
              progress: !_prefsLoaded
                  ? const AlwaysStoppedAnimation(0)
                  : (_animationEnabled
                        ? _intro
                        : const AlwaysStoppedAnimation(1)),
              onSkip: _skip,
              onDisable: _disableAndSkip,
            ),
          ),
      ],
    );
  }
}

class _SplashSurface extends StatelessWidget {
  const _SplashSurface({
    required this.progress,
    required this.onSkip,
    required this.onDisable,
  });

  final Animation<double> progress;
  final VoidCallback onSkip;
  final VoidCallback onDisable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final skipLabel = locale == "zh" ? "跳过" : "Skip";
    final disableLabel = locale == "zh" ? "关闭动画" : "Turn off";

    return AtmosphereBackdrop(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: onDisable,
                    style: TextButton.styleFrom(
                      foregroundColor: SundayColors.muted,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      disableLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: SundayColors.ink,
                      backgroundColor: SundayColors.panel.withValues(
                        alpha: 0.72,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SundayRadii.pill),
                        side: const BorderSide(color: SundayColors.line),
                      ),
                    ),
                    child: Text(
                      skipLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: progress,
                builder: (context, _) {
                  return _SplashHero(t: progress.value);
                },
              ),
            ),
            Positioned(
              left: 48,
              right: 48,
              bottom: 36,
              child: AnimatedBuilder(
                animation: progress,
                builder: (context, _) {
                  return _SplashProgress(value: progress.value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashHero extends StatelessWidget {
  const _SplashHero({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 0–0.35 mark, 0.25–0.55 name, 0.45–0.7 title, then hold / breathe.
    final markOpacity = Curves.easeOut.transform((t / 0.32).clamp(0.0, 1.0));
    final markScale = 0.82 + 0.18 * markOpacity;
    final nameOpacity = Curves.easeOut.transform(
      ((t - 0.22) / 0.28).clamp(0.0, 1.0),
    );
    final nameDy = (1 - nameOpacity) * 16;
    final titleOpacity = Curves.easeOut.transform(
      ((t - 0.42) / 0.26).clamp(0.0, 1.0),
    );
    final pulse = 1 + 0.025 * math.sin(t * math.pi * 2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: markOpacity,
          child: Transform.scale(
            scale: markScale * pulse,
            child: SizedBox(
              width: 88,
              height: 88,
              child: CustomPaint(
                painter: _MarkPainter(drawProgress: markOpacity),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Opacity(
          opacity: nameOpacity,
          child: Transform.translate(
            offset: Offset(0, nameDy),
            child: Text(
              Site.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: SundayColors.ink,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                height: 1.1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Opacity(
          opacity: titleOpacity,
          child: Text(
            Site.jobTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              color: SundayColors.accent,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _SplashProgress extends StatelessWidget {
  const _SplashProgress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: 3,
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          backgroundColor: SundayColors.line,
          color: SundayColors.accent,
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({required this.drawProgress});

  final double drawProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final sweep = 5.4 * drawProgress.clamp(0.0, 1.0);

    final ring = Paint()
      ..color = SundayColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -0.9,
      sweep,
      false,
      ring,
    );

    if (drawProgress < 0.55) return;

    final chevronOpacity = ((drawProgress - 0.55) / 0.45).clamp(0.0, 1.0);
    final chevron = Paint()
      ..color = SundayColors.ink.withValues(alpha: chevronOpacity)
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
  bool shouldRepaint(covariant _MarkPainter oldDelegate) =>
      oldDelegate.drawProgress != drawProgress;
}
