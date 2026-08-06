import { describe, expect, it } from "vitest";
import { parseContactBody, contactSchema } from "@/lib/contact";

describe("contact validation", () => {
  it("accepts a valid payload", () => {
    const result = parseContactBody({
      name: "Ada",
      email: "ada@example.com",
      message: "Hello from desktop",
    });
    expect(result.ok).toBe(true);
  });

  it("rejects invalid email", () => {
    const result = parseContactBody({
      name: "Ada",
      email: "not-an-email",
      message: "Hello",
    });
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.fieldErrors?.email).toBe("invalid_email");
    }
  });

  it("rejects empty fields", () => {
    const result = contactSchema.safeParse({
      name: " ",
      email: "",
      message: "",
    });
    expect(result.success).toBe(false);
  });

  it("rejects oversized name", () => {
    const result = parseContactBody({
      name: "x".repeat(121),
      email: "ada@example.com",
      message: "Hello",
    });
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error).toBe("name_too_long");
    }
  });
});
