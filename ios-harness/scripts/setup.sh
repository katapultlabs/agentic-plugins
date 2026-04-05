#!/usr/bin/env bash
# setup.sh — One-command environment verification and tool installation
#
# Checks prerequisites, installs missing tools, boots a simulator, and
# prints a status report. Safe to run repeatedly.

set -e

echo "=== iOS Harness — Setup ==="
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
  echo "WARNING: xcode-select points to CommandLineTools."
  echo "  Attempting to switch to Xcode.app..."
  if [[ -d "/Applications/Xcode.app" ]]; then
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
    echo "  Switched to /Applications/Xcode.app/Contents/Developer"
  else
    echo "  ERROR: /Applications/Xcode.app not found. Install Xcode from the App Store."
    exit 1
  fi
fi
echo "[ok] Xcode: $(xcodebuild -version 2>/dev/null | head -1)"

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

# --- python3 ---
if command -v python3 &>/dev/null; then
  echo "[ok] python3 available"
else
  echo "WARNING: python3 not found. Some scripts require it."
  echo "  Install: brew install python3"
fi

# --- xcodegen (optional) ---
if command -v xcodegen &>/dev/null; then
  echo "[ok] xcodegen installed"
else
  echo "[--] xcodegen not installed (optional — needed for project scaffolding)"
  read -r -p "  Install xcodegen? [y/N] " response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    brew install xcodegen
    echo "[ok] xcodegen installed"
  fi
fi

# --- xcbeautify (optional) ---
if command -v xcbeautify &>/dev/null; then
  echo "[ok] xcbeautify installed"
else
  echo "[--] xcbeautify not installed (optional — prettier build output)"
  read -r -p "  Install xcbeautify? [y/N] " response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    brew install xcbeautify
    echo "[ok] xcbeautify installed"
  fi
fi

# --- Boot a simulator if none running ---
echo ""
BOOTED=$(xcrun simctl list devices booted 2>/dev/null | grep -c "Booted" || true)
if [[ "$BOOTED" -eq 0 ]]; then
  echo "No simulator running. Booting one..."
  # Find the newest available iPhone
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
echo "  1. Copy assets/Makefile.template into your project as Makefile"
echo "  2. Edit the header variables (APP_NAME, PLATFORM, etc.)"
echo "  3. Run: make diagnose"
echo "  4. Run: make build"
