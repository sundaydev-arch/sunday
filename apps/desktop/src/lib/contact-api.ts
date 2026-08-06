import type { ContactPayload } from "@/lib/contact";
import { config } from "@/lib/config";

export type ContactApiResult =
  | { ok: true }
  | { ok: false; status: number; error: string };

const CONTACT_TIMEOUT_MS = 20_000;

export async function submitContact(
  payload: ContactPayload,
): Promise<ContactApiResult> {
  if (typeof navigator !== "undefined" && navigator.onLine === false) {
    return {
      ok: false,
      status: 0,
      error: "You appear to be offline. Check your connection and try again.",
    };
  }

  const base = config.apiBaseUrl.replace(/\/$/, "");
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), CONTACT_TIMEOUT_MS);

  try {
    const res = await fetch(`${base}/api/contact`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
      signal: controller.signal,
    });

    const json = (await res.json().catch(() => ({}))) as {
      error?: string;
      ok?: boolean;
    };

    if (!res.ok) {
      return {
        ok: false,
        status: res.status,
        error: json.error ?? "Request failed.",
      };
    }

    return { ok: true };
  } catch (error) {
    if (error instanceof DOMException && error.name === "AbortError") {
      return {
        ok: false,
        status: 408,
        error: "Request timed out. Please try again.",
      };
    }
    throw error;
  } finally {
    clearTimeout(timer);
  }
}
