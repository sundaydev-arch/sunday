# Sunday monorepo — agent instructions

## Stack

- pnpm workspaces + Turborepo
- Next.js 16 App Router (`apps/web`)
- Shared packages under `packages/*`
- ESLint (Next core-web-vitals) + Prettier
- Vitest (unit) + Playwright (e2e / perf smoke)
- Sentry + PostHog via `@sunday/analytics`
- Contact: Zod + Sonner UI feedback; Supabase insert; optional Resend notify
- SEO/GEO: `sitemap` / `robots` / JSON-LD / `public/llms.txt`

## Rules

- Default locale is English (`/en`); Chinese is `/zh`.
- Canonical site URL: `https://sundaydev.vercel.app` (`site.url` in `apps/web/src/lib/site.ts`).
- Do not expose real name, employers, school, phone, or private email in the public site.
- Prefer editing shared packages over duplicating helpers in the app.
- Read Next.js docs under `apps/web/node_modules/next/dist/docs/` before changing Next APIs.
- `PageProps` / `LayoutProps` come from `next typegen` (wired into `pnpm typecheck`) — do not remove that step.
- Contact form: keep the terminal aesthetic; do **not** drop in default shadcn Input/Button skins. Sonner toast styling should match copper/dark tokens.
- Keep changes scoped; no drive-by refactors.

## Commands

```bash
pnpm install
pnpm dev
pnpm check          # lint + typecheck + unit
pnpm test:e2e       # Playwright (builds first via turbo)
pnpm analyze        # bundle analyzer
```

## Layout

```text
apps/web                 @sunday/web
packages/analytics       @sunday/analytics
packages/eslint-config   @sunday/eslint-config
packages/typescript-config
```
