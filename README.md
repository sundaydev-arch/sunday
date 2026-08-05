# Sunday — personal site (pnpm monorepo)

Modern Next.js portfolio with EN/ZH routing, Sentry + PostHog, and a full quality toolchain.

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
    workflows/pr.yml          # conventional PR title
    ISSUE_TEMPLATE/
    dependabot.yml
```

## Tooling map

| Concern                          | Tool                                                          |
| -------------------------------- | ------------------------------------------------------------- |
| Lint / a11y-ish web vitals rules | ESLint 9 + `eslint-config-next` (core-web-vitals)             |
| Format                           | Prettier + Tailwind plugin                                    |
| Types                            | TypeScript (`pnpm typecheck`)                                 |
| Unit tests                       | Vitest + Testing Library                                      |
| E2E + perf smoke                 | Playwright                                                    |
| Bundle size                      | `@next/bundle-analyzer` (`pnpm analyze`)                      |
| Errors / traces                  | Sentry                                                        |
| Product analytics                | PostHog                                                       |
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

See `apps/web/.env.example` for Supabase, Sentry, and PostHog keys.

## Deploy (Vercel)

Import the repo root. `vercel.json` runs `pnpm install` + `pnpm --filter @sunday/web build`. Add the same env vars in the Vercel project.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md). PRs use the template under `.github/PULL_REQUEST_TEMPLATE.md`. CI + conventional PR title checks run on every non-draft pull request.

## License

[MIT](./LICENSE)
