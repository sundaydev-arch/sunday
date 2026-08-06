import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../core/site.dart";
import "dictionary.dart";

const _localeKey = "sunday.locale";

final localeProvider = StateNotifierProvider<LocaleController, String>((ref) {
  return LocaleController();
});

final dictionaryProvider = FutureProvider<Dictionary>((ref) async {
  final locale = ref.watch(localeProvider);
  return Dictionary.load(locale);
});

class LocaleController extends StateNotifier<String> {
  LocaleController() : super(defaultLocale) {
    _hydrate();
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localeKey);
    if (saved != null && isLocale(saved)) {
      state = saved;
    }
  }

  Future<void> setLocale(String locale) async {
    if (!isLocale(locale) || locale == state) return;
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale);
  }

  Future<void> toggle() => setLocale(state == "en" ? "zh" : "en");
}
