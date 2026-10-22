# Theta Lake API — Legal Matters Reference

Legal matters preserve records and prevent deletion or modification for legal or
compliance purposes.

> **Renamed.** This resource was `/legal_hold` in earlier spec revisions, and its
> sub-resource was `rules`. Both were renamed: `/legal_hold` → `/legal_matters`
> and `rules` → `custodians`. Verified on dev1 (2026-10-22): `GET /api/v1/legal_hold`
> returns 404, `GET /api/v1/legal_matters` returns 200. The payload shapes are
> unchanged, so only the paths and the sub-resource noun differ.
>
> Permission scopes kept the **old** names — `legal_hold:read`, `legal_hold:create`,
> `legal_hold:update`, `legal_hold:delete` — as reported by `/token/context`. The
> spec does not declare per-operation scopes for these endpoints.

## Endpoints

### GET /legal_matters — List all legal matters
**Permission:** `legal_hold:read` | **Query Parameters:** `page_token`, `max`

Response carries `legal_matters` (array) plus `paging`.

### POST /legal_matters — Create a legal matter
**Permission:** `legal_hold:create`

**Request Body:**
```json
{
  "name": "Investigation 2026-Q1",
  "description": "Records related to Q1 compliance investigation"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Legal matter name |
| `description` | string | No | Description |

Response carries `legal_matter`.

### PUT /legal_matters/{id} — Update a legal matter
**Permission:** `legal_hold:update`

Same body as POST.

> There is no `GET /legal_matters/{id}`. The old spec documented a single-item
> GET on `/legal_hold/{id}`; the current spec defines only PUT on this path.
> List and filter via `GET /legal_matters`.

### GET /legal_matters/{id}/logs — Get legal matter logs
**Permission:** `legal_hold:read` | **Query Parameters:** `page_token`, `max`

Returns activity logs for the legal matter.

### GET /legal_matters/roles — List legal matter roles
**Permission:** `legal_hold:read`

Returns the roles available for custodian assignments. Use the `value` field from
the response when creating a custodian.

## Custodians

Custodians define which identities are placed under a legal matter, with specific
roles. This is the resource previously called `rules`.

### GET /legal_matters/{id}/custodians — List custodians
**Permission:** `legal_hold:read` | **Query Parameters:** `page_token`, `max`

### POST /legal_matters/{id}/custodians — Add a custodian
**Permission:** `legal_hold:update`

**Request Body:**
```json
{
  "identity_id": 2345,
  "roles": ["ALL_RECIPIENT_ROLES", "recipient_bcc", "activemember"],
  "start_date": "2021-06-16T01:37:04.262Z",
  "end_date": null
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `identity_id` | integer | Yes | Identity to place under the legal matter |
| `roles` | string[] | Yes | Roles from `/legal_matters/roles` (`value` field). At least 1 required |
| `start_date` | date-time | No | Start date (RFC3339) |
| `end_date` | date-time | No | End date (RFC3339) |

### PUT /legal_matters/{id}/custodians/{custodian_id} — Update a custodian
**Permission:** `legal_hold:update`

Same body as POST; all required fields must be provided.

### DELETE /legal_matters/{id}/custodians/{custodian_id} — Remove a custodian
**Permission:** `legal_hold:delete`

Returns a `result` string.

## Examples

```bash
# List all legal matters
./scripts/tl-curl.sh GET /legal_matters

# Create a legal matter
./scripts/tl-curl.sh POST /legal_matters -d '{"name":"Investigation 2026-Q1","description":"Q1 compliance review"}'

# Update a legal matter
./scripts/tl-curl.sh PUT /legal_matters/42 -d '{"name":"Investigation 2026-Q1 (reopened)"}'

# List available roles for custodians
./scripts/tl-curl.sh GET /legal_matters/roles

# Add a custodian (identity + roles)
./scripts/tl-curl.sh POST /legal_matters/42/custodians -d '{"identity_id":2345,"roles":["ALL_RECIPIENT_ROLES"],"start_date":"2024-01-01T00:00:00Z"}'

# Update a custodian
./scripts/tl-curl.sh PUT /legal_matters/42/custodians/7 -d '{"identity_id":2345,"roles":["ALL_RECIPIENT_ROLES","activemember"]}'

# Remove a custodian
./scripts/tl-curl.sh DELETE /legal_matters/42/custodians/7
```
