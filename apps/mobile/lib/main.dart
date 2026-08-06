import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:sentry_flutter/sentry_flutter.dart";

import "app.dart";
import "core/config.dart";
import "core/di.dart";
import "core/flavor.dart";

Future<void> startApp(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.flavor = flavor;

  Future<void> bootstrap() async {
    await bootstrapApp();
    runApp(const ProviderScope(child: SundayApp()));
  }

  if (AppConfig.hasSentry) {
    await SentryFlutter.init((options) {
      options.dsn = AppConfig.sentryDsn;
      options.tracesSampleRate = 0.1;
      options.environment = FlavorConfig.label;
      options.dist = FlavorConfig.label;
    }, appRunner: bootstrap);
  } else {
    await bootstrap();
  }
}

/// Default entry — production flavor.
Future<void> main() => startApp(AppFlavor.prod);
