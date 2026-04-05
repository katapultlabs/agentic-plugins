#!/usr/bin/env bash
# doctor.sh — Verify Xcode toolchain readiness
#
# Checks all required and optional tools, prints status and remediation hints.
# Exit 0 if all required tools present, exit 1 otherwise.

set -euo pipefail

PASS=0
FAIL=0
WARN=0

check_required() {
  local name="$1" cmd="$2" fix="${3:-}"
  if command -v "$cmd" &>/dev/null; then
    echo "  [ok]      $name"
    ((PASS++))
  else
    echo "  [MISSING] $name"
    [[ -n "$fix" ]] && echo "            Fix: $fix"
    ((FAIL++))
  fi
}

check_optional() {
  local name="$1" cmd="$2" fix="${3:-}"
  if command -v "$cmd" &>/dev/null; then
    echo "  [ok]      $name"
    ((PASS++))
  else
    echo "  [--]      $name (optional)"
    [[ -n "$fix" ]] && echo "            Install: $fix"
    ((WARN++))
  fi
}

echo "=== iOS Harness — Doctor ==="
echo ""

# --- Xcode developer directory ---
echo "Xcode:"
XCODE_PATH="$(xcode-select -p 2>/dev/null || echo "")"
if [[ -n "$XCODE_PATH" ]]; then
  echo "  [ok]      xcode-select → $XCODE_PATH"
  if [[ "$XCODE_PATH" == *"CommandLineTools"* ]]; then
    echo "  [WARN]    Points to CommandLineTools, not Xcode.app"
    echo "            Fix: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    ((WARN++))
  else
    ((PASS++))
  fi
else
  echo "  [MISSING] xcode-select not configured"
  echo "            Fix: xcode-select --install"
  ((FAIL++))
fi

# Show Xcode version
if command -v xcodebuild &>/dev/null; then
  XCODE_VER="$(xcodebuild -version 2>/dev/null | head -1 || echo "unknown")"
  echo "  [info]    $XCODE_VER"
fi

# List installed Xcode apps
for app in /Applications/Xcode*.app; do
  [[ -d "$app" ]] && echo "  [info]    Found: $app"
done

echo ""
echo "Required tools:"
check_required "xcodebuild" "xcodebuild" "Install Xcode from the App Store"
check_required "xcrun" "xcrun" "Part of Xcode Command Line Tools"
check_required "python3" "python3" "brew install python3"

echo ""
echo "Recommended tools:"
check_optional "xcodegen" "xcodegen" "brew install xcodegen"
check_optional "xcbeautify" "xcbeautify" "brew install xcbeautify"
check_optional "jq" "jq" "brew install jq"

echo ""

# --- Available simulators ---
echo "iOS Simulators:"
BOOTED="$(xcrun simctl list devices booted 2>/dev/null | grep -c "Booted" || true)"
AVAILABLE="$(xcrun simctl list devices available 2>/dev/null | grep -c "iPhone" || true)"
echo "  [info]    $AVAILABLE iPhone simulators available, $BOOTED booted"

if [[ "$AVAILABLE" -eq 0 ]]; then
  echo "  [WARN]    No iPhone simulators installed"
  echo "            Fix: Xcode > Settings > Platforms > download iOS runtime"
  ((WARN++))
fi

echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL + WARN))
echo "Summary: $PASS ok, $FAIL missing, $WARN warnings (of $TOTAL checks)"

if [[ "$FAIL" -gt 0 ]]; then
  echo ""
  echo "Fix the missing tools above before building."
  exit 1
fi

echo ""
echo "Ready to build."
