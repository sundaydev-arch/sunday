/// Compile-time / runtime config via `--dart-define`.
///
/// Example:
/// ```bash
/// flutter run \
///   --dart-define=API_BASE_URL=https://sundaydev.vercel.app \
///   --dart-define=TURNSTILE_SITE_KEY=... \
///   --dart-define=SENTRY_DSN=... \
///   --dart-define=POSTHOG_KEY=... \
///   --dart-define=POSTHOG_HOST=https://us.i.posthog.com \
///   --dart-define=CAL_LINK=https://cal.com/nathan-zhao
/// ```
class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: SiteUrl.defaultApi,
  );

  static const turnstileSiteKey = String.fromEnvironment(
    "TURNSTILE_SITE_KEY",
    defaultValue: "",
  );

  static const sentryDsn = String.fromEnvironment(
    "SENTRY_DSN",
    defaultValue: "",
  );

  static const posthogKey = String.fromEnvironment(
    "POSTHOG_KEY",
    defaultValue: "",
  );

  static const posthogHost = String.fromEnvironment(
    "POSTHOG_HOST",
    defaultValue: "https://us.i.posthog.com",
  );

  static const calLink = String.fromEnvironment(
    "CAL_LINK",
    defaultValue: "https://cal.com/nathan-zhao",
  );

  /// Optional HTTP(S) proxy for API calls (dev only).
  /// Pass via `--dart-define=HTTPS_PROXY=http://127.0.0.1:7890` or
  /// `dart_defines.dev.json` — never hardcoded into release builds.
  static const httpsProxy = String.fromEnvironment("HTTPS_PROXY");

  static bool get hasTurnstile => turnstileSiteKey.isNotEmpty;
  static bool get hasSentry => sentryDsn.isNotEmpty;
  static bool get hasPosthog => posthogKey.isNotEmpty;
  static bool get hasHttpsProxy => httpsProxy.trim().isNotEmpty;
}

class SiteUrl {
  static const defaultApi = "https://sundaydev.vercel.app";
}
