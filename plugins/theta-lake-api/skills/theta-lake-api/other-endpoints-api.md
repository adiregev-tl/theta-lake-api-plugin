# Theta Lake API — Other Endpoints Reference

This file covers: Labels, Integrations, Retention Libraries, Reviews, Reconciliation, Storage Accounts, Org Units, Audit Logs, Analysis, Directory Groups.

> **Records** endpoints have been moved to their own file — see [`records-api.md`](records-api.md).

---

## Analysis

### Policies

#### GET /analysis/policies — List all policies
**Permission:** `policies:read` | **Rate Limit:** heavy

Returns all analysis policies.

#### GET /analysis/policies/{id} — Get policy by ID
**Permission:** `policies:read` | **Rate Limit:** heavy

Returns policy with detection rules and SWRV rules.

#### GET /analysis/policy_hits — List all policy hits
**Permission:** `analysis:read` | **Rate Limit:** medium

Returns all policy hit types (used for filtering in search).

### Detection Rules

#### GET /analysis/detection_rules — List all detection rules
**Permission:** `analysis:read` | **Rate Limit:** medium

**Query Parameters:** `page_token`, `max` (1-100, default 25)

Returns a paginated list of detection rules (summary view).

**`detection_rule` object (list):**
| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Detection rule ID |
| `name` | string | Detection rule name |
| `description` | string | Description of the detection rule |
| `accepts_input` | boolean | Whether the rule accepts custom input |
| `created_at` | date-time | Creation timestamp (RFC3339) |
| `updated_at` | date-time | Last update timestamp (RFC3339) |
| `disabled_at` | date-time | Disabled timestamp (RFC3339), if disabled |

#### GET /analysis/detection_rules/{id} — Get detection rule by ID
**Permission:** `analysis:read` | **Rate Limit:** medium

Returns full details for a single detection rule, including configuration and rules.

**`detection_rule` object (detail):**
| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Detection rule ID |
| `name` | string | Detection rule name |
| `description` | string | Description |
| `accepts_input` | boolean | Whether the rule accepts custom input |
| `attachments_enabled` | boolean | Whether the rule applies to attachments |
| `boilerplate_enabled` | boolean | Whether the boilerplate classifier is enabled |
| `chatroom_name_analyzed` | boolean | Whether the rule applies to chatroom names |
| `communication_direction` | enum (nullable) | Direction to apply rule: `inbound`, `outbound`, or `null` (all directions) |
| `count_proximity_by_characters` | boolean | If `true`, proximity term uses characters; if `false`, uses words |
| `email_smart_body` | boolean | Whether the rule uses smart body analysis for emails |
| `email_subject_analyzed` | boolean | Whether the rule applies to email subjects |
| `filename_analyzed` | boolean | Whether the rule applies to filenames |
| `max_participants` | integer (nullable) | Max participants the rule applies to. `null` = no limit |
| `min_num_rules_with_hits` | integer (nullable) | Min rule hits required to create a policy hit. `null` = no minimum |
| `rules` | object | Key-value pairs of rule ID → rule pattern (the lexicon) |
| `rule_scope` | enum | Scope: `screen` (video/audio only), `spoken`, `image`, or `both` |
| `created_at` | date-time | Creation timestamp (RFC3339) |
| `updated_at` | date-time | Last update timestamp (RFC3339) |
| `disabled_at` | date-time | Disabled timestamp (RFC3339), if disabled |

#### GET /analysis/detection_rules/{id}/stats — Detection rule stats (beta)
**Permission:** `analysis:read_stats` | **Rate Limit:** heavy

Returns stats for a detection rule over a date range.

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `start` | date-time | Yes | Inclusive start of date range (RFC3339) |
| `end` | date-time | Yes | Inclusive end of date range (RFC3339) |

