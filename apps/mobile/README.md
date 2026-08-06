# Nathan Zhao — Flutter (iOS / Android)

Portfolio app with content and feature parity against `@sunday/web`.

## Stack

| Layer | Choice |
| --- | --- |
| SDK | Flutter **3.41.6** (pinned in CI) / Dart 3.11+ |
| State | `flutter_riverpod` + **get_it** DI |
| Flavors | `dev` / `prod` (`main_dev.dart` / `main_prod.dart`) |
| Offline | `connectivity_plus` banner + contact outbox queue |
| Networking | `dio` → `POST {API_BASE_URL}/api/contact` |
| Captcha | `cloudflare_turnstile` (optional via dart-define) |
| Analytics | `posthog_flutter` + `sentry_flutter` |
| Fonts | Google Fonts — **Sora** (display) · **Manrope** (UI) · IBM Plex Mono (CLI crumbs) |
| Motion | `flutter_animate` |
| i18n | EN / ZH message JSON (same copy as web) |

## Screens

- Home · About · Projects · Contact
- Locale toggle EN ↔ ZH (persisted)
- App-native **Signal Light** (cool bright field · ice teal · sparse chrome)

## Platforms

iOS · Android · macOS · Web (desktop/web for local preview; primary targets remain iOS / Android).

## Run

```bash
cd apps/mobile
flutter pub get
flutter devices

# Dev flavor (Android requires --flavor; iOS uses -t only until Xcode schemes exist)
flutter run --flavor dev -t lib/main_dev.dart -d iPhone
# or with local dart-defines / Clash proxy:
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_defines.dev.json

# Prod flavor
flutter run --flavor prod -t lib/main_prod.dart
```

### dart-define (optional)

```bash
flutter run \
  --dart-define=API_BASE_URL=https://sundaydev.vercel.app \
  --dart-define=TURNSTILE_SITE_KEY= \
  --dart-define=SENTRY_DSN= \
  --dart-define=POSTHOG_KEY= \
  --dart-define=POSTHOG_HOST=https://us.i.posthog.com \
  --dart-define=CAL_LINK=https://cal.com/nathan-zhao
```

| Define | Default | Notes |
| --- | --- | --- |
| `API_BASE_URL` | `https://sundaydev.vercel.app` | Same contact API as web |
| `HTTPS_PROXY` | empty | Optional **dev-only** proxy via dart-define / `dart_defines.dev.json` (no hardcoded Clash fallback in release) |
| `TURNSTILE_SITE_KEY` | empty | Widget hidden when empty; production may still require captcha |
| `SENTRY_DSN` | empty | No-op when empty |
| `POSTHOG_KEY` | empty | No-op when empty |
| `CAL_LINK` | `https://cal.com/nathan-zhao` | Embedded Cal booker |

Local China tip — copy defines and run through Clash (dev only):

```bash
cp dart_defines.dev.json.example dart_defines.dev.json
# set TURNSTILE_SITE_KEY / HTTPS_PROXY as needed
flutter run --dart-define-from-file=dart_defines.dev.json
```

## Quality gates

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
flutter build apk --debug --flavor dev -t lib/main_dev.dart
flutter build ios --no-codesign --debug -t lib/main_dev.dart
```

CI: `.github/workflows/mobile.yml` (path-filtered on `apps/mobile/**`).

## Packaging · CI/CD · Store submit

See **[docs/RELEASE.md](./docs/RELEASE.md)** for local release builds, Fastlane lanes, GitHub Secrets, and auto submit-for-review.

```bash
# Cut a store release (bump + tag + dispatch): Actions → Mobile Cut Release
# Or manually:
flutter build appbundle --release --flavor prod -t lib/main_prod.dart \
  --dart-define-from-file=dart_defines.prod.json
flutter build ipa --release -t lib/main_prod.dart \
  --dart-define-from-file=dart_defines.prod.json
git tag mobile-v1.0.0 && git push origin mobile-v1.0.0
```

## Content + contact sync

Messages: `@sunday/content` → `assets/messages/`.

Contact validation: `@sunday/contact` `contract.json` → generated Dart mirror (Zod cannot run in Flutter).

```bash
node scripts/sync-mobile-messages.mjs
node scripts/sync-mobile-contact.mjs
# CI:
node scripts/sync-mobile-messages.mjs --check
node scripts/sync-mobile-contact.mjs --check
```

Offline note: when Turnstile is enabled, contact submits are **not** queued (captcha cannot be replayed). Without Turnstile, failed/offline submits go to a local outbox and flush when connectivity returns.

## Privacy

Public brand: **Nathan Zhao**. Do not expose employers, school, phone, or private email.
