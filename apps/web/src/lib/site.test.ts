import { describe, expect, it } from "vitest";
import { isLocale, locales, site, stripLocale, withLocale } from "@/lib/site";

describe("site config", () => {
  it("exposes public brand only", () => {
    expect(site.name).toBe("Nathan Zhao");
    expect(site.handle).toBe("nathan");
    expect(site.social.github).toContain("sundaydev-arch");
    expect(site.url).toBe("https://sundaydev.vercel.app");
    expect(site.social.website).toBe("https://sundaydev.vercel.app/");
    expect(site.social.cal).toBe("https://cal.com/nathan-zhao");
    expect(site.jobTitle).toBe("Fullstack Engineer");
    expect(site.knowsAbout).toContain("TypeScript");
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
