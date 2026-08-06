#!/usr/bin/env node
/**
 * Sync @sunday/content messages into apps/mobile assets.
 *
 * Usage:
 *   node scripts/sync-mobile-messages.mjs          # copy
 *   node scripts/sync-mobile-messages.mjs --check  # fail if out of sync
 */
import { copyFileSync, readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const locales = ["en", "zh"];
const srcDir = join(root, "packages/content/src/messages");
const destDir = join(root, "apps/mobile/assets/messages");
const check = process.argv.includes("--check");

mkdirSync(destDir, { recursive: true });

let drifted = false;
for (const locale of locales) {
  const src = join(srcDir, `${locale}.json`);
  const dest = join(destDir, `${locale}.json`);
  const next = readFileSync(src, "utf8");
  let current = "";
  try {
    current = readFileSync(dest, "utf8");
  } catch {
    current = "";
  }
  if (current !== next) {
    drifted = true;
    if (check) {
      console.error(`Out of sync: ${dest} ≠ packages/content (${locale})`);
    } else {
      writeFileSync(dest, next);
      console.error(`Synced ${locale}.json → apps/mobile/assets/messages/`);
    }
  }
}

if (check && drifted) {
  console.error("Run: node scripts/sync-mobile-messages.mjs");
  process.exit(1);
}

if (!check && !drifted) {
  console.error("Mobile messages already in sync with @sunday/content.");
}
