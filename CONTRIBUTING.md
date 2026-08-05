# Contributing to Sunday

Thanks for helping improve this open-source personal site (**Nathan Zhao** on the public pages).

## Before you start

1. Read [AGENTS.md](./AGENTS.md) for monorepo conventions.
2. Keep the public site free of employers, school, phone, or private email (project case studies stay anonymized).
3. Default locale is English (`/en`); Chinese is `/zh`.
4. Public brand name is **Nathan Zhao**.

## Setup

```bash
corepack enable
pnpm install
cp apps/web/.env.example apps/web/.env.local
pnpm --filter @sunday/web exec playwright install
pnpm dev
```

## Workflow

1. Fork and create a branch from `main`
2. Make a focused change
3. Run quality gates:

```bash
pnpm check
pnpm test:e2e   # if UI / routing / layout changed
```

4. Open a PR using the template
5. Use a [Conventional Commits](https://www.conventionalcommits.org/) style PR title, e.g.:
   - `feat: add dark theme toggle`
   - `fix: correct mobile nav overflow`
   - `chore: bump playwright`

## Project layout

| Path                         | Package             |
| ---------------------------- | ------------------- |
| `apps/web`                   | `@sunday/web`       |
| `packages/analytics`         | `@sunday/analytics` |
| `packages/typescript-config` | shared TS configs   |

## CI pipeline

Every non-draft PR runs:

1. **CI** — Oxfmt · Oxlint · TypeScript (`next typegen` + `tsc`) · Vitest · Playwright
2. **Lighthouse** — Performance / a11y / SEO budgets (`.github/workflows/lighthouse.yml`)
3. **PR** — Conventional PR title check (**skipped for Dependabot**)

Dependabot opens grouped npm PRs weekly and GitHub Actions PRs monthly. Prefer reviewing Action major bumps separately from npm groups.

## Reporting issues

Use the GitHub Issue templates (Bug / Feature / Docs). Avoid pasting secrets or private identity data.
