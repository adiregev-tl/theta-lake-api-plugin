# Theta Lake API — Common Patterns

## Standard Response Envelope

Every response includes:
```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  ...resource fields...
}
```

Always save `request_id` for support tickets on 500 errors.

## Pagination

### Token-Based Pagination
Most list endpoints use token-based pagination:

**Request parameters:**
- `page_token` (string) — Token from previous response's `paging` object
- `max` (integer) — Items per page (default: 25, max varies by endpoint)

**Response paging object:**
```json
{
  "paging": {
    "prev_page_token": null,        // null if no previous page
    "next_page_token": "eyJ..."     // null if no next page, base64-encoded
  }
}
```

**Notes:**
- Some endpoints don't support `prev_page_token` (audit_logs, search)
- Tokens are base64-encoded and have an expiry time
- Pass the token value as-is to the next request

**Example: Paginating through cases**
```bash
# First page
./scripts/tl-curl.sh GET "/cases?max=50"

# Next page (using next_page_token from response)
./scripts/tl-curl.sh GET "/cases?max=50&page_token=eyJjdXJy..."
```

## Rate Limits

Three tiers, from most to least permissive:
| Tier | Description | Typical Use |
|------|-------------|-------------|
| `light` | Highest throughput | Ingestion endpoints |
| `medium` | Standard throughput | Most CRUD operations |
| `heavy` | Lowest throughput | Search, audit logs, analysis, retention |

**Dynamic rate limiting** applies to search with `content` queries — the system adjusts limits based on the date range and content complexity.

When you hit a 429:
```json
{
  "status_code": 429,
  "status_string": "Too Many Requests",
  "request_id": "uuid",
  "message": "Too many requests for the route"
}
```

Best practice: Implement exponential backoff. Check response headers for retry-after hints.

## Date Formats

| Format | Used For | Example |
|--------|----------|---------|
| RFC3339 date-time | Timestamps, date ranges | `2024-01-15T14:30:00.000Z` |
| RFC3339 full-date | Date-only filters | `2024-01-15` |

- All dates in ranges are **inclusive** (both start and end)
- Dates default to UTC
- Search default range: last 7 days from current date (if no range specified)

## Error Responses

All errors follow the same structure:
```json
{
  "status_code": 400,
  "status_string": "Bad Request",
  "request_id": "uuid",
  "message": "Human readable error message"
}
```

| Code | Name | Common Cause |
|------|------|-------------|
| 400 | Bad Request | Missing/malformed body or query parameter |
| 401 | Unauthorized | Missing, expired, or malformed token |
| 403 | Forbidden | Token lacks required permission scope |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Resource already exists (e.g., duplicate identity) |
| 415 | Unsupported Media Type | File type not supported for ingestion |
| 422 | Unprocessable Entity | Bad CSV upload, expired search context |
| 423 | Locked | Resource is currently locked |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server bug — include `request_id` in support ticket |
| 503 | Service Unavailable | Temporary outage |

## Org Unit Switching

Some tokens have access to multiple org units. The current org unit determines which data is visible.

```bash
# See current org unit
./scripts/tl-curl.sh GET /org_units/current

# List available org units
./scripts/tl-curl.sh GET /org_units

# Switch to a different org unit
./scripts/tl-curl.sh PUT /org_units/5/switch
```

After switching, all subsequent API calls operate in the context of the new org unit. Returns 403 if the user isn't a member of the target org unit.

## Content Sources

Common content source identifiers used in search and records:
- `microsoft_teams`, `webex_meetings_ecomms`, `zoom`, `slack`
- `ringcentral`, `symphony`, `bloomberg`, `ice_chat`
- `linkedin`, `whatsapp`, `smarsh`
- And many more platform-specific identifiers

## Media Types

Records are classified into media types:
- `audio` — Phone calls, voice recordings
- `chat` — IM, messaging conversations
- `document` — Files, PDFs, documents
- `email` — Email messages (.eml)
- `video` — Video calls, recordings
- `other` — Everything else

## Risk Levels

Records are analyzed and assigned a risk level:
- `low` — No significant risk detected
- `slight` — Minor risk indicators
- `medium` — Moderate risk
- `high` — Significant risk detected
- `not_analyzed` — Not yet analyzed (only returned alone, not combined with other levels)
