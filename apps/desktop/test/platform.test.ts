import { describe, expect, it } from "vitest";
import { detectDesktopOs, usesOverlayTitleBar } from "@/lib/platform";

describe("platform chrome", () => {
  it("detects macOS from userAgent", () => {
    Object.defineProperty(navigator, "userAgent", {
      configurable: true,
      value:
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15",
    });
    Object.defineProperty(navigator, "platform", {
      configurable: true,
      value: "MacIntel",
    });

    expect(detectDesktopOs()).toBe("macos");
    expect(usesOverlayTitleBar()).toBe(true);
  });

  it("detects Windows without overlay title bar", () => {
    Object.defineProperty(navigator, "userAgent", {
      configurable: true,
      value: "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
    });
    Object.defineProperty(navigator, "platform", {
      configurable: true,
      value: "Win32",
    });

    expect(detectDesktopOs()).toBe("windows");
    expect(usesOverlayTitleBar()).toBe(false);
  });
});
