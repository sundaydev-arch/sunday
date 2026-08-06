import "package:flutter/material.dart";

import "../core/theme.dart";

/// Soft sky wash behind pages — cool, not flat white.
class AtmosphereBackdrop extends StatelessWidget {
  const AtmosphereBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: SundayColors.background),
        const Positioned(
          top: -120,
          right: -80,
          child: _Glow(size: 320, color: SundayColors.heroGlow),
        ),
        const Positioned(
          top: 180,
          left: -100,
          child: _Glow(size: 260, color: SundayColors.glowCool),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
