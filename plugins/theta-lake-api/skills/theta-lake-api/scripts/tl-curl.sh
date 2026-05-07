#!/usr/bin/env bash
# tl-curl.sh — Authenticated curl wrapper for Theta Lake API
# Usage: ./scripts/tl-curl.sh METHOD /endpoint [extra-curl-args...]
# Examples:
#   ./scripts/tl-curl.sh GET /token/context
#   ./scripts/tl-curl.sh POST /search/records -d '{"range":{"days":7}}'
#   ./scripts/tl-curl.sh PUT /cases/123 -d '{"name":"Updated"}'

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env.theta-lake"

# --- Load credentials ---
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: $ENV_FILE not found. Copy the template and fill in your credentials." >&2
  exit 1
fi

set -a
source "$ENV_FILE"
set +a

if [[ -z "${TL_BASE_URL:-}" ]]; then
  echo "Error: TL_BASE_URL is not set in $ENV_FILE" >&2
  exit 1
fi

# --- Parse arguments ---
if [[ $# -lt 2 ]]; then
  echo "Usage: tl-curl.sh METHOD /endpoint [extra-curl-args...]" >&2
  echo "  METHOD: GET, POST, PUT, DELETE, PATCH" >&2
  echo "  /endpoint: API path (e.g., /token/context)" >&2
  exit 1
fi

METHOD=$(printf '%s' "$1" | tr '[:lower:]' '[:upper:]')
ENDPOINT="$2"
shift 2

# Strip leading slash if base URL ends with one
BASE_URL="${TL_BASE_URL%/}"
ENDPOINT="/${ENDPOINT#/}"
URL="${BASE_URL}${ENDPOINT}"

# --- Resolve auth token ---
get_token() {
  if [[ -n "${TL_API_TOKEN:-}" ]]; then
    echo "$TL_API_TOKEN"
    return
  fi

  if [[ -n "${TL_CLIENT_ID:-}" && -n "${TL_CLIENT_SECRET:-}" && -n "${TL_TOKEN_URL:-}" ]]; then
    local token_response
    token_response=$(curl -sS -X POST "$TL_TOKEN_URL" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "grant_type=client_credentials&client_id=${TL_CLIENT_ID}&client_secret=${TL_CLIENT_SECRET}")

    local token
    token=$(echo "$token_response" | jq -r '.access_token // empty')
    if [[ -z "$token" ]]; then
      echo "Error: Failed to obtain OAuth token. Response: $token_response" >&2
      return 1
    fi
    echo "$token"
    return
  fi

  echo "Error: No auth credentials configured. Set TL_API_TOKEN or TL_CLIENT_ID + TL_CLIENT_SECRET + TL_TOKEN_URL in $ENV_FILE" >&2
  return 1
}

TOKEN=$(get_token) || exit 1

# --- Build curl command ---
CURL_ARGS=(
  -sS
  -X "$METHOD"
  -H "Authorization: Bearer $TOKEN"
  -H "Content-Type: application/json"
  -H "Accept: application/json"
)

# --- Execute request ---
execute_request() {
  local response http_code body
  response=$(curl -w "\n%{http_code}" "${CURL_ARGS[@]}" "$@" "$URL")
  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')

  echo "$body" | jq . 2>/dev/null || echo "$body"

  if [[ "$http_code" -ge 400 ]]; then
    echo "--- HTTP $http_code ---" >&2
    return 1
  fi
}

# First attempt
if ! execute_request "$@" 2>/tmp/tl-curl-stderr; then
  stderr_output=$(cat /tmp/tl-curl-stderr)

  # If 401 and we have OAuth creds, try refreshing token
  if echo "$stderr_output" | grep -q "HTTP 401" && [[ -n "${TL_CLIENT_ID:-}" && -n "${TL_CLIENT_SECRET:-}" && -n "${TL_TOKEN_URL:-}" ]]; then
    echo "Token expired, refreshing..." >&2
    TL_API_TOKEN=""
    TOKEN=$(get_token) || exit 1
    CURL_ARGS[4]="Authorization: Bearer $TOKEN"
    execute_request "$@" 2>&1
  else
    echo "$stderr_output" >&2
    exit 1
  fi
fi

rm -f /tmp/tl-curl-stderr
