import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:sunday_mobile/data/connectivity_service.dart";
import "package:sunday_mobile/data/contact_api.dart";
import "package:sunday_mobile/data/contact_outbox.dart";
import "package:sunday_mobile/data/contact_validation.dart";

class _FakeApi extends ContactApi {
  _FakeApi() : super(dio: Dio(BaseOptions(baseUrl: "http://localhost")));

  final calls = <ContactPayload>[];

  @override
  Future<ContactSubmitResult> submit(ContactPayload payload) async {
    calls.add(payload);
    return const ContactSubmitOk();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("outbox enqueues and drains", () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final api = _FakeApi();
    final connectivity = ConnectivityService.seeded(false);

    final outbox = ContactOutbox(
      prefs: prefs,
      api: api,
      connectivity: connectivity,
    );
    await outbox.enqueue(
      const ContactPayload(name: "n", email: "a@b.co", message: "hello"),
    );
    expect(outbox.pendingCount, 1);

    await outbox.start();
    expect(outbox.pendingCount, 1);

    // Coming online triggers auto-drain via the connectivity listener.
    connectivity.debugSetOnline(true);
    for (var i = 0; i < 20 && outbox.pendingCount > 0; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    if (outbox.pendingCount > 0) {
      await outbox.drain();
    }

    expect(outbox.pendingCount, 0);
    expect(api.calls, hasLength(1));
    expect(api.calls.single.email, "a@b.co");
  });
}
