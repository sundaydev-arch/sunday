# Branding

Source app mark: `sunday-icon-1024.png` (cropped from the Sunday logo; no wordmark).

## Regenerate platform icons

```bash
# Desktop (Tauri) — also writes ios/ + android/ helpers under src-tauri/icons/
export PATH="$HOME/.n/bin:$PATH"   # Node ≥18
cd apps/desktop && pnpm exec tauri icon ../../branding/sunday-icon-1024.png

# Then redistribute to web + mobile (or re-run the copy script used in CI/docs).
```

Targets updated from this mark:

- `apps/desktop/src-tauri/icons/` (`.icns` / `.ico` / PNGs)
- `apps/web/src/app/{icon,apple-icon,favicon}.*`
- `apps/mobile` iOS / Android / macOS / web favicons
