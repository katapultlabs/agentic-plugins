#!/usr/bin/env bash
# resolve-sim.sh — Intelligent iOS Simulator auto-selection
#
# Picks the best available simulator based on boot state, iOS version, and model.
# Returns an xcodebuild -destination string.
#
# Usage:
#   bash scripts/resolve-sim.sh                          # Auto-pick best
#   bash scripts/resolve-sim.sh --name "iPhone 16 Pro"   # Pick specific model
#   bash scripts/resolve-sim.sh --udid <UDID>            # Use exact device
#
# Output (stdout): platform=iOS Simulator,id=<UDID>
# Exit 1 if no suitable simulator found.

set -euo pipefail

SIM_NAME=""
SIM_UDID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) SIM_NAME="$2"; shift 2 ;;
    --udid) SIM_UDID="$2"; shift 2 ;;
    *)      echo "ERROR: Unknown flag '$1'" >&2; exit 1 ;;
  esac
done

# Direct UDID — skip all resolution
if [[ -n "$SIM_UDID" ]]; then
  echo "platform=iOS Simulator,id=$SIM_UDID"
  exit 0
fi

# Query available simulators
SIMCTL_JSON="${SIMCTL_LIST_JSON:-}"
if [[ -z "$SIMCTL_JSON" ]]; then
  SIMCTL_JSON="$(xcrun simctl list devices -j 2>/dev/null)" || {
    echo "ERROR: Failed to query simulators via xcrun simctl." >&2
    exit 1
  }
fi

if ! command -v python3 &>/dev/null; then
  echo "ERROR: python3 is required for simulator resolution." >&2
  echo "  Install: brew install python3" >&2
  exit 1
fi

# Rank simulators via Python — JSON passed via stdin, name via env var
RESULT="$(echo "$SIMCTL_JSON" | SIM_REQUESTED="$SIM_NAME" python3 -c '
import json, os, re, sys

data = json.load(sys.stdin)
devices = data.get("devices", {})
requested = os.environ.get("SIM_REQUESTED", "").strip()

candidates = []
for runtime_key, device_list in devices.items():
    m = re.search(r"iOS[- ](\d+)[- .](\d+)", runtime_key)
    if not m:
        continue
    ios_major, ios_minor = int(m.group(1)), int(m.group(2))

    for dev in device_list:
        if not dev.get("isAvailable", False):
            continue
        name = dev.get("name", "")
        if "iPhone" not in name:
            continue

        if requested and requested.lower() != "auto":
            if requested.lower() not in name.lower():
                continue

        booted = 1 if dev.get("state") == "Booted" else 0

        # Model ranking: extract iPhone number and variant
        model_match = re.search(r"iPhone\s*(\d+)", name)
        model_num = int(model_match.group(1)) if model_match else 0
        name_lower = name.lower()
        if "pro max" in name_lower:
            variant = 6
        elif "pro" in name_lower:
            variant = 5
        elif "plus" in name_lower:
            variant = 4
        elif "air" in name_lower:
            variant = 3
        elif "mini" in name_lower:
            variant = 1
        elif "se" in name_lower or re.search(r"iphone\s*\d+e\b", name_lower):
            variant = 0
        else:
            variant = 2  # standard

        candidates.append((
            booted, ios_major, ios_minor, model_num, variant,
            dev["udid"], name
        ))

candidates.sort(reverse=True)
if candidates:
    best = candidates[0]
    print(f"platform=iOS Simulator,id={best[5]}")
    state = "booted" if best[0] else "shutdown"
    print(f"# {best[6]} (iOS {best[1]}.{best[2]}, {state})", file=sys.stderr)
else:
    sys.exit(1)
' 2>/dev/null)" || {
  if [[ -n "$SIM_NAME" ]]; then
    echo "ERROR: No simulator matching '$SIM_NAME' found." >&2
  else
    echo "ERROR: No available iPhone simulator found." >&2
  fi
  echo "  Run: xcrun simctl list devices available" >&2
  exit 1
}

# Extract destination line (first line, not the stderr comment)
DESTINATION="$(echo "$RESULT" | head -1)"

if [[ -z "$DESTINATION" || "$DESTINATION" == "platform=iOS Simulator,id=" ]]; then
  echo "ERROR: Simulator resolution returned empty result." >&2
  echo "  Run: xcrun simctl list devices available" >&2
  exit 1
fi

echo "$DESTINATION"
