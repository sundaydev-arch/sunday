import type { ContactPayload } from "@/lib/contact";
import { config } from "@/lib/config";

export type ContactApiResult =
  | { ok: true }
  | { ok: false; status: number; error: string };

export async function submitContact(
  payload: ContactPayload,
): Promise<ContactApiResult> {
  const base = config.apiBaseUrl.replace(/\/$/, "");
  const res = await fetch(`${base}/api/contact`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
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
}
