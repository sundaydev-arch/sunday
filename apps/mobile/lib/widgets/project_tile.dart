import "package:flutter/material.dart";

import "../core/site.dart";
import "../core/theme.dart";

class ProjectTile extends StatelessWidget {
  const ProjectTile({
    super.key,
    required this.project,
    this.compact = false,
    this.index,
  });

  final Project project;
  final bool compact;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padY = compact ? 22.0 : 28.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padY),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index != null) ...[
            SizedBox(
              width: 36,
              child: Text(
                index!.toString().padLeft(2, "0"),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: SundayColors.accent,
                  letterSpacing: 0.5,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          height: 1.2,
                          fontSize: compact ? 20 : 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(SundayRadii.pill),
                        border: Border.all(color: SundayColors.line),
                      ),
                      child: Text(
                        project.year,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: SundayColors.muted,
                          letterSpacing: 0.3,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  project.role,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: SundayColors.accentDeep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 12),
                  Text(
                    project.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
                  ),
                  const SizedBox(height: 14),
                  ...project.highlights.map(
                    (h) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: SundayColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              h,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: SundayColors.foreground,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Text(
                  project.tags.join("  ·  "),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SundayColors.muted,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
