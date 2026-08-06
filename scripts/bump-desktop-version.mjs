#!/usr/bin/env node
/**
 * Bump @sunday/desktop version across package.json, tauri.conf.json, Cargo.toml.
 *
 * Usage:
 *   node scripts/bump-desktop-version.mjs patch|minor|major|X.Y.Z
 *
 * Prints the new version to stdout (last line) for CI capture.
 */
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const packagePath = join(root, "apps/desktop/package.json");
const tauriConfPath = join(root, "apps/desktop/src-tauri/tauri.conf.json");
const cargoPath = join(root, "apps/desktop/src-tauri/Cargo.toml");

function parseSemver(version) {
  const match = /^(\d+)\.(\d+)\.(\d+)$/.exec(version.trim());
  if (!match) {
    throw new Error(`Invalid semver: ${version}`);
  }
  return {
    major: Number(match[1]),
    minor: Number(match[2]),
    patch: Number(match[3]),
  };
}

function formatSemver({ major, minor, patch }) {
  return `${major}.${minor}.${patch}`;
}

function bump(version, kind) {
  if (/^\d+\.\d+\.\d+$/.test(kind)) {
    return kind;
  }
  const current = parseSemver(version);
  if (kind === "major") {
    return formatSemver({ major: current.major + 1, minor: 0, patch: 0 });
  }
  if (kind === "minor") {
    return formatSemver({
      major: current.major,
      minor: current.minor + 1,
      patch: 0,
    });
  }
  if (kind === "patch") {
    return formatSemver({
      major: current.major,
      minor: current.minor,
      patch: current.patch + 1,
    });
  }
  throw new Error(
    `Usage: bump-desktop-version.mjs <patch|minor|major|X.Y.Z> (got: ${kind})`,
  );
}

const kind = process.argv[2];
if (!kind) {
  console.error("Usage: bump-desktop-version.mjs <patch|minor|major|X.Y.Z>");
  process.exit(1);
}

const pkg = JSON.parse(readFileSync(packagePath, "utf8"));
const next = bump(pkg.version, kind);

pkg.version = next;
writeFileSync(packagePath, `${JSON.stringify(pkg, null, 2)}\n`);

const tauriConf = JSON.parse(readFileSync(tauriConfPath, "utf8"));
tauriConf.version = next;
writeFileSync(tauriConfPath, `${JSON.stringify(tauriConf, null, 2)}\n`);

const cargo = readFileSync(cargoPath, "utf8");
if (!/^version\s*=\s*"[^"]+"/m.test(cargo)) {
  throw new Error("Could not find version in Cargo.toml");
}
writeFileSync(
  cargoPath,
  cargo.replace(/^version\s*=\s*"[^"]+"/m, `version = "${next}"`),
);

console.error(`Bumped desktop → ${next}`);
console.log(next);
