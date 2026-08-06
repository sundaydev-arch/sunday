# Sunday — open-source personal site (pnpm monorepo)

Open-source Next.js portfolio for **Nathan Zhao**. EN/ZH routing, Sentry + PostHog, contact inbox (Supabase + Resend + Turnstile), and a full quality toolchain. Repo / packages stay `sunday` / `@sunday/*`.

**Live:** [https://sundaydev.vercel.app/](https://sundaydev.vercel.app/) · **Source:** [sundaydev-arch/sunday](https://github.com/sundaydev-arch/sunday)

```text
sunday/
  apps/web                 # @sunday/web — Next.js 16
  apps/mobile              # Flutter iOS / Android
  apps/desktop             # Tauri macOS / Windows
  packages/analytics       # Sentry / PostHog helpers
  packages/content         # site meta + en/zh messages
  packages/contact         # shared Zod contact schema
  packages/typescript-config
  supabase/                # schema + RLS contract
  .agents/skills/          # agent skills (seo-audit, …)
  .cursor/skills/          # symlinks → .agents/skills
  lighthouserc.cjs
  .github/workflows/       # ci · pr · lighthouse · mobile · desktop · desktop-release
```

## Setup checklist

```bash
corepack enable
pnpm install
cp apps/web/.env.example apps/web/.env.local
# fill apps/web/.env.local — see Environment below
pnpm --filter @sunday/web exec playwright install
pnpm dev
```

Then:

1. **Supabase** — apply [`supabase/schema/messages.sql`](./supabase/README.md) (anon INSERT-only RLS)
2. **Turnstile** — site + secret keys in env (production)
3. **Resend** (optional) — email notify
4. **Vercel** — same env vars; repo-root `vercel.json` builds `@sunday/web`

## Scripts

| Command                | Description                            |
| ---------------------- | -------------------------------------- |
| `pnpm dev`             | Next.js dev server                     |
| `pnpm build`           | Production build (turbo)               |
| `pnpm check`           | format + lint + typecheck + unit       |
| `pnpm test`            | Unit tests                             |
| `pnpm test:e2e`        | Playwright (+ axe)                     |
| `pnpm test:lighthouse` | Lighthouse CI (run `pnpm build` first) |
| `pnpm analyze`         | Bundle analyzer                        |
| `pnpm format`          | Oxfmt write                            |

`pnpm typecheck` runs `next typegen` then `tsc` (needed for `PageProps` / `LayoutProps`).

## Tooling

| Concern       | Tool                                                |
| ------------- | --------------------------------------------------- |
| App           | Next.js 16 App Router · Tailwind 4 · `next-intl`    |
| Contact       | Zod · Sonner · Turnstile · IP rate limit · Supabase |
| Observability | Sentry · PostHog (`@sunday/analytics`)              |
| Quality       | Oxlint · Oxfmt · Vitest · Playwright · LHCI         |
| Monorepo      | pnpm · Turborepo                                    |

## Environment

Copy from [`apps/web/.env.example`](./apps/web/.env.example):

| Vars                                                      | Purpose                                                   |
| --------------------------------------------------------- | --------------------------------------------------------- |
| `NEXT_PUBLIC_SUPABASE_*`                                  | Contact inbox ([schema](./supabase/README.md))            |
| `NEXT_PUBLIC_SENTRY_DSN` (+ optional auth/org/project)    | Errors                                                    |
| `NEXT_PUBLIC_POSTHOG_*`                                   | Analytics                                                 |
| `RESEND_*` / `CONTACT_NOTIFY_*`                           | Email notify — `CONTACT_NOTIFY_FROM` must be an **email** |
| `NEXT_PUBLIC_TURNSTILE_SITE_KEY` / `TURNSTILE_SECRET_KEY` | Captcha (required in production)                          |
| `NEXT_PUBLIC_CAL_LINK`                                    | Cal.com embed path (e.g. `nathan-zhao`) on Contact        |

Never commit `.env.local`. Never put `service_role` in `NEXT_PUBLIC_*`.

## SEO / GEO

- Canonical + `hreflang` · Open Graph · `sitemap.xml` · `robots.txt` · JSON-LD
- [`/llms.txt`](./apps/web/public/llms.txt) and `/.well-known/llms.txt`

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md). Conventional PR titles for humans; Dependabot titles are skipped. CI + Lighthouse run on non-draft PRs.

## License

[MIT](./LICENSE)
