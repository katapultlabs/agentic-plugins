#!/bin/bash
set -e

# React Native Simulator Harness — One-command setup
# Installs IDB, configures ios-simulator-mcp, boots a simulator, verifies everything

echo "=== React Native Simulator Harness Setup ==="
echo ""

# --- Check macOS ---
if [[ "$(uname)" != "Darwin" ]]; then
  echo "ERROR: iOS Simulator requires macOS."
  exit 1
fi

# --- Check Xcode ---
if ! xcode-select -p &>/dev/null; then
  echo "ERROR: Xcode not installed. Install from the App Store."
  exit 1
fi
echo "✓ Xcode installed"

# --- Install IDB companion ---
if ! command -v idb_companion &>/dev/null; then
  echo "Installing idb-companion..."
  brew tap facebook/fb 2>/dev/null
  brew install idb-companion
else
  echo "✓ idb-companion installed"
fi

# --- Install pipx ---
if ! command -v pipx &>/dev/null; then
  echo "Installing pipx..."
  brew install pipx
  pipx ensurepath
fi

# --- Install fb-idb ---
if ! command -v idb &>/dev/null; then
  echo "Installing fb-idb..."

  # Find Python 3.11 or 3.12 (required — 3.13+ has asyncio issues)
  PYTHON_BIN=""
  if command -v mise &>/dev/null; then
    for ver in 3.12 3.11; do
      MISE_PYTHON="$(mise where python "$ver" 2>/dev/null)/bin/python3" || true
      if [ -x "$MISE_PYTHON" ]; then
        PYTHON_BIN="$MISE_PYTHON"
        break
      fi
    done
  fi
  if [ -z "$PYTHON_BIN" ]; then
    for cmd in python3.12 python3.11; do
      if command -v "$cmd" &>/dev/null; then
        PYTHON_BIN="$cmd"
        break
      fi
    done
  fi

  if [ -n "$PYTHON_BIN" ]; then
    echo "  Using Python: $PYTHON_BIN"
    pipx install fb-idb --python "$PYTHON_BIN"
  else
    echo "  WARNING: Python 3.11/3.12 not found. Trying system Python (may fail on 3.13+)."
    pipx install fb-idb
  fi
else
  echo "✓ fb-idb installed"
fi

# --- Verify IDB ---
if idb list-targets &>/dev/null; then
  DEVICE_COUNT=$(idb list-targets 2>/dev/null | grep -c "simulator" || true)
  echo "✓ IDB working ($DEVICE_COUNT simulators found)"
else
  echo "WARNING: idb list-targets failed. Check IDB installation."
fi

# --- Configure .mcp.json ---
if [ -f ".mcp.json" ]; then
  if grep -q "ios-simulator" .mcp.json 2>/dev/null; then
    echo "✓ ios-simulator-mcp already configured in .mcp.json"
  else
    echo "NOTE: .mcp.json exists but doesn't include ios-simulator-mcp."
    echo "  Add the ios-simulator entry from the skill's assets/mcp-config.json"
  fi
else
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  ASSET_DIR="$SCRIPT_DIR/../assets"
  if [ -f "$ASSET_DIR/mcp-config.json" ]; then
    cp "$ASSET_DIR/mcp-config.json" .mcp.json
    echo "✓ Created .mcp.json with ios-simulator-mcp"
  else
    echo "NOTE: No .mcp.json found. Create one with ios-simulator-mcp configuration."
  fi
fi

# --- Add test-artifacts to .gitignore ---
if [ -f ".gitignore" ]; then
  if ! grep -q "test-artifacts" .gitignore 2>/dev/null; then
    echo "test-artifacts/" >> .gitignore
    echo "✓ Added test-artifacts/ to .gitignore"
  fi
fi
mkdir -p test-artifacts

# --- Boot a simulator if none running ---
BOOTED=$(xcrun simctl list devices booted 2>/dev/null | grep -c "Booted" || true)
if [ "$BOOTED" = "0" ]; then
  # Find the newest iPhone
  DEVICE=$(xcrun simctl list devices available 2>/dev/null | grep "iPhone" | tail -1 | sed 's/.*(\(.*\)).*/\1/' | head -1)
  if [ -n "$DEVICE" ]; then
    xcrun simctl boot "$DEVICE" 2>/dev/null || true
    DEVICE_NAME=$(xcrun simctl list devices booted 2>/dev/null | grep "Booted" | sed 's/ (.*//;s/^[[:space:]]*//' | head -1)
    echo "✓ Booted simulator: $DEVICE_NAME"
  fi
else
  DEVICE_NAME=$(xcrun simctl list devices booted 2>/dev/null | grep "Booted" | sed 's/ (.*//;s/^[[:space:]]*//' | head -1)
  echo "✓ Simulator already running: $DEVICE_NAME"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code to pick up .mcp.json changes"
echo "  2. Build your app: npx expo run:ios"
echo "  3. Ask Claude to test a flow!"
