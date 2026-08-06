import "core/flavor.dart";
import "main.dart" as app;

/// Dev flavor entrypoint:
/// `flutter run --flavor dev -t lib/main_dev.dart`
Future<void> main() => app.startApp(AppFlavor.dev);
