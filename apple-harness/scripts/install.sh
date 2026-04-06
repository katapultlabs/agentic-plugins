#!/usr/bin/env bash
# install.sh — Install Apple Harness into an Xcode project
#
# Auto-detects app name, scheme, and platform from the .xcodeproj/.xcworkspace,
# then copies scripts, Makefile, and .gitignore into the project.
#
# Usage:
#   bash install.sh                             # Auto-detect everything in cwd
#   bash install.sh --project-dir /path/to/app  # Specify project directory
#   bash install.sh --app-name Recipes          # Override app name
#   bash install.sh --platform macos            # Override platform
#   bash install.sh --dry-run                   # Preview without writing files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PROJECT_DIR=""
APP_NAME=""
SCHEME=""
PLATFORM=""
DRY_RUN=false
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --app-name)    APP_NAME="$2"; shift 2 ;;
    --scheme)      SCHEME="$2"; shift 2 ;;
    --platform)    PLATFORM="$2"; shift 2 ;;
    --dry-run)     DRY_RUN=true; shift ;;
    --force)       FORCE=true; shift ;;
    -h|--help)
      echo "Usage: bash install.sh [options]"
      echo ""
      echo "Options:"
      echo "  --project-dir DIR   Project directory (default: current directory)"
      echo "  --app-name NAME     App name (default: auto-detect from .xcodeproj)"
      echo "  --scheme NAME       Scheme name (default: auto-detect or APP_NAME)"
      echo "  --platform PLAT     Platform: ios, macos (default: auto-detect)"
      echo "  --dry-run           Preview actions without writing files"
      echo "  --force             Overwrite existing Makefile and scripts"
      echo "  -h, --help          Show this help"
      exit 0
      ;;
    *) echo "ERROR: Unknown flag '$1'. Run with --help for usage." >&2; exit 1 ;;
  esac
done

# Default project dir to cwd
PROJECT_DIR="${PROJECT_DIR:-.}"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

echo "=== Apple Harness — Install ==="
echo ""
echo "Project: $PROJECT_DIR"
echo ""

# ─── Auto-detect app name from .xcworkspace or .xcodeproj ───────────────────
if [[ -z "$APP_NAME" ]]; then
  WORKSPACE="$(ls -d "$PROJECT_DIR"/*.xcworkspace 2>/dev/null | head -1 || true)"
  XCODEPROJ="$(ls -d "$PROJECT_DIR"/*.xcodeproj 2>/dev/null | head -1 || true)"

  if [[ -n "$WORKSPACE" ]]; then
    APP_NAME="$(basename "$WORKSPACE" .xcworkspace)"
  elif [[ -n "$XCODEPROJ" ]]; then
    APP_NAME="$(basename "$XCODEPROJ" .xcodeproj)"
  fi

  if [[ -z "$APP_NAME" ]]; then
    echo "ERROR: No .xcodeproj or .xcworkspace found in $PROJECT_DIR" >&2
    echo "  Either cd into your project directory or use --project-dir" >&2
    echo "  Or provide --app-name explicitly" >&2
    exit 1
  fi
  echo "Detected app: $APP_NAME"
fi

# ─── Auto-detect scheme ─────────────────────────────────────────────────────
if [[ -z "$SCHEME" ]]; then
  if command -v xcodebuild &>/dev/null; then
    SCHEMES="$(cd "$PROJECT_DIR" && xcodebuild -list -json 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    container = d.get('project', d.get('workspace', {}))
    for s in container.get('schemes', []):
        print(s)
except: pass
" 2>/dev/null || true)"

    # Pick first non-test scheme
    SCHEME="$(echo "$SCHEMES" | grep -iv "test" | head -1 || true)"
  fi
  SCHEME="${SCHEME:-$APP_NAME}"
  echo "Detected scheme: $SCHEME"
fi

# ─── Auto-detect platform from project.pbxproj ──────────────────────────────
if [[ -z "$PLATFORM" ]]; then
  PBXPROJ="$(ls "$PROJECT_DIR"/*.xcodeproj/project.pbxproj 2>/dev/null | head -1 || true)"
  if [[ -f "$PBXPROJ" ]]; then
    SDKROOT="$(grep -m1 'SDKROOT' "$PBXPROJ" 2>/dev/null | sed 's/.*= *//;s/;.*//' | tr -d '"[:space:]' || true)"
    case "$SDKROOT" in
      iphoneos*)  PLATFORM="ios" ;;
      macosx*)    PLATFORM="macos" ;;
      *)          PLATFORM="ios" ;;
    esac
  fi
  PLATFORM="${PLATFORM:-ios}"
  echo "Detected platform: $PLATFORM"
fi

echo ""

# ─── Check for existing files ───────────────────────────────────────────────
if [[ "$FORCE" != true && "$DRY_RUN" != true ]]; then
  if [[ -f "$PROJECT_DIR/Makefile" ]]; then
    echo "WARNING: Makefile already exists in $PROJECT_DIR"
    echo "  Use --force to overwrite, or edit it manually."
    echo "  Skipping Makefile generation."
    SKIP_MAKEFILE=true
  fi
  if [[ -d "$PROJECT_DIR/scripts" ]] && ls "$PROJECT_DIR/scripts/"*.sh &>/dev/null 2>&1; then
    echo "WARNING: scripts/ directory already contains .sh files."
    echo "  Use --force to overwrite."
    SKIP_SCRIPTS=true
  fi
