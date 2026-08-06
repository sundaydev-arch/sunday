#!/usr/bin/env bash
# Print / apply GitHub Actions secrets for the Tauri updater signing key.
#
# Usage:
#   bash scripts/setup-desktop-updater-secrets.sh           # print instructions
#   bash scripts/setup-desktop-updater-secrets.sh --apply   # gh secret set (needs gh auth)
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
key_path="${SUNDAY_UPDATER_KEY_PATH:-$root/.local/sunday-updater.key}"
pub_path="${key_path}.pub"

if [[ ! -f "$key_path" ]]; then
  echo "Private key not found at: $key_path"
  echo "Generate one:"
  echo "  mkdir -p .local"
  echo "  cd apps/desktop && CI=true pnpm tauri signer generate -w ../../.local/sunday-updater.key -p '' --ci -f"
  exit 1
fi

echo "Public key (already in tauri.conf.json plugins.updater.pubkey):"
echo "-----"
cat "$pub_path"
echo "-----"
echo
echo "Endpoint:"
echo "  https://github.com/sundaydev-arch/sunday/releases/latest/download/latest.json"
echo

if [[ "${1:-}" == "--apply" ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo "gh CLI not found — install GitHub CLI, then re-run with --apply."
    exit 1
  fi
  gh secret set TAURI_SIGNING_PRIVATE_KEY --repo sundaydev-arch/sunday < "$key_path"
  # Empty password key: omit password secret or set blank intentionally.
  if [[ -n "${TAURI_SIGNING_PRIVATE_KEY_PASSWORD:-}" ]]; then
    printf '%s' "$TAURI_SIGNING_PRIVATE_KEY_PASSWORD" | \
      gh secret set TAURI_SIGNING_PRIVATE_KEY_PASSWORD --repo sundaydev-arch/sunday
  fi
  echo "Set TAURI_SIGNING_PRIVATE_KEY on sundaydev-arch/sunday."
  exit 0
fi

echo "To upload the private key as a repo secret:"
echo "  bash scripts/setup-desktop-updater-secrets.sh --apply"
echo "Or:"
echo "  gh secret set TAURI_SIGNING_PRIVATE_KEY --repo sundaydev-arch/sunday < .local/sunday-updater.key"
echo
echo "Keep .local/ out of git (gitignored). Losing this key breaks updates for installed apps."
