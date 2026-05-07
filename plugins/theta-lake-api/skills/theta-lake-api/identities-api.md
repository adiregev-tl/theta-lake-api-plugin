# Theta Lake API — Identities Reference

Identities represent people tracked across communication platforms. Each identity can have multiple email addresses, phone numbers, and extra attributes, and be associated with supervision spaces.

## Endpoints

### GET /identities — List all identities
**Permission:** `identities:read` | **Rate Limit:** light

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `page_token` | string | Pagination token |
| `max` | integer (1-100, default 25) | Items per page |
| `query` | string | Search across identity fields (`email`, `name`, `phone_number`, `id`, `external_id`) |
| `field_name` | string | Restrict `query` to a specific field: `email`, `external_id`, `id`, `name`, `phone_number` |

### PUT /identities — Merge identities (synchronous)
**Permission:** `identities:update` | **Rate Limit:** heavy

**Request Body:**
```json
{
  "identity_ids": [21, 22, 23],
  "target_identity_id": 20
}
```

Note: May run slowly depending on the number of records associated with the merging identities. An `extra_attribute` is added to the target to indicate each merged identity.

### POST /identities — Create an identity
**Permission:** `identities:create` | **Rate Limit:** light

**Request Body:**
```json
{
  "name": "John Smith",
  "email": "john@company.com",
  "email_start_date": "2024-01-01",
  "email_end_date": null,
  "phone_number": "555-867-5309",
  "phone_number_start_date": "2024-01-01",
  "external_id": "EMP-12345",
  "extra_attributes": [
    { "field": "email", "value": "john.s@personal.com", "source": "csv", "start_date": "2024-01-01" }
  ]
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | Identity name |
| `email` | string | No | Primary email |
| `email_start_date` / `email_end_date` | date | No | Email validity window |
| `phone_number` | string | No | Primary phone |
| `phone_number_start_date` / `phone_number_end_date` | date | No | Phone validity window |
| `external_id` | string | No | External identifier |
| `external_id_start_date` / `external_id_end_date` | date | No | External ID validity window |
| `extra_attributes` | array | No | Additional attributes (field, value, source, dates) |

Returns 409 Conflict if the identity already exists.

### GET /identities/search — Search identities
**Permission:** `identities:read` | **Rate Limit:** light

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `date_type` | string | `created_at` or `updated_at` (default: `updated_at`) |
| `start` | date-time | Inclusive start of range (RFC3339). Defaults to 7 days ago |
| `end` | date-time | Inclusive end of range (RFC3339). Defaults to now |
| `managed` | boolean | If true, only return managed identities (created by API/CSV/AD sync) |
| `page_token` | string | Pagination token |
| `max` | integer (1-500, default 25) | Items per page |

**Note:** If `managed` is false/not provided, the start/end range cannot exceed 7 days.

### GET /identities/{id} — Get identity by ID
**Permission:** `identities:read` | **Rate Limit:** light

### PUT /identities/{id} — Update an identity
**Permission:** `identities:update` | **Rate Limit:** light

**Request Body:**
```json
{
  "name": "John Smith",
  "email": "john.new@company.com",
  "email_start_date": "2024-06-01",
  "phone_number": "555-123-4567",
  "external_id": "EMP-12345"
}
```

### DELETE /identities/{id} — Delete an identity
**Permission:** `identities:delete` | **Rate Limit:** light

**Note:** Identities with connections to records cannot be deleted. Must disconnect first.

### PUT /identities/merge/async — Merge identities (async)
**Permission:** `identities:update` | **Rate Limit:** heavy

**Request Body:**
```json
{
  "identity_ids": [101, 102],
  "target_identity_id": 100,
  "reset_and_reenter_reason": "Change of department - reprocessing needed"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `identity_ids` | int[] | Source identity IDs to merge |
| `target_identity_id` | int | Target identity to merge into |
| `reset_and_reenter_reason` | string (nullable) | If provided, records are reset and reentered through workflow |

Returns 202 Accepted when queued for processing.

### GET /identities/merge/async/{uuid} — Check async merge status
**Permission:** `identities:update` | **Rate Limit:** heavy

Returns merge operation status and result.

## Extra Attributes

Extra attributes are additional email addresses, phone numbers, or other fields for an identity.

### POST /identities/{id}/extra_attributes — Add extra attributes
**Permission:** `identities:update` | **Rate Limit:** heavy

```json
{
  "extra_attributes": [
    { "field": "email", "value": "john.secondary@company.com", "source": "api", "start_date": "2024-01-01" },
    { "field": "phone_number", "value": "555-999-0000" }
  ]
}
```
Max 50 extra attributes per request. Each has: `field`, `value`, `source`, `start_date`, `end_date`.

### PUT /identities/{id}/extra_attributes — Update extra attributes
**Permission:** `identities:update` | **Rate Limit:** heavy

```json
{
  "extra_attributes": [
    { "id": 758170, "field": "email", "value": "updated@company.com" }
  ]
}
```
Max 50 per request. Each must include `id` (the extra attribute ID).

### GET /identities/extra_attributes/{id} — Get extra attribute
**Permission:** `identities:read` | **Rate Limit:** light

### PUT /identities/extra_attributes/{id} — Update extra attribute (single)
**Permission:** `identities:update` | **Rate Limit:** light

```json
{ "field": "email", "value": "new@company.com", "start_date": "2024-01-01", "end_date": null }
```

### DELETE /identities/extra_attributes/{id} — Delete extra attribute
**Permission:** `identities:update` | **Rate Limit:** light

### PUT /identities/extra_attributes/{id}/make_primary — Make primary
**Permission:** `identities:update` | **Rate Limit:** light

Swaps the extra attribute value with the primary value. For example, if identity has email="john@gmail.com" and extra_attribute email="john@company.com", calling this swaps them.

## Supervision Spaces & Risk

### GET /identities/{id}/supervision_spaces — List supervision spaces (beta)
**Permission:** `supervision_spaces:read` | **Rate Limit:** heavy

### GET /identities/{id}/risk — Get risk log
**Permission:** `identities:read` | **Rate Limit:** light

Paginated risk history. Params: `page_token`, `max` (1-100, default 25).

### POST /identities/{id}/risk — Flag identity as risky
**Permission:** `identities:update` | **Rate Limit:** light

```json
{
  "datum_id": 12345,
  "risky": true,
  "comment": "Suspicious communication pattern detected"
}
```

## Examples

```bash
# List identities matching an email
./scripts/tl-curl.sh GET "/identities?query=john@company.com&field_name=email"

# Search identities updated in last 7 days
./scripts/tl-curl.sh GET "/identities/search?date_type=updated_at&max=100"

# Create an identity
./scripts/tl-curl.sh POST /identities -d '{"name":"Jane Smith","email":"jane@company.com","external_id":"EMP-456"}'

# Add extra attributes
./scripts/tl-curl.sh POST /identities/100/extra_attributes -d '{"extra_attributes":[{"field":"email","value":"jane.s@personal.com","source":"api"}]}'

# Merge identities async
./scripts/tl-curl.sh PUT /identities/merge/async -d '{"identity_ids":[101,102],"target_identity_id":100}'

# Flag identity as risky
./scripts/tl-curl.sh POST /identities/100/risk -d '{"risky":true,"comment":"Flagged for review"}'
```