**Response:**
```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "...",
  "stats": {
    "false_negatives_reported": 3,
    "false_positives_reported": 12,
    "total_analyzed_records": 50000,
    "total_analyzed_records_by_media_type": {
      "audio": 5000,
      "chat": 30000,
      "document": 5000,
      "email": 8000,
      "video": 2000
    },
    "total_analyzed_records_with_hits": 150,
    "total_analyzed_records_with_hits_by_media_type": {
      "audio": 10,
      "chat": 100,
      "document": 15,
      "email": 20,
      "video": 5
    },
    "total_analyzed_records_with_hits_by_rule": {
      "hits": 150,
      "rule": "\\b\\d{3}-\\d{2}-\\d{4}\\b"
    },
    "true_positives_reported": 45
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `stats.false_negatives_reported` | integer | Times a record should have hit but didn't |
| `stats.false_positives_reported` | integer | Times a record should not have triggered a hit |
| `stats.total_analyzed_records` | integer | Records analyzed in the date range |
| `stats.total_analyzed_records_by_media_type` | object | Breakdown by media type (audio, chat, document, email, video) |
| `stats.total_analyzed_records_with_hits` | integer | Records that had hits for this detection rule |
| `stats.total_analyzed_records_with_hits_by_media_type` | object | Hits breakdown by media type |
| `stats.total_analyzed_records_with_hits_by_rule` | object | `hits` count + `rule` pattern string |
| `stats.true_positives_reported` | integer | Times customer flagged a detection as "Confirmed Risk" |

### Custom Detection Rule Inputs

Custom detection rule inputs are model files uploaded for custom detection rules. Only 1 input can be active per detection rule at a time.

#### GET /analysis/inputs — List all custom detection rule inputs
**Permission:** `analysis:read` | **Rate Limit:** medium

**Query Parameters:** `page_token`, `max` (1-100, default 25)

Returns paginated list of all inputs across all detection rules.

#### GET /analysis/detection_rules/{id}/inputs — List inputs for a detection rule
**Permission:** `analysis:read` | **Rate Limit:** medium

Returns all inputs for the specified detection rule.

#### GET /analysis/detection_rules/{id}/inputs/{input-id} — Get input by ID
**Permission:** `analysis:read` | **Rate Limit:** medium

Returns a single input with its detection rule details.

#### GET /analysis/detection_rules/{id}/inputs/{input-id}/download — Download input
**Permission:** `analysis:read` | **Rate Limit:** heavy

Returns the input file as binary (`application/octet-stream`).

#### POST /analysis/detection_rules/{id}/inputs — Upload input
**Permission:** `analysis:create` | **Rate Limit:** heavy

**Content-Type:** `multipart/form-data`
- `meta`: JSON object with `name` (string) — the name of the input
- `file`: Binary file — the input for the model

#### PUT /analysis/detection_rules/{id}/inputs/{input-id}/activate — Activate input
**Permission:** `analysis:update` | **Rate Limit:** heavy

> **Note:** Only 1 detection rule input can be active at any point. Setting input to active will set all other inputs for this detection rule to inactive.

#### PUT /analysis/detection_rules/{id}/inputs/{input-id}/deactivate — Deactivate input
**Permission:** `analysis:update` | **Rate Limit:** heavy

#### DELETE /analysis/detection_rules/{id}/inputs/{input-id} — Delete input
**Permission:** `analysis:delete` | **Rate Limit:** heavy

**Response:** `{ ..., "result": "message indicating action was successful" }`

### `input` Object (shared response schema)

The GET, POST, PUT (activate/deactivate) endpoints all return an `input` object:

```json
{
  "input": {
    "id": 25,
    "created_at": "2025-01-15T10:00:00.000Z",
    "updated_at": "2025-06-01T14:30:00.000Z",
    "active": true,
    "name": "My Custom Model v2",
    "detection_rule": {
      "accepts_input": true,
      "created_at": "2024-03-13T18:54:09.000Z",
      "description": "Custom keyword detection",
      "disabled_at": null,
      "name": "Custom Keywords Rule",
      "id": 1235,
      "updated_at": "2025-01-10T12:00:00.000Z"
    }
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Model input ID |
| `created_at` | date-time | Creation timestamp (RFC3339) |
| `updated_at` | date-time | Last update timestamp (RFC3339) |
| `active` | boolean | Whether this input is actively being used for the detection rule |
| `name` | string | Name of the input |
| `detection_rule.accepts_input` | boolean | Whether the detection rule accepts custom input |
| `detection_rule.created_at` | date-time | Detection rule creation timestamp |
| `detection_rule.description` | string | Description of the detection rule |
| `detection_rule.disabled_at` | date-time (nullable) | When the detection rule was disabled |
| `detection_rule.name` | string | Name of the detection rule |
| `detection_rule.id` | integer | Detection rule ID |
| `detection_rule.updated_at` | date-time | Detection rule last update timestamp |

---

## Audit Logs

### GET /audit_logs — List audit logs
**Permission:** `audit_log:read` | **Rate Limit:** heavy

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `user_id` | integer | Filter by user |
| `auditable_type` | string | Filter by type (see enum in spec) |
| `from_date` | date | Start date (default: 7 days ago) |
| `to_date` | date | End date (default: now) |
| `auditable_action` | string | Filter by action |
| `order` | string | `asc` or `desc` (default: desc) |
| `page_token` | string | Pagination (no prev pages) |
| `max` | integer (1-500) | Items per page (default: 25) |

### GET /audit_logs/config_change — Config change logs
**Permission:** `audit_log:read` | **Rate Limit:** heavy

Same params as above (date filters + pagination).

### POST /audit_logs/search — Search audit logs
**Permission:** `audit_log:read` | **Rate Limit:** heavy

**Query Parameters:** `page_token` (60s expiry), `max` (1-500, default 25)

```json
{
  "auditable_action": ["create", "update"],
  "auditable_type": ["Case", "Identity"],
  "range": {
    "start": "2024-01-01T00:00:00.000Z",
    "end": "2024-12-31T23:59:59.999Z"
  },
  "source": {
    "type": "user",
    "user_id": [92]
  },
  "order": "desc"
}
```

---

## Directory Groups

### GET /directory_groups — List all
**Permission:** `directory_group:read` | **Rate Limit:** light

**Query Parameters:** `page_token`, `max`, `include_identities` (bool, default true)

### POST /directory_groups — Create
**Permission:** `directory_group:create` | **Rate Limit:** light
```json
{ "name": "UK Support Team", "external_id": "uk-support", "description": "UK support staff" }
```

### GET /directory_groups/{id} — Get by ID
**Permission:** `directory_group:read` | **Rate Limit:** light

**Query Parameters:** `include_identities` (bool)

### PUT /directory_groups/{id} — Update
**Permission:** `directory_group:update` | **Rate Limit:** light
```json
{ "name": "Updated Name", "external_id": "new-id", "description": "Updated" }
```

### DELETE /directory_groups/{id} — Delete
**Permission:** `directory_group:delete` | **Rate Limit:** light

### POST /directory_groups/{id}/identities — Bulk-add identities
**Permission:** `directory_group:update` | **Rate Limit:** light

Body is a plain array of identity IDs:
```json
[100, 101, 102]
```

### GET /directory_groups/{id}/identities — List identities
**Permission:** `directory_group:read` | **Rate Limit:** light

**Query Parameters:** `page_token`, `max`

### POST /directory_groups/{id}/identity — Create new identity in group
**Permission:** `directory_group:update` | **Rate Limit:** light
```json
{ "name": "Jane Smith", "email": "jane@company.com", "phone_number": "555-123-4567", "external_id": "EMP-456" }
```

### DELETE /directory_groups/{id}/identity/{identity_id} — Remove identity
**Permission:** `directory_group:update` | **Rate Limit:** light

### POST /directory_groups/upload — Upload CSV
**Permission:** `directory_group:update` | **Rate Limit:** light

**Content-Type:** `multipart/form-data`
- `file`: CSV file with identity data

---

## Integrations

### GET /integrations — List all integrations
**Permission:** `integrations:read` | **Rate Limit:** heavy

### GET /integrations/{id} — Get integration by ID
**Permission:** `integrations:read` | **Rate Limit:** heavy

Returns detailed integration info including configuration.

### GET /integrations/{id}/run_history — Run history
**Permission:** `integrations:read` | **Rate Limit:** heavy

**Query Parameters:** `start` (date-time), `end` (date-time), `page_token`, `max` (1-100, default 25)

Defaults to last 7 days.

### GET /integrations/user_installs — User install status
**Permission:** `integrations:read` | **Rate Limit:** minimal

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `integration_type` | string | Yes | Integration type (enum: `ms_teams`) |
| `tenant_id` | string | Yes | Integration's tenant ID |
| `account_user_id` | string | No | Account user ID to lookup |
| `email` | string | No | Email address to lookup |

### GET /integrations/{id}/installed_users — Installed users
**Permission:** `integrations:read` | **Rate Limit:** heavy

**Query Parameters:** `page_token`, `max` (1-100, default 25)

---

## Labels

### GET /labels — List all labels
**Permission:** `labels:read` | **Rate Limit:** heavy

### POST /labels — Create a label
**Permission:** `labels:create` | **Rate Limit:** heavy
```json
{
  "short_name": "Important",
  "long_name": "This is an important label for flagged records",
  "background_color": "#FFC906",
  "hidden": false
}
```

| Field | Type | Description |
|-------|------|-------------|
| `short_name` | string | Label name shown on records |
| `long_name` | string | Label description |
| `background_color` | string | RGB hex color (e.g. `#FFC906`) |
| `hidden` | boolean | Whether label is hidden in UI |

### GET /labels/{id} — Get by ID
**Permission:** `labels:read` | **Rate Limit:** heavy

### PUT /labels/{id} — Update
**Permission:** `labels:update` | **Rate Limit:** heavy
```json
{ "short_name": "Critical", "background_color": "#CC0000" }
```

### DELETE /labels/{id} — Delete
**Permission:** `labels:delete` | **Rate Limit:** heavy

### POST /labels/{label_id}/records/{record_id} — Apply label to record
**Permission:** `labels:use` | **Rate Limit:** heavy

No body required.

### DELETE /labels/{label_id}/records/{record_id} — Remove label from record
**Permission:** `labels:use` | **Rate Limit:** heavy

No body required.

---

## Org Units

### GET /org_units — List all org units
**Permission:** `org_units:read` | **Rate Limit:** heavy

### GET /org_units/current — Get current org unit
**Permission:** `org_units:read` | **Rate Limit:** heavy

### GET /org_units/{id} — Get by ID
**Permission:** `org_units:read` | **Rate Limit:** heavy

### PUT /org_units/{id} — Update
**Permission:** `org_units:update` | **Rate Limit:** heavy

```json
{
  "allow_anonymous_via_shared_links": false,
  "analysis_supervision_space_ids": [1, 2, 3],
  "audit_log_retention_period": null,
  "default_org_timezone": "Etc/UTC",
  "delete_on_expiration": true,
  "fallback_language": "en",
  "preferred_languages": ["en", "es"],
  "use_name_matcher": true,
  "use_owner_only_space_matcher": false
}
```

| Field | Type | Description |
|-------|------|-------------|
| `allow_anonymous_via_shared_links` | boolean | Allow public record sharing |
| `analysis_supervision_space_ids` | int[] | Supervision spaces for risky behavior analysis |
| `audit_log_retention_period` | integer (nullable) | Audit log retention duration |
| `default_org_timezone` | string | Default timezone (e.g. `Etc/UTC`) |
| `delete_on_expiration` | boolean | Delete records when they expire from archive |
| `fallback_language` | string | Fallback language if not in preferred list |
| `preferred_languages` | string[] | Preferred language list |
| `use_name_matcher` | boolean | Use names in identity matching |
| `use_owner_only_space_matcher` | boolean | Stop matching after owner, fallback to default |

### PUT /org_units/{id}/switch — Switch to org unit
**Permission:** none | **Rate Limit:** heavy

Changes the active org unit for subsequent API calls. Returns 403 `ForbiddenOrgChange` if user isn't a member.

---

## Reconciliation

### POST /reconciliation — Reconcile records
**Permission:** `reconciliation:read` | **Rate Limit:** medium

```json
{
  "range": {
    "type": "upload_date",
    "start": "2024-01-08T00:00:00.000Z",
    "end": "2024-01-15T00:00:00.000Z"
  },
  "queries": [
    {
      "platform": "microsoft_teams",
      "attribute": {
        "name": "channel_conversation_id",
        "value": "DEBA5748-A73A-47BB-A2B9-5F05DC24E76F"
      },
      "media_types": ["chat", "audio"],
      "integration_id": 1579,
      "includes_timestamp": "2024-01-10T14:00:00.000Z"
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `range` | object (nullable) | Date range (max 7 days). `type`: `create_date`/`upload_date` (default). Defaults to last 7 days |
| `queries` | array (max 500) | Reconciliation queries |
| `queries[].platform` | string (required) | Third party platform (e.g. `microsoft_teams`) |
| `queries[].attribute` | object (required) | `name` + `value` of platform attribute |
| `queries[].media_types` | string[] | Filter: audio, chat, document, email, other, video (OR) |
| `queries[].integration_id` | integer | Filter to specific integration |
| `queries[].includes_timestamp` | date-time | Records containing this timestamp |

### POST /reconciliation/count — Count records by platform
**Permission:** `reconciliation:read` | **Rate Limit:** medium

```json
{
  "platform": "microsoft_teams",
  "integration_id": 1579,
  "start": "2024-01-01T00:00:00.000Z",
  "end": "2024-01-15T00:00:00.000Z",
  "type": "upload_date"
}
```

---

## Retention Libraries

### GET /retention_libraries — List all
**Permission:** `retention_libraries:read` | **Rate Limit:** heavy

### POST /retention_libraries — Create
**Permission:** `retention_libraries:create` | **Rate Limit:** heavy
```json
{
  "name": "7-Year Retention",
  "storage_account_id": 1,
  "description": "Long-term compliance archive",
  "external_id": "123456-ABC",
  "sec_compliant_storage_enabled": false,
  "retention_period_enabled": true,
  "retention_period_days": 2555,
  "retain_in_review": true
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Retention library name |
| `storage_account_id` | integer | Yes | Storage account ID |
| `description` | string | No | Description |
| `external_id` | string | No | External identifier |
| `sec_compliant_storage_enabled` | boolean | No | SEC Rule 17a-4 compliance |
| `retention_period_enabled` | boolean | No | Enable retention period policy |
| `retention_period_days` | integer | No | Retention period in days |
| `retain_in_review` | boolean | No | Retain while review is open |

### GET /retention_libraries/{id} — Get by ID
**Permission:** `retention_libraries:read` | **Rate Limit:** heavy

### PUT /retention_libraries/{id} — Update
**Permission:** `retention_libraries:update` | **Rate Limit:** heavy

Same fields as POST (all optional for update).

### DELETE /retention_libraries/{id} — Delete
**Permission:** `retention_libraries:delete` | **Rate Limit:** heavy

---

## Reviews

### GET /reviews/escalated_comments — List escalated comments
**Permission:** `comments:read` | **Rate Limit:** heavy

**Query Parameters:** `start` (date-time, defaults to 7 days ago), `end` (date-time, defaults to now)

---

## Storage Accounts

### GET /storage_accounts — List all
**Permission:** `storage_accounts:read` | **Rate Limit:** heavy

Returns storage accounts with region, status, and retention library count.

---

## Examples

```bash
# List policies
./scripts/tl-curl.sh GET /analysis/policies

# Get audit logs for last 30 days
./scripts/tl-curl.sh GET "/audit_logs?from_date=2026-01-14&to_date=2026-02-13&max=100"

# List all custom detection rule inputs
./scripts/tl-curl.sh GET /analysis/inputs

# List inputs for a specific detection rule
./scripts/tl-curl.sh GET /analysis/detection_rules/1235/inputs

# Get detection rule stats (beta) — requires date range
./scripts/tl-curl.sh GET "/analysis/detection_rules/1235/stats?start=2026-01-01T00:00:00.000Z&end=2026-02-01T00:00:00.000Z"

# Activate a custom detection rule input (deactivates all others)
./scripts/tl-curl.sh PUT /analysis/detection_rules/126/inputs/53/activate

# Download a custom detection rule input to file
./scripts/tl-curl.sh GET /analysis/detection_rules/1235/inputs/25/download > input_file.bin

# List integrations
./scripts/tl-curl.sh GET /integrations

# Apply a label to a record
./scripts/tl-curl.sh POST /labels/5/records/12345

# Get current org unit
./scripts/tl-curl.sh GET /org_units/current

# Switch org unit
./scripts/tl-curl.sh PUT /org_units/3/switch

# List storage accounts
./scripts/tl-curl.sh GET /storage_accounts

# Get record comments
./scripts/tl-curl.sh GET /records/12345/comments
```
