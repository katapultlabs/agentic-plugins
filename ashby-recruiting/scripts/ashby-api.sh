#!/usr/bin/env bash
# Ashby API Helper Script
# Usage: bash ashby-api.sh <endpoint> [json-body]
# Example: bash ashby-api.sh candidate.list '{"per_page": 10}'
#
# Requires: ASHBY_API_KEY environment variable
# Get your key at: https://app.ashbyhq.com/admin/api/keys

set -euo pipefail

ASHBY_BASE_URL="https://api.ashbyhq.com"

# Load API key from config file if env var is not set
if [ -z "${ASHBY_API_KEY:-}" ] && [ -f "$HOME/.ashby_api_key" ]; then
  ASHBY_API_KEY="$(cat "$HOME/.ashby_api_key")"
fi

if [ -z "${ASHBY_API_KEY:-}" ]; then
  echo "ERROR: ASHBY_API_KEY is not set and no config file found." >&2
  echo "" >&2
  echo "Option 1 — Write key to config file (persists across shell calls):" >&2
  echo "  echo 'your-api-key-here' > ~/.ashby_api_key && chmod 600 ~/.ashby_api_key" >&2
  echo "" >&2
  echo "Option 2 — Set environment variable (current shell only):" >&2
  echo "  export ASHBY_API_KEY='your-api-key-here'" >&2
  echo "" >&2
  echo "To get your API key:" >&2
  echo "  1. Log into Ashby as an Admin" >&2
  echo "  2. Go to https://app.ashbyhq.com/admin/api/keys" >&2
  echo "  3. Click 'Create API Key'" >&2
  echo "  4. Give it a descriptive name (e.g., 'Claude Cowork Plugin')" >&2
  echo "  5. Grant it the permissions you need (candidatesRead, jobsRead, offersRead, etc.)" >&2
  echo "  6. Copy the key and save it using one of the options above" >&2
  exit 1
fi

ENDPOINT="${1:?Usage: ashby-api.sh <endpoint> [json-body]}"

# Avoid bash brace expansion bug: ${2:-{}} parses as ${2:-{} + literal }
# which produces malformed JSON (e.g., "{}}") when $2 is provided
if [ -n "${2:-}" ]; then
  BODY="$2"
else
  BODY='{}'
fi

curl -s \
  -X POST \
  "${ASHBY_BASE_URL}/${ENDPOINT}" \
  -u "${ASHBY_API_KEY}:" \
  -H "Accept: application/json; version=1" \
  -H "Content-Type: application/json" \
  -d "${BODY}"
