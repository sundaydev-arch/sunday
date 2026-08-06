#!/usr/bin/env node
/**
 * Generate Flutter Dart mirror of @sunday/contact from contract.json.
 * Zod cannot run in Dart — this keeps limits + error codes in lockstep.
 *
 * Usage:
 *   node scripts/sync-mobile-contact.mjs
 *   node scripts/sync-mobile-contact.mjs --check
 */
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const contractPath = join(root, "packages/contact/src/contract.json");
const destPath = join(root, "apps/mobile/lib/data/contact_validation.dart");
const check = process.argv.includes("--check");

const contract = JSON.parse(readFileSync(contractPath, "utf8"));
const { limits, errorMessages, errorCodes } = contract;

const messagesEntries = errorCodes
  .map((code) => `  "${code}": ${JSON.stringify(errorMessages[code])},`)
  .join("\n");

const dart = `// GENERATED FILE — do not edit by hand.
// Source: packages/contact/src/contract.json (@sunday/contact)
// Regenerate: node scripts/sync-mobile-contact.mjs

typedef ContactValidationError = String;

const contactNameMax = ${limits.nameMax};
const contactEmailMax = ${limits.emailMax};
const contactMessageMax = ${limits.messageMax};

const contactErrorMessages = <ContactValidationError, String>{
${messagesEntries}
};

final _emailPattern = RegExp(
  r"^[a-zA-Z0-9.!#\\$%&'*+/=?^_\`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+\$",
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
`;

let current = "";
try {
  current = readFileSync(destPath, "utf8");
} catch {
  current = "";
}

if (current === dart) {
  if (!check) {
    console.error(
      "Mobile contact validation already in sync with @sunday/contact.",
    );
  }
  process.exit(0);
}

if (check) {
  console.error(
    "Out of sync: apps/mobile/lib/data/contact_validation.dart ≠ packages/contact/src/contract.json",
  );
  console.error("Run: node scripts/sync-mobile-contact.mjs");
  process.exit(1);
}

writeFileSync(destPath, dart);
console.error("Synced contact_validation.dart ← @sunday/contact contract.json");
