import "package:flutter/material.dart";

import "../core/theme.dart";

/// Shared empty / load-failure surface used by screens and the router.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.title,
    this.detail,
    this.onRetry,
  });

  final String title;
  final String? detail;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: SundayColors.danger,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: SundayColors.ink,
                ),
              ),
              if (detail != null) ...[
                const SizedBox(height: 8),
                Text(
                  detail!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SundayColors.muted,
                    height: 1.45,
                  ),
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SundayColors.accent,
                    side: const BorderSide(color: SundayColors.line),
                  ),
                  child: const Text("retry"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
