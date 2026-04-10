#!/usr/bin/env bash
set -euo pipefail

# ghsetup — Zero-friction GitHub workflow for non-technical users.
# This script is called by Claude Code via the CLAUDE.md plugin instructions.
# Users never run this directly.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR=".ghsetup"
STATE_FILE="$STATE_DIR/state.json"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_require_jq() {
  if ! command -v jq &>/dev/null; then
    echo '{"ok":false,"error":"jq is not installed. Run: brew install jq (mac) or sudo apt install jq (linux)"}'
    exit 1
  fi
}

_require_gh() {
  if ! command -v gh &>/dev/null; then
    echo '{"ok":false,"error":"gh CLI is not installed. Run the setup script first: bash '"$SCRIPT_DIR"'/setup.sh"}'
    exit 1
  fi
}

_require_git() {
  if ! command -v git &>/dev/null; then
    echo '{"ok":false,"error":"git is not installed. Run the setup script first: bash '"$SCRIPT_DIR"'/setup.sh"}'
    exit 1
  fi
}

_require_auth() {
  if ! gh auth status &>/dev/null 2>&1; then
    echo '{"ok":false,"error":"not_authenticated","message":"GitHub authentication required. Run: bash '"$SCRIPT_DIR"'/setup.sh"}'
    exit 1
  fi
}

_require_state() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo '{"ok":false,"error":"no_project","message":"No ghsetup project found in this directory. Run ghsetup init first."}'
    exit 1
  fi
}

_resolve_owner() {
  # Determines where repos should be created. Resolution order:
  # 1. State file (already initialized project)
  # 2. GHSETUP_ORG env var (team lockdown — admins set this for their users)
  # 3. Auto-detect from GitHub account
  # Sets OWNER and OWNER_SOURCE. If source is "needs_choice", OWNER_ORGS has the list.
  _require_jq
  _require_gh
  _require_auth

  # 1. Check state file
  if [[ -f "$STATE_FILE" ]]; then
    local state_owner
    state_owner=$(jq -r '.owner // ""' "$STATE_FILE" 2>/dev/null || echo "")
    if [[ -n "$state_owner" && "$state_owner" != "null" ]]; then
      OWNER="$state_owner"
      OWNER_SOURCE="state"
      return 0
    fi
    # Fallback: derive owner from repo_full in existing state
    local repo_full_val
    repo_full_val=$(jq -r '.repo_full // ""' "$STATE_FILE" 2>/dev/null || echo "")
    if [[ -n "$repo_full_val" && "$repo_full_val" == *"/"* ]]; then
      OWNER="${repo_full_val%%/*}"
      OWNER_SOURCE="state"
      return 0
    fi
  fi

  # 2. Check GHSETUP_ORG env var (team override)
  if [[ -n "${GHSETUP_ORG:-}" ]]; then
    OWNER="$GHSETUP_ORG"
    OWNER_SOURCE="env"
    return 0
  fi

  # 3. Auto-detect from GitHub account
  local username
  username=$(gh api user --jq '.login' 2>/dev/null || echo "")
  if [[ -z "$username" ]]; then
    echo '{"ok":false,"error":"auth_failed","message":"Could not detect your GitHub username. Try logging in again."}'
    exit 1
  fi

  local orgs_json
  orgs_json=$(gh api user/orgs --jq '[.[].login]' 2>/dev/null || echo "[]")
  local org_count
  org_count=$(echo "$orgs_json" | jq 'length' 2>/dev/null || echo "0")

  OWNER_USERNAME="$username"
  OWNER_ORGS="$orgs_json"

  if [[ "$org_count" -eq 0 ]]; then
    OWNER="$username"
    OWNER_SOURCE="personal"
    return 0
  else
    # User has orgs — Claude should ask them where to create the project
    OWNER=""
    OWNER_SOURCE="needs_choice"
    return 0
  fi
}

