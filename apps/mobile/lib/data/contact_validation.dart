// GENERATED FILE — do not edit by hand.
// Source: packages/contact/src/contract.json (@sunday/contact)
// Regenerate: node scripts/sync-mobile-contact.mjs

typedef ContactValidationError = String;

const contactNameMax = 120;
const contactEmailMax = 254;
const contactMessageMax = 5000;

const contactErrorMessages = <ContactValidationError, String>{
  "missing_fields": "Please fill in all fields.",
  "invalid_email": "Please enter a valid email.",
  "invalid_body": "Invalid request.",
  "name_too_long": "Name is too long.",
  "message_too_long": "Message is too long.",
  "captcha_required": "Please complete the captcha.",
  "captcha_failed": "Captcha verification failed. Please try again.",
  "rate_limited": "Too many messages. Please wait and try again.",
};

final _emailPattern = RegExp(
  r"^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
);

class ContactPayload {
  const ContactPayload({
    required this.name,
    required this.email,
    required this.message,
    this.turnstileToken,
  });

  final String name;
  final String email;
  final String message;
  final String? turnstileToken;

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "message": message,
    if (turnstileToken != null && turnstileToken!.isNotEmpty)
      "turnstileToken": turnstileToken,
  };

  factory ContactPayload.fromJson(Map<String, dynamic> json) {
    return ContactPayload(
      name: json["name"] as String,
      email: json["email"] as String,
      message: json["message"] as String,
      turnstileToken: json["turnstileToken"] as String?,
    );
  }
}

class ContactParseResult {
  const ContactParseResult.ok(this.data) : error = null, fieldErrors = null;
  const ContactParseResult.fail(this.error, {this.fieldErrors}) : data = null;

  final ContactPayload? data;
  final ContactValidationError? error;
  final Map<String, ContactValidationError>? fieldErrors;

  bool get success => data != null;
}

ContactParseResult parseContactBody({
  required String name,
  required String email,
  required String message,
  String? turnstileToken,
}) {
  final trimmedName = name.trim();
  final trimmedEmail = email.trim();
  final trimmedMessage = message.trim();
  final fieldErrors = <String, ContactValidationError>{};

  if (trimmedName.isEmpty) {
    fieldErrors["name"] = "missing_fields";
  } else if (trimmedName.length > contactNameMax) {
    fieldErrors["name"] = "name_too_long";
  }

  if (trimmedEmail.isEmpty) {
    fieldErrors["email"] = "missing_fields";
  } else if (trimmedEmail.length > contactEmailMax ||
      !_emailPattern.hasMatch(trimmedEmail)) {
    fieldErrors["email"] = "invalid_email";
  }

  if (trimmedMessage.isEmpty) {
    fieldErrors["message"] = "missing_fields";
  } else if (trimmedMessage.length > contactMessageMax) {
    fieldErrors["message"] = "message_too_long";
  }

  if (fieldErrors.isNotEmpty) {
    return ContactParseResult.fail(
      fieldErrors.values.first,
      fieldErrors: fieldErrors,
    );
  }

  return ContactParseResult.ok(
    ContactPayload(
      name: trimmedName,
      email: trimmedEmail,
      message: trimmedMessage,
      turnstileToken: turnstileToken,
    ),
  );
}
