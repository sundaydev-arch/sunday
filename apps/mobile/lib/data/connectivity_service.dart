import "dart:async";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/foundation.dart";

/// Online / offline status for banners and outbox drain.
class ConnectivityService extends ChangeNotifier {
  ConnectivityService(this._connectivity);

  /// Test / offline construction — no plugin calls.
  ConnectivityService.seeded(bool online)
    : _connectivity = null,
      _online = online;

  final Connectivity? _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  var _online = true;

  bool get isOnline => _online;

  Future<void> start() async {
    final connectivity = _connectivity;
    if (connectivity == null) return;
    final initial = await connectivity.checkConnectivity();
    _setOnline(_hasConnection(initial));
    _sub = connectivity.onConnectivityChanged.listen((results) {
      _setOnline(_hasConnection(results));
    });
  }

  @visibleForTesting
  void debugSetOnline(bool value) => _setOnline(value);

  void _setOnline(bool value) {
    if (_online == value) return;
    _online = value;
    notifyListeners();
  }

  static bool _hasConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
