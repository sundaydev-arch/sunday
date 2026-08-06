# apps/mobile — agent notes

Flutter portfolio for **Nathan Zhao**. Content and contact API parity with `apps/web`.

- Messages: `assets/messages/{en,zh}.json` — sync from `packages/content/src/messages/`
- Site constants: `lib/core/site.dart` (mirrors `@sunday/content` / `packages/content/src/site.ts`)
- Contact: `POST {API_BASE_URL}/api/contact` via `lib/data/contact_api.dart` (limits mirror `@sunday/contact`)
- Do not expose employers, school, phone, or private email
- Keep terminal / geek-shell UI (no stock Material form skins that break the look)
- Quality: `flutter analyze --fatal-infos` · `flutter test` · CI `.github/workflows/mobile.yml`
