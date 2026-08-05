# Sunday monorepo — agent instructions

## Stack

- pnpm workspaces + Turborepo · Next.js 16 (`apps/web`) · `next-intl` (`[locale]`)
- Contact: Zod · Sonner · Turnstile · IP rate limit · Supabase · optional Resend
- Observability: `@sunday/analytics` (Sentry + PostHog)
- SEO/GEO: sitemap · robots · JSON-LD · `public/llms.txt`
- DB contract: `supabase/schema/messages.sql` + `supabase/README.md` (anon INSERT-only)

## Rules

- Public name: **Nathan Zhao** (`site.name`). Handle display: `nathan`.
- Default locale `/en`; Chinese `/zh`. Messages live in `apps/web/src/messages/`.
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
```

## Layout

```text
apps/web
packages/analytics
packages/typescript-config
supabase/                 # schema SQL + RLS docs
.agents/skills/           # agent skills (source of truth)
.cursor/skills/           # symlinks → .agents/skills
```

## Skills

- SEO / GEO audit: `.agents/skills/seo-audit` (Cursor via `.cursor/skills/seo-audit` symlink).
- Sunday inventory: `.agents/skills/seo-audit/references/sunday-site.md`
