#!/usr/bin/env bash
# clean.sh — Remove build artifacts (agent-scoped or all)
#
# Usage:
#   bash scripts/clean.sh                  # Clean current agent
#   bash scripts/clean.sh --agent CLAUDE   # Clean specific agent
#   bash scripts/clean.sh --all            # Clean everything under build/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"

AGENT=""
CLEAN_ALL=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2 ;;
    --all)   CLEAN_ALL=true; shift ;;
    *)       echo "ERROR: Unknown flag '$1'" >&2; exit 1 ;;
  esac
done

if [[ ! -d "$BUILD_DIR" ]]; then
  echo "Nothing to clean (no build/ directory)."
  exit 0
fi

if [[ "$CLEAN_ALL" == true ]]; then
  echo "Cleaning all build artifacts..."
  rm -rf "$BUILD_DIR"
  echo "Removed: $BUILD_DIR"
  exit 0
fi

# Resolve agent name
if [[ -z "$AGENT" ]]; then
  if [[ -n "${AGENT_NAME:-}" ]]; then
    AGENT="$AGENT_NAME"
  elif [[ -f "$PROJECT_DIR/agents/current_name.txt" ]]; then
    AGENT="$(tr -d '\n\r' < "$PROJECT_DIR/agents/current_name.txt")"
  fi
fi
AGENT="${AGENT:-CLAUDE}"
SAFE_AGENT="$(echo "$AGENT" | tr ' /' '__')"

echo "Cleaning build artifacts for agent: $AGENT"

CLEANED=0
for subdir in DerivedData cache logs tmp home; do
  TARGET="$BUILD_DIR/$subdir/$SAFE_AGENT"
  if [[ -d "$TARGET" ]]; then
    rm -rf "$TARGET"
    echo "  Removed: build/$subdir/$SAFE_AGENT"
    ((CLEANED++))
  fi
done

if [[ "$CLEANED" -eq 0 ]]; then
  echo "  Nothing to clean for agent '$AGENT'."
else
  echo "Cleaned $CLEANED directories."
fi
