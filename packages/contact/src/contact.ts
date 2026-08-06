import { z } from "zod";
import contract from "./contract.json" with { type: "json" };

export type ContactValidationError = (typeof contract.errorCodes)[number];

export const contactLimits = contract.limits;

export const contactErrorMessages = contract.errorMessages as Record<
  ContactValidationError,
  string
>;

export const contactSchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, "missing_fields")
    .max(contactLimits.nameMax, "name_too_long"),
  email: z
    .string()
    .trim()
    .min(1, "missing_fields")
    .email("invalid_email")
    .max(contactLimits.emailMax, "invalid_email"),
  message: z
    .string()
    .trim()
    .min(1, "missing_fields")
    .max(contactLimits.messageMax, "message_too_long"),
  turnstileToken: z.string().optional(),
});

export type ContactPayload = z.infer<typeof contactSchema>;

/** Fields persisted to Supabase (no captcha token). */
export type ContactMessage = Pick<ContactPayload, "name" | "email" | "message">;

export function parseContactBody(input: unknown):
  | { ok: true; data: ContactPayload }
  | {
      ok: false;
      error: ContactValidationError;
      fieldErrors?: Partial<
        Record<"name" | "email" | "message", ContactValidationError>
      >;
    } {
  if (!input || typeof input !== "object") {
    return { ok: false, error: "invalid_body" };
  }

  const result = contactSchema.safeParse(input);
  if (result.success) {
    return { ok: true, data: result.data };
  }

  const fieldErrors: Partial<
    Record<"name" | "email" | "message", ContactValidationError>
  > = {};
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

export function toContactMessage(data: ContactPayload): ContactMessage {
  return {
    name: data.name,
    email: data.email,
    message: data.message,
  };
}
