import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "../core/config.dart";
import "../core/site.dart";
import "../core/theme.dart";
import "../i18n/dictionary.dart";

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key, required this.dict});

  final Dictionary dict;

  @override
  Widget build(BuildContext context) {
    final links = [
      (dict.contact["github"] as String, Site.github),
      (dict.contact["website"] as String, Site.website),
      (dict.contact["schedule"] as String, AppConfig.calLink),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: SundayColors.line, height: 1),
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SundayColors.accent,
                      decoration: TextDecoration.underline,
                      decorationColor: SundayColors.line,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "${dict.footer["exit"] as String}0 · ${dict.footer["stack"] as String}",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: SundayColors.muted),
          ),
        ],
      ),
    );
  }
}
