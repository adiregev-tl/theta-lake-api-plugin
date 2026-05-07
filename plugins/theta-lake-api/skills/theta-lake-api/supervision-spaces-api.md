# Theta Lake API — Supervision Spaces Reference

Supervision spaces define the scope of monitoring — which participants/users are monitored, which policies apply, and which workflows process their records.

## Endpoints

### GET /supervision_spaces — List all
**Permission:** `supervision_spaces:read` | **Rate Limit:** heavy

**Query Parameters:** `page_token`, `max` (1-500, default 25)

### POST /supervision_spaces — Create
**Permission:** `supervision_spaces:create` | **Rate Limit:** heavy

**Request Body:**
```json
{
  "name": "Sales Team Monitoring",
  "description": "Monitor all sales team communications",
  "all_participants": false,
  "all_users": false,
  "directory_group_ids": [1988, 1997],
  "integration_ids": [5, 8],
  "media_type_ids": [1, 2, 3],
  "retention_library_ids": [10],
  "external_id": "sales-monitoring-001",
  "hard_enforce": false,
  "supervision_space_priority": 1
}
```

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Space name |
| `description` | string | Description |
| `all_participants` | boolean | Include all org participants (only one space can have this enabled) |
| `all_users` | boolean | Include all org users |
| `directory_group_ids` | int[] | Directory group IDs to associate |
| `integration_ids` | int[] | Integration IDs to associate |
| `media_type_ids` | int[] | 1=Video, 2=Audio, 3=Chat, 4=Attachment, 5=Email |
| `retention_library_ids` | int[] | Retention library IDs |
| `external_id` | string | External identifier |
| `hard_enforce` | boolean | Hard enforcement flag |
| `supervision_space_priority` | integer | Priority level |

### GET /supervision_spaces/{id} — Get by ID
**Permission:** `supervision_spaces:read` | **Rate Limit:** heavy

Returns detailed supervision space including all associations.

### PUT /supervision_spaces/{id} — Update
**Permission:** `supervision_spaces:update` | **Rate Limit:** heavy

Same body as POST (all fields optional).

### DELETE /supervision_spaces/{id} — Delete
**Permission:** `supervision_spaces:delete` | **Rate Limit:** heavy

## Directory Groups

### POST /supervision_spaces/{id}/directory_groups — Add
**Permission:** `supervision_spaces:update` | **Rate Limit:** heavy

Body is a plain array of directory group IDs:
```json
[1988, 1997]
```

### DELETE /supervision_spaces/{id}/directory_groups — Remove
**Permission:** `supervision_spaces:update` | **Rate Limit:** heavy

Body is a plain array of directory group IDs:
```json
[1988]
```

## Identities

### POST /supervision_spaces/{id}/identities — Add
**Permission:** `supervision_spaces:update` | **Rate Limit:** heavy

Body is a plain array of identity IDs (max 500):
```json
[302, 304, 305]
```

## Participants

### POST /supervision_spaces/{id}/participants — Add
**Permission:** `supervision_spaces:update` | **Rate Limit:** heavy

Uses a semi-CSV format in `participants_text`:
```json
{
  "participants_text": "johnsmith@example.com\nBob Jones, bob@example.com\nJames K Anderson, james@example.com, 123-333-4567\n"
}
```

Each line can contain any combination of: name, email, phone number. The system searches for matching identities — if found, adds them; if not found, creates new identities.

### DELETE /supervision_spaces/{id}/participants — Remove
**Permission:** `supervision_spaces:update` | **Rate Limit:** heavy
```json
{
  "identity_ids": [5647, 31973]
}
```

## User Groups

### POST /supervision_spaces/{id}/user_groups — Add
**Permission:** `supervision_spaces:update` | **Rate Limit:** heavy

Body is a plain array of user group IDs:
```json
[75, 84]
```

### DELETE /supervision_spaces/{id}/user_groups — Remove
**Permission:** `supervision_spaces:update` | **Rate Limit:** heavy
```json
[75]
```

## Users

### POST /supervision_spaces/{id}/users — Add
**Permission:** `supervision_spaces:update` | **Rate Limit:** heavy

Body is a plain array of user IDs:
```json
[24, 422, 404]
```

### DELETE /supervision_spaces/{id}/users — Remove
**Permission:** `supervision_spaces:update` | **Rate Limit:** heavy
```json
[24]
```

## Examples

```bash
# List all supervision spaces
./scripts/tl-curl.sh GET "/supervision_spaces?max=100"

# Create a supervision space
./scripts/tl-curl.sh POST /supervision_spaces -d '{"name":"Sales Monitoring","description":"Monitor sales team","all_participants":false,"media_type_ids":[1,2,3]}'

# Add participants (semi-CSV format)
./scripts/tl-curl.sh POST /supervision_spaces/5/participants -d '{"participants_text":"john@company.com\nJane Smith, jane@company.com\n"}'

# Add identities (max 500)
./scripts/tl-curl.sh POST /supervision_spaces/5/identities -d '[302, 304, 305]'

# Add directory groups
./scripts/tl-curl.sh POST /supervision_spaces/5/directory_groups -d '[1988, 1997]'

# Remove participants by identity IDs
./scripts/tl-curl.sh DELETE /supervision_spaces/5/participants -d '{"identity_ids":[5647]}'
```
