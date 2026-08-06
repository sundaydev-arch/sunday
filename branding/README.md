# Branding

Source app mark: `sunday-icon-1024.png`

Terminal glyph: open copper ring + prompt chevron on `#0B0908` (no wordmark).
Accent: `#D4926A` / `#B8734A`.

Do **not** use the default Tauri logo or a flat letter "S" as this file.

## Regenerate platform icons

```bash
export PATH="$HOME/.n/bin:$PATH"   # Node ≥18
cd apps/desktop && pnpm exec tauri icon ../../branding/sunday-icon-1024.png
# Then redistribute into web + mobile icon slots (see agent notes / prior script).
```

Targets:

- `apps/desktop/src-tauri/icons/` (`.icns` / `.ico` / PNGs)
- `apps/web` favicon / apple-touch / app icon
- `apps/mobile` iOS / Android / macOS / web icons
