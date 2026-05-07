# Theta Lake API — Records Endpoints Reference

All Records endpoints accept either a **numeric ID** or **UUID** for the `{id}` path parameter (e.g. `501263` or `ca116f96-bbd5-11ef-9468-53af98260bba`).

> **Note:** Several endpoints (`/content`, `/policy_hits`, `/sentences`) are tied to a license within Theta Lake and may return 402 Payment Required. Licensed endpoints increase your monthly quota usage (content by file size; policy_hits and sentences by 1000 bytes per call). Contact your Theta Lake account manager for license information.

---

## GET /records/{id}/content — Download content

**Permission:** `records:read` | **Rate Limit:** heavy | **Licensed endpoint**

Downloads the original content of a record as a binary file. This is the raw source file (audio, video, chat transcript, email, document, etc.) as it was originally ingested.

> **License required:** This endpoint is tied to a license within Theta Lake. If you would like access, please reach out to your Theta Lake account manager. This endpoint will increase the monthly quota usage by the size of the record content.

### Response

- **Content-Type:** `application/octet-stream`
- **Body:** Binary file contents

The response is the raw file — not JSON. You'll need to save it to disk or pipe it to a file.

### Example

```bash
# Download record content to a file
./scripts/tl-curl.sh GET /records/501263/content > record_501263.bin

# Download using UUID
./scripts/tl-curl.sh GET /records/ca116f96-bbd5-11ef-9468-53af98260bba/content > record.bin

# Download and detect file type (useful since content-type is octet-stream)
./scripts/tl-curl.sh GET /records/501263/content > record_content && file record_content
```

---

## GET /records/{id}/policy_hits — Get policy hits

**Permission:** `records:read` | **Rate Limit:** heavy | **Licensed endpoint**

Returns the policy hits (detections) for a record — which policies were triggered, with what confidence, and where in the content.

> **License required:** This endpoint is tied to a license within Theta Lake. This endpoint will increase the quota by **1000 bytes** per API call.

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  "policy_hits": [
    {
      "annotations": ["keyword match found"],
      "attachment": null,
      "classification_id": 42,
      "confidence": 0.95,
      "detection_rule": {
        "id": 101,
        "name": "PII Detection Rule"
      },
      "offsets": [
        { "start": "00:01:30", "end": "00:01:45" }
      ],
      "policy": {
        "id": 5,
        "name": "PII Policy"
      },
      "risk_type": "pii",
      "rule": "SSN pattern \\d{3}-\\d{2}-\\d{4}"
    }
  ]
}
```

### `policy_hit` Object

| Field | Type | Description |
|-------|------|-------------|
| `annotations` | string[] | Annotations from the detection rule |
| `attachment` | object (nullable) | The attachment associated with the policy hit. `null` if not from an attachment |
| `classification_id` | integer | The classification ID |
| `confidence` | number (nullable) | Confidence score of the detection. Only set if the detection is from a classifier that provides a confidence score |
| `detection_rule` | object | The detection rule that triggered |
| `offsets` | array of objects | Offsets based on the record's media type (format varies — see Theta Lake docs) |
| `policy` | object | The policy that was hit |
| `risk_type` | string | The type of risk associated with this policy hit |
| `rule` | string (nullable) | The rule applied to the detection. Populated for detection rules that have a rule associated with them |

### Nested Objects

**`attachment`** (when not null)

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Name of the attachment |
| `uuid` | string | Record UUID of the attachment |

**`detection_rule`**

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Detection rule ID |
| `name` | string | Detection rule name |

**`policy`**

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Policy ID |
| `name` | string | Policy name |

### Example

```bash
# Get policy hits for a record
./scripts/tl-curl.sh GET /records/501263/policy_hits

# Get policy hits using UUID
./scripts/tl-curl.sh GET /records/ca116f96-bbd5-11ef-9468-53af98260bba/policy_hits
```

---

## GET /records/{id}/archive_handles — Get archive handles

**Permission:** `records:read` | **Rate Limit:** heavy

Returns the archive handles for a record — these represent where/how the record was archived (email, SFTP, etc.).

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  "archive_handles": [
    {
      "id": 599,
      "handle": "95292686-CBBB-B8C0-0351-25DAB7C2154D",
      "destination": "bob@thetalake.com",
      "sent_at": "2021-06-16T01:37:04.262Z"
    },
    {
      "id": 600,
      "handle": "ZOOMCHAT_20223420610.000000_2024061123150.2123315959_2052352240611.180001",
      "destination": "sftp.thetalake.com/uploads",
      "sent_at": "2021-06-16T01:37:04.262Z"
    }
  ]
}
```

### `archive_handle` Object

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Archive handle ID |
| `handle` | string | File path or email message ID. If destination is email, this is a message ID; otherwise it's a filename/path |
| `destination` | string | Comma-separated list of destinations where the record was sent |
| `sent_at` | string (date-time) | Archive operation timestamp (RFC3339) |

### Example

