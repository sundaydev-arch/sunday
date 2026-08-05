import { afterEach, describe, expect, it, vi } from "vitest";
import { getCalLink, getCalUrl } from "./cal";

describe("getCalLink", () => {
  afterEach(() => {
    vi.unstubAllEnvs();
  });

  it("returns null when unset", () => {
    vi.stubEnv("NEXT_PUBLIC_CAL_LINK", "");
    expect(getCalLink()).toBeNull();
    expect(getCalUrl()).toBeNull();
  });

  it("accepts username path", () => {
    vi.stubEnv("NEXT_PUBLIC_CAL_LINK", "nathan-zhao");
    expect(getCalLink()).toBe("nathan-zhao");
    expect(getCalUrl()).toBe("https://cal.com/nathan-zhao");
  });

  it("strips cal.com origin", () => {
    vi.stubEnv("NEXT_PUBLIC_CAL_LINK", "https://cal.com/nathan-zhao/30min");
    expect(getCalLink()).toBe("nathan-zhao/30min");
  });
});
