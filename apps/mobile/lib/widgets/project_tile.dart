import "package:flutter/material.dart";

import "../core/site.dart";
import "../core/theme.dart";

class ProjectTile extends StatelessWidget {
  const ProjectTile({super.key, required this.project, this.compact = false});

  final Project project;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: compact ? 20 : 28),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: SundayColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: SundayColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                project.year,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SundayColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            project.role,
            style: theme.textTheme.bodySmall?.copyWith(
              color: SundayColors.accent,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 12),
            Text(
              project.summary,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: SundayColors.foreground,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            ...project.highlights.map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "› ",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SundayColors.accent,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        h,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: SundayColors.muted,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: project.tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: SundayColors.accentDim,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: SundayColors.line),
                    ),
                    child: Text(
                      tag,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: SundayColors.ink,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
