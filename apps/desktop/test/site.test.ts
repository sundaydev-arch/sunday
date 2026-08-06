import { describe, expect, it } from "vitest";
import { getDictionary, getProjectsFromDict } from "@/lib/dictionary";
import { defaultLocale, isLocale, site } from "@/lib/site";

describe("site", () => {
  it("exposes public brand meta", () => {
    expect(site.name).toBe("Nathan Zhao");
    expect(site.handle).toBe("nathan");
    expect(site.url).toBe("https://sundaydev.vercel.app");
  });

  it("validates locales", () => {
    expect(isLocale("en")).toBe(true);
    expect(isLocale("zh")).toBe(true);
    expect(isLocale("fr")).toBe(false);
    expect(defaultLocale).toBe("en");
  });
});

describe("dictionary", () => {
  it("loads en and zh messages with projects", () => {
    const en = getDictionary("en");
    const zh = getDictionary("zh");
    expect(en.nav.home).toBeTruthy();
    expect(zh.nav.home).toBeTruthy();
    expect(getProjectsFromDict(en).length).toBeGreaterThan(0);
    expect(getProjectsFromDict(zh).length).toBe(getProjectsFromDict(en).length);
  });
});
