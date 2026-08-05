import { describe, expect, it } from "vitest";
import {
  clientIpFromHeaders,
  hashIp,
  rateLimit,
} from "@/lib/rate-limit";

describe("rateLimit", () => {
  it("allows up to the limit then blocks", () => {
    const key = `test-${Math.random()}`;
    for (let i = 0; i < 3; i++) {
      expect(rateLimit(key, { limit: 3, windowMs: 60_000 }).ok).toBe(true);
    }
    const blocked = rateLimit(key, { limit: 3, windowMs: 60_000 });
    expect(blocked.ok).toBe(false);
    if (!blocked.ok) {
      expect(blocked.retryAfterSec).toBeGreaterThan(0);
    }
  });

  it("hashes IP and reads forwarded header", () => {
    expect(hashIp("1.2.3.4")).toHaveLength(32);
    const headers = new Headers({
      "x-forwarded-for": "9.9.9.9, 8.8.8.8",
    });
    expect(clientIpFromHeaders(headers)).toBe("9.9.9.9");
  });
});
