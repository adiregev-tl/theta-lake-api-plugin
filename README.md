# Theta Lake API Plugin for Claude Code

A Claude Code plugin that turns natural-language requests into Theta Lake API
calls. It bundles the Theta Lake OpenAPI 3.0 spec, a curated quick reference
of every endpoint (path, permission, rate-limit class), and an authenticated
`curl` wrapper that supports both static bearer tokens and OAuth
client-credentials (with automatic refresh on `401`).

## What's inside

- A user-invocable skill, `theta-lake-api`, with an instruction file
  (`SKILL.md`) and per-domain reference docs (`cases-api.md`,
  `records-api.md`, `search-api.md`, `workflows-api.md`, `ingestion-api.md`,
  …) plus a `common-patterns.md` covering pagination, errors, and date
  ranges.
- `theta_lake_api_v1.yml` — the full Theta Lake OpenAPI spec (v1.23.0) for
  exact schema lookups.
- `scripts/tl-curl.sh` — authenticated `curl` wrapper. Reads credentials
  from `.env.theta-lake` next to the script, resolves a token (static or
  OAuth), pretty-prints JSON via `jq`, and retries once on `401` after
  refreshing the OAuth token.
- `.env.theta-lake.example` — credentials template.

## Architecture

```
┌────────────────────────────┐
│  Claude Code session       │
│  (skill: theta-lake-api)   │
└──────────────┬─────────────┘
               │ prefers MCP if available
               ├──────────────────────────────► mcp__theta-lake__* tools
               │
               │ falls back to curl
               └──────────────► scripts/tl-curl.sh
                                    │
                                    ├── reads .env.theta-lake
                                    ├── resolves bearer or OAuth token
                                    └── curl → Theta Lake API
```

The skill instructs Claude to:

1. Map the user's intent to candidate endpoints via `api-quick-ref.md`.
2. Read the relevant per-domain reference for parameters and permissions.
3. Compose the call with `./scripts/tl-curl.sh METHOD /endpoint …`.
4. Execute `GET` directly; ask for confirmation before `POST` / `PUT` /
   `PATCH` / `DELETE`.
5. Summarize responses, mention pagination, and explain `403` / `401`
   errors using the bundled permission map.

## Prerequisites

- Claude Code (CLI, desktop, or IDE extension).
- `bash` (3.2+ — the wrapper avoids bash-4-only syntax), `curl`, and `jq`.
- A Theta Lake tenant with API access.

## Installation

### As a marketplace (recommended)

```bash
# In Claude Code:
/plugin marketplace add adiregev-tl/theta-lake-api-plugin
/plugin install theta-lake-api@theta-lake-plugins
```

### Direct from a local clone

```bash
git clone https://github.com/adiregev-tl/theta-lake-api-plugin.git
# Then in Claude Code:
/plugin marketplace add /absolute/path/to/theta-lake-api-plugin
/plugin install theta-lake-api@theta-lake-plugins
```

## Configuration

Copy the template and fill in your credentials:

```bash
cp skills/theta-lake-api/.env.theta-lake.example skills/theta-lake-api/.env.theta-lake
```

`.env.theta-lake` keys:

| Key | Purpose |
|---|---|
| `TL_BASE_URL` | Tenant API root, e.g. `https://your-tenant.thetalake.com/api/v1` |
| `TL_API_TOKEN` | Static bearer token (use this **or** the OAuth trio below) |
| `TL_CLIENT_ID` | OAuth client ID |
| `TL_CLIENT_SECRET` | OAuth client secret |
| `TL_TOKEN_URL` | OAuth token endpoint |

`.env.theta-lake` is gitignored; never commit real credentials.

## Project layout

```
theta-lake-api-plugin/
├── .claude-plugin/
│   ├── plugin.json          # plugin manifest
│   └── marketplace.json     # marketplace manifest (this repo IS a marketplace)
├── skills/
│   └── theta-lake-api/
│       ├── SKILL.md
│       ├── api-quick-ref.md
│       ├── *-api.md         # per-domain reference docs
│       ├── common-patterns.md
│       ├── theta_lake_api_v1.yml
│       ├── .env.theta-lake.example
│       └── scripts/tl-curl.sh
└── README.md
```

## Design notes

- **Prefer MCP over curl.** When the `mcp__theta-lake__*` tools are
  available in the session, the skill uses them — they handle auth,
  pagination, and workspace context automatically and never expose
  tokens. The curl wrapper is the fallback for operations not covered
  by MCP, or when the user explicitly wants a raw HTTP call.
- **Bash 3.2 compatible.** macOS still ships bash 3.2 by default, so
  the wrapper avoids `${var^^}` and other bash-4 idioms.
- **Token refresh is transparent.** On `401`, if OAuth credentials are
  configured the wrapper requests a new token and retries the call
  exactly once.
- **Safety-first writes.** The skill is instructed to confirm before
  any state-changing call (`POST` / `PUT` / `PATCH` / `DELETE`).

## License

MIT (or your preferred license — update before publishing).
