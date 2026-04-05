#!/usr/bin/env bash
# xcbuild.sh — Agent-isolated xcodebuild wrapper
#
# Runs xcodebuild with DerivedData, caches, temp files, and logs scoped to a
# named agent under build/. This prevents collisions when multiple agents
# (or a human + agent) build the same project simultaneously.
#
# HOME is NOT overridden — signing credentials, SSH keys, and .gitconfig remain
# accessible. Only build artifacts and caches are isolated.
#
# Usage:
#   bash scripts/xcbuild.sh --agent CLAUDE --action build -- -scheme MyApp ...
#   bash scripts/xcbuild.sh --action test -- -scheme MyApp test
#
# Agent name resolves from: --agent flag > $AGENT_NAME env > agents/current_name.txt > "CLAUDE"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Argument parsing ---
AGENT=""
ACTION="build"
XCODE_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)   AGENT="$2"; shift 2 ;;
    --action)  ACTION="$2"; shift 2 ;;
    --)        shift; XCODE_ARGS=("$@"); break ;;
    *)         echo "ERROR: Unknown flag '$1'. Use -- before xcodebuild args." >&2; exit 1 ;;
  esac
done

# --- Resolve agent name ---
if [[ -z "$AGENT" ]]; then
  if [[ -n "${AGENT_NAME:-}" ]]; then
    AGENT="$AGENT_NAME"
  elif [[ -f "$PROJECT_DIR/agents/current_name.txt" ]]; then
    AGENT="$(tr -d '\n\r' < "$PROJECT_DIR/agents/current_name.txt")"
  fi
fi
AGENT="${AGENT:-CLAUDE}"

# Sanitize for filesystem paths
SAFE_AGENT="$(echo "$AGENT" | tr ' /' '__')"
SAFE_ACTION="$(echo "$ACTION" | tr ' /' '__')"

# --- Build isolation directories ---
DERIVED_DATA="$PROJECT_DIR/build/DerivedData/$SAFE_AGENT"
CACHE_DIR="$PROJECT_DIR/build/cache/$SAFE_AGENT"
LOG_DIR="$PROJECT_DIR/build/logs/$SAFE_AGENT"
TMP_DIR="$PROJECT_DIR/build/tmp/$SAFE_AGENT"
ARCHIVE_DIR="$LOG_DIR/archive"

CLANG_CACHE="$CACHE_DIR/clang/ModuleCache"
SWIFT_CACHE="$CACHE_DIR/swift/ModuleCache"
SPM_SOURCES="$CACHE_DIR/swiftpm/SourcePackages"
XDG_CACHE="$CACHE_DIR/xdg"

mkdir -p "$DERIVED_DATA" "$CLANG_CACHE" "$SWIFT_CACHE" "$SPM_SOURCES" \
         "$XDG_CACHE" "$LOG_DIR" "$ARCHIVE_DIR" "$TMP_DIR"

# --- Archive previous logs and results ---
LOG_FILE="$LOG_DIR/${SAFE_ACTION}.log"
RESULT_BUNDLE="$LOG_DIR/${SAFE_ACTION}.xcresult"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

if [[ -f "$LOG_FILE" ]]; then
  mv "$LOG_FILE" "$ARCHIVE_DIR/${SAFE_ACTION}-${TIMESTAMP}.log"
fi
if [[ -d "$RESULT_BUNDLE" ]]; then
  mv "$RESULT_BUNDLE" "$ARCHIVE_DIR/${SAFE_ACTION}-${TIMESTAMP}.xcresult"
fi

# --- Resolve output filter ---
FILTER_CMD="cat"
if command -v xcbeautify &>/dev/null; then
  FILTER_CMD="xcbeautify --quiet"
fi

# --- Build the xcodebuild command ---
echo "=== xcbuild: agent=$AGENT action=$ACTION ==="
echo "    DerivedData: $DERIVED_DATA"
echo "    Logs:        $LOG_FILE"
echo ""

# Isolate TMPDIR and XDG cache, but preserve real HOME for signing/credentials
XCODEBUILD_CMD=(
  env
  TMPDIR="$TMP_DIR"
  XDG_CACHE_HOME="$XDG_CACHE"
  xcodebuild
  -derivedDataPath "$DERIVED_DATA"
  -clonedSourcePackagesDirPath "$SPM_SOURCES"
  -resultBundlePath "$RESULT_BUNDLE"
  CLANG_MODULE_CACHE_PATH="$CLANG_CACHE"
  SWIFT_MODULE_CACHE_PATH="$SWIFT_CACHE"
  "${XCODE_ARGS[@]}"
)

# --- Execute with logging ---
set +e
"${XCODEBUILD_CMD[@]}" 2>&1 | $FILTER_CMD | tee "$LOG_FILE"
PIPE_STATUSES=("${PIPESTATUS[@]}")
set -e

XCBUILD_EXIT="${PIPE_STATUSES[0]:-1}"
FILTER_EXIT="${PIPE_STATUSES[1]:-0}"
TEE_EXIT="${PIPE_STATUSES[2]:-0}"

if [[ "$FILTER_EXIT" -ne 0 && "$XCBUILD_EXIT" -eq 0 ]]; then
  echo "WARNING: Output filter exited with $FILTER_EXIT (build succeeded)" >&2
fi

if [[ "$TEE_EXIT" -ne 0 ]]; then
  echo "WARNING: Log write failed (tee exited with $TEE_EXIT)" >&2
fi

if [[ "$XCBUILD_EXIT" -ne 0 ]]; then
  echo "" >&2
  echo "BUILD FAILED (exit $XCBUILD_EXIT)" >&2
  echo "  Log:    $LOG_FILE" >&2
  echo "  Result: $RESULT_BUNDLE" >&2
  exit "$XCBUILD_EXIT"
fi

echo ""
echo "BUILD SUCCEEDED"
echo "  Log:    $LOG_FILE"
echo "  Result: $RESULT_BUNDLE"
