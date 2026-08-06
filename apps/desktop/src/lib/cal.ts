import { config } from "@/lib/config";
import { site } from "@/lib/site";

/** Cal.com path without origin, e.g. `nathan-zhao` or `nathan-zhao/30min`. */
export function getCalLink(): string | null {
  const raw = config.calLinkRaw.trim();
  if (!raw) return null;
  const path = raw
    .replace(/^https?:\/\/(www\.)?cal\.com\//i, "")
    .replace(/^\/+|\/+$/g, "");
  return path || null;
}

export function getCalUrl(): string {
  const link = getCalLink();
  return link ? `https://cal.com/${link}` : site.social.cal;
}
