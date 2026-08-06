enum AppFlavor { dev, prod }

/// Compile-time flavor — set via entrypoint (`main_dev` / `main_prod`).
abstract final class FlavorConfig {
  static AppFlavor flavor = AppFlavor.prod;

  static bool get isDev => flavor == AppFlavor.dev;
  static bool get isProd => flavor == AppFlavor.prod;

  static String get label => isDev ? "dev" : "prod";

  static String get appTitle => isDev ? "Nathan Zhao (dev)" : "Nathan Zhao";
}
