export type ContactPayload = {
  name: string;
  email: string;
  message: string;
};

export type ContactValidationError =
  "missing_fields" | "invalid_email" | "invalid_body";

const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function parseContactBody(
  input: unknown,
):
  | { ok: true; data: ContactPayload }
  | { ok: false; error: ContactValidationError } {
  if (!input || typeof input !== "object") {
    return { ok: false, error: "invalid_body" };
  }

  const record = input as Record<string, unknown>;
  const name = typeof record.name === "string" ? record.name.trim() : "";
  const email = typeof record.email === "string" ? record.email.trim() : "";
  const message =
    typeof record.message === "string" ? record.message.trim() : "";

  if (!name || !email || !message) {
    return { ok: false, error: "missing_fields" };
  }

  if (!emailPattern.test(email)) {
    return { ok: false, error: "invalid_email" };
  }

  return { ok: true, data: { name, email, message } };
}

export const contactErrorMessages: Record<ContactValidationError, string> = {
  missing_fields: "Please fill in all fields.",
  invalid_email: "Please enter a valid email.",
  invalid_body: "Invalid request.",
};
