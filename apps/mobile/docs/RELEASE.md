# Mobile release — packaging · CI/CD · store submit

Existing quality gates: `.github/workflows/mobile.yml` (analyze / test / debug builds).

**Production store releases** need developer accounts, signing credentials, GitHub Secrets, Fastlane under this app, and `.github/workflows/mobile-release.yml`.

> Automation covers: **build → sign → upload → submit for review**.  
> Apple / Google human review cannot be skipped.

---

## 1. Local packaging

```bash
cd apps/mobile
flutter pub get

# Android (AAB for Play; APK for sideload / internal only)
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://sundaydev.vercel.app
# Output: build/app/outputs/bundle/release/app-release.aab

flutter build apk --release \
  --dart-define=API_BASE_URL=https://sundaydev.vercel.app

# iOS (signing configured + matching Simulator / device SDK)
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://sundaydev.vercel.app
# Output: build/ios/ipa/*.ipa
```

Optional dart-defines: `TURNSTILE_SITE_KEY` · `SENTRY_DSN` · `POSTHOG_KEY` · `CAL_LINK`.

---

## 2. One-time store setup

### Android (Google Play)

1. Create the app in [Google Play Console](https://play.google.com/console) (applicationId must match `android/app/build.gradle.kts`: `app.sundaydev.sunday_mobile`).
2. Enable Play App Signing / create an upload key.
3. Generate a local keystore (**do not commit**):

```bash
keytool -genkey -v -keystore ~/sunday-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias sunday
```

4. Copy `android/key.properties.example` → `android/key.properties` (gitignored).
5. Create a Play Console service-account JSON with Release management access.

### iOS (App Store)

1. Create the app in [Apple Developer](https://developer.apple.com) + [App Store Connect](https://appstoreconnect.apple.com) (Bundle ID: `app.sundaydev.sundayMobile`).
2. Users and Access → Integrations → **App Store Connect API** → create a Key (`.p8`); save Key ID / Issuer ID.
3. Prefer [fastlane match](https://docs.fastlane.tools/actions/match/) with a private certs repo (CI readonly).
4. Optionally Archive once in Xcode to verify signing.

---

## 3. CI/CD layers

| Layer | Trigger | What it does |
| --- | --- | --- |
| **PR / push** | `mobile.yml` | format · analyze · test · debug build (existing) |
| **Release** | tag `mobile-v*` or `workflow_dispatch` | signed release → TestFlight / Play internal |
| **Store submit** | Fastlane lane + optional `submit_for_review: true` | upload and submit for review |

Suggested cadence:

```text
merge to main → tag mobile-v1.0.0 → CI uploads TestFlight + Play internal
  → smoke-test → submit the same build for production review
    (or re-run submit lane / another tag)
```

---

## 4. Automated store submit (Fastlane)

Scaffold:

- `ios/fastlane/` — TestFlight / App Store
- `android/fastlane/` — Play internal / production
- `.github/workflows/mobile-release.yml` — tag / manual trigger

### Local lanes

```bash
# iOS (bundler + match / ASC API configured)
cd apps/mobile/ios && bundle install
bundle exec fastlane beta          # → TestFlight
bundle exec fastlane release       # → App Store (submit off by default; see Fastfile)

# Android
cd apps/mobile/android && bundle install
bundle exec fastlane internal      # → Play internal testing
bundle exec fastlane production    # → Play production
```

### GitHub Secrets / variables

| Secret / Var | Purpose |
| --- | --- |
| `ASC_KEY_ID` / `ASC_ISSUER_ID` / `ASC_PRIVATE_KEY` | App Store Connect API (full `.p8` body) |
| `MATCH_PASSWORD` / `MATCH_GIT_URL` / `MATCH_GIT_BASIC_AUTHORIZATION` | fastlane match private repo |
| `APP_IDENTIFIER` | e.g. `app.sundaydev.sundayMobile` |
| `ANDROID_KEYSTORE_BASE64` | upload keystore as base64 |
| `ANDROID_KEYSTORE_PASSWORD` / `ANDROID_KEY_ALIAS` / `ANDROID_KEY_PASSWORD` | signing |
| `PLAY_SERVICE_ACCOUNT_JSON` | Play service-account JSON body |
| `MOBILE_DART_DEFINES` | optional, e.g. `API_BASE_URL=https://sundaydev.vercel.app` |
| **Repo variable** `ENABLE_ASC_UPLOAD=true` | enable iOS store upload (build-only by default) |
| **Repo variable** `ENABLE_PLAY_UPLOAD=true` | enable Play upload |

Publish via tag:

```bash
git tag mobile-v1.0.0
git push origin mobile-v1.0.0
```

### About “auto review”

- **iOS**: `upload_to_app_store(submit_for_review: true)` clicks Submit for Review. First release still needs privacy, screenshots, age rating, etc. in App Store Connect.
- **Android**: `upload_to_play_store(track: 'production', release_status: 'completed')` sends/publishes per account policy. Prefer `internal` / `alpha` first.
- Review outcomes remain human; CI only removes manual upload/submit clicks.

---

## 5. Alternatives: Codemagic / Shorebird

If you prefer not to manage certs and macOS runners yourself:

- [Codemagic](https://codemagic.io) — managed Flutter CI with store publishing
- [Shorebird](https://shorebird.dev) — code push / OTA (still needs an initial store listing)

This repo defaults to **GitHub Actions + Fastlane**, consistent with the web CI style.

---

## 6. First-release checklist

- [ ] Bundle ID / applicationId matches the store listing  
- [ ] Icons, splash, privacy policy URL  
- [ ] Screenshots (iPhone + optional iPad; Android phone/tablet)  
- [ ] Age rating, export compliance, encryption declarations (iOS)  
- [ ] Production dart-defines for Turnstile if enabled  
- [ ] Production Sentry / PostHog keys  
- [ ] Validate on internal tracks before `submit_for_review`  
