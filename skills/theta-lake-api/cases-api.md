# Theta Lake API — Cases Reference

Cases allow grouping records together for investigation or review purposes.

## Endpoints

### GET /cases — List all cases
**Permission:** `cases:read` | **Rate Limit:** heavy

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page_token` | string | — | Pagination token |
| `max` | integer (1-100) | 25 | Items per page |

**Response:** `cases[]` array with pagination.

### POST /cases — Create a case
**Permission:** `cases:create` | **Rate Limit:** heavy

**Request Body:**
```json
{
  "name": "Investigation Q1-2026",
  "description": "Quarterly compliance review",
  "number": "Case-2026-01-15",
  "open_date": "2026-01-15T00:00:00.000Z",
  "visibility": "PUBLIC"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Case name |
| `description` | string | No | Case description |
| `number` | string | No | Unique case identifier/number |
| `open_date` | date-time | No | When the case was opened (RFC3339) |
| `visibility` | string | No | `PUBLIC` or `PRIVATE` |

### GET /cases/{id} — Get a case
**Permission:** `cases:read` | **Rate Limit:** heavy

### PUT /cases/{id} — Update a case
**Permission:** `cases:create` | **Rate Limit:** heavy

Same body as POST (all fields optional for update).

### POST /cases/{id}/records — Add records to a case
**Permission:** `cases:add_records` | **Rate Limit:** heavy

**Request Body:**
```json
{
  "ids": [12345, 67890]
}
```
- Max 100 record IDs per request

### DELETE /cases/{id}/records — Remove records from a case
**Permission:** `cases:remove_records` | **Rate Limit:** heavy

**Request Body:**
```json
{
  "ids": [12345, 67890]
}
```
- Max 100 record IDs per request

### PUT /cases/{id}/managers — Add manager to case
**Permission:** `cases:update` | **Rate Limit:** medium

**Request Body:**
```json
{
  "user_id": 42
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | integer | Yes | ID of the user to add as a case manager |

### DELETE /cases/{id}/managers/{user_id} — Remove manager from case
**Permission:** `cases:update` | **Rate Limit:** medium

Removes the specified user from the case's manager list.

### PUT /cases/{id}/close — Close a case
**Permission:** `cases:update` | **Rate Limit:** heavy

**Request Body:**
```json
{
  "close_date": "2026-01-31T23:59:59.000Z"
}
```
Closes the case (does not delete it).

### PUT /cases/{id}/open — Reopen a case
**Permission:** `cases:update` | **Rate Limit:** heavy

No body required. Reopens a previously closed case.

## Case Object

```json
{
  "id": 271,
  "name": "Investigation Q1",
  "description": "Quarterly review",
  "number": "Case-2026-01-15",
  "status": "open",
  "visibility": "PUBLIC",
  "open_date": "2026-01-15T00:00:00.000Z",
  "close_date": null,
  "created_at": "2026-01-15T10:00:00.000Z",
  "updated_at": "2026-01-20T15:30:00.000Z"
}
```

## Examples

```bash
# List open cases
./scripts/tl-curl.sh GET "/cases?max=50"

# Create a case
./scripts/tl-curl.sh POST /cases -d '{"name":"Q1 Review","description":"Quarterly compliance review","visibility":"PUBLIC"}'

# Add records to case 271
./scripts/tl-curl.sh POST /cases/271/records -d '{"ids":[12345,67890]}'

# Add user 42 as a manager of case 271
./scripts/tl-curl.sh PUT /cases/271/managers -d '{"user_id":42}'

# Remove user 42 as a manager from case 271
./scripts/tl-curl.sh DELETE /cases/271/managers/42

# Close case 271
./scripts/tl-curl.sh PUT /cases/271/close -d '{"close_date":"2026-01-31T23:59:59.000Z"}'

# Reopen case 271
./scripts/tl-curl.sh PUT /cases/271/open
```
