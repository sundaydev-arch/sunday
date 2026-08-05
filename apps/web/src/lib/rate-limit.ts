import { createHash } from "node:crypto";

type Entry = { timestamps: number[] };

const store = new Map<string, Entry>();

export type RateLimitResult =
  | { ok: true; remaining: number }
  | { ok: false; remaining: number; retryAfterSec: number };

/**
 * Best-effort fixed-window limiter (per server instance).
 * On multi-instance serverless this is soft protection — pair with Turnstile.
 */
export function rateLimit(
  key: string,
  {
    limit = 5,
    windowMs = 15 * 60 * 1000,
  }: { limit?: number; windowMs?: number } = {},
): RateLimitResult {
  const now = Date.now();
  const entry = store.get(key) ?? { timestamps: [] };
  entry.timestamps = entry.timestamps.filter((t) => now - t < windowMs);

  if (entry.timestamps.length >= limit) {
    const oldest = entry.timestamps[0] ?? now;
    const retryAfterSec = Math.max(1, Math.ceil((windowMs - (now - oldest)) / 1000));
    store.set(key, entry);
    return { ok: false, remaining: 0, retryAfterSec };
  }

  entry.timestamps.push(now);
  store.set(key, entry);
  return { ok: true, remaining: limit - entry.timestamps.length };
}

export function clientIpFromHeaders(headers: Headers): string {
  const forwarded = headers.get("x-forwarded-for");
  if (forwarded) {
    const first = forwarded.split(",")[0]?.trim();
    if (first) return first;
  }
  return (
    headers.get("cf-connecting-ip") ||
    headers.get("x-real-ip") ||
    "unknown"
  );
}

export function hashIp(ip: string): string {
  return createHash("sha256").update(ip).digest("hex").slice(0, 32);
}