_read_state() {
  _require_jq
  _require_state
  REPO_NAME=$(jq -r '.repo_name' "$STATE_FILE")
  REPO_FULL=$(jq -r '.repo_full' "$STATE_FILE")
  OWNER=$(jq -r '.owner // ""' "$STATE_FILE")
  PAGES_ENABLED=$(jq -r '.pages_enabled // false' "$STATE_FILE")
  PAGES_URL=$(jq -r '.pages_url // ""' "$STATE_FILE")
  # Backfill owner from repo_full for older state files
  if [[ -z "$OWNER" || "$OWNER" == "null" ]] && [[ -n "$REPO_FULL" && "$REPO_FULL" == *"/"* ]]; then
    OWNER="${REPO_FULL%%/*}"
  fi
}

_write_state() {
  mkdir -p "$STATE_DIR"
  cat > "$STATE_FILE" <<EOF
{
  "owner": "$1",
  "repo_name": "$2",
  "repo_full": "$3",
  "pages_enabled": $4,
  "pages_url": "$5",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

_update_state_field() {
  _require_jq
  local tmp
  tmp=$(mktemp)
  jq "$1" "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
}

_current_branch() {
  git branch --show-current 2>/dev/null || echo ""
}

_generate_commit_message() {
  local stats
  stats=$(git diff --cached --stat --no-color 2>/dev/null || echo "")
  if [[ -z "$stats" ]]; then
    echo "Save progress"
    return
  fi
  local files_changed
  files_changed=$(echo "$stats" | tail -1 | grep -oE '[0-9]+ file' | grep -oE '[0-9]+' || echo "some")
  echo "Update ${files_changed} files"
}

# ---------------------------------------------------------------------------
# Secret scanning — lightweight pre-commit check
# ---------------------------------------------------------------------------

_scan_for_secrets() {
  local found=0
  local issues=""

  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    # Skip binary files
    if file "$file" | grep -qE 'binary|executable|image|font'; then
      continue
    fi
    # Pattern scan
    local matches=""
    matches=$(grep -nEi \
      '(sk_live_|sk_test_|pk_live_|pk_test_|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36}|-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----|password\s*[:=]\s*["\x27][^"\x27]{8,}|secret\s*[:=]\s*["\x27][^"\x27]{8,}|api[_-]?key\s*[:=]\s*["\x27][^"\x27]{8,})' \
      "$file" 2>/dev/null || true)

    if [[ -n "$matches" ]]; then
      found=1
      issues="${issues}FILE: ${file}\n${matches}\n---\n"
    fi
  done < <(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)

  if [[ $found -eq 1 ]]; then
    echo '{"ok":false,"error":"secrets_detected","message":"Potential secrets found in staged files. Remove them before saving.","details":"'"$(echo -e "$issues" | head -20 | sed 's/"/\\"/g' | tr '\n' ' ')"'"}'
    return 1
  fi
  return 0
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

cmd_init() {
  local name=""
  local explicit_owner=""

  # Parse arguments: [--owner <owner>] [name]
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --owner) explicit_owner="$2"; shift 2 ;;
      *)       name="$1"; shift ;;
    esac
  done

  _require_gh
  _require_git
  _require_auth

  # Default name from directory
  if [[ -z "$name" ]]; then
    name=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g')
  else
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g')
  fi

  # Check if already initialized
  if [[ -f "$STATE_FILE" ]]; then
    _read_state
    echo '{"ok":true,"already_initialized":true,"repo_name":"'"$REPO_NAME"'","repo_full":"'"$REPO_FULL"'","pages_url":"'"$PAGES_URL"'"}'
    return 0
  fi

  # Resolve owner
  if [[ -n "$explicit_owner" ]]; then
    OWNER="$explicit_owner"
    OWNER_SOURCE="explicit"
  else
    _resolve_owner
  fi

  # If we need the user to choose, return the options for Claude to ask
  if [[ "$OWNER_SOURCE" == "needs_choice" ]]; then
    echo '{"ok":true,"needs_choice":true,"username":"'"$OWNER_USERNAME"'","orgs":'"$OWNER_ORGS"',"message":"User has organizations. Ask where to create the project."}'
    return 0
  fi

  # Scaffold blank project if no index.html exists
  if [[ ! -f "index.html" ]]; then
    cat > index.html <<'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Project</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <h1>Hello world</h1>
  <p>Start editing to build something great.</p>
  <script src="script.js"></script>
</body>
</html>
HTMLEOF

    cat > style.css <<'CSSEOF'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: system-ui, -apple-system, sans-serif;
  line-height: 1.6;
  padding: 2rem;
  max-width: 800px;
  margin: 0 auto;
  color: #1a1a1a;
  background: #fafafa;
}

h1 {
  margin-bottom: 0.5rem;
}
CSSEOF

    cat > script.js <<'JSEOF'
// Your JavaScript goes here
console.log('Project ready');
JSEOF
  fi

  # Copy the hardened .gitignore
  cp "$SCRIPT_DIR/gitignore-template" .gitignore 2>/dev/null || true

  # Init git repo
  if [[ ! -d ".git" ]]; then
    git init -q
  fi

  # Create the GitHub repo under the resolved owner
  local repo_full="${OWNER}/${name}"
  local create_output
  if ! create_output=$(gh repo create "$repo_full" --public --source=. --push 2>&1); then
    # Handle name collision
    if echo "$create_output" | grep -qi "name already exists"; then
      local suffix
      suffix=$(date +%s | tail -c 5)
      name="${name}-${suffix}"
      repo_full="${OWNER}/${name}"
      if ! create_output=$(gh repo create "$repo_full" --public --source=. --push 2>&1); then
        echo '{"ok":false,"error":"repo_create_failed","message":"Could not create the repository.","details":"'"$(echo "$create_output" | sed 's/"/\\"/g')"'"}'
        return 1
      fi
    else
      echo '{"ok":false,"error":"repo_create_failed","message":"Could not create the repository.","details":"'"$(echo "$create_output" | sed 's/"/\\"/g')"'"}'
      return 1
    fi
  fi

  # Write state
  _write_state "$OWNER" "$name" "$repo_full" "false" ""

  echo '{"ok":true,"repo_name":"'"$name"'","repo_full":"'"$repo_full"'","owner":"'"$OWNER"'","url":"https://github.com/'"$repo_full"'"}'
}

