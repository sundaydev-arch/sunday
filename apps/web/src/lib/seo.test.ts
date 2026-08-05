import { describe, expect, it } from "vitest";
import {
  absoluteUrl,
  buildPageMetadata,
  buildSiteJsonLd,
  hreflangLanguages,
  localeUrl,
  siteRoutes,
} from "@/lib/seo";

describe("seo helpers", () => {
  it("lists public routes", () => {
    expect(siteRoutes).toEqual(["/", "/about", "/projects", "/contact"]);
  });

  it("builds absolute and locale URLs (default locale unprefixed)", () => {
    expect(absoluteUrl("/")).toBe("https://sundaydev.vercel.app");
    expect(localeUrl("en", "/about")).toBe(
      "https://sundaydev.vercel.app/about",
    );
    expect(localeUrl("zh")).toBe("https://sundaydev.vercel.app/zh");
  });

  it("includes hreflang map with x-default", () => {
    expect(hreflangLanguages("/projects")).toMatchObject({
      en: "https://sundaydev.vercel.app/projects",
      zh: "https://sundaydev.vercel.app/zh/projects",
      "x-default": "https://sundaydev.vercel.app/projects",
    });
  });

  it("builds page metadata with canonical and social tags", () => {
    const meta = buildPageMetadata({
      lang: "en",
      path: "/",
      title: "Nathan Zhao — Fullstack Engineer",
      description: "Test description",
      absoluteTitle: true,
    });
    expect(meta.alternates?.canonical).toBe("https://sundaydev.vercel.app");
    expect(meta.openGraph?.url).toBe("https://sundaydev.vercel.app");
    expect(meta.twitter).toMatchObject({ card: "summary_large_image" });
  });

  it("emits Person + WebSite JSON-LD", () => {
    const [person, website] = buildSiteJsonLd("en", "desc");
    expect(person["@type"]).toBe("Person");
    expect(person.name).toBe("Nathan Zhao");
    expect(website["@type"]).toBe("WebSite");
    expect(website.url).toBe("https://sundaydev.vercel.app");
  });
});
