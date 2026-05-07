# Theta Lake API — Workspaces Reference

Workspaces provide multi-tenant isolation within a single Theta Lake organization. Each workspace has its own configuration, users, and data scope. Users can be members of multiple workspaces and switch between them.

## Endpoints

### GET /workspaces — List all workspaces
**Permission:** `workspaces:read` | **Rate Limit:** heavy

Returns all workspaces the current user has access to.

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  "workspaces": [
    {
      "id": 108,
      "name": "East Region Sales",
      "description": "Fake Bank - East Asia Regional",
      "disabled": false,
      "disabled_at": null,
      "allow_anonymous_via_shared_links": false,
      "default_workspace_timezone": "Etc/UTC",
      "delete_on_expiration": true,
      "fallback_language": "en",
      "preferred_languages": ["en", "nl", "de"],
      "use_name_matcher": true,
      "use_owner_only_space_matcher": false,
      "shared_links_expiration_period": 730,
      "audit_log_retention_period": null,
      "analysis_supervision_spaces": [
        { "id": 1, "name": "Example Supervision Space" }
      ],
      "preferred_language_list": [
        { "code": "en", "label": "English" },
        { "code": "nl", "label": "Dutch" },
        { "code": "de", "label": "German" }
      ],
      "users": [
        { "id": 380, "name": "Jane Doe", "email": "jane.doe@example.com" }
      ],
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-06-01T00:00:00.000Z"
    }
  ]
}
```

---

### GET /workspaces/current — Get current workspace
**Permission:** `workspaces:read` | **Rate Limit:** heavy

Returns the workspace the current user is operating in.

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  "current_workspace": {
    "id": 1,
    "name": "Theta Lake Support"
  }
}
```

---

### GET /workspaces/{id} — Get workspace by ID
**Permission:** `workspaces:read` | **Rate Limit:** heavy

Returns full workspace details including configuration, users, and language preferences.

Response is the same `workspace` object as shown in the list response above.

---

### PUT /workspaces/{id} — Update workspace
**Permission:** `workspaces:update` | **Rate Limit:** heavy

Updates workspace configuration. All fields are optional.

### Request Body

```json
{
  "allow_anonymous_via_shared_links": false,
  "analysis_supervision_space_ids": [1, 2, 3],
  "audit_log_retention_period": null,
  "default_workspace_timezone": "Etc/UTC",
  "delete_on_expiration": true,
  "fallback_language": "en",
  "preferred_languages": ["en", "nl", "de"],
  "use_name_matcher": true,
  "use_owner_only_space_matcher": false
}
```

| Field | Type | Description |
|-------|------|-------------|
| `allow_anonymous_via_shared_links` | boolean | Allow public record sharing via links |
| `analysis_supervision_space_ids` | int[] | Supervision spaces whose records will be analyzed |
| `audit_log_retention_period` | integer (nullable) | Audit log retention duration |
| `default_workspace_timezone` | string | Default timezone (e.g. `Etc/UTC`) |
| `delete_on_expiration` | boolean | Delete records when they expire from archive |
| `fallback_language` | string | Fallback language. Enum: `en`, `es`, `nl`, `de`, `fr`, `it`, `ja`, `cmn`, `pt` |
| `preferred_languages` | string[] | Preferred language list (same enum values) |
| `use_name_matcher` | boolean | Use names in identity matching |
| `use_owner_only_space_matcher` | boolean | Stop matching after owner, fallback to default |

Response returns the updated workspace object.

---

### PUT /workspaces/{id}/switch — Switch workspace
**Permission:** none | **Rate Limit:** heavy

Switches the active workspace for subsequent API calls.

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  "message": "Ok, you've been switched to the East Region Sales workspace."
}
```

---

### PUT /workspaces/{id}/users — Add user to workspace
**Permission:** none | **Rate Limit:** heavy

Adds a user to a workspace.

### Request Body

```json
{
  "user_id": 380
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | integer | Yes | The ID of the user to add |

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  "message": "Jim Halpert has been added to the workspace"
}
```

---

### DELETE /workspaces/{id}/users/{user_id} — Remove user from workspace
**Permission:** none | **Rate Limit:** heavy

Removes a user from a workspace.

### Response

```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "ca116f96-bbd5-11ef-9468-53af98260bba",
  "message": "Jim Halpert has been removed from the workspace"
}
```

---

## Workspace Object

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Workspace ID |
| `name` | string | Workspace name |
| `description` | string | Workspace description |
| `disabled` | boolean | Whether workspace is disabled |
| `disabled_at` | string (nullable) | When the workspace was disabled (RFC3339) |
| `allow_anonymous_via_shared_links` | boolean | Allow public record sharing |
| `default_workspace_timezone` | string | Default timezone |
| `delete_on_expiration` | boolean | Delete records when they expire |
| `fallback_language` | string | Fallback language code |
| `preferred_languages` | string[] | Preferred language codes |
| `preferred_language_list` | object[] | Language objects with `code` and `label` |
| `use_name_matcher` | boolean | Use names in identity matching |
| `use_owner_only_space_matcher` | boolean | Stop matching after owner |
| `shared_links_expiration_period` | integer | Days shared links are valid |
| `audit_log_retention_period` | integer (nullable) | Audit log retention duration |
| `analysis_supervision_spaces` | object[] | Supervision spaces for analysis (`id`, `name`) |
| `users` | object[] | Users in workspace (`id`, `name`, `email`) |
| `created_at` | string (date-time) | Creation timestamp (RFC3339) |
| `updated_at` | string (date-time) | Last update timestamp (RFC3339) |

## Examples

```bash
# List all workspaces
./scripts/tl-curl.sh GET /workspaces

# Get current workspace
./scripts/tl-curl.sh GET /workspaces/current

# Get workspace by ID
./scripts/tl-curl.sh GET /workspaces/108

# Update workspace settings
./scripts/tl-curl.sh PUT /workspaces/108 -d '{"fallback_language":"es","preferred_languages":["en","es"]}'

# Switch to a workspace
./scripts/tl-curl.sh PUT /workspaces/108/switch

# Add user to workspace
./scripts/tl-curl.sh PUT /workspaces/108/users -d '{"user_id":380}'

# Remove user from workspace (confirm before executing!)
./scripts/tl-curl.sh DELETE /workspaces/108/users/380
```
