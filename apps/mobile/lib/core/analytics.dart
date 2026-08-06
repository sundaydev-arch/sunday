import "package:flutter/foundation.dart";
import "package:posthog_flutter/posthog_flutter.dart";
import "package:sentry_flutter/sentry_flutter.dart";

import "config.dart";

/// Typed event names — keep product analytics consistent with `@sunday/analytics`.
abstract final class AnalyticsEvents {
  static const pageView = "\$pageview";
  static const contactSubmitSucceeded = "contact_submit_succeeded";
  static const contactSubmitFailed = "contact_submit_failed";
}

class Analytics {
  Analytics._();
  static final instance = Analytics._();

  bool _posthogReady = false;

  Future<void> init() async {
    if (AppConfig.hasPosthog) {
      final config = PostHogConfig(AppConfig.posthogKey);
      config.host = AppConfig.posthogHost;
      config.captureApplicationLifecycleEvents = true;
      config.debug = kDebugMode;
      await Posthog().setup(config);
      _posthogReady = true;
    }
  }

  Future<void> capturePageView(String path) async {
    if (!_posthogReady) return;
    await Posthog().screen(screenName: path, properties: {"\$pathname": path});
  }

  Future<void> captureEvent(
    String name, {
    Map<String, Object>? properties,
  }) async {
    if (!_posthogReady) return;
    await Posthog().capture(eventName: name, properties: properties);
  }

  Future<void> captureException(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) async {
    if (!AppConfig.hasSentry) {
      debugPrint("Analytics exception: $error");
      return;
    }
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (extras != null) {
          scope.setContexts("extras", extras);
        }
      },
    );
  }
}
