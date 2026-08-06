/** Best-effort OS detection for chrome layout (macOS Overlay vs native title). */
export type DesktopOs = "macos" | "windows" | "linux" | "other";

export function detectDesktopOs(): DesktopOs {
  if (typeof navigator === "undefined") return "other";

  const platform = (
    (navigator as Navigator & { userAgentData?: { platform?: string } })
      .userAgentData?.platform ??
    navigator.platform ??
    ""
  ).toLowerCase();
  const ua = navigator.userAgent.toLowerCase();

  if (platform.includes("mac") || ua.includes("mac os")) return "macos";
  if (platform.includes("win") || ua.includes("windows")) return "windows";
  if (platform.includes("linux") || ua.includes("linux")) return "linux";
  return "other";
}

/** macOS Overlay title bar needs traffic-light padding + drag region. */
export function usesOverlayTitleBar(): boolean {
  return detectDesktopOs() === "macos";
}
