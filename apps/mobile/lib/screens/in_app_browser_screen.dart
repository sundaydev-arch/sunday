import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:webview_flutter/webview_flutter.dart";

import "../core/theme.dart";

/// Open an https link in the in-app WebView (never the system browser).
void openInAppWebView(
  BuildContext context, {
  required String url,
  String? title,
}) {
  final uri = Uri.parse(url);
  final q = <String, String>{
    "url": uri.toString(),
    if (title != null && title.isNotEmpty) "title": title,
  };
  context.push(Uri(path: "/browse", queryParameters: q).toString());
}

class InAppBrowserScreen extends StatefulWidget {
  const InAppBrowserScreen({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  State<InAppBrowserScreen> createState() => _InAppBrowserScreenState();
}

class _InAppBrowserScreenState extends State<InAppBrowserScreen> {
  late final WebViewController _controller;
  var _loading = true;
  var _progress = 0;
  String _pageTitle = "";

  @override
  void initState() {
    super.initState();
    _pageTitle = widget.title ?? Uri.tryParse(widget.url)?.host ?? "browser";

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(SundayColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (mounted) setState(() => _progress = p);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) async {
            final title = await _controller.getTitle();
            if (!mounted) return;
            setState(() {
              _loading = false;
              if (title != null && title.trim().isNotEmpty) {
                _pageTitle = title.trim();
              }
            });
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SundayColors.background,
      appBar: AppBar(
        backgroundColor: SundayColors.navTrack,
        foregroundColor: SundayColors.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: "Close",
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          _pageTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: SundayColors.ink,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: () => _controller.reload(),
            icon: const Icon(Icons.refresh_rounded, size: 20),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _loading
              ? LinearProgressIndicator(
                  value: _progress > 0 && _progress < 100
                      ? _progress / 100
                      : null,
                  minHeight: 2,
                  backgroundColor: SundayColors.line,
                  color: SundayColors.accent,
                )
              : const SizedBox(height: 2),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
