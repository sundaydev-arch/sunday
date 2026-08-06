import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/theme.dart";
import "../i18n/locale_controller.dart";
import "../widgets/project_tile.dart";
import "../widgets/site_footer.dart";

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);

    return dictAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("$e")),
      data: (dict) {
        final theme = Theme.of(context);
        final projects = dict.projects;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 0),
          children: [
            Text(
              projects["eyebrow"] as String,
              style: theme.textTheme.labelSmall?.copyWith(
                color: SundayColors.accent,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              projects["title"] as String,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: SundayColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              projects["blurb"] as String,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: SundayColors.muted,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 20),
            ...dict.items.map((p) => ProjectTile(project: p)),
            SiteFooter(dict: dict),
          ],
        );
      },
    );
  }
}
