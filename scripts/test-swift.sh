#!/usr/bin/env bash
#
# Runs the Swift test suite against a tvOS simulator.
#
# The sources are tvOS-only, so they can't be tested on the host the way the
# Jest suite is. Package.swift exists solely to give them a test target.
#
# This runs locally only, via `npm test` and the pre-commit hook. CI stays on
# Linux and runs the Jest suite alone, so it never needs a simulator.
#
# Skips cleanly where Xcode isn't available, so a contributor without a Mac can
# still run `npm test` and get the Jest suite.
set -euo pipefail

SCHEME="ExpoTvosSearchCore"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "Swift tests skipped: xcodebuild not found (needs macOS with Xcode)."
  exit 0
fi

# Pick the first available tvOS simulator instead of hardcoding a device name,
# which would break on any machine with a different Xcode or runtime installed.
# Targets the UDID, not the name: device names contain parentheses of their own
# ("Apple TV 4K (3rd generation)") and are easy to truncate by accident.
DEVICE_LINE=$(xcrun simctl list devices available \
  | awk '/^-- tvOS/{f=1;next} /^--/{f=0} f && NF' | head -1)

UDID=$(printf '%s' "$DEVICE_LINE" \
  | grep -oE '[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}' | head -1)

if [ -z "$UDID" ]; then
  echo "Swift tests skipped: no tvOS simulator installed."
  echo "Install one via Xcode > Settings > Components."
  exit 0
fi

DEVICE=$(printf '%s' "$DEVICE_LINE" | sed -E 's/ \([0-9A-Fa-f]{8}-.*//; s/^ +//')
echo "Running Swift tests on $DEVICE..."

LOG=$(mktemp)
trap 'rm -f "$LOG"' EXIT

if xcodebuild test \
  -scheme "$SCHEME" \
  -destination "platform=tvOS Simulator,id=$UDID" \
  >"$LOG" 2>&1; then
  grep -E "^\s+Executed .* tests" "$LOG" | tail -1
  echo "Swift tests passed."
else
  echo "Swift tests failed:"
  grep -E "error:|failed|XCTAssert" "$LOG" | head -30
  echo ""
  echo "Full log: $LOG"
  trap - EXIT
  exit 1
fi
