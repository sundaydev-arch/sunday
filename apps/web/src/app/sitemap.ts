import type { MetadataRoute } from "next";
import { locales, site, withLocale } from "@/lib/site";
import { siteRoutes } from "@/lib/seo";

export default function sitemap(): MetadataRoute.Sitemap {
  const lastModified = new Date();

  return locales.flatMap((lang) =>
    siteRoutes.map((path) => ({
      url: `${site.url}${withLocale(lang, path)}`,
      lastModified,
      changeFrequency: path === "/" ? ("weekly" as const) : ("monthly" as const),
      priority: path === "/" ? 1 : 0.7,
      alternates: {
        languages: Object.fromEntries(
          locales.map((locale) => [
            locale,
            `${site.url}${withLocale(locale, path)}`,
          ]),
        ),
      },
    })),
  );
}
