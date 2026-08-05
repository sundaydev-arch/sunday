const VERIFY_URL = "https://challenges.cloudflare.com/turnstile/v0/siteverify";

export function isTurnstileConfigured(): boolean {
  return Boolean(process.env.TURNSTILE_SECRET_KEY?.trim());
}

export function getTurnstileSiteKey(): string | undefined {
  const key = process.env.NEXT_PUBLIC_TURNSTILE_SITE_KEY?.trim();
  return key || undefined;
}

/**
 * Verify Cloudflare Turnstile token.
 * When TURNSTILE_SECRET_KEY is unset (local/dev), verification is skipped.
 */
export async function verifyTurnstileToken(
  token: unknown,
  ip?: string,
): Promise<{ ok: true } | { ok: false; error: "captcha_required" | "captcha_failed" }> {
  if (!isTurnstileConfigured()) {
    return { ok: true };
  }

  if (typeof token !== "string" || token.trim().length === 0) {
    return { ok: false, error: "captcha_required" };
  }

  const body = new URLSearchParams({
    secret: process.env.TURNSTILE_SECRET_KEY!,
    response: token,
  });
  if (ip && ip !== "unknown") {
    body.set("remoteip", ip);
  }

  try {
    const res = await fetch(VERIFY_URL, {
      method: "POST",
      headers: { "content-type": "application/x-www-form-urlencoded" },
      body,
    });
    const json = (await res.json()) as { success?: boolean };
    if (!json.success) {
      return { ok: false, error: "captcha_failed" };
    }
    return { ok: true };
  } catch {
    return { ok: false, error: "captcha_failed" };
  }
}
