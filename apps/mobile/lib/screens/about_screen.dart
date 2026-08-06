import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/theme.dart";
import "../i18n/dictionary.dart";
import "../i18n/locale_controller.dart";
import "../widgets/site_footer.dart";

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);

    return dictAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("$e")),
      data: (dict) => _AboutBody(dict: dict),
    );
  }
}

class _AboutBody extends StatelessWidget {
  const _AboutBody({required this.dict});
  final Dictionary dict;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final about = dict.about;
    final skills = dict.skills;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 0),
      children: [
        Text(
          about["eyebrow"] as String,
          style: theme.textTheme.labelSmall?.copyWith(
            color: SundayColors.accent,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          about["title"] as String,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: SundayColors.ink,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          about["intro"] as String,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: SundayColors.foreground,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        _kv(theme, about["focusLabel"] as String, about["focus"] as String),
        const SizedBox(height: 24),
        Text(
          about["strengthsLabel"] as String,
          style: theme.textTheme.labelMedium?.copyWith(
            color: SundayColors.accent,
          ),
        ),
        const SizedBox(height: 12),
        ...dict.strengths.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: SundayColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: SundayColors.muted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          about["stackLabel"] as String,
          style: theme.textTheme.labelMedium?.copyWith(
            color: SundayColors.accent,
          ),
        ),
        const SizedBox(height: 12),
        for (final entry in skills.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _kv(theme, entry.key, entry.value),
          ),
        SiteFooter(dict: dict),
      ],
    );
  }

  Widget _kv(ThemeData theme, String key, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          key,
          style: theme.textTheme.labelMedium?.copyWith(
            color: SundayColors.accent,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: SundayColors.muted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
