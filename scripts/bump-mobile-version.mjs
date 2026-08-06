#!/usr/bin/env node
/**
 * Bump apps/mobile pubspec version (name + build number).
 *
 * Usage:
 *   node scripts/bump-mobile-version.mjs patch|minor|major|X.Y.Z
 *
 * Prints the new semver (without +build) to stdout for CI capture.
 */
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const pubspecPath = join(root, "apps/mobile/pubspec.yaml");

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
    `Usage: bump-mobile-version.mjs <patch|minor|major|X.Y.Z> (got: ${kind})`,
  );
}

const kind = process.argv[2];
if (!kind) {
  console.error("Usage: bump-mobile-version.mjs <patch|minor|major|X.Y.Z>");
  process.exit(1);
}

const pubspec = readFileSync(pubspecPath, "utf8");
const match = /^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$/m.exec(pubspec);
if (!match) {
  throw new Error("Could not parse version: from apps/mobile/pubspec.yaml");
}

const nextName = bump(match[1], kind);
const nextBuild = Number(match[2]) + 1;
const nextLine = `version: ${nextName}+${nextBuild}`;

writeFileSync(
  pubspecPath,
  pubspec.replace(/^version:\s*\d+\.\d+\.\d+\+\d+\s*$/m, nextLine),
);

console.error(`Bumped mobile → ${nextName}+${nextBuild}`);
console.log(nextName);
