import "core/flavor.dart";
import "main.dart" as app;

/// Prod flavor entrypoint:
/// `flutter run --flavor prod -t lib/main_prod.dart`
Future<void> main() => app.startApp(AppFlavor.prod);
