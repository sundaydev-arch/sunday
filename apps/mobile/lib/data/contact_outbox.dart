import "dart:async";
import "dart:convert";

import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

import "connectivity_service.dart";
import "contact_api.dart";
import "contact_validation.dart";

/// Persist contact payloads while offline; flush when connectivity returns.
class ContactOutbox extends ChangeNotifier {
  ContactOutbox({
    required SharedPreferences prefs,
    required ContactApi api,
    required ConnectivityService connectivity,
  }) : _prefs = prefs,
       _api = api,
       _connectivity = connectivity;

  static const _storageKey = "contact_outbox_v1";

  final SharedPreferences _prefs;
  final ContactApi _api;
  final ConnectivityService _connectivity;

  final List<ContactPayload> _queue = [];
  var _draining = false;
  VoidCallback? _connectivityListener;

  List<ContactPayload> get pending => List.unmodifiable(_queue);
  int get pendingCount => _queue.length;
  bool get isDraining => _draining;

  Future<void> start() async {
    _load();
    _connectivityListener = () {
      if (_connectivity.isOnline) {
        unawaited(drain());
      }
    };
    _connectivity.addListener(_connectivityListener!);
    if (_connectivity.isOnline && _queue.isNotEmpty) {
      unawaited(drain());
    }
  }

  void _load() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _queue
        ..clear()
        ..addAll(
          list.map(
            (e) => ContactPayload.fromJson(Map<String, dynamic>.from(e as Map)),
          ),
        );
    } catch (e) {
      debugPrint("ContactOutbox load failed: $e");
      _queue.clear();
    }
  }

  Future<void> _persist() async {
    final encoded = jsonEncode(_queue.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
    notifyListeners();
  }

  /// Enqueue for later send. Captcha tokens are dropped (re-auth on drain
  /// is not possible offline — payload is name/email/message only).
  Future<void> enqueue(ContactPayload payload) async {
    _queue.add(
      ContactPayload(
        name: payload.name,
        email: payload.email,
        message: payload.message,
      ),
    );
    await _persist();
  }

  Future<int> drain() async {
    if (_draining || !_connectivity.isOnline || _queue.isEmpty) {
      return 0;
    }
    _draining = true;
    notifyListeners();

    var sent = 0;
    try {
      while (_queue.isNotEmpty && _connectivity.isOnline) {
        final next = _queue.first;
        final result = await _api.submit(next);
        if (result is ContactSubmitOk) {
          _queue.removeAt(0);
          sent++;
          await _persist();
        } else if (result is ContactSubmitErr && result.message == "network") {
          break;
        } else {
          // Drop poison messages that the server rejects permanently.
          _queue.removeAt(0);
          await _persist();
          debugPrint("ContactOutbox dropped item: $result");
        }
      }
    } finally {
      _draining = false;
      notifyListeners();
    }
    return sent;
  }

  @override
  void dispose() {
    if (_connectivityListener != null) {
      _connectivity.removeListener(_connectivityListener!);
    }
    super.dispose();
  }
}
