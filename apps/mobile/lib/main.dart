import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:sentry_flutter/sentry_flutter.dart";

import "app.dart";
import "core/analytics.dart";
import "core/config.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Future<void> bootstrap() async {
    await Analytics.instance.init();
    runApp(const ProviderScope(child: SundayApp()));
  }

  if (AppConfig.hasSentry) {
    await SentryFlutter.init((options) {
      options.dsn = AppConfig.sentryDsn;
      options.tracesSampleRate = 0.1;
      options.environment = const String.fromEnvironment(
        "SENTRY_ENVIRONMENT",
        defaultValue: "production",
      );
    }, appRunner: bootstrap);
  } else {
    await bootstrap();
  }
}
