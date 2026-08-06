import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "core/theme.dart";
import "i18n/locale_controller.dart";
import "router/app_router.dart";

class SundayApp extends ConsumerWidget {
  const SundayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: "Nathan Zhao",
      debugShowCheckedModeBanner: false,
      theme: buildSundayTheme(),
      locale: Locale(locale),
      supportedLocales: const [Locale("en"), Locale("zh")],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
