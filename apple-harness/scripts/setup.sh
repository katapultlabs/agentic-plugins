#!/usr/bin/env bash
# setup.sh — One-command environment verification and tool installation
#
# Checks prerequisites, optionally installs missing tools, boots a simulator,
# and prints a status report. Safe to run repeatedly.
#
# Usage:
#   bash scripts/setup.sh              # Interactive (prompts for optional installs)
#   bash scripts/setup.sh --yes        # Non-interactive (install everything)
#   bash scripts/setup.sh --check      # Non-interactive (check only, no installs)

set -e

AUTO_YES=false
CHECK_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes)   AUTO_YES=true; shift ;;
    --check) CHECK_ONLY=true; shift ;;
    *)       echo "ERROR: Unknown flag '$1'" >&2; exit 1 ;;
  esac
done

prompt_install() {
  local name="$1" cmd="$2"
  if [[ "$CHECK_ONLY" == true ]]; then
    echo "[--] $name not installed"
    return 1
  fi
  if [[ "$AUTO_YES" == true ]]; then
    return 0
  fi
  if [[ -t 0 ]]; then
    read -r -p "  Install $name? [y/N] " response
    [[ "$response" =~ ^[Yy]$ ]]
  else
    echo "[--] $name not installed (run with --yes to auto-install)"
    return 1
  fi
}

echo "=== Apple Harness — Setup ==="
echo ""

# --- macOS check ---
if [[ "$(uname)" != "Darwin" ]]; then
  echo "ERROR: iOS development requires macOS."
  exit 1
fi

# --- Xcode check ---
if ! xcode-select -p &>/dev/null; then
  echo "ERROR: Xcode not installed. Install from the App Store, then run:"
  echo "  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  exit 1
fi

XCODE_PATH="$(xcode-select -p)"
if [[ "$XCODE_PATH" == *"CommandLineTools"* ]]; then
  echo "[WARN] xcode-select points to CommandLineTools, not Xcode.app"
  # Find installed Xcode apps instead of hardcoding one path
  XCODE_APP="$(find /Applications -maxdepth 1 -name 'Xcode*.app' -print -quit 2>/dev/null || true)"
  if [[ -n "$XCODE_APP" ]]; then
    echo "  Fix: sudo xcode-select -s \"$XCODE_APP/Contents/Developer\""
  else
    echo "  Fix: Install Xcode from the App Store, then:"
    echo "       sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  fi
  echo ""
  echo "  NOTE: This requires sudo. Run the command above manually."
else
  echo "[ok] Xcode: $(xcodebuild -version 2>/dev/null | head -1)"
fi

# --- xcodebuild ---
if command -v xcodebuild &>/dev/null; then
  echo "[ok] xcodebuild available"
else
  echo "ERROR: xcodebuild not found. Xcode may not be fully installed."
  exit 1
fi

# --- xcrun ---
if command -v xcrun &>/dev/null; then
  echo "[ok] xcrun available"
else
  echo "ERROR: xcrun not found."
  exit 1
fi

# --- python3 (required) ---
if command -v python3 &>/dev/null; then
  echo "[ok] python3 available"
else
  echo "ERROR: python3 not found. Required by resolve-sim.sh."
  echo "  Install: brew install python3"
  exit 1
fi

# --- Check for Homebrew before optional installs ---
HAS_BREW=false
if command -v brew &>/dev/null; then
  HAS_BREW=true
fi

# --- xcodegen (optional) ---
if command -v xcodegen &>/dev/null; then
  echo "[ok] xcodegen installed"
elif [[ "$HAS_BREW" == true ]] && prompt_install "xcodegen" "xcodegen"; then
  brew install xcodegen
  echo "[ok] xcodegen installed"
else
  [[ "$HAS_BREW" == false ]] && echo "[--] xcodegen not installed (install Homebrew first, then: brew install xcodegen)"
fi

# --- xcbeautify (optional) ---
if command -v xcbeautify &>/dev/null; then
  echo "[ok] xcbeautify installed"
elif [[ "$HAS_BREW" == true ]] && prompt_install "xcbeautify" "xcbeautify"; then
  brew install xcbeautify
  echo "[ok] xcbeautify installed"
else
  [[ "$HAS_BREW" == false ]] && echo "[--] xcbeautify not installed (install Homebrew first, then: brew install xcbeautify)"
fi

# --- Boot a simulator if none running ---
echo ""
BOOTED=$(xcrun simctl list devices booted 2>/dev/null | grep -c "Booted" || true)
if [[ "$BOOTED" -eq 0 ]]; then
  echo "No simulator running. Booting one..."
  DEVICE_UDID=$(xcrun simctl list devices available -j 2>/dev/null | python3 -c "
import json, re, sys
data = json.load(sys.stdin)
best = None
for key, devs in data.get('devices', {}).items():
    m = re.search(r'iOS[- ](\d+)[- .](\d+)', key)
    if not m: continue
    ver = (int(m.group(1)), int(m.group(2)))
    for d in devs:
        if d.get('isAvailable') and 'iPhone' in d.get('name',''):
            if best is None or ver > best[0]:
                best = (ver, d['udid'], d['name'])
if best:
    print(best[1])
" 2>/dev/null || true)

  if [[ -n "$DEVICE_UDID" ]]; then
    xcrun simctl boot "$DEVICE_UDID" 2>/dev/null || true
    DEVICE_NAME=$(xcrun simctl list devices booted 2>/dev/null | grep "Booted" | sed 's/ (.*//;s/^[[:space:]]*//' | head -1)
    echo "[ok] Booted simulator: $DEVICE_NAME"
  else
    echo "WARNING: Could not find an iPhone simulator to boot."
    echo "  Install one: Xcode > Settings > Platforms"
  fi
else
  DEVICE_NAME=$(xcrun simctl list devices booted 2>/dev/null | grep "Booted" | sed 's/ (.*//;s/^[[:space:]]*//' | head -1)
  echo "[ok] Simulator already running: $DEVICE_NAME"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Copy the harness scripts into your project:"
echo "     cp -r <plugin-path>/scripts/ ./scripts/"
echo "  2. Copy the Makefile template:"
echo "     cp <plugin-path>/assets/Makefile.template ./Makefile"
echo "  3. Edit the Makefile header variables (APP_NAME, PLATFORM, etc.)"
echo "  4. Run: make diagnose"
echo "  5. Run: make build"
