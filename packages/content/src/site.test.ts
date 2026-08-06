import { describe, expect, it } from "vitest";
import { isLocale, locales, site, stripLocale, withLocale } from "./site";
import { getDictionary, getProjectsFromDict } from "./dictionary";

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

  it("strips and rebuilds locale prefixes (as-needed)", () => {
    expect(stripLocale("/en")).toBe("/");
    expect(stripLocale("/zh/projects")).toBe("/projects");
    expect(stripLocale("/about")).toBe("/about");
    expect(withLocale("en")).toBe("/");
    expect(withLocale("en", "/about")).toBe("/about");
    expect(withLocale("zh")).toBe("/zh");
    expect(withLocale("zh", "/about")).toBe("/zh/about");
  });
});

describe("dictionary", () => {
  it("loads matching project lists for en and zh", () => {
    const en = getDictionary("en");
    const zh = getDictionary("zh");
    expect(getProjectsFromDict(en).length).toBeGreaterThan(0);
    expect(getProjectsFromDict(zh).length).toBe(
      getProjectsFromDict(en).length,
    );
  });
});
