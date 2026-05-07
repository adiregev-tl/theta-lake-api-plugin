# Theta Lake API — Search Reference

## POST /search/records

The most powerful endpoint. Searches records with complex filtering.

**Permission:** `search:create`
**Rate Limit:** `heavy` + dynamic rate limiting (for content queries)
**Max results:** 10,000
**Default range:** Last 7 days (if no range specified)

### Query Parameters

| Param | Type | Description |
|-------|------|-------------|
| `page_token` | string | Pagination token from previous response |
| `max` | integer (0-100) | Items per page, default 25 |

### Request Body (all fields optional)

```json
{
  "range": { ... },
  "risk": [ ... ],
  "media": [ ... ],
  "content": [ ... ],
  "content_source": [ ... ],
  "participants": { ... },
  "identities": { ... },
  "people": { ... },
  "policy_detections": { ... },
  "workflow": { ... },
  "cases": { ... },
  "comments": { ... },
  "attachments": { ... },
  "email": { ... },
  "sort": { ... }
}
```

### Field Details

#### `range` — Date range filter
```json
{
  "range": {
    "type": "upload_date",  // "create_date" | "upload_date" | "processed_date"
    "start": "2024-01-01T00:00:00.000Z",
    "end": "2024-01-31T23:59:59.999Z"
  }
}
```
- Default type: `upload_date`
- Default range: last 7 days
- Both start/end are **inclusive**
- Subject to dynamic rate limits (wider ranges = stricter limits)

#### `risk` — Risk level filter
```json
{
  "risk": ["high", "medium"]
}
```
Values: `low`, `slight`, `medium`, `high`, `not_analyzed`
- Multiple values use OR
- `not_analyzed` must be used alone (not combined with other levels)

#### `media` — Media type filter
```json
{
  "media": ["chat", "audio"]
}
```
Values: `audio`, `chat`, `document`, `email`, `other`, `video`
- Multiple values use OR

#### `content` — Text content search (triggers dynamic rate limiting)
```json
{
  "content": [
    {
      "query": "\"confidential\" + \"do not share\"",
      "operator": "and",
      "scopes": ["chat_text", "transcript"]
    }
  ]
}
```

**Query syntax:**
- Exact phrase: `"keep it between us"`
- OR: `word1 | word2`
- AND/proximity: `word1 + word2`
- Grouping: `("keep it" | just) + "between us"`

**Operators** between content array items: `and`, `or` (default: `or`)

**Scopes** (which parts of records to search):
| Scope | Description |
|-------|-------------|
| `attachment_name` | Attachment filenames |
| `attachment_text` | Text extracted from attachments |
| `chat_text` | Chat/IM message text |
| `conference_chat` | Chat within video conferences |
| `document_text` | Document body text |
| `email_extended_body` | Full email body |
| `email_headers` | Email headers (to, from, subject) |
| `email_smart_body` | Cleaned email body (no signatures/quotes) |
| `image_text` | OCR text from images |
| `journal_headers` | Journal entry headers |
| `media_title` | Title of media files |
| `screen_text` | Text from screen recordings |
| `transcript` | Audio/video transcription |

If no scopes specified, all scopes are searched.

#### `content_source` — Platform filter
```json
{
  "content_source": ["microsoft_teams", "zoom"]
}
```
Multiple values use OR.

#### `participants` — Participant filter
```json
{
  "participants": {
    "operator": "AND",
    "attributes": [
      {
        "attribute": "email",
        "participant_information": "user@company.com"
      }
    ],
    "identity_ids": [1234]
  }
}
```

**Attribute types:** `email`, `first_name`, `last_name`, `name`, `id`, `location`, `phone_number`, `extension`, `org_relationship`, `primary_domain`, `all_domains`

- `operator`: `AND` or `OR` between attributes
- `identity_ids`: Limited to 1 identity per search

#### `identities` — Identity filter
```json
{
  "identities": {
    "ids": [7]
  }
}
```
Limited to 1 identity ID per search.

#### `people` — Communication direction filter
```json
{
  "people": {
    "communication_direction": {
      "internal_sender": true,
      "internal_receiver": true,
      "external_sender": false,
      "external_receiver": false
    }
  }
}
```

#### `policy_detections` — Policy hit filter
```json
{
  "policy_detections": {
    "policy_hits": {
      "inclusion": "is",
      "policy_hit": [640, 641]
    }
  }
}
```
- `inclusion`: `is` or `is_not`
- `policy_hit`: Array of policy hit IDs (from GET /analysis/policy_hits)

#### `workflow` — Workflow filter
```json
{
  "workflow": {
    "name": {
      "id": [1, 2]
    },
    "state": {
      "inclusion": "is",
      "id": [1, 2]
    }
  }
}
```
- Workflow IDs from GET /workflows
- State IDs from GET /workflows/{id}