cmd_save() {
  _require_gh
  _require_git
  _require_auth
  _read_state

  local message="${1:-}"

  # Stage everything
  git add -A

  # Check if there's anything to commit
  if git diff --cached --quiet 2>/dev/null; then
    echo '{"ok":true,"nothing_to_save":true,"message":"Everything is already saved."}'
    return 0
  fi

  # Scan for secrets before committing
  if ! _scan_for_secrets; then
    git reset HEAD -- . &>/dev/null
    return 1
  fi

  # Generate commit message if not provided
  if [[ -z "$message" ]]; then
    message=$(_generate_commit_message)
  fi

  git commit -q -m "$message"

  if ! git push -q 2>&1; then
    echo '{"ok":false,"error":"push_failed","message":"Saved locally but could not upload. Check your internet connection."}'
    return 1
  fi

  echo '{"ok":true,"message":"'"$message"'"}'
}

cmd_deploy() {
  _require_gh
  _require_git
  _require_auth
  _read_state

  # Save first
  git add -A
  if ! git diff --cached --quiet 2>/dev/null; then
    if ! _scan_for_secrets; then
      git reset HEAD -- . &>/dev/null
      return 1
    fi
    git commit -q -m "Deploy site"
    git push -q 2>/dev/null || true
  fi

  # Enable GitHub Pages if not already
  if [[ "$PAGES_ENABLED" != "true" ]]; then
    local pages_output
    # Try to enable pages — may already be enabled
    pages_output=$(gh api "repos/${REPO_FULL}/pages" \
      -X POST \
      -f "build_type=legacy" \
      -f "source[branch]=main" \
      -f "source[path]=/" \
      2>&1) || true

    # If it failed because already enabled, that's fine
    if echo "$pages_output" | grep -qi "already enabled\|409"; then
      : # Pages already enabled, continue
    elif echo "$pages_output" | grep -qi "error\|not found"; then
      # Check if pages is already on via GET
      local check
      check=$(gh api "repos/${REPO_FULL}/pages" 2>&1) || true
      if ! echo "$check" | grep -qi "html_url"; then
        echo '{"ok":false,"error":"pages_failed","message":"Could not enable GitHub Pages. The repo may need an index.html file.","details":"'"$(echo "$pages_output" | head -3 | sed 's/"/\\"/g')"'"}'
        return 1
      fi
    fi

    _update_state_field '.pages_enabled = true'
  fi

  # Get the pages URL
  local pages_info
  pages_info=$(gh api "repos/${REPO_FULL}/pages" 2>/dev/null || echo "{}")
  local pages_url
  pages_url=$(echo "$pages_info" | jq -r '.html_url // ""' 2>/dev/null || echo "")

  if [[ -z "$pages_url" || "$pages_url" == "null" ]]; then
    pages_url="https://${OWNER}.github.io/${REPO_NAME}/"
  fi

  _update_state_field ".pages_url = \"$pages_url\""

  # Poll for deployment (up to 60 seconds)
  local status="building"
  local attempts=0
  while [[ "$status" != "built" && $attempts -lt 12 ]]; do
    sleep 5
    status=$(gh api "repos/${REPO_FULL}/pages" 2>/dev/null | jq -r '.status // "building"' 2>/dev/null || echo "building")
    attempts=$((attempts + 1))
  done

  echo '{"ok":true,"pages_url":"'"$pages_url"'","status":"'"$status"'","message":"Site is live (or will be in a few moments)."}'
}

