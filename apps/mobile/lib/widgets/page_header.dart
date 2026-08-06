import "package:flutter/material.dart";

import "../core/theme.dart";

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.blurb});

  final String title;
  final String? blurb;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineLarge?.copyWith(fontSize: 34),
        ),
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: SundayColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        if (blurb != null) ...[
          const SizedBox(height: 16),
          Text(
            blurb!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: SundayColors.muted,
            ),
          ),
        ],
      ],
    );
  }
}
