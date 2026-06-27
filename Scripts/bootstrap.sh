#!/usr/bin/env bash
# Generates Daybreak.xcodeproj from project.yml using XcodeGen.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v xcodegen >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    echo "XcodeGen not found — installing via Homebrew…"
    brew install xcodegen
  else
    echo "error: XcodeGen is not installed and Homebrew is unavailable." >&2
    echo "Install it from https://github.com/yonaskolb/XcodeGen, then re-run this script." >&2
    exit 1
  fi
fi

xcodegen generate
echo "Generated Daybreak.xcodeproj — open it in Xcode and pick your signing team."
