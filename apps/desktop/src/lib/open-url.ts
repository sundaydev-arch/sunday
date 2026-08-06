import { openUrl } from "@tauri-apps/plugin-opener";

/** Open external http(s) links in the system browser when running under Tauri. */
export async function openExternal(url: string) {
  try {
    await openUrl(url);
  } catch {
    window.open(url, "_blank", "noopener,noreferrer");
  }
}
