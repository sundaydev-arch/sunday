import "package:flutter_test/flutter_test.dart";
import "package:sunday_mobile/data/contact_validation.dart";

void main() {
  group("parseContactBody", () {
    test("accepts valid payload", () {
      final result = parseContactBody(
        name: " Nathan ",
        email: "you@domain.dev",
        message: "hello",
      );
      expect(result.success, isTrue);
      expect(result.data!.name, "Nathan");
      expect(result.data!.email, "you@domain.dev");
    });

    test("rejects empty fields", () {
      final result = parseContactBody(name: " ", email: "", message: "");
      expect(result.success, isFalse);
      expect(result.error, "missing_fields");
      expect(result.fieldErrors!["name"], "missing_fields");
      expect(result.fieldErrors!["email"], "missing_fields");
      expect(result.fieldErrors!["message"], "missing_fields");
    });

    test("rejects invalid email", () {
      final result = parseContactBody(
        name: "n",
        email: "not-an-email",
        message: "hi",
      );
      expect(result.success, isFalse);
      expect(result.fieldErrors!["email"], "invalid_email");
    });

    test("rejects oversized name", () {
      final result = parseContactBody(
        name: "x" * 121,
        email: "a@b.co",
        message: "hi",
      );
      expect(result.success, isFalse);
      expect(result.fieldErrors!["name"], "name_too_long");
    });

    test("rejects oversized message", () {
      final result = parseContactBody(
        name: "n",
        email: "a@b.co",
        message: "m" * 5001,
      );
      expect(result.success, isFalse);
      expect(result.fieldErrors!["message"], "message_too_long");
    });
  });
}
