# Sunday site — SEO / GEO context for audits

Read this before auditing. Live: https://sundaydev.vercel.app/

## Identity

|                |                                                                 |
| -------------- | --------------------------------------------------------------- |
| Project / repo | **Sunday** (`@sunday/*`)                                        |
| Public brand   | **Nathan Zhao** (`site.name`)                                   |
| Handle         | `nathan`                                                        |
| Canonical      | `https://sundaydev.vercel.app` (`site.url`)                     |
| Locales        | English unprefixed (`/`), Chinese `/zh` (`as-needed`)           |
| Cal.com        | `NEXT_PUBLIC_CAL_LINK` (e.g. `nathan-zhao`) embedded on Contact |

Do **not** recommend putting employers, school, phone, or private email on public pages.

## Already implemented (check before suggesting duplicates)

- `apps/web/src/lib/seo.ts` — `buildPageMetadata`, canonical, `hreflang`, OG/Twitter
- `apps/web/src/app/sitemap.ts` · `robots.ts`
- `apps/web/src/components/json-ld.tsx` — Person / WebSite JSON-LD
- `apps/web/public/llms.txt` + `public/.well-known/llms.txt`
- `apps/web/src/app/opengraph-image.tsx` · `manifest.ts`
- Per-route metadata in `apps/web/src/app/[locale]/**/page.tsx` from `@sunday/content` messages (`packages/content/src/messages/{en,zh}.json`) → `meta.pages.*`
- Lighthouse CI: root `lighthouserc.cjs` / `pnpm test:lighthouse`

## Key routes

`/`, `/about`, `/projects`, `/contact` (Chinese: `/zh`, `/zh/about`, …)

## Audit focus for this site

1. Locale + canonical + `hreflang` consistency
2. Copy quality in `packages/content/src/messages/*.json` (not keyword stuffing)
3. JSON-LD accuracy vs on-page brand (Nathan Zhao)
4. Contact / Cal embed: indexable text vs iframe-only content
5. GEO: `llms.txt` freshness vs live meta
6. Perf / CWV only if Lighthouse or field data shows issues

## Commands

```bash
pnpm --filter @sunday/web typecheck
pnpm test:lighthouse   # after build
```
