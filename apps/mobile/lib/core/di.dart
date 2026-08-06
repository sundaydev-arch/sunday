import "dart:async";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/foundation.dart";
import "package:get_it/get_it.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../data/contact_api.dart";
import "../data/contact_outbox.dart";
import "../data/connectivity_service.dart";
import "analytics.dart";
import "flavor.dart";

final GetIt getIt = GetIt.instance;

/// Completes when DI + analytics finished — splash can exit safely.
final Completer<void> bootstrapCompleter = Completer<void>();

Future<void> get bootstrapReady => bootstrapCompleter.future;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<SharedPreferences>()) {
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(getIt<Connectivity>()),
  );

  getIt.registerLazySingleton<ContactApi>(() => ContactApi());
  getIt.registerLazySingleton<ContactOutbox>(
    () => ContactOutbox(
      prefs: getIt<SharedPreferences>(),
      api: getIt<ContactApi>(),
      connectivity: getIt<ConnectivityService>(),
    ),
  );

  await getIt<ConnectivityService>().start();
  await getIt<ContactOutbox>().start();

  if (kDebugMode) {
    debugPrint("DI ready · flavor=${FlavorConfig.label}");
  }
}

Future<void> bootstrapApp() async {
  try {
    await configureDependencies();
    await Analytics.instance.init();
    if (!bootstrapCompleter.isCompleted) {
      bootstrapCompleter.complete();
    }
  } catch (error, stackTrace) {
    if (!bootstrapCompleter.isCompleted) {
      bootstrapCompleter.completeError(error, stackTrace);
    }
    rethrow;
  }
}
