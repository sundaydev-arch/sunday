# Sunday — personal site (pnpm monorepo)

Modern Next.js portfolio with EN/ZH routing, Sentry + PostHog, contact inbox (Supabase + Resend), and a full quality toolchain.

**Live:** [https://sundaydev.vercel.app/](https://sundaydev.vercel.app/) · **Source:** [sundaydev-arch/sunday](https://github.com/sundaydev-arch/sunday)

```text
sunday/
  apps/web                      # @sunday/web — Next.js 16
  packages/analytics            # @sunday/analytics — Sentry/PostHog helpers
  packages/eslint-config        # shared ESLint flat config
  packages/typescript-config
  turbo.json
  .github/
    PULL_REQUEST_TEMPLATE.md
    workflows/ci.yml          # lint · typecheck · unit · e2e
    workflows/pr.yml          # conventional PR title (skips Dependabot)
    ISSUE_TEMPLATE/
    dependabot.yml
```

## Tooling map

| Concern                          | Tool                                                          |
| -------------------------------- | ------------------------------------------------------------- |
| Lint / a11y-ish web vitals rules | ESLint 9 + `eslint-config-next` (core-web-vitals)             |
| Format                           | Prettier + Tailwind plugin                                    |
| Types                            | TypeScript (`next typegen` + `tsc`, via `pnpm typecheck`)     |
| Unit tests                       | Vitest + Testing Library                                      |
| E2E + perf smoke                 | Playwright                                                    |
| Bundle size                      | `@next/bundle-analyzer` (`pnpm analyze`)                      |
| Errors / traces                  | Sentry                                                        |
| Product analytics                | PostHog                                                       |
| Contact form                     | Zod validation · Sonner toasts · Supabase `messages` · Resend |
| Task graph                       | Turborepo                                                     |
| Agents                           | `AGENTS.md`, `CLAUDE.md`, `.codex/AGENTS.md`, `.cursor/rules` |

## Setup

```bash
corepack enable
pnpm install
cp apps/web/.env.example apps/web/.env.local
pnpm --filter @sunday/web exec playwright install
pnpm dev
```

## Scripts

| Command         | Description                   |
| --------------- | ----------------------------- |
| `pnpm dev`      | Next.js dev server            |
| `pnpm build`    | Production build (turbo)      |
| `pnpm check`    | lint + typecheck + unit tests |
| `pnpm test`     | Unit tests                    |
| `pnpm test:e2e` | Playwright (builds first)     |
| `pnpm analyze`  | Open bundle analyzer          |
| `pnpm format`   | Prettier write                |

## Environment

See `apps/web/.env.example` for:

- Supabase (`NEXT_PUBLIC_SUPABASE_*`) — contact inbox
- Sentry / PostHog — observability
- Resend (`RESEND_API_KEY`, `CONTACT_NOTIFY_*`) — optional email notify (`CONTACT_NOTIFY_FROM` must be an **email**, not the site URL)

Vercel: Project → Settings → Environment Variables (same keys). Repo-root `vercel.json` builds `@sunday/web`.

## Deploy (Vercel)

Import the repo root. Production URL: [https://sundaydev.vercel.app/](https://sundaydev.vercel.app/).

## SEO / GEO

- Per-page metadata with canonical + `hreflang` (`en` / `zh` / `x-default`)
- Open Graph + Twitter cards (`opengraph-image.tsx`)
- `sitemap.xml` · `robots.txt` · web app `manifest`
- JSON-LD (`Person` + `WebSite`, privacy-safe brand only)
- Generative engines: [`/llms.txt`](./apps/web/public/llms.txt) and `/.well-known/llms.txt`

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md). PRs use the template under `.github/PULL_REQUEST_TEMPLATE.md`. CI runs on every non-draft pull request; conventional PR titles are required for human PRs (Dependabot is skipped).

## License

[MIT](./LICENSE)
