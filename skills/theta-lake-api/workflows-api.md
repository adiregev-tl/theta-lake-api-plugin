# Theta Lake API — Workflows Reference

Workflows define the review process that records go through after analysis. Each workflow has states and transition events.

## Endpoints

### GET /workflows — List all workflows
**Permission:** `workflows:read` | **Rate Limit:** medium

### GET /workflows/{id} — Get workflow by ID
**Permission:** `workflows:read` | **Rate Limit:** medium

Returns the workflow with its states and state events (transitions).

### GET /workflows/queue — List records in workflow queues
**Permission:** `workflows:read` | **Rate Limit:** medium

Returns a paginated list of records in workflow queues, filtered by state type.

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `state_type` | string[] | No | Filter by state type. Enum: `open`, `closed`, `in_progress` |
| `max` | integer (1-100) | No | Max records to return (default: 25) |
| `page_token` | string | No | Pagination token from `paging` in response |

---

### GET /workflows/record/{id} — Get workflow actions for a record
**Permission:** `workflows:read` | **Rate Limit:** heavy

Returns the current workflow state, available actions, and assigned user for a record. The `{id}` parameter accepts either a numeric ID or UUID.

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  "record": {
    "assigned_to": {
      "id": 1,
      "name": "Admin"
    },
    "workflow": {
      "id": 83,
      "name": "My Workflow",
      "description": "Standard review process"
    },
    "workflow_state": {
      "id": 1,
      "name": "Needs Review",
      "description": "Record is pending review",
      "state_type": "open",
      "reassign_users": [
        { "id": 1, "name": "Admin", "email": "admin@company.com" },
        { "id": 45, "name": "Reviewer", "email": "reviewer@company.com" }
      ]
    },
    "workflow_actions": [
      {
        "id": 223,
        "name": "Approve",
        "description": "Mark as reviewed and approved",
        "to_state": {
          "id": 2,
          "name": "Approved",
          "state_type": "closed",
          "reassign_users": []
        }
      },
      {
        "id": 224,
        "name": "Escalate",
        "description": "Escalate for further review",
        "to_state": {
          "id": 3,
          "name": "Escalated",
          "state_type": "in_progress",
          "reassign_users": [
            { "id": 92, "name": "Senior Reviewer", "email": "senior@company.com" }
          ]
        }
      }
    ]
  }
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `record.assigned_to` | object | Currently assigned user (`id`, `name`) |
| `record.workflow` | object | The workflow (`id`, `name`, `description`) |
| `record.workflow_state` | object | Current state with `id`, `name`, `description`, `state_type`, `reassign_users` |
| `record.workflow_actions` | array | Available actions, each with `id`, `name`, `description`, and `to_state` |
| `workflow_state.state_type` | enum | One of: `open`, `in_progress`, `closed` |
| `workflow_state.reassign_users` | array | Users who can be assigned in this state (`id`, `name`, `email`) |

---

### PUT /workflows/record/{id} — Perform workflow action on a record
**Permission:** `workflows:use` | **Rate Limit:** heavy

Performs a workflow action on a record (e.g. approve, escalate, reassign). The `{id}` parameter accepts either a numeric ID or UUID.

### Request Body

```json
{
  "action_id": 223,
  "assign_to_user_id": 404,
  "comment": "This record has been approved."
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `action_id` | integer | Yes | The ID of the workflow action to perform (from GET /workflows/record/{id}) |
| `assign_to_user_id` | integer | Yes | The user ID to assign the record to after the action |
| `comment` | string | Yes | Comment to add with the action |

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  "record": {
    "assigned_user": {
      "id": 404,
      "name": "Compliance Officer"
    },
    "current_state": {
      "id": 2,
      "name": "Approved",
      "description": "Record has been reviewed and approved"
    }
  }
}
```

---

## Workflow Object

```json
{
  "id": 1,
  "name": "Standard Review",
  "description": "Default review workflow",
  "active": true,
  "states": [
    {
      "id": 1,
      "name": "Pending Review",
      "position": 1,
      "events": [
        {
          "id": 10,
          "name": "Approve",
          "target_state_id": 2,
          "description": "Mark as reviewed and approved"
        },
        {
          "id": 11,
          "name": "Escalate",
          "target_state_id": 3,
          "description": "Escalate for further review"
        }
      ]
    },
    {
      "id": 2,
      "name": "Approved",
      "position": 2,
      "events": []
    }
  ],
  "created_at": "2024-01-01T00:00:00.000Z",
  "updated_at": "2024-06-01T00:00:00.000Z"
}
```

