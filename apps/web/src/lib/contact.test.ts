import { describe, expect, it } from "vitest";
import { parseContactBody } from "@/lib/contact";

describe("parseContactBody", () => {
  it("accepts a valid payload", () => {
    const result = parseContactBody({
      name: " Ada ",
      email: "ada@example.com",
      message: "hello",
    });
    expect(result).toEqual({
      ok: true,
      data: {
        name: "Ada",
        email: "ada@example.com",
        message: "hello",
      },
    });
  });

  it("rejects missing fields and bad email", () => {
    expect(
      parseContactBody({ name: "", email: "a@b.c", message: "x" }).ok,
    ).toBe(false);
    expect(
      parseContactBody({ name: "Ada", email: "not-an-email", message: "x" }),
    ).toEqual({ ok: false, error: "invalid_email" });
  });
});