```bash
# Get archive handles for a record by numeric ID
./scripts/tl-curl.sh GET /records/501263/archive_handles

# Get archive handles for a record by UUID
./scripts/tl-curl.sh GET /records/ca116f96-bbd5-11ef-9468-53af98260bba/archive_handles
```

---

## GET /records/{id}/comments — Get comments

**Permission:** `comments:read` | **Rate Limit:** medium

Returns all comments on a record, including nested replies.

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  "comments": [
    {
      "id": 12345,
      "record_id": 501263,
      "text": "This looks like a potential compliance issue",
      "flag": "confirmed_risk",
      "user_id": 92,
      "parent_id": null,
      "created_at": "2021-06-16T01:37:04.262Z",
      "updated_at": "2022-10-12T02:29:49.146Z",
      "replies": [
        {
          "id": 12346,
          "record_id": 501263,
          "text": "Agreed, escalating to legal",
          "flag": "escalate",
          "user_id": 45,
          "parent_id": 12345,
          "created_at": "2021-06-17T09:15:00.000Z",
          "updated_at": "2021-06-17T09:15:00.000Z"
        }
      ]
    }
  ]
}
```

### `comment` Object

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Comment ID |
| `record_id` | integer | Record ID the comment is associated with |
| `text` | string | Text content of the comment |
| `flag` | string (enum) | One of: `cleared`, `confirmed_risk`, `escalate`, `false_detection`, `missed_detection`, `noteworthy` |
| `user_id` | integer (nullable) | ID of the user who created the comment. `null` for system comments |
| `parent_id` | integer (nullable) | ID of the parent comment if this is a reply. `null` for top-level comments |
| `created_at` | string (date-time) | Creation timestamp (RFC3339) |
| `updated_at` | string (date-time) | Last update timestamp (RFC3339) |
| `replies` | array | Nested array of reply comments (same shape as `comment`, minus the `replies` field) |

### Flag Values

| Flag | Meaning |
|------|---------|
| `cleared` | Issue has been reviewed and cleared |
| `confirmed_risk` | Confirmed as a genuine risk/violation |
| `escalate` | Needs escalation to higher authority |
| `false_detection` | Policy hit was a false positive |
| `missed_detection` | A risk that was not initially detected |
| `noteworthy` | Flagged as noteworthy for reference |

### Example

```bash
# Get all comments on a record
./scripts/tl-curl.sh GET /records/501263/comments

