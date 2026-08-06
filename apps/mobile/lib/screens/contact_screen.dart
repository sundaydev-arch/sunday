import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:url_launcher/url_launcher.dart";

import "../core/config.dart";
import "../core/site.dart";
import "../core/theme.dart";
import "../i18n/locale_controller.dart";
import "../widgets/contact_form.dart";
import "../widgets/site_footer.dart";

class ContactScreen extends ConsumerWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictAsync = ref.watch(dictionaryProvider);

    return dictAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("$e")),
      data: (dict) {
        final theme = Theme.of(context);
        final contact = dict.contact;
        final links = [
          (contact["github"] as String, Site.github),
          (contact["website"] as String, Site.website),
          (contact["schedule"] as String, AppConfig.calLink),
        ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 0),
          children: [
            Text(
              contact["eyebrow"] as String,
              style: theme.textTheme.labelSmall?.copyWith(
                color: SundayColors.accent,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              contact["title"] as String,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: SundayColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              contact["blurb"] as String,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: SundayColors.muted,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                for (final (label, url) in links)
                  InkWell(
                    onTap: () => launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: SundayColors.accent,
                        decoration: TextDecoration.underline,
                        decorationColor: SundayColors.line,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            ContactForm(dict: dict),
            const SizedBox(height: 40),
            Text(
              contact["calEyebrow"] as String,
              style: theme.textTheme.labelSmall?.copyWith(
                color: SundayColors.accent,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              contact["calTitle"] as String,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: SundayColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              contact["calBlurb"] as String,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: SundayColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => launchUrl(
                Uri.parse(AppConfig.calLink),
                mode: LaunchMode.externalApplication,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: SundayColors.ink,
                side: const BorderSide(color: SundayColors.line),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const StadiumBorder(),
              ),
              child: Text(contact["schedule"] as String),
            ),
            SiteFooter(dict: dict),
          ],
        );
      },
    );
  }
}
