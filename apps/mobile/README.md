# Nathan Zhao — Flutter (iOS / Android)

Portfolio app with content and feature parity against `@sunday/web`.

## Stack

| Layer | Choice |
| --- | --- |
| SDK | Flutter 3.41+ / Dart 3.11+ |
| State | `flutter_riverpod` |
| Routing | `go_router` |
| Networking | `dio` → `POST {API_BASE_URL}/api/contact` |
| Captcha | `cloudflare_turnstile` (optional via dart-define) |
| Analytics | `posthog_flutter` + `sentry_flutter` |
| Fonts | Google Fonts — Space Grotesk + IBM Plex Mono |
| Motion | `flutter_animate` |
| i18n | EN / ZH message JSON (same copy as web) |

## Screens

- Home · About · Projects · Contact
- Locale toggle EN ↔ 中文 (persisted)
- Terminal / geek-shell visual language matching web

## Platforms

iOS · Android · macOS · Web (desktop/web for local preview; primary targets remain iOS / Android).

## Run

```bash
cd apps/mobile
flutter pub get
flutter devices
# iOS Simulator (start Simulator.app first if needed)
open -a Simulator
flutter run -d iPhone
# or macOS / Chrome
flutter run -d macos
flutter run -d chrome
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
| `TURNSTILE_SITE_KEY` | empty | Widget hidden when empty; server skips verify when secret unset |
| `SENTRY_DSN` | empty | No-op when empty |
| `POSTHOG_KEY` | empty | No-op when empty |
| `CAL_LINK` | `https://cal.com/nathan-zhao` | Opens in browser |

## Quality gates

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
flutter build apk --debug
flutter build ios --no-codesign --debug
```

CI: `.github/workflows/mobile.yml` (path-filtered on `apps/mobile/**`).

## Content sync

Copy lives in `assets/messages/{en,zh}.json` — keep in sync with `packages/content/src/messages/`.

## Privacy

Public brand: **Nathan Zhao**. Do not expose employers, school, phone, or private email.
