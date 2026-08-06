import "package:flutter/material.dart";

import "../core/cal.dart";
import "../core/site.dart";
import "../core/theme.dart";
import "../i18n/dictionary.dart";
import "../screens/in_app_browser_screen.dart";

/// Shared external links row used on contact + footers.
class SiteLinks extends StatelessWidget {
  const SiteLinks({
    super.key,
    required this.links,
    this.includeSchedule = false,
    this.dict,
    this.trailing,
  });

  /// `(rawLabel, url)` pairs. Labels are display-normalized.
  final List<(String, String)> links;
  final bool includeSchedule;
  final Dictionary? dict;

  /// Quiet meta after the links (e.g. license), same baseline.
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved = [
      ...links.map((e) => (displayLabel(e.$1), e.$2)),
      if (includeSchedule && dict != null)
        (displayLabel(dict!.contact["schedule"] as String), getCalUrl()),
    ];
    final meta = trailing?.trim();
    final hasMeta = meta != null && meta.isNotEmpty;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0,
      runSpacing: 12,
      children: [
        for (var i = 0; i < resolved.length; i++) ...[
          if (i > 0) const _DotSep(),
          _FooterLink(
            label: resolved[i].$1,
            onTap: () => openInAppWebView(
              context,
              url: resolved[i].$2,
              title: resolved[i].$1,
            ),
          ),
        ],
        if (hasMeta) ...[
          const _DotSep(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              meta,
              style: theme.textTheme.bodySmall?.copyWith(
                color: SundayColors.muted,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
                height: 1.2,
              ),
            ),
          ),
        ],
      ],
    );
  }

  static String displayLabel(String raw) {
    switch (raw.toLowerCase()) {
      case "github":
        return "GitHub";
      case "website":
        return "Website";
      case "schedule":
        return "Schedule";
      default:
        return raw;
    }
  }
}

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key, required this.dict});

  final Dictionary dict;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 48, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 1, color: SundayColors.line),
          const SizedBox(height: 28),
          SiteLinks(
            dict: dict,
            includeSchedule: true,
            trailing: dict.footer["stack"] as String,
            links: [
              (dict.contact["github"] as String, Site.github),
              (dict.contact["website"] as String, Site.website),
            ],
          ),
        ],
      ),
    );
  }
}

class _DotSep extends StatelessWidget {
  const _DotSep();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        "·",
        style: theme.textTheme.bodyMedium?.copyWith(
          color: SundayColors.lineStrong,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: SundayColors.ink,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
