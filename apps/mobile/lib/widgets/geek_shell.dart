import "package:flutter/material.dart";

/// Kept for call sites that still wrap hero content.
class GeekShell extends StatelessWidget {
  const GeekShell({super.key, required this.child, this.minHeight});

  final Widget child;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      color: Colors.transparent,
      child: child,
    );
  }
}