cmd_status() {
  _require_gh
  _require_git
  _require_auth

  if [[ ! -f "$STATE_FILE" ]]; then
    echo '{"ok":true,"initialized":false,"message":"No project in this directory."}'
    return 0
  fi

  _read_state

  local has_changes="false"
  if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    has_changes="true"
  fi

  local untracked
  untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

  echo '{"ok":true,"initialized":true,"repo_name":"'"$REPO_NAME"'","repo_full":"'"$REPO_FULL"'","pages_enabled":'"$PAGES_ENABLED"',"pages_url":"'"$PAGES_URL"'","has_unsaved_changes":'"$has_changes"',"untracked_files":'"$untracked"'}'
}

cmd_collab() {
  local action="${1:-add}"
  local user="${2:-}"

  _require_gh
  _require_auth
  _read_state

  if [[ -z "$user" ]]; then
    echo '{"ok":false,"error":"missing_user","message":"Please provide a GitHub username or email."}'
    return 1
  fi

  if [[ "$action" == "add" ]]; then
    local output
    if output=$(gh api "repos/${REPO_FULL}/collaborators/${user}" -X PUT -f permission=push 2>&1); then
      echo '{"ok":true,"action":"added","user":"'"$user"'","repo":"'"$REPO_FULL"'"}'
    else
      echo '{"ok":false,"error":"collab_failed","message":"Could not add collaborator.","details":"'"$(echo "$output" | sed 's/"/\\"/g')"'"}'
      return 1
    fi
  elif [[ "$action" == "remove" ]]; then
    local output
    if output=$(gh api "repos/${REPO_FULL}/collaborators/${user}" -X DELETE 2>&1); then
      echo '{"ok":true,"action":"removed","user":"'"$user"'"}'
    else
      echo '{"ok":false,"error":"collab_failed","message":"Could not remove collaborator.","details":"'"$(echo "$output" | sed 's/"/\\"/g')"'"}'
      return 1
    fi
  fi
}