## SWRV Rules

SWRV (Supervision, Workflow, Retention, and Visibility) rules define how records are routed to supervision spaces, workflows, and retention libraries based on conditions. Rules are ordered by priority (highest to lowest).

### GET /workflows/swrv_rules — List all SWRV rules
**Permission:** `swrv_rules:read` | **Rate Limit:** heavy

Returns SWRV rules ordered by priority.

### POST /workflows/swrv_rules — Create a SWRV rule
**Permission:** `swrv_rules:create` | **Rate Limit:** heavy

**Request Body (all required fields marked):**
```json
{
  "name": "Route Teams to Sales Review",
  "description": "Route Microsoft Teams records to the Sales supervision space",
  "input_sources": [
    { "type": "integration", "id": 5 }
  ],
  "policy_id": 147,
  "workflow_id": 1,
  "retention_library_id": 10,
  "supervision_space_id": 120,
  "priority": 0
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Rule name |
| `description` | string | Yes | Rule description |
| `input_sources` | array | Yes | Array of input source objects |
| `policy_id` | integer | Yes | Analysis policy ID |
| `workflow_id` | integer | Yes | Review workflow ID |
| `retention_library_id` | integer | Yes | Retention library ID |
| `supervision_space_id` | integer | No (nullable) | Supervision space ID |
| `priority` | integer | No | Priority (0 = highest). If not specified, gets lowest priority |

**Input source types:**
| Type | Description |
|------|-------------|
| `all_integration_uploads` | All integration uploads |
| `all_submission_portal_uploads` | All submission portal uploads |
| `all_uploads` | All uploads |
| `all_user_uploads` | All user uploads |
| `integration` | Specific integration (requires `id` field) |

### GET /workflows/swrv_rules/{id} — Get SWRV rule by ID
**Permission:** `swrv_rules:read` | **Rate Limit:** heavy

### PUT /workflows/swrv_rules/{id} — Update SWRV rule
**Permission:** `swrv_rules:update` | **Rate Limit:** medium

Same body as POST (all required fields must be provided).

### DELETE /workflows/swrv_rules/{id} — Delete a SWRV rule
**Permission:** `workflows:delete` | **Rate Limit:** medium

## SWRV Rule Object

```json
{
  "id": 1,
  "name": "Route Teams to Sales Review",
  "description": "Route Microsoft Teams records to the Sales supervision space",
  "active": true,
  "priority": 0,
  "input_sources": [
    { "type": "integration", "id": 5 }
  ],
  "policy": { "id": 147, "name": "All Detections Active" },
  "retention_library": { "id": 10, "name": "7-Year Retention" },
  "supervision_space": { "id": 120, "name": "Sales Team" },
  "workflow": { "id": 1, "name": "Standard Review" },
  "created_at": "2024-01-01T00:00:00.000Z",
  "updated_at": "2024-06-01T00:00:00.000Z"
}
```

## Examples

```bash
# List all workflows
./scripts/tl-curl.sh GET /workflows

# Get a specific workflow (shows states and events)
./scripts/tl-curl.sh GET /workflows/1

# List records in open workflow queues
./scripts/tl-curl.sh GET "/workflows/queue?state_type=open&max=50"

# Get available workflow actions for a record
./scripts/tl-curl.sh GET /workflows/record/501263

# Perform a workflow action (approve a record) — confirm before executing!
./scripts/tl-curl.sh PUT /workflows/record/501263 -d '{"action_id":223,"assign_to_user_id":404,"comment":"Approved after review"}'

# List SWRV rules
./scripts/tl-curl.sh GET /workflows/swrv_rules

# Create a SWRV rule
./scripts/tl-curl.sh POST /workflows/swrv_rules -d '{"name":"Teams to Sales","description":"Route Teams to Sales review","input_sources":[{"type":"integration","id":5}],"policy_id":147,"workflow_id":1,"retention_library_id":10,"supervision_space_id":120,"priority":0}'

# Update a SWRV rule
./scripts/tl-curl.sh PUT /workflows/swrv_rules/1 -d '{"name":"Teams to Sales (Updated)","description":"Updated routing","input_sources":[{"type":"integration","id":5}],"policy_id":147,"workflow_id":1,"retention_library_id":10,"priority":1}'

# Delete a SWRV rule (confirm before executing!)
./scripts/tl-curl.sh DELETE /workflows/swrv_rules/5
```
