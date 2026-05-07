# Theta Lake API — Authentication Guide

## Authentication Methods

The API supports two authentication methods:

### 1. Bearer JWT (API Token)
Direct API token authentication. Tokens are created in the Theta Lake portal.

```
Authorization: Bearer <jwt-token>
```

- Tokens have an expiry date (visible via `/token/context`)
- Tokens are scoped with specific permissions
- Tokens are tied to a specific data center

### 2. OAuth2 Client Credentials
Machine-to-machine authentication using OAuth2 client credentials flow.

**Token endpoint:** `POST /token`

```bash
curl -X POST "$TL_BASE_URL/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=YOUR_CLIENT_ID&client_secret=YOUR_CLIENT_SECRET"
```

Response:
```json
{
  "access_token": "eyJ...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

Notes:
- Token is received in the response body (per `x-receive-token-in: request-body`)
- Tokens expire — check `expires_in` and refresh before expiry
- No scopes required in the request (scopes are configured on the client)

## Token Validation

### GET /token/context
Validates the current token and returns context information.

**Permission:** None required (works with any valid token)
**Rate Limit:** medium

**Response:**
```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "uuid",
  "context": {
    "created_at": "2024-01-15T10:00:00.000Z",
    "data_center": "US East",
    "expires_at": "2025-01-15T10:00:00.000Z",
    "name": "My API key",
    "permissions": [
      "audit_logs:read",
      "cases:read",
      "cases:create",
      "search:create",
      ...
    ],
    "type": "jwt"  // or "oauth" or "third_party"
  }
}
```

**Token types:**
- `jwt` — Direct API token
- `oauth` — OAuth2 client credentials token
- `third_party` — Third-party integration token (includes `integration_id`)

## Permission Model

Permissions follow the pattern `resource:action`:
- `read` — List/get operations
- `create` — Create operations
- `update` — Update operations
- `delete` — Delete operations
- Some special ones: `search:create`, `search:reset`, `identities:merge`

Common permission groups:
- **Read-only:** `*:read` permissions
- **Full access:** `*:read`, `*:create`, `*:update`, `*:delete`
- **Search:** `search:create`, `search:read`, `search:reset`

## Using tl-curl.sh

The `scripts/tl-curl.sh` wrapper handles authentication automatically:
1. Loads credentials from `.env.theta-lake`
2. Prefers `TL_API_TOKEN` if set (direct JWT)
3. Falls back to OAuth2 client credentials if `TL_CLIENT_ID` + `TL_CLIENT_SECRET` + `TL_TOKEN_URL` are set
4. Automatically retries with a fresh token on 401 (OAuth only)

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| 401 Unauthorized | Token missing, expired, or malformed | Check `TL_API_TOKEN` or refresh OAuth token |
| 403 Forbidden | Token lacks required permission | Check `/token/context` for permissions list |
| Token expired | JWT or OAuth token past expiry | Generate new token or use OAuth auto-refresh |