# Get comments using UUID
./scripts/tl-curl.sh GET /records/ca116f96-bbd5-11ef-9468-53af98260bba/comments
```

---

## POST /records/{id}/comments — Create a comment

**Permission:** `comments:create` | **Rate Limit:** medium

Creates a new comment on a record. Can be a top-level comment or a reply to an existing comment.

### Request Body

```json
{
  "comment": "This needs further review",
  "parent_id": null
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `comment` | string | Yes | Text content of the comment |
| `parent_id` | integer | No | ID of the top-level parent comment when posting a reply. Must not be an ID of another reply |

### Example

```bash
# Create a top-level comment
./scripts/tl-curl.sh POST /records/501263/comments -d '{"comment":"Flagging for review"}'

# Reply to comment 12345
./scripts/tl-curl.sh POST /records/501263/comments -d '{"comment":"Agreed, escalating","parent_id":12345}'
```

---

## PUT /records/{id}/comments/{comment_id} — Update a comment

**Permission:** `comments:update` | **Rate Limit:** medium

Updates the text content of an existing comment.

### Request Body

```json
{
  "comment": "Updated review note"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `comment` | string | Yes | Updated text content of the comment |

### Example

```bash
# Update comment 12345 on record 501263
./scripts/tl-curl.sh PUT /records/501263/comments/12345 -d '{"comment":"Updated: confirmed risk after review"}'
```

---

## DELETE /records/{id}/comments/{comment_id} — Delete a comment

**Permission:** `comments:delete` | **Rate Limit:** medium

Deletes a comment from a record.

### Example

```bash
# Delete comment 12345 from record 501263
./scripts/tl-curl.sh DELETE /records/501263/comments/12345
```

---

## GET /records/{id}/shareable_link — Get shareable link

**Permission:** `records:read` | **Rate Limit:** heavy

Generates a shareable link URL for a record. Whether anonymous access is allowed depends on the org unit setting `allow_anonymous_via_shared_links`.

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  "shareable_link": "https://app-useast.thetalake.com/api/v1/datum_shared_links/ca116f96-bbd5-11ef-9468-53af98260bba"
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `shareable_link` | string | Full URL for the shareable link to the record |

### Example

```bash
# Get a shareable link for a record
./scripts/tl-curl.sh GET /records/501263/shareable_link

# Get shareable link using UUID
./scripts/tl-curl.sh GET /records/ca116f96-bbd5-11ef-9468-53af98260bba/shareable_link
```

---

## GET /records/{id}/sentences — Get sentences

**Permission:** `records:read` | **Rate Limit:** heavy | **Licensed endpoint**

Returns the sentences (transcribed/extracted text segments) found for a record. The structure of the offsets varies by media type.

> **License required:** This endpoint is tied to a license within Theta Lake. This endpoint will increase the quota by **1000 bytes** per API call.

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  "sentences": {
    "output_format_version": "1.0.0",
    "offsets": {
      "...": "varies by media type"
    },
    "sentences": {
      "...": "varies by media type"
    }
  }
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `sentences.output_format_version` | string | Version of the sentences format (`major.minor.patch`) |
| `sentences.offsets` | object | Offsets keyed by media-type-specific keys (structure varies) |
| `sentences.sentences` | object | Sentence data keyed by media-type-specific keys (structure varies) |

> **Note:** The `offsets` and `sentences` objects have dynamic keys that vary based on the record's media type (audio, chat, email, etc.). Refer to Theta Lake's documentation for media-type-specific offset formats.

### Example

```bash
# Get sentences for a record
./scripts/tl-curl.sh GET /records/501263/sentences

# Get sentences using UUID
./scripts/tl-curl.sh GET /records/ca116f96-bbd5-11ef-9468-53af98260bba/sentences
```

---

## GET /records/{id}/workflow_history — Get workflow history

**Permission:** `workflows:read` | **Rate Limit:** heavy

Returns the full workflow history for a record — every state transition, action taken, and user assignment.

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  "workflow_history": [
    {
      "id": 12364,
      "description": "Took the action 'Needs Review' and assigned the record to Admin.",
      "created_at": "2025-07-02T16:20:00.000Z",
      "workflow": {
        "id": 83,
        "name": "My Workflow"
      },
      "workflow_state": {
        "id": 1,
        "name": "Needs Review",
        "category": "Needs Review"
      },
      "workflow_action": {
        "id": 372,
        "name": "Needs Review",
        "type": "button"
      },
      "assigned_user": {
        "id": 1,
        "name": "Admin"
      },
      "previous_user": {
        "id": null,
        "name": null
      }
    }
  ]
}
```

### `WorkflowHistoryItem` Object

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Workflow history item ID |
| `description` | string | Human-readable description of the action taken |
| `created_at` | string (date-time) | Timestamp when this history item was created (RFC3339) |
| `workflow` | object | The workflow this item belongs to |
| `workflow_state` | object | The workflow state after this action |
| `workflow_action` | object | The action that was taken |
| `assigned_user` | object | The user assigned after this action |
| `previous_user` | object | The user who was previously assigned |

### Nested Objects

**`workflow`**

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Workflow ID |
| `name` | string | Workflow name |

**`workflow_state`**

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Workflow state ID |
| `name` | string | Workflow state name |
| `category` | string | Workflow state category |

**`workflow_action`**

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer (nullable) | Workflow action ID. `null` if the action is not part of a workflow |
| `name` | string | Action name |
| `type` | string | Action type (e.g. `button`) |

**`assigned_user` / `previous_user`**

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer (nullable) | User ID. `null` if no user was assigned |
| `name` | string (nullable) | User name. `null` if no user was assigned |

### Example

```bash
# Get workflow history for a record
./scripts/tl-curl.sh GET /records/501263/workflow_history

# Get workflow history using UUID
./scripts/tl-curl.sh GET /records/ca116f96-bbd5-11ef-9468-53af98260bba/workflow_history
```

---

## GET /records/quota — Get download quota information

**Permission:** `records:read` | **Rate Limit:** medium

Returns the download quota information for the licensed Records endpoints (content, policy_hits, sentences). Use this to check how much quota you've used and when it resets.

> **Note:** This endpoint does NOT take a record `{id}` — the path is simply `/records/quota`.

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  "quota": {
    "bytes_allotted": 10737418240,
    "bytes_remaining": 8589934592,
    "bytes_used": 2147483648,
    "resets_at": "2026-03-01T00:00:00.000Z"
  }
}
```

### `quota` Object

| Field | Type | Description |
|-------|------|-------------|
| `bytes_allotted` | integer | Total number of bytes allotted |
| `bytes_remaining` | integer | Total number of bytes remaining until the quota is reset |
| `bytes_used` | integer | Total number of bytes used since the quota was reset |
| `resets_at` | string (date-time) | Timestamp when the used quota resets back to 0 |

### Example

```bash
# Check download quota
./scripts/tl-curl.sh GET /records/quota
```

---

## Error Responses

All endpoints return standard error responses:

| Code | Description |
|------|-------------|
| 400 | Bad Request — invalid ID format (shareable_link, workflow_history only) |
| 401 | Unauthorized — missing or invalid token |
| 402 | Payment Required — endpoint requires a license (content, policy_hits, sentences) |
| 403 | Forbidden — insufficient permissions |
| 429 | Too Many Requests — rate limit exceeded |
| 500 | Internal Server Error |
| 503 | Service Unavailable (archive_handles, comments, content, shareable_link only) |
