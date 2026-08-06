# Nathan Zhao — Tauri (macOS / Windows)

Portfolio desktop app with content and feature parity against `@sunday/web`.

## Stack

| Layer      | Choice                                                          |
| ---------- | --------------------------------------------------------------- |
| Shell      | Tauri 2                                                         |
| UI         | React 19 · Vite · TypeScript · Tailwind CSS v4                  |
| Routing    | TanStack Router                                                 |
| Networking | `fetch` → `POST {VITE_API_BASE_URL}/api/contact`                |
| Captcha    | Cloudflare Turnstile (optional via `VITE_TURNSTILE_SITE_KEY`)   |
| Analytics  | `posthog-js` + `@sentry/react` (same event names as web/mobile) |
| Fonts      | Google Fonts — Space Grotesk + IBM Plex Mono                    |
| i18n       | EN / ZH message JSON (same copy as web)                         |

## Screens

- Home · About · Projects · Contact
- Locale toggle EN ↔ ZH (persisted)
- Terminal / geek-shell visual language matching web

## Run

Frontend only (browser):

```bash
cd apps/desktop
pnpm install   # from monorepo root preferred
pnpm --filter @sunday/desktop dev
```

Native window (requires [Tauri prerequisites](https://v2.tauri.app/start/prerequisites/)):

```bash
pnpm --filter @sunday/desktop tauri:dev
```

### Env (optional)

See `.env.example`. Empty optional keys disable those integrations.

| Variable                  | Default                        | Notes                      |
| ------------------------- | ------------------------------ | -------------------------- |
| `VITE_API_BASE_URL`       | `https://sundaydev.vercel.app` | Same contact API as web    |
| `VITE_TURNSTILE_SITE_KEY` | empty                          | Widget hidden when empty   |
| `VITE_SENTRY_DSN`         | empty                          | No-op when empty           |
| `VITE_POSTHOG_KEY`        | empty                          | No-op when empty           |
| `VITE_CAL_LINK`           | `https://cal.com/nathan-zhao`  | Cal embed + schedule links |

## Quality gates

```bash
pnpm --filter @sunday/desktop typecheck
pnpm --filter @sunday/desktop test
pnpm --filter @sunday/desktop build
cd apps/desktop/src-tauri && cargo fmt --check && cargo clippy -- -D warnings
pnpm --filter @sunday/desktop tauri:build
```

CI: `.github/workflows/desktop.yml` (path-filtered on `apps/desktop/**`).

## Release (CD)

**Preferred — one click in Actions**

1. Merge your desktop changes to the default branch.
2. Actions → **Desktop Cut Release** → choose `patch` / `minor` / `major` → Run.
3. That bumps `package.json` + `tauri.conf.json` + `Cargo.toml`, commits, tags `desktop-v…`, then builds installers into a **draft** GitHub Release. Review and publish.

Local bump only (no tag):

```bash
node scripts/bump-desktop-version.mjs patch   # or minor | major | 0.2.0
```

**Alternative** — from your machine after bumping:

```bash
git tag desktop-v0.1.1
git push origin desktop-v0.1.1
```

Workflows: [`desktop-cut-release.yml`](../../.github/workflows/desktop-cut-release.yml) · [`desktop-release.yml`](../../.github/workflows/desktop-release.yml)

### Required: Actions write permission

`tauri-action` creates/uploads a GitHub Release with `GITHUB_TOKEN`. If the run fails with **Resource not accessible by integration**, open **Settings → Actions → General → Workflow permissions**, choose **Read and write permissions**, save, then re-run.

### Optional secrets (signing / prod env)

| Secret                                                                                                                    | Purpose                              |
| ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| `APPLE_CERTIFICATE`                                                                                                       | Base64 `.p12` for macOS codesign     |
| `APPLE_CERTIFICATE_PASSWORD`                                                                                              | P12 password                         |
| `APPLE_SIGNING_IDENTITY`                                                                                                  | e.g. `Developer ID Application: …`   |
| `APPLE_ID` / `APPLE_PASSWORD` / `APPLE_TEAM_ID`                                                                           | Notarization (app-specific password) |
| `TAURI_SIGNING_PRIVATE_KEY` / `TAURI_SIGNING_PRIVATE_KEY_PASSWORD`                                                        | Optional updater signatures          |
| `DESKTOP_TURNSTILE_SITE_KEY` / `DESKTOP_SENTRY_DSN` / `DESKTOP_POSTHOG_KEY` / `DESKTOP_POSTHOG_HOST` / `DESKTOP_CAL_LINK` | Baked into release builds            |

Without Apple secrets, CI still uploads **unsigned** installers (fine for testing; Gatekeeper may warn). Windows Authenticode can be added later via `tauri.conf` certificate settings.

## Content sync

Copy and site meta come from `@sunday/content` (`packages/content`). Contact validation from `@sunday/contact`.

## Privacy

Public brand: **Nathan Zhao**. Do not expose employers, school, phone, or private email.
