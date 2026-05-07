# Theta Lake API — Legal Hold Reference

Legal holds preserve records and prevent deletion/modification for legal or compliance purposes.

## Endpoints

### GET /legal_hold — List all legal holds
**Permission:** `legal_hold:read` | **Rate Limit:** medium

### POST /legal_hold — Create a legal hold
**Permission:** `legal_hold:create` | **Rate Limit:** heavy

**Request Body:**
```json
{
  "name": "Investigation 2026-Q1",
  "description": "Records related to Q1 compliance investigation"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Legal hold name |
| `description` | string | No | Description |

### GET /legal_hold/{id} — Get a legal hold
**Permission:** `legal_hold:read` | **Rate Limit:** heavy

### PUT /legal_hold/{id} — Update a legal hold
**Permission:** `legal_hold:update` | **Rate Limit:** heavy

**Request Body:**
```json
{
  "name": "Updated Name",
  "description": "Updated description"
}
```

### GET /legal_hold/{id}/logs — Get legal hold logs
**Permission:** `legal_hold:read` | **Rate Limit:** heavy

Returns activity logs for the legal hold.

### GET /legal_hold/roles — List legal hold roles
**Permission:** `legal_hold:read` | **Rate Limit:** medium

Returns available roles for legal hold assignments. Use the `value` field from the response when creating rules.

## Legal Hold Rules

Rules define which identities are placed under a legal hold, with specific roles.

### GET /legal_hold/{id}/rules — List rules
**Permission:** `legal_hold:read` | **Rate Limit:** medium

**Query Parameters:** `page_token`, `max` (1-100, default 25)

### POST /legal_hold/{id}/rules — Create a rule
**Permission:** `legal_hold:update` | **Rate Limit:** heavy

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
| `identity_id` | integer | Yes | Identity to place under legal hold |
| `roles` | string[] | Yes | Roles from `/legal_hold/roles` endpoint (`value` field). At least 1 required |
| `start_date` | date-time | No | Start date for the hold (RFC3339) |
| `end_date` | date-time | No | End date for the hold (RFC3339) |

### PUT /legal_hold/{id}/rules/{rule_id} — Update a rule
**Permission:** `legal_hold:update` | **Rate Limit:** heavy

Same body as POST (all required fields must be provided).

### DELETE /legal_hold/{id}/rules/{rule_id} — Delete a rule
**Permission:** `legal_hold:delete` | **Rate Limit:** heavy

Returns: `"Identity removed from legal hold rule"`

## Examples

```bash
# List all legal holds
./scripts/tl-curl.sh GET /legal_hold

# Create a legal hold
./scripts/tl-curl.sh POST /legal_hold -d '{"name":"Investigation 2026-Q1","description":"Q1 compliance review"}'

# Get a specific legal hold
./scripts/tl-curl.sh GET /legal_hold/42

# List available roles for rules
./scripts/tl-curl.sh GET /legal_hold/roles

# Add a rule to a legal hold (identity + roles)
./scripts/tl-curl.sh POST /legal_hold/42/rules -d '{"identity_id":2345,"roles":["ALL_RECIPIENT_ROLES"],"start_date":"2024-01-01T00:00:00Z"}'

# Update a rule
./scripts/tl-curl.sh PUT /legal_hold/42/rules/7 -d '{"identity_id":2345,"roles":["ALL_RECIPIENT_ROLES","activemember"]}'

# Delete a rule
./scripts/tl-curl.sh DELETE /legal_hold/42/rules/7
```
