import { beforeEach, describe, expect, it, vi } from "vitest";

vi.mock("@sunday/analytics/sentry", () => ({
  captureException: vi.fn(),
}));

vi.mock("@/lib/supabase/server", () => ({
  createClient: vi.fn(),
}));

vi.mock("@/lib/notify-contact", () => ({
  notifyContactMessage: vi.fn().mockResolvedValue({ sent: false }),
}));

vi.mock("@/lib/turnstile", () => ({
  verifyTurnstileToken: vi.fn().mockResolvedValue({ ok: true }),
}));

import { POST } from "@/app/api/contact/route";
import { createClient } from "@/lib/supabase/server";
import { verifyTurnstileToken } from "@/lib/turnstile";

function jsonRequest(body: unknown) {
  return new Request("http://localhost/api/contact", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-forwarded-for": `203.0.113.${Math.floor(Math.random() * 200)}`,
    },
    body: JSON.stringify(body),
  });
}

describe("POST /api/contact", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(verifyTurnstileToken).mockResolvedValue({ ok: true });
  });

  it("rejects invalid payloads", async () => {
    const res = await POST(
      jsonRequest({ name: "", email: "bad", message: "" }),
    );
    expect(res.status).toBe(400);
  });

  it("rejects when captcha fails", async () => {
    vi.mocked(verifyTurnstileToken).mockResolvedValue({
      ok: false,
      error: "captcha_failed",
    });
    const res = await POST(
      jsonRequest({
        name: "Ada",
        email: "ada@example.com",
        message: "hello from tests",
        turnstileToken: "x",
      }),
    );
    expect(res.status).toBe(400);
    await expect(res.json()).resolves.toMatchObject({
      error: expect.stringMatching(/captcha/i),
    });
  });

  it("inserts a valid message", async () => {
    const insert = vi.fn().mockResolvedValue({ error: null });
    vi.mocked(createClient).mockResolvedValue({
      from: () => ({ insert }),
    } as never);

    const res = await POST(
      jsonRequest({
        name: "Ada",
        email: "ada@example.com",
        message: "hello from tests",
      }),
    );
    expect(res.status).toBe(200);
    expect(insert).toHaveBeenCalledWith({
      name: "Ada",
      email: "ada@example.com",
      message: "hello from tests",
    });
  });
});