cmd_doctor() {
  _require_jq

  local results=()
  local all_ok=true

  # Check git
  if command -v git &>/dev/null; then
    results+=("\"git\":\"ok\"")
  else
    results+=("\"git\":\"missing\"")
    all_ok=false
  fi

  # Check gh
  if command -v gh &>/dev/null; then
    results+=("\"gh_cli\":\"ok\"")
  else
    results+=("\"gh_cli\":\"missing\"")
    all_ok=false
  fi

  # Check auth
  if gh auth status &>/dev/null 2>&1; then
    local gh_user
    gh_user=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
    results+=("\"auth\":\"ok\",\"gh_user\":\"$gh_user\"")
  else
    results+=("\"auth\":\"not_authenticated\"")
    all_ok=false
  fi

  # Check owner resolution
  if [[ -f "$STATE_FILE" ]]; then
    local state_owner
    state_owner=$(jq -r '.owner // ""' "$STATE_FILE" 2>/dev/null || echo "")
    if [[ -n "$state_owner" && "$state_owner" != "null" ]]; then
      results+=("\"owner\":\"$state_owner\",\"owner_source\":\"state\"")
    fi
  elif [[ -n "${GHSETUP_ORG:-}" ]]; then
    results+=("\"owner\":\"$GHSETUP_ORG\",\"owner_source\":\"env\"")
  else
    # Auto-detect: just report the username
    local gh_username
    gh_username=$(gh api user --jq '.login' 2>/dev/null || echo "")
    if [[ -n "$gh_username" ]]; then
      local user_orgs
      user_orgs=$(gh api user/orgs --jq '[.[].login]' 2>/dev/null || echo "[]")
      results+=("\"owner\":\"auto_detect\",\"username\":\"$gh_username\",\"orgs\":$user_orgs")
    else
      results+=("\"owner\":\"unknown\"")
    fi
  fi

  # Check project state
  if [[ -f "$STATE_FILE" ]]; then
    _read_state
    results+=("\"project\":\"ok\",\"repo\":\"$REPO_FULL\",\"pages_enabled\":$PAGES_ENABLED")
  else
    results+=("\"project\":\"not_initialized\"")
  fi

  # Check gitignore
  if [[ -f ".gitignore" ]]; then
    if grep -q "\.env" .gitignore 2>/dev/null; then
      results+=("\"gitignore\":\"ok\"")
    else
      results+=("\"gitignore\":\"missing_env_rule\"")
      all_ok=false
    fi
  else
    results+=("\"gitignore\":\"missing\"")
    all_ok=false
  fi

  local joined
  joined=$(IFS=,; echo "${results[*]}")
  echo "{\"ok\":$all_ok,$joined}"
}

