import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:share_plus/share_plus.dart";
import "package:url_launcher/url_launcher.dart";

import "../core/site.dart";
import "../core/theme.dart";

/// Instagram-style share sheet for the in-app browser.
Future<void> showBrowserShareSheet(
  BuildContext context, {
  required String url,
  required String title,
  required bool zh,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: SundayColors.ink.withValues(alpha: 0.35),
    isScrollControlled: true,
    builder: (sheetContext) {
      return BrowserShareSheet(url: url, title: title, zh: zh);
    },
  );
}

class BrowserShareSheet extends StatelessWidget {
  const BrowserShareSheet({
    super.key,
    required this.url,
    required this.title,
    required this.zh,
  });

  final String url;
  final String title;
  final bool zh;

  String get _shareText => "$title\n$url";

  Future<void> _runAfterClose(
    BuildContext context,
    Future<void> Function(ScaffoldMessengerState messenger) action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    await action(messenger);
  }

  Future<void> _copyLink(ScaffoldMessengerState messenger) async {
    await Clipboard.setData(ClipboardData(text: url));
    messenger.showSnackBar(
      SnackBar(content: Text(zh ? "链接已复制" : "Link copied")),
    );
  }

  Future<void> _systemShare() async {
    await SharePlus.instance.share(
      ShareParams(text: _shareText, subject: title),
    );
  }

  Future<void> _launchShareUri(
    Uri uri,
    ScaffoldMessengerState messenger,
  ) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(zh ? "无法打开该应用，试试「更多」" : "App unavailable — try More"),
        ),
      );
    }
  }

  Future<void> _openExternal(ScaffoldMessengerState messenger) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(zh ? "无法打开系统浏览器" : "Could not open browser")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final targets = <_ShareTarget>[
      _ShareTarget(
        label: zh ? "复制" : "Copy",
        background: SundayColors.ink,
        foreground: Colors.white,
        icon: Icons.link_rounded,
        onTap: () => _runAfterClose(context, _copyLink),
      ),
      _ShareTarget(
        label: zh ? "信息" : "Messages",
        background: const Color(0xFF34C759),
        foreground: Colors.white,
        icon: Icons.sms_rounded,
        onTap: () => _runAfterClose(
          context,
          (m) => _launchShareUri(
            Uri(scheme: "sms", queryParameters: {"body": _shareText}),
            m,
          ),
        ),
      ),
      _ShareTarget(
        label: zh ? "邮件" : "Mail",
        background: const Color(0xFF007AFF),
        foreground: Colors.white,
        icon: Icons.mail_rounded,
        onTap: () => _runAfterClose(
          context,
          (m) => _launchShareUri(
            Uri(
              scheme: "mailto",
              queryParameters: {"subject": title, "body": _shareText},
            ),
            m,
          ),
        ),
      ),
      _ShareTarget(
        label: "X",
        background: SundayColors.ink,
        foreground: Colors.white,
        glyph: "𝕏",
        onTap: () => _runAfterClose(
          context,
          (m) => _launchShareUri(
            Uri.https("twitter.com", "/intent/tweet", {
              "text": title,
              "url": url,
            }),
            m,
          ),
        ),
      ),
      _ShareTarget(
        label: "LinkedIn",
        background: const Color(0xFF0A66C2),
        foreground: Colors.white,
        glyph: "in",
        onTap: () => _runAfterClose(
          context,
          (m) => _launchShareUri(
            Uri.https("www.linkedin.com", "/sharing/share-offsite/", {
              "url": url,
            }),
            m,
          ),
        ),
      ),
      _ShareTarget(
        label: "WhatsApp",
        background: const Color(0xFF25D366),
        foreground: Colors.white,
        icon: Icons.chat_rounded,
        onTap: () => _runAfterClose(
          context,
          (m) =>
              _launchShareUri(Uri.https("wa.me", "/", {"text": _shareText}), m),
        ),
      ),
      _ShareTarget(
        label: zh ? "更多" : "More",
        background: SundayColors.accentDim,
        foreground: SundayColors.accentDeep,
        icon: Icons.ios_share_rounded,
        onTap: () => _runAfterClose(context, (_) => _systemShare()),
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, bottom + 12),
      child: Material(
        color: SundayColors.panel,
        borderRadius: BorderRadius.circular(SundayRadii.lg),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: SundayColors.lineStrong,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zh ? "分享" : "Share",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: SundayColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: SundayColors.muted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: zh ? "关闭" : "Close",
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: SundayColors.muted,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 104,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: targets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  return _ShareBubble(target: targets[index]);
                },
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: SundayColors.line.withValues(alpha: 0.9)),
            _ActionTile(
              icon: Icons.open_in_browser_rounded,
              label: zh ? "用系统浏览器打开" : "Open in browser",
              onTap: () => _runAfterClose(context, _openExternal),
            ),
            _ActionTile(
              icon: Icons.person_outline_rounded,
              label: zh ? "分享作品集主页" : "Share portfolio home",
              onTap: () => _runAfterClose(context, (_) async {
                final text = zh
                    ? "${Site.name} · ${Site.jobTitle}\n${Site.website}"
                    : "${Site.name} — ${Site.jobTitle}\n${Site.website}";
                await SharePlus.instance.share(
                  ShareParams(text: text, subject: Site.name),
                );
              }),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _ShareTarget {
  const _ShareTarget({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.icon,
    this.glyph,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final IconData? icon;
  final String? glyph;
}

class _ShareBubble extends StatelessWidget {
  const _ShareBubble({required this.target});

  final _ShareTarget target;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: target.onTap,
      borderRadius: BorderRadius.circular(SundayRadii.md),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: target.background,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: target.glyph != null
                  ? Text(
                      target.glyph!,
                      style: TextStyle(
                        color: target.foreground,
                        fontSize: target.glyph == "in" ? 18 : 22,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    )
                  : Icon(target.icon, color: target.foreground, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              target.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: SundayColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: SundayColors.ink, size: 22),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: SundayColors.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      minVerticalPadding: 14,
    );
  }
}
