/** Cal.com path without origin, e.g. `nathan-zhao` or `nathan-zhao/30min`. */
export function getCalLink(): string | null {
  const raw = process.env.NEXT_PUBLIC_CAL_LINK?.trim();
  if (!raw) return null;
  const path = raw
    .replace(/^https?:\/\/(www\.)?cal\.com\//i, "")
    .replace(/^\/+|\/+$/g, "");
  return path || null;
}

export function getCalUrl(): string | null {
  const link = getCalLink();
  return link ? `https://cal.com/${link}` : null;
}