cmd_branch() {
  local description=""

  while [[ $# -gt 0 ]]; do
    description="$*"
    break
  done

  _require_gh
  _require_git
  _require_auth
  _require_state
  _read_state

  # Derive branch name from description, or generate a timestamped one
  local branch_name
  if [[ -n "$description" ]]; then
    branch_name=$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | sed 's/  */ /g' | sed 's/ /-/g' | cut -c1-50)
    branch_name="${branch_name%-}"  # trim trailing dash
  else
    branch_name="change-$(date +%Y%m%d-%H%M%S)"
  fi

  local parent_branch
  parent_branch=$(_current_branch)
  if [[ -z "$parent_branch" ]]; then
    parent_branch="main"
  fi

  # Check if branch already exists
  if git show-ref --verify --quiet "refs/heads/$branch_name" 2>/dev/null; then
    local suffix
    suffix=$(date +%s | tail -c 5)
    branch_name="${branch_name}-${suffix}"
  fi

  # Check for unsaved changes
  local has_unsaved="false"
  if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    has_unsaved="true"
  fi
  local untracked
  untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$untracked" -gt 0 ]]; then
    has_unsaved="true"
  fi

  if [[ "$has_unsaved" == "true" ]]; then
    echo '{"ok":false,"error":"unsaved_changes","message":"You have unsaved work. Save it first before starting a new change.","parent_branch":"'"$parent_branch"'"}'
    return 1
  fi

  # Create and switch to the new branch
  if ! git checkout -b "$branch_name" 2>/dev/null; then
    echo '{"ok":false,"error":"branch_failed","message":"Could not start a new change. Something went wrong."}'
    return 1
  fi

  # Push the branch so it exists on GitHub
  if ! git push -u origin "$branch_name" -q 2>/dev/null; then
    echo '{"ok":false,"error":"push_failed","message":"Created the change locally but could not upload it. Check your internet connection."}'
    return 1
  fi

  # Store parent branch in state
  _update_state_field ".parent_branch = \"$parent_branch\" | .current_branch = \"$branch_name\""

  echo '{"ok":true,"branch":"'"$branch_name"'","parent_branch":"'"$parent_branch"'","message":"Ready to work on: '"$description"'"}'
}

cmd_pr() {
  local title="${1:-}"

  _require_gh
  _require_git
  _require_auth
  _require_state
  _read_state

  local current
  current=$(_current_branch)

  # Read parent branch from state, fall back to main
  local parent_branch
  parent_branch=$(jq -r '.parent_branch // ""' "$STATE_FILE" 2>/dev/null || echo "")
  if [[ -z "$parent_branch" || "$parent_branch" == "null" ]]; then
    parent_branch="main"
  fi

  # Don't allow PR from the parent branch to itself
  if [[ "$current" == "$parent_branch" ]]; then
    echo '{"ok":false,"error":"no_changes_branch","message":"You are on the base branch. Start a new change first before submitting."}'
    return 1
  fi

  # Save any pending work first
  git add -A
  if ! git diff --cached --quiet 2>/dev/null; then
    if ! _scan_for_secrets; then
      git reset HEAD -- . &>/dev/null
      return 1
    fi
    local msg
    msg=$(_generate_commit_message)
    git commit -q -m "$msg"
    git push -q 2>/dev/null || true
  fi

  # Generate a PR title if not provided
  if [[ -z "$title" ]]; then
    # Use the branch name as a readable title
    title=$(echo "$current" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/')
  fi

  # Check if a PR already exists for this branch
  local existing_pr
  existing_pr=$(gh pr view "$current" --json url --jq '.url' 2>/dev/null || echo "")
  if [[ -n "$existing_pr" ]]; then
    echo '{"ok":true,"already_exists":true,"pr_url":"'"$existing_pr"'","message":"A review request already exists for this change."}'
    return 0
  fi

  # Create the PR
  local pr_output
  if ! pr_output=$(gh pr create \
    --base "$parent_branch" \
    --head "$current" \
    --title "$title" \
    --body "Changes from $current" \
    2>&1); then
    echo '{"ok":false,"error":"pr_failed","message":"Could not submit your changes for review.","details":"'"$(echo "$pr_output" | sed 's/"/\\"/g')"'"}'
    return 1
  fi

  # pr_output should be the PR URL
  local pr_url="$pr_output"

  echo '{"ok":true,"pr_url":"'"$pr_url"'","base":"'"$parent_branch"'","head":"'"$current"'","title":"'"$title"'"}'
}

# ---------------------------------------------------------------------------
# Router
# ---------------------------------------------------------------------------

case "${1:-help}" in
  init)    shift; cmd_init "$@" ;;
  save)    cmd_save "${2:-}" ;;
  deploy)  cmd_deploy ;;
  status)  cmd_status ;;
  collab)  cmd_collab "${2:-add}" "${3:-}" ;;
  doctor)  cmd_doctor ;;
  branch)  shift; cmd_branch "$@" ;;
  pr)      cmd_pr "${2:-}" ;;
  *)
    echo '{"ok":false,"error":"unknown_command","usage":"ghsetup [init|save|deploy|status|collab|doctor|branch|pr]"}'
    exit 1
    ;;
esac
