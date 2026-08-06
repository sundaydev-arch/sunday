# Sunday monorepo — agent instructions

## Stack

- pnpm workspaces + Turborepo · Next.js 16 (`apps/web`) · `next-intl` (`[locale]`)
- Flutter (`apps/mobile`) · Riverpod · go_router · iOS / Android (content + contact API parity)
- Tauri 2 (`apps/desktop`) · React 19 · Vite · TanStack Router · Tailwind 4 · macOS / Windows
- Contact: Zod · Sonner · Turnstile · IP rate limit · Supabase · optional Resend
- Observability: `@sunday/analytics` (Sentry + PostHog); mobile uses `sentry_flutter` + `posthog_flutter`; desktop uses `@sentry/react` + `posthog-js`
- SEO/GEO: sitemap · robots · JSON-LD · `public/llms.txt`
- DB contract: `supabase/schema/messages.sql` + `supabase/README.md` (anon INSERT-only)

## Rules

- Public name: **Nathan Zhao** (`site.name`). Handle display: `nathan`.
- Default locale English at `/` (unprefixed); Chinese `/zh`. Shared copy: `packages/content` (`@sunday/content`). Contact Zod: `packages/contact` (`@sunday/contact`). Mobile still mirrors JSON under `apps/mobile/assets/messages/`.
- Site URL: `https://sundaydev.vercel.app` (`site.url`).
- Do not expose employers, school, phone, or private email on the public site (projects stay anonymized).
- Contact UI stays terminal-themed; do not drop in stock shadcn Input/Button skins.
- `pnpm typecheck` must keep `next typegen` (for `PageProps` / `LayoutProps`).
- Read `apps/web/node_modules/next/dist/docs/` before changing Next APIs.
- Keep changes scoped. Package names `@sunday/*` are monorepo IDs — not the public brand.

## Commands

```bash
pnpm install
pnpm dev
pnpm check              # format + lint + typecheck + unit
pnpm test:e2e
pnpm test:lighthouse    # after pnpm build
pnpm analyze

# Flutter (apps/mobile)
cd apps/mobile && flutter pub get && flutter run
cd apps/mobile && flutter analyze && flutter test

# Tauri (apps/desktop)
pnpm --filter @sunday/desktop tauri:dev
pnpm --filter @sunday/desktop typecheck && pnpm --filter @sunday/desktop test
# Release: Actions → Desktop Cut Release (patch|minor|major) → draft GitHub Release
```

## CI path filters

App workflows stay isolated; shared packages fan out to dependents:

| Change | Web CI · Lighthouse | Desktop CI | Mobile CI |
| --- | --- | --- | --- |
| `apps/web/**` | ✓ | | |
| `apps/desktop/**` | | ✓ | |
| `apps/mobile/**` | | | ✓ |
| `packages/content` · `packages/contact` | ✓ | ✓ | ✓ |
| `packages/analytics` · `packages/typescript-config` | ✓ | ✓ | |
| Root tooling (`package.json`, lockfile, oxlint/oxfmt, turbo, …) | ✓ | ✓ (lint/format) | |

Release CD (`desktop-v*` / `mobile-v*` tags or workflow_dispatch) is separate from these CI path filters.
## Layout

```text
apps/web                  # Next.js portfolio
apps/mobile               # Flutter iOS / Android (parity with web)
apps/desktop              # Tauri macOS / Windows (parity with web)
packages/analytics
packages/content          # site meta + en/zh messages (web + desktop)
packages/contact          # shared Zod contact schema
packages/typescript-config
supabase/                 # schema SQL + RLS docs
.agents/skills/           # agent skills (source of truth)
.cursor/skills/           # symlinks → .agents/skills
```

## Skills

- SEO / GEO audit: `.agents/skills/seo-audit` (Cursor via `.cursor/skills/seo-audit` symlink).
- Sunday inventory: `.agents/skills/seo-audit/references/sunday-site.md`
