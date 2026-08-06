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

  static bool get hasTurnstile => turnstileSiteKey.isNotEmpty;
  static bool get hasSentry => sentryDsn.isNotEmpty;
  static bool get hasPosthog => posthogKey.isNotEmpty;
}

class SiteUrl {
  static const defaultApi = "https://sundaydev.vercel.app";
}
