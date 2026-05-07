# Theta Lake API — Users & User Groups Reference

## Users

### GET /users — List all users
**Permission:** `users:read` | **Rate Limit:** heavy

**Query Parameters:** `page_token`, `max`

### POST /users — Create a user
**Permission:** `users:create` | **Rate Limit:** heavy

**Request Body:**
```json
{
  "name": "Jane Doe",
  "email": "jane@company.com",
  "password": "SecureP@ss123",
  "password_confirmation": "SecureP@ss123",
  "role_id": 80,
  "search_id": 500311
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | User's full name |
| `email` | string | Yes | User's email address |
| `password` | string | Yes | Password |
| `password_confirmation` | string | Yes | Must match password |
| `role_id` | integer | Yes | Role ID (from GET /roles) |
| `search_id` | integer | No | Security filter search ID |

### GET /users/me — Get current user
**Permission:** `users:read` | **Rate Limit:** heavy

Returns the authenticated user's profile.

### GET /users/{id} — Get user by ID
**Permission:** `users:read` | **Rate Limit:** heavy

### PUT /users/{id} — Update a user
**Permission:** `users:update` | **Rate Limit:** heavy

```json
{
  "name": "Jane Smith",
  "email": "jane.smith@company.com",
  "role_id": 81,
  "search_id": 500311
}
```

### DELETE /users/{id} — Delete a user
**Permission:** `users:delete` | **Rate Limit:** heavy

### PUT /users/{id}/disable — Disable a user
**Permission:** `users:disable` | **Rate Limit:** heavy

No body required. Prevents the user from logging in.

### PUT /users/{id}/enable — Enable a user
**Permission:** `users:disable` | **Rate Limit:** heavy

No body required. Re-enables a disabled user.

## User Object

```json
{
  "id": 92,
  "name": "Jane Doe",
  "email": "jane@company.com",
  "role": "Reviewer",
  "role_id": 80,
  "disabled": false,
  "last_login": "2024-06-15T10:00:00.000Z",
  "current_org_unit": {
    "id": 1,
    "name": "Theta Lake Support",
    "archive_only": false
  }
}
```

---

## User Groups

### GET /user_groups — List all user groups
**Permission:** `user_groups:read` | **Rate Limit:** heavy

**Query Parameters:** `page_token`, `max`

### POST /user_groups — Create a user group
**Permission:** `user_groups:create` | **Rate Limit:** heavy

```json
{
  "name": "Accounting",
  "description": "Accounting Department",
  "external_id": "acct-123",
  "category_ids": [1, 2]
}
```

### GET /user_groups/{id} — Get user group by ID
**Permission:** `user_groups:read` | **Rate Limit:** heavy

Returns group details including users and categories.

### PUT /user_groups/{id} — Update a user group
**Permission:** `user_groups:update` | **Rate Limit:** heavy

```json
{
  "name": "Accounting Team",
  "description": "Updated description",
  "external_id": "acct-456",
  "category_ids": [1, 2, 3]
}
```

### DELETE /user_groups/{id} — Delete a user group
**Permission:** `user_groups:delete` | **Rate Limit:** heavy

### PUT /user_groups/{id}/add_users — Add users to group
**Permission:** `user_groups:update` | **Rate Limit:** heavy

Body is a plain array of user IDs:
```json
[92, 93, 94]
```

### PUT /user_groups/{id}/remove_users — Remove users from group
**Permission:** `user_groups:update` | **Rate Limit:** heavy

Body is a plain array of user IDs:
```json
[94]
```

## User Group Object

```json
{
  "id": 117,
  "name": "Accounting",
  "description": "Accounting Department",
  "external_id": "acct-123",
  "categories": [...],
  "users": [
    {
      "id": 92,
      "name": "Jane Doe",
      "email": "jane@company.com",
      "role": "Reviewer",
      "role_id": 80,
      "disabled": false
    }
  ],
  "created_at": "2024-01-01T00:00:00.000Z",
  "updated_at": "2024-06-15T12:00:00.000Z"
}
```

## Roles

### GET /roles — List all roles
**Permission:** `roles:read` | **Rate Limit:** heavy

Returns available roles that can be assigned to users.

## Examples

```bash
# List all users
./scripts/tl-curl.sh GET /users

# Get current user
./scripts/tl-curl.sh GET /users/me

# Create a user
./scripts/tl-curl.sh POST /users -d '{"name":"Jane Doe","email":"jane@company.com","role_id":80}'

# Disable a user
./scripts/tl-curl.sh PUT /users/92/disable

# Create a user group
./scripts/tl-curl.sh POST /user_groups -d '{"name":"Trading Desk","description":"Trading desk team"}'

# Add users to a group
./scripts/tl-curl.sh PUT /user_groups/117/add_users -d '{"user_ids":[92,93]}'

# List available roles
./scripts/tl-curl.sh GET /roles
```
