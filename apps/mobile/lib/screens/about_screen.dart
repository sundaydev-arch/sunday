import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/mobile_copy.dart";
import "../core/theme.dart";
import "../i18n/dictionary.dart";
import "../i18n/locale_controller.dart";
import "../widgets/app_chrome.dart";
import "../widgets/app_error.dart";
import "../widgets/page_header.dart";
import "../widgets/site_footer.dart";

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);
    final locale = ref.watch(localeProvider);

    return dictAsync.when(
      loading: () =>
          const PageScaffold(child: Center(child: CircularProgressIndicator())),
      error: (e, _) => PageScaffold(
        child: AppErrorView(
          title: "Couldn't load about",
          detail: "$e",
          onRetry: () => ref.invalidate(dictionaryProvider),
        ),
      ),
      data: (dict) => PageScaffold(
        child: _AboutBody(dict: dict, locale: locale),
      ),
    );
  }
}

class _AboutBody extends StatelessWidget {
  const _AboutBody({required this.dict, required this.locale});
  final Dictionary dict;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final about = dict.about;
    final skills = dict.skills;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        SundaySpace.pageX,
        appTopChromeInset(context) + 8,
        SundaySpace.pageX,
        appBottomChromeInset(context),
      ),
      children: [
        PageHeader(title: MobileCopy.aboutTitle(locale)),
        const SizedBox(height: 20),
        Text(about["intro"] as String, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 36),
        Text(
          MobileCopy.focus(locale).toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: SundayColors.muted,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          about["focus"] as String,
          style: theme.textTheme.titleMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 36),
        Text(
          MobileCopy.strengths(locale).toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: SundayColors.muted,
          ),
        ),
        ...dict.strengths.map(
          (s) => Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.label, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  s.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: SundayColors.muted,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 36),
        Text(
          MobileCopy.stack(locale).toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: SundayColors.muted,
          ),
        ),
        for (final entry in skills.entries)
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _skillTitle(entry.key),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: SundayColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: SundayColors.muted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        SiteFooter(dict: dict),
      ],
    );
  }

  String _skillTitle(String key) {
    if (key.isEmpty) return key;
    return "${key[0].toUpperCase()}${key.substring(1)}";
  }
}
