import type { MetadataRoute } from "next";
import { site } from "@/lib/site";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: "*",
        allow: "/",
        disallow: ["/api/", "/ingest/", "/sentry-tunnel/"],
      },
      // GEO: allow major AI / answer-engine crawlers to read public pages
      {
        userAgent: [
          "GPTBot",
          "ChatGPT-User",
          "Google-Extended",
          "PerplexityBot",
          "ClaudeBot",
          "Applebot-Extended",
        ],
        allow: "/",
        disallow: ["/api/", "/ingest/", "/sentry-tunnel/"],
      },
    ],
    sitemap: `${site.url}/sitemap.xml`,
    host: site.url,
  };
}
