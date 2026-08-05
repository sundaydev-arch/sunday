import type { Metadata } from "next";
import {
  defaultLocale,
  locales,
  site,
  withLocale,
  type Locale,
} from "@/lib/site";

const routes = ["/", "/about", "/projects", "/contact"] as const;
export type SiteRoute = (typeof routes)[number];

export const siteRoutes: readonly SiteRoute[] = routes;

export function absoluteUrl(path = "/"): string {
  const normalized = path.startsWith("/") ? path : `/${path}`;
  if (normalized === "/") return site.url;
  return `${site.url}${normalized}`;
}

/** Absolute locale URL, e.g. `/about` + `en` → `https://…/en/about` */
export function localeUrl(
  lang: Locale,
  path: SiteRoute | string = "/",
): string {
  return absoluteUrl(withLocale(lang, path));
}

export function hreflangLanguages(path: SiteRoute | string = "/") {
  const languages: Record<string, string> = {};
  for (const locale of locales) {
    languages[locale] = localeUrl(locale, path);
  }
  languages["x-default"] = localeUrl(defaultLocale, path);
  return languages;
}

type PageMetaInput = {
  lang: Locale;
  path: SiteRoute | string;
  title: string;
  description: string;
  /** When true, title is used as-is (no layout template). */
  absoluteTitle?: boolean;
};

export function buildPageMetadata({
  lang,
  path,
  title,
  description,
  absoluteTitle = false,
}: PageMetaInput): Metadata {
  const url = localeUrl(lang, path);
  const ogLocale = lang === "zh" ? "zh_CN" : "en_US";

  return {
    title: absoluteTitle ? { absolute: title } : title,
    description,
    alternates: {
      canonical: url,
      languages: hreflangLanguages(path),
    },
    openGraph: {
      type: "website",
      url,
      siteName: site.name,
      title,
      description,
      locale: ogLocale,
      alternateLocale: locales
        .filter((l) => l !== lang)
        .map((l) => (l === "zh" ? "zh_CN" : "en_US")),
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
    },
    robots: {
      index: true,
      follow: true,
      googleBot: {
        index: true,
        follow: true,
        "max-image-preview": "large",
        "max-snippet": -1,
        "max-video-preview": -1,
      },
    },
  };
}

/** Privacy-safe Person + WebSite JSON-LD for GEO/SEO crawlers. */
export function buildSiteJsonLd(lang: Locale, description: string) {
  const home = localeUrl(lang);
  const personId = `${site.url}/#person`;
  const websiteId = `${site.url}/#website`;

  return [
    {
      "@context": "https://schema.org",
      "@type": "Person",
      "@id": personId,
      name: site.name,
      url: site.url,
      jobTitle: site.jobTitle,
      description,
      sameAs: [site.social.github, site.social.website, site.social.cal],
      knowsAbout: [...site.knowsAbout],
    },
    {
      "@context": "https://schema.org",
      "@type": "WebSite",
      "@id": websiteId,
      name: site.name,
      url: home,
      description,
      inLanguage: locales,
      publisher: { "@id": personId },
      author: { "@id": personId },
    },
  ];
}
