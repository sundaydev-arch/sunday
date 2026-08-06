import "dart:async";

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

  // Paint the Flutter splash ASAP. Heavy DI / analytics warm up underneath
  // so users don't sit on a blank native launch screen.
  runApp(const ProviderScope(child: SundayApp()));
  unawaited(_warmServices());
}

Future<void> _warmServices() async {
  try {
    if (AppConfig.hasSentry) {
      await SentryFlutter.init((options) {
        options.dsn = AppConfig.sentryDsn;
        options.tracesSampleRate = 0.1;
        options.environment = FlavorConfig.label;
        options.dist = FlavorConfig.label;
      });
    }
    await bootstrapApp();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stackTrace),
    );
    if (!bootstrapCompleter.isCompleted) {
      bootstrapCompleter.complete();
    }
  }
}

/// Default entry — production flavor.
Future<void> main() => startApp(AppFlavor.prod);
