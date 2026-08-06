import { afterEach, describe, expect, it, vi } from "vitest";
import { submitContact } from "@/lib/contact-api";

afterEach(() => {
  vi.unstubAllGlobals();
  vi.restoreAllMocks();
});

describe("submitContact", () => {
  it("posts JSON to the contact API", async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ ok: true }),
    });
    vi.stubGlobal("fetch", fetchMock);
    vi.stubGlobal("navigator", { onLine: true });

    const result = await submitContact({
      name: "Ada",
      email: "ada@example.com",
      message: "Hello",
    });

    expect(result).toEqual({ ok: true });
    expect(fetchMock).toHaveBeenCalledOnce();
    const [url, init] = fetchMock.mock.calls[0] as [string, RequestInit];
    expect(url).toContain("/api/contact");
    expect(init.method).toBe("POST");
    expect(init.signal).toBeInstanceOf(AbortSignal);
  });

  it("returns offline error without calling fetch", async () => {
    const fetchMock = vi.fn();
    vi.stubGlobal("fetch", fetchMock);
    vi.stubGlobal("navigator", { onLine: false });

    const result = await submitContact({
      name: "Ada",
      email: "ada@example.com",
      message: "Hello",
    });

    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.status).toBe(0);
      expect(result.error).toMatch(/offline/i);
    }
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("maps abort to a timeout result", async () => {
    vi.stubGlobal("navigator", { onLine: true });
    vi.stubGlobal(
      "fetch",
      vi.fn().mockImplementation((_url, init: RequestInit) => {
        return new Promise((_resolve, reject) => {
          init.signal?.addEventListener("abort", () => {
            reject(new DOMException("Aborted", "AbortError"));
          });
        });
      }),
    );

    vi.useFakeTimers();
    const pending = submitContact({
      name: "Ada",
      email: "ada@example.com",
      message: "Hello",
    });
    await vi.advanceTimersByTimeAsync(21_000);
    const result = await pending;
    vi.useRealTimers();

    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.status).toBe(408);
      expect(result.error).toMatch(/timed out/i);
    }
  });
});
