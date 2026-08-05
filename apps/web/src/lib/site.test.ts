import { describe, expect, it } from "vitest";
import { isLocale, locales, site, stripLocale, withLocale } from "@/lib/site";

describe("site config", () => {
  it("exposes public brand only", () => {
    expect(site.name).toBe("Sunday");
    expect(site.handle).toBe("sunday");
    expect(site.social.github).toContain("sundaydev-arch");
  });

  it("supports en and zh locales", () => {
    expect(locales).toEqual(["en", "zh"]);
    expect(isLocale("en")).toBe(true);
    expect(isLocale("zh")).toBe(true);
    expect(isLocale("fr")).toBe(false);
  });

  it("strips and rebuilds locale prefixes", () => {
    expect(stripLocale("/en")).toBe("/");
    expect(stripLocale("/zh/projects")).toBe("/projects");
    expect(withLocale("en")).toBe("/en");
    expect(withLocale("zh", "/about")).toBe("/zh/about");
  });
});
