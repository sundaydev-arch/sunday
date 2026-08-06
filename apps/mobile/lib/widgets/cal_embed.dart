import "package:flutter/material.dart";
import "package:webview_flutter/webview_flutter.dart";

import "../core/cal.dart";
import "../core/theme.dart";

/// In-app Cal.com booker (parity with web/desktop `CalEmbed`).
///
/// Height tracks the embedded page so event-list vs calendar views
/// don't leave a tall empty slab under short content.
class CalEmbed extends StatefulWidget {
  const CalEmbed({
    super.key,
    this.minHeight = 320,
    this.maxHeight = 720,
    this.initialHeight = 400,
  });

  final double minHeight;
  final double maxHeight;
  final double initialHeight;

  @override
  State<CalEmbed> createState() => _CalEmbedState();
}

class _CalEmbedState extends State<CalEmbed> {
  late final WebViewController _controller;
  late double _height;
  var _loading = true;
  var _failed = false;

  static const _heightChannel = "CalHeight";

  @override
  void initState() {
    super.initState();
    _height = widget.initialHeight;
    final embedUrl = getCalEmbedUrl();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF101010))
      ..addJavaScriptChannel(
        _heightChannel,
        onMessageReceived: (message) {
          final raw = double.tryParse(message.message);
          if (raw == null || !mounted) return;
          final next = raw.clamp(widget.minHeight, widget.maxHeight);
          if ((next - _height).abs() < 6) return;
          setState(() => _height = next);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) async {
            if (!mounted) return;
            await _installHeightObserver();
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _loading = false;
                _failed = true;
              });
            }
          },
          onNavigationRequest: (request) {
            final host = Uri.tryParse(request.url)?.host ?? "";
            // Keep booking flow inside the WebView; block random external hops.
            if (host.contains("cal.com") || host.isEmpty) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(embedUrl));
  }

  Future<void> _installHeightObserver() async {
    try {
      await _controller.runJavaScript("""
(function () {
  if (window.__sundayCalHeight) return;
  window.__sundayCalHeight = true;

  var style = document.createElement('style');
  style.textContent = [
    'html, body { height: auto !important; min-height: 0 !important; margin: 0 !important; }',
    'body { overflow: hidden !important; }',
    '[data-testid="event-types"], [data-testid="booker-container"],',
    '.cal-embed, #__next, main, [class*="Booker"] {',
    '  min-height: 0 !important; height: auto !important;',
    '}',
  ].join('\\n');
  document.head.appendChild(style);

  function contentHeight() {
    var nodes = document.querySelectorAll(
      'main, [data-testid="event-types"], [data-testid="booker-container"], [class*="Booker"], #__next > div'
    );
    var max = 0;
    for (var i = 0; i < nodes.length; i++) {
      var r = nodes[i].getBoundingClientRect();
      max = Math.max(max, r.height);
    }
    var body = document.body;
    var doc = document.documentElement;
    var fallback = Math.max(
      body ? body.scrollHeight : 0,
      body ? body.offsetHeight : 0,
      doc ? doc.scrollHeight : 0,
      doc ? doc.offsetHeight : 0
    );
    // Prefer the largest visible block; avoid 100vh-inflated fallbacks when possible.
    var h = max > 120 ? max : fallback;
    return Math.ceil(h + 8);
  }

  function report() {
    try {
      $_heightChannel.postMessage(String(contentHeight()));
    } catch (e) {}
  }

  report();
  setTimeout(report, 200);
  setTimeout(report, 600);
  setTimeout(report, 1200);

  if (window.ResizeObserver) {
    new ResizeObserver(report).observe(document.body);
  }
  if (window.MutationObserver) {
    new MutationObserver(function () {
      setTimeout(report, 80);
    }).observe(document.body, { childList: true, subtree: true });
  }
})();
""");
    } catch (_) {
      // Channel / JS may fail on transient loads; fixed height remains.
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(SundayRadii.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF101010),
          border: Border.all(color: SundayColors.line),
          borderRadius: BorderRadius.circular(SundayRadii.md),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: _height,
            width: double.infinity,
            child: Stack(
              children: [
                if (!_failed)
                  Positioned.fill(
                    child: WebViewWidget(controller: _controller),
                  ),
                if (_loading && !_failed)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0xFF101010),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: SundayColors.accent,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "loading…",
                              style: TextStyle(
                                color: SundayColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_failed)
                  Positioned.fill(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Couldn't load calendar.",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _failed = false;
                                  _loading = true;
                                  _height = widget.initialHeight;
                                });
                                _controller.loadRequest(
                                  Uri.parse(getCalEmbedUrl()),
                                );
                              },
                              child: const Text(
                                "retry",
                                style: TextStyle(color: SundayColors.accent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
