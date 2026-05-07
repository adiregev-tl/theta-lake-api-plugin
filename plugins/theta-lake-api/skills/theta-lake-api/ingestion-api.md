# Theta Lake API — Data Ingestion Reference

Upload communications data to Theta Lake for analysis. All upload endpoints use the integration ID to specify which integration the data belongs to.

## Endpoints

### GET /ingestion/exists — Check if data exists
**Permission:** `ingestion:read` | **Rate Limit:** light

Check if data has already been uploaded using query parameters.

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `hash_sha256` | string[] | SHA256 hashes to check (max 20) |
| `identity_data` | string[] | Arbitrary string identifiers to check (max 20) |

Only one identifier type can be specified. If both are provided, only `identity_data` is checked. Never returns 404 — returns empty array if not found.

### POST /ingestion/integration/{id}/ai_interactions — Upload AI interaction
**Permission:** `ingestion:upload` | **Rate Limit:** heavy

**Content-Type:** `multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `meta` | JSON object | Yes | Metadata (required: `file_name`, `identity_data`, `create_date`) |
| `ai_interaction` | JSON object | Yes | AI interaction data (required: `application`, `conversation`, `participants`, `messages`, `attachments`) |

**Known AI participant constants:**
| AI Service | Name ID |
|-----------|---------|
| Anthropic Claude | `e31a9f3d-62d8-3b60-5d52-9366a8852932` |
| Zoom AI Companion | `acc7f28a-f3e1-0366-9192-fd5008404c16` |

### POST /ingestion/integration/{id}/audio — Upload audio
**Permission:** `ingestion:upload` | **Rate Limit:** heavy

**Content-Type:** `multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `meta` | JSON object | Yes | Required: `file_name`, `identity_data`, `create_date`. Optional: `audio_type`, `call_direction`, `call_scope`, `owner`, `participants`, `platform_attributes` |
| `data` | binary | No* | The audio file |

**Special Headers:**
- `X-Thetalake-Metaonly: true` — Set if no audio file is attached
- `X-Thetalake-Content-Type` — MIME type; required if no file attached, must NOT be set if file is attached

### POST /ingestion/integration/{id}/chat — Upload chat
**Permission:** `ingestion:upload` | **Rate Limit:** heavy

**Content-Type:** `multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `meta` | JSON object | Yes | Required: `file_name`, `identity_data`, `create_date`. Optional: `participants`, `platform_attributes` |
| `chat` | JSON object | Yes | Required: `application` (with `name`), `conversation` (with `id`, `name`, `begin_time`, `end_time`), `participants`, `messages`, `attachments` |

**Chat structure:**
```json
{
  "meta": {
    "file_name": "Team Discussion",
    "identity_data": "conv-123",
    "create_date": "2024-01-15T10:00:00.000Z"
  },
  "chat": {
    "application": { "name": "Teams" },
    "conversation": {
      "id": "conv-123",
      "name": "Team Discussion",
      "begin_time": "2024-01-15T10:00:00.000Z",
      "end_time": "2024-01-15T11:00:00.000Z"
    },
    "participants": [...],
    "messages": [...],
    "attachments": [...]
  }
}
```

Handles image attachments inline and file attachments separately.

### POST /ingestion/integration/{id}/document — Upload document
**Permission:** `ingestion:upload` | **Rate Limit:** heavy

**Content-Type:** `multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `meta` | JSON object | Yes | Required: `file_name`, `identity_data`, `create_date`. Optional: `document_type`, `owner`, `participants` |
| `data` | binary | No* | The document file (PDF, DOCX, etc.) |

Same `X-Thetalake-Metaonly` / `X-Thetalake-Content-Type` header support as audio.

### POST /ingestion/integration/{id}/email — Upload email
**Permission:** `ingestion:upload` | **Rate Limit:** heavy

