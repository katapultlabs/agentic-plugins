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

# Escape sed replacement metacharacters (/, &, \)
sed_escape() { printf '%s' "$1" | sed 's/[\/&\\]/\\&/g'; }

# Require a value argument for a flag
require_value() {
  if [[ $# -lt 2 ]]; then
    echo "ERROR: $1 requires a value." >&2
    exit 1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir) require_value "$@"; PROJECT_DIR="$2"; shift 2 ;;
    --app-name)    require_value "$@"; APP_NAME="$2"; shift 2 ;;
    --scheme)      require_value "$@"; SCHEME="$2"; shift 2 ;;
    --platform)    require_value "$@"; PLATFORM="$2"; shift 2 ;;
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

# Validate platform if explicitly provided
if [[ -n "$PLATFORM" ]]; then
  case "$PLATFORM" in
    ios|macos) ;;
    *) echo "ERROR: Invalid platform '$PLATFORM'. Must be 'ios' or 'macos'." >&2; exit 1 ;;
  esac
fi

# Default project dir to cwd
PROJECT_DIR="${PROJECT_DIR:-.}"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

echo "=== Apple Harness — Install ==="
echo ""
echo "Project: $PROJECT_DIR"
echo ""

# ─── Auto-detect app name from .xcworkspace or .xcodeproj ───────────────────
if [[ -z "$APP_NAME" ]]; then
  WORKSPACES=()
  while IFS= read -r -d '' f; do WORKSPACES+=("$f"); done < <(find "$PROJECT_DIR" -maxdepth 1 -name "*.xcworkspace" -print0 2>/dev/null || true)
  XCODEPROJS=()
  while IFS= read -r -d '' f; do XCODEPROJS+=("$f"); done < <(find "$PROJECT_DIR" -maxdepth 1 -name "*.xcodeproj" -print0 2>/dev/null || true)

  if [[ ${#WORKSPACES[@]} -gt 1 ]]; then
    echo "ERROR: Multiple .xcworkspace files found:" >&2
    printf "  %s\n" "${WORKSPACES[@]}" >&2
    echo "  Use --app-name to specify which one." >&2
    exit 1
  elif [[ ${#XCODEPROJS[@]} -gt 1 && ${#WORKSPACES[@]} -eq 0 ]]; then
    echo "ERROR: Multiple .xcodeproj files found:" >&2
    printf "  %s\n" "${XCODEPROJS[@]}" >&2
    echo "  Use --app-name to specify which one." >&2
    exit 1
  fi

  if [[ ${#WORKSPACES[@]} -eq 1 ]]; then
    APP_NAME="$(basename "${WORKSPACES[0]}" .xcworkspace)"
  elif [[ ${#XCODEPROJS[@]} -eq 1 ]]; then
    APP_NAME="$(basename "${XCODEPROJS[0]}" .xcodeproj)"
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

    # Exclude only conventional test scheme suffixes (Tests, UITests)
    SCHEME="$(echo "$SCHEMES" | grep -ivE '(Tests|UITests)$' | head -1 || true)"
  fi
  SCHEME="${SCHEME:-$APP_NAME}"
  echo "Detected scheme: $SCHEME"
fi

# ─── Auto-detect platform from project.pbxproj ──────────────────────────────
if [[ -z "$PLATFORM" ]]; then
  # NOTE: In multi-target projects the first SDKROOT may not be the app target.
  # Use --platform to override if auto-detection picks wrong.
  PBXPROJ="$(find "$PROJECT_DIR" -maxdepth 2 -name "project.pbxproj" -print -quit 2>/dev/null || true)"
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

# ─── Check for existing files (runs for both dry-run and real) ──────────────
SKIP_MAKEFILE=false
SKIP_SCRIPTS=false

if [[ "$FORCE" != true ]]; then
  if [[ -f "$PROJECT_DIR/Makefile" ]]; then
    echo "WARNING: Makefile already exists in $PROJECT_DIR"
    echo "  Use --force to overwrite, or edit it manually."
    SKIP_MAKEFILE=true
  fi
  if [[ -d "$PROJECT_DIR/scripts" ]] && ls "$PROJECT_DIR/scripts/"*.sh &>/dev/null 2>&1; then
    echo "WARNING: scripts/ directory already contains .sh files."
    echo "  Use --force to overwrite."
    SKIP_SCRIPTS=true
  fi
fi

# Determine what would happen to .gitignore and CLAUDE.md
GITIGNORE="$PROJECT_DIR/.gitignore"
CLAUDEMD="$PROJECT_DIR/CLAUDE.md"

if [[ -f "$GITIGNORE" ]]; then
  GITIGNORE_ACTION="merge"
else
  GITIGNORE_ACTION="create"
fi

if [[ -f "$CLAUDEMD" ]]; then
  if grep -q "^## Apple Build Harness$" "$CLAUDEMD" 2>/dev/null; then
    CLAUDEMD_ACTION="skip"
  else
    CLAUDEMD_ACTION="append"
  fi
else
  CLAUDEMD_ACTION="create"
fi

# ─── Dry run: show what would happen ────────────────────────────────────────
if [[ "$DRY_RUN" == true ]]; then
  echo "Dry run — would perform these actions:"
  echo ""

  if [[ "$SKIP_SCRIPTS" == true ]]; then
    echo "  [skip] scripts/ (already exists, use --force to overwrite)"
  else
    echo "  [copy] scripts/ → $PROJECT_DIR/scripts/"
    echo "         xcbuild.sh, resolve-sim.sh, doctor.sh, clean.sh, setup.sh, install.sh"
  fi
  echo ""

  if [[ "$SKIP_MAKEFILE" == true ]]; then
    echo "  [skip] Makefile (already exists, use --force to overwrite)"
  else
    echo "  [generate] Makefile → $PROJECT_DIR/Makefile"
    echo "             APP_NAME=$APP_NAME, SCHEME=$SCHEME, PLATFORM=$PLATFORM"
  fi
  echo ""

  echo "  [$GITIGNORE_ACTION] .gitignore → $PROJECT_DIR/.gitignore"
  echo ""

  case "$CLAUDEMD_ACTION" in
    skip)   echo "  [skip] CLAUDE.md (already has Apple Harness section)" ;;
    append) echo "  [append] CLAUDE.md → add Apple Build Harness section" ;;
    create) echo "  [create] CLAUDE.md → $PROJECT_DIR/CLAUDE.md" ;;
  esac
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
  SAFE_APP="$(sed_escape "$APP_NAME")"
  SAFE_SCHEME="$(sed_escape "$SCHEME")"
  SAFE_PLATFORM="$(sed_escape "$PLATFORM")"
  sed \
    -e "s/^APP_NAME      := .*/APP_NAME      := $SAFE_APP/" \
    -e "s/^PLATFORM      := .*/PLATFORM      := $SAFE_PLATFORM/" \
    -e "s/^SCHEME        ?= .*/SCHEME        ?= $SAFE_SCHEME/" \
    "$PLUGIN_DIR/assets/Makefile.template" > "$PROJECT_DIR/Makefile"
  echo "[ok] Generated Makefile (APP_NAME=$APP_NAME, SCHEME=$SCHEME, PLATFORM=$PLATFORM)"
else
  echo "[--] Skipped Makefile (already exists)"
fi

# ─── Merge .gitignore ───────────────────────────────────────────────────────
HARNESS_ENTRIES=(
  "# Apple Harness build artifacts"
  "build/"
  "DerivedData/"
  "agents/locks/"
)

if [[ "$GITIGNORE_ACTION" == "merge" ]]; then
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
SAFE_APP_CLAUDE="$(sed_escape "$APP_NAME")"
SAFE_PLATFORM_CLAUDE="$(sed_escape "$PLATFORM")"

case "$CLAUDEMD_ACTION" in
  skip)
    echo "[ok] CLAUDE.md already has Apple Harness section"
    ;;
  append)
    echo "" >> "$CLAUDEMD"
    sed \
      -e "s/{{APP_NAME}}/$SAFE_APP_CLAUDE/g" \
      -e "s/{{PLATFORM}}/$SAFE_PLATFORM_CLAUDE/g" \
      -e "s/{{BUNDLE_ID}}/TODO/g" \
      "$PLUGIN_DIR/assets/claude-md-template.md" >> "$CLAUDEMD"
    echo "[ok] Appended Apple Harness section to CLAUDE.md"
    ;;
  create)
    sed \
      -e "s/{{APP_NAME}}/$SAFE_APP_CLAUDE/g" \
      -e "s/{{PLATFORM}}/$SAFE_PLATFORM_CLAUDE/g" \
      -e "s/{{BUNDLE_ID}}/TODO/g" \
      "$PLUGIN_DIR/assets/claude-md-template.md" > "$CLAUDEMD"
    echo "[ok] Created CLAUDE.md with Apple Harness section"
    ;;
esac

# ─── Verify ─────────────────────────────────────────────────────────────────
echo ""
echo "=== Install Complete ==="
echo ""
printf '  cd "%s"\n' "$PROJECT_DIR"
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
