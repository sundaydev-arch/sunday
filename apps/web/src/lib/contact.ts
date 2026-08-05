import { z } from "zod";

export const contactSchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, "missing_fields")
    .max(120, "name_too_long"),
  email: z
    .string()
    .trim()
    .min(1, "missing_fields")
    .email("invalid_email")
    .max(254, "invalid_email"),
  message: z
    .string()
    .trim()
    .min(1, "missing_fields")
    .max(5000, "message_too_long"),
});

export type ContactPayload = z.infer<typeof contactSchema>;

export type ContactValidationError =
  | "missing_fields"
  | "invalid_email"
  | "invalid_body"
  | "name_too_long"
  | "message_too_long";

export function parseContactBody(
  input: unknown,
):
  | { ok: true; data: ContactPayload }
  | { ok: false; error: ContactValidationError; fieldErrors?: Partial<Record<keyof ContactPayload, ContactValidationError>> } {
  if (!input || typeof input !== "object") {
    return { ok: false, error: "invalid_body" };
  }

  const result = contactSchema.safeParse(input);
  if (result.success) {
    return { ok: true, data: result.data };
  }

  const fieldErrors: Partial<Record<keyof ContactPayload, ContactValidationError>> =
    {};
  let first: ContactValidationError = "invalid_body";

  for (const issue of result.error.issues) {
    const key = issue.path[0];
    const code = issue.message as ContactValidationError;
    if (key === "name" || key === "email" || key === "message") {
      if (!fieldErrors[key]) fieldErrors[key] = code;
    }
    if (first === "invalid_body") first = code;
  }

  return { ok: false, error: first, fieldErrors };
}

export const contactErrorMessages: Record<ContactValidationError, string> = {
  missing_fields: "Please fill in all fields.",
  invalid_email: "Please enter a valid email.",
  invalid_body: "Invalid request.",
  name_too_long: "Name is too long.",
  message_too_long: "Message is too long.",
};