#### `cases` — Case filter
```json
{
  "cases": {
    "filter_type": "is",
    "ids": [1234, 5678]
  }
}
```
- `filter_type`: `is` or `is_not`

#### `comments` — Comment filter
```json
{
  "comments": {
    "flags": ["confirmed_risk", "escalated"],
    "author_name": ["John Doe"],
    "author_email": ["john@example.com"]
  }
}
```
Flags: `cleared`, `confirmed_risk`, `escalated`, `false_detection`, `noteworthy`

#### `attachments` — Attachment count filter
```json
{
  "attachments": {
    "attachment_count": {
      "min": 1,
      "max": 10
    }
  }
}
```

#### `email` — Email-specific filters
```json
{
  "email": {
    "duplicate_count": { "min": 1, "max": 10 },
    "duplicate_date": {
      "start": "2024-01-01T00:00:00.000Z",
      "end": "2024-12-31T23:59:59.999Z"
    }
  }
}
```

#### `sort` — Result ordering
```json
{
  "sort": {
    "by": "create_date",
    "order": "desc"
  }
}
```
- `by`: `create_date`, `upload_date`, `processed_date` (default: `upload_date`)
- `order`: `asc`, `desc` (default: `desc`)

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "uuid",
  "paging": {
    "prev_page_token": null,
    "next_page_token": "eyJ..."
  },
  "result": {
    "created_at": "2024-01-15T10:00:00.000Z",
    "id": 543,
    "total_hits": 24123,
    "records": [
      {
        "id": 215779,
        "uuid": "95292686-cbbb-b8c0-0351-25dab7c2154d",
        "media_type": "Chat",
        "content_source": "microsoft_teams",
        "content_type": "video/mp4",
        "risk": "low",
        "create_date": "2024-01-15T10:00:00.000Z",
        "upload_date": "2024-01-15T12:00:00.000Z",
        "processed_date": "2024-01-15T12:05:00.000Z",
        "original_file_name": "meeting.mp4",
        "record_size": 215779,
        "hash_sha256": "5179a08f...",
        "attachment_count": 3,
        "supervision_space_id": 123456,
        "integration": { "id": 1, "name": "Teams" },
        "participants": { ... },
        "platform_attributes": { ... },
        "communication_direction": { ... },
        "data_path": "2025-01-01/data/uuid"
      }
    ]
  }
}
```

### Common Search Examples

**High risk records from last 30 days:**
```json
{
  "range": {
    "type": "upload_date",
    "start": "2025-12-14T00:00:00.000Z",
    "end": "2026-01-13T23:59:59.999Z"
  },
  "risk": ["high"]
}
```

**Chat records mentioning "confidential":**
```json
{
  "media": ["chat"],
  "content": [{ "query": "\"confidential\"", "scopes": ["chat_text"] }]
}
```

**Records from a specific participant:**
```json
{
  "participants": {
    "attributes": [{ "attribute": "email", "participant_information": "john@company.com" }]
  }
}
```

**Records in a specific workflow state:**
```json
{
  "workflow": {
    "name": { "id": [1] },
    "state": { "inclusion": "is", "id": [3] }
  }
}
```

---

## POST /search/records/ids

Search up to 100 records by ID or UUID. No date restriction.

**Permission:** `search:create`
**Rate Limit:** `heavy`

### Request Body
```json
{
  "id": [1520, 1521],
  "uuid": ["971219f9-3a00-3f2e-e835-55e7e2cfcc36"],
  "sort": {
    "by": "create_date",
    "order": "desc"
  }
}
```
- Provide `id` OR `uuid` (or both)
- Limit: 100 IDs/UUIDs per request
- Sort by: `create_date` or `upload_date`

---

## GET /search/saved

List saved searches.

**Permission:** `search:read`
**Rate Limit:** `heavy`

### Query Parameters
| Param | Required | Description |
|-------|----------|-------------|
| `types` | Yes | Comma-separated: `history`, `private`, `workflow`, `security_filter` |
| `page_token` | No | Pagination token |
| `max` | No | Items per page (default 25) |

---

## GET /search/saved/{id}

Run a saved search and get matching records.

**Permission:** `search:read`
**Rate Limit:** `heavy`

---

## POST /search/saved/{id}/reset_and_reenter

Reset and reenter records from a saved search back into their workflow.

**Permission:** `search:reset`
**Rate Limit:** `heavy`
**Max records:** 20,000

### Request Body
```json
{
  "reason": "Records need to be re-reviewed after policy update"
}
```

Creates a batch job. Check progress by running the search again.

---

## Dynamic Rate Limiting

Content searches (`content` field) use dynamic rate limiting that considers:
- Date range width (wider = more strict)
- Query complexity
- Current system load

When rate limited on content search, try:
1. Narrow the date range
2. Simplify the query
3. Wait and retry with exponential backoff