**Content-Type:** `multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `meta` | JSON object | Yes | Required: `file_name`, `identity_data`, `create_date` |
| `data` | binary | No* | The EML file (`Content-Type: message/rfc822`) |

**Note:** Participant metadata is parsed directly from the EML file — do not include in the JSON meta payload.

### POST /ingestion/integration/{id}/other — Upload other file type
**Permission:** `ingestion:upload` | **Rate Limit:** heavy

Same structure as document upload. For file types that don't fit other categories.

### POST /ingestion/integration/{id}/video — Upload video
**Permission:** `ingestion:upload` | **Rate Limit:** heavy

**Content-Type:** `multipart/form-data`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `meta` | JSON object | Yes | Required: `file_name`, `identity_data`, `create_date`. Optional: `video_type`, `owner`, `participants` |
| `data` | binary | No* | The video file |

Same `X-Thetalake-Metaonly` / `X-Thetalake-Content-Type` header support.

## Common `meta` Fields (all upload endpoints)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `file_name` | string | Yes | Title that appears as record title in Portal |
| `identity_data` | string | Yes | Arbitrary unique string identifier for the record |
| `create_date` | date-time | Yes | When the communication occurred (RFC3339) |
| `custom_transport_type` | string | No | Custom transport type identifier |
| `platform_attributes` | object | No | Key-value pairs of platform-specific attributes |
| `owner` | object | No | Owner info (name, email, etc.) |
| `participants` | array | No | Participant list (format varies by media type) |

## Integration State

### GET /ingestion/integration/{id}/state — Get state
**Permission:** `ingestion:read` | **Rate Limit:** heavy

### PUT /ingestion/integration/{id}/state — Update state
**Permission:** `ingestion:update` | **Rate Limit:** heavy

```json
{
  "internal": { "last_cursor": "abc123", "sync_count": 42 },
  "last_run": "2024-01-15T10:00:00.000Z",
  "status": "active"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `internal` | object (nullable) | Free-form JSON for tracking integration state |
| `last_run` | date-time | Timestamp of the last run (set by integration) |
| `status` | string | Integration status |

## Quota

### GET /ingestion/quota — Get upload quota
**Permission:** `ingestion:read` | **Rate Limit:** heavy

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `from` | string (YYYY-MM-DD) | Start of summary period |
| `to` | string (YYYY-MM-DD) | End of summary period |

Quota is for the entire org unit.

## Upload Response

Successful uploads return:
```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "uuid",
  "result": {
    "uuid": "95292686-cbbb-b8c0-0351-25dab7c2154d",
    "hash_sha256": "5179a08f...",
    "content_type": "audio/mp3"
  }
}
```

## Error Responses

| Code | Meaning |
|------|---------|
| 409 | Data already uploaded (returns existing record info with uuid, hash, content_type) |
| 415 | Unsupported file type (e.g., executables) |
| 422 | Unable to process the uploaded file |

## Examples

```bash
# Check if data exists by hash
./scripts/tl-curl.sh GET "/ingestion/exists?hash_sha256=5179a08ff65e6388..."

# Upload a chat conversation (multipart with meta + chat JSON)
curl -X POST "$TL_BASE_URL/ingestion/integration/5/chat" \
  -H "Authorization: Bearer $TL_API_TOKEN" \
  -F 'meta={"file_name":"Team Chat","identity_data":"conv-123","create_date":"2024-01-15T10:00:00Z"}' \
  -F 'chat={"application":{"name":"Teams"},"conversation":{"id":"conv-123","name":"Team Chat","begin_time":"2024-01-15T10:00:00Z","end_time":"2024-01-15T11:00:00Z"},"participants":[],"messages":[],"attachments":[]}'

# Upload an audio file
curl -X POST "$TL_BASE_URL/ingestion/integration/5/audio" \
  -H "Authorization: Bearer $TL_API_TOKEN" \
  -F 'meta={"file_name":"Call Recording","identity_data":"call-456","create_date":"2024-01-15T10:00:00Z"}' \
  -F "data=@recording.mp3"

# Upload metadata only (no file)
curl -X POST "$TL_BASE_URL/ingestion/integration/5/audio" \
  -H "Authorization: Bearer $TL_API_TOKEN" \
  -H "X-Thetalake-Metaonly: true" \
  -H "X-Thetalake-Content-Type: audio/mpeg" \
  -F 'meta={"file_name":"Call Metadata","identity_data":"call-789","create_date":"2024-01-15T10:00:00Z"}'

# Get ingestion quota
./scripts/tl-curl.sh GET "/ingestion/quota?from=2026-01-01&to=2026-02-13"

# Update integration state
./scripts/tl-curl.sh PUT /ingestion/integration/5/state -d '{"internal":{"cursor":"abc"},"last_run":"2026-02-13T10:00:00Z"}'
```