fi
SKIP_MAKEFILE="${SKIP_MAKEFILE:-false}"
SKIP_SCRIPTS="${SKIP_SCRIPTS:-false}"

# ─── Dry run: show what would happen ────────────────────────────────────────
if [[ "$DRY_RUN" == true ]]; then
  echo "Dry run — would perform these actions:"
  echo ""
  echo "  Copy scripts/ → $PROJECT_DIR/scripts/"
  echo "    xcbuild.sh, resolve-sim.sh, doctor.sh, clean.sh, setup.sh, install.sh"
  echo ""
  echo "  Generate Makefile → $PROJECT_DIR/Makefile"
  echo "    APP_NAME=$APP_NAME, SCHEME=$SCHEME, PLATFORM=$PLATFORM"
  echo ""
  echo "  Merge .gitignore → $PROJECT_DIR/.gitignore"
  echo "    Add build/, DerivedData/, agents/ exclusions"
  echo ""
  echo "  Append CLAUDE.md section → $PROJECT_DIR/CLAUDE.md"
  echo "    Apple Build Harness quick reference"
  echo ""
  echo "No files written."
  exit 0
fi

# ─── Copy scripts ───────────────────────────────────────────────────────────
if [[ "$SKIP_SCRIPTS" != true ]]; then
  mkdir -p "$PROJECT_DIR/scripts"
  for script in xcbuild.sh resolve-sim.sh doctor.sh clean.sh setup.sh install.sh; do
    cp "$PLUGIN_DIR/scripts/$script" "$PROJECT_DIR/scripts/$script"
  done
  chmod +x "$PROJECT_DIR/scripts/"*.sh
  echo "[ok] Copied scripts/ (6 files)"
else
  echo "[--] Skipped scripts/ (already exists)"
fi

# ─── Generate Makefile from template ────────────────────────────────────────
if [[ "$SKIP_MAKEFILE" != true ]]; then
  sed \
    -e "s/^APP_NAME      := .*/APP_NAME      := $APP_NAME/" \
    -e "s/^PLATFORM      := .*/PLATFORM      := $PLATFORM/" \
    -e "s/^SCHEME        ?= .*/SCHEME        ?= $SCHEME/" \
    "$PLUGIN_DIR/assets/Makefile.template" > "$PROJECT_DIR/Makefile"
  echo "[ok] Generated Makefile (APP_NAME=$APP_NAME, SCHEME=$SCHEME, PLATFORM=$PLATFORM)"
else
  echo "[--] Skipped Makefile (already exists)"
fi

# ─── Merge .gitignore ───────────────────────────────────────────────────────
GITIGNORE="$PROJECT_DIR/.gitignore"
HARNESS_ENTRIES=(
  "# Apple Harness build artifacts"
  "build/"
  "DerivedData/"
  "agents/locks/"
)

if [[ -f "$GITIGNORE" ]]; then
  ADDED=0
  for entry in "${HARNESS_ENTRIES[@]}"; do
    if ! grep -qF "$entry" "$GITIGNORE" 2>/dev/null; then
      echo "$entry" >> "$GITIGNORE"
      ADDED=$((ADDED + 1))
    fi
  done
  if [[ "$ADDED" -gt 0 ]]; then
    echo "[ok] Merged $ADDED entries into existing .gitignore"
  else
    echo "[ok] .gitignore already has harness entries"
  fi
else
  cp "$PLUGIN_DIR/assets/gitignore-template" "$GITIGNORE"
  echo "[ok] Created .gitignore"
fi

# ─── Append CLAUDE.md section ───────────────────────────────────────────────
CLAUDEMD="$PROJECT_DIR/CLAUDE.md"
if [[ -f "$CLAUDEMD" ]]; then
  if grep -q "Apple Build Harness" "$CLAUDEMD" 2>/dev/null; then
    echo "[ok] CLAUDE.md already has Apple Harness section"
  else
    echo "" >> "$CLAUDEMD"
    sed \
      -e "s/{{APP_NAME}}/$APP_NAME/g" \
      -e "s/{{PLATFORM}}/$PLATFORM/g" \
      -e "s/{{BUNDLE_ID}}/TODO/g" \
      "$PLUGIN_DIR/assets/claude-md-template.md" >> "$CLAUDEMD"
    echo "[ok] Appended Apple Harness section to CLAUDE.md"
  fi
else
  sed \
    -e "s/{{APP_NAME}}/$APP_NAME/g" \
    -e "s/{{PLATFORM}}/$PLATFORM/g" \
    -e "s/{{BUNDLE_ID}}/TODO/g" \
    "$PLUGIN_DIR/assets/claude-md-template.md" > "$CLAUDEMD"
  echo "[ok] Created CLAUDE.md with Apple Harness section"
fi

# ─── Verify ─────────────────────────────────────────────────────────────────
echo ""
echo "=== Install Complete ==="
echo ""
echo "Verify with:"
echo "  cd $PROJECT_DIR"
echo "  make diagnose"
echo "  make build"
echo ""
echo "Quick reference:"
echo "  make build          Build with strict Swift 6 flags"
echo "  make test           Run unit tests"
echo "  make run            Launch on simulator"
echo "  make build-and-run  Build then launch"
echo "  make console        Stream simulator console logs"
echo "  make clean          Clean build artifacts"
