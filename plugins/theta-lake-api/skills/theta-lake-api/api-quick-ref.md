# Theta Lake API — Quick Reference

> All endpoints require `Authorization: Bearer <token>`. Base URL from `.env.theta-lake`.
> Rate limits: `light` (highest throughput) → `medium` → `heavy` (lowest throughput).
> All responses include `status_code`, `status_string`, `request_id`.

## Analysis

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/analysis/policies` | List all policies | `policies:read` | heavy |
| GET | `/analysis/policies/{id}` | Get a policy by id (includes detection rules + SWRV rules) | `policies:read` | heavy |
| GET | `/analysis/policy_hits` | List all policy hits | `analysis:read` | medium |
| GET | `/analysis/detection_rules` | List all detection rules. Params: `page_token`, `max` | `analysis:read` | medium |
| GET | `/analysis/detection_rules/{id}` | Get detection rule by ID (full config + rules) | `analysis:read` | medium |
| GET | `/analysis/detection_rules/{id}/stats` | Detection rule stats (beta). Params: `start`, `end` (required, date-time) | `analysis:read_stats` | heavy |
| GET | `/analysis/inputs` | List all custom detection rule inputs. Params: `page_token`, `max` | `analysis:read` | medium |
| GET | `/analysis/detection_rules/{id}/inputs` | List custom detection rule inputs for a detection rule | `analysis:read` | medium |
| GET | `/analysis/detection_rules/{id}/inputs/{input-id}` | Get custom detection rule input by ID | `analysis:read` | medium |
| GET | `/analysis/detection_rules/{id}/inputs/{input-id}/download` | Download custom detection rule input (binary) | `analysis:read` | heavy |
| POST | `/analysis/detection_rules/{id}/inputs` | Upload custom detection rule input. Body: multipart `meta` (name) + `file` | `analysis:create` | heavy |
| PUT | `/analysis/detection_rules/{id}/inputs/{input-id}/activate` | Activate input (deactivates all others for this rule) | `analysis:update` | heavy |
| PUT | `/analysis/detection_rules/{id}/inputs/{input-id}/deactivate` | Deactivate custom detection rule input | `analysis:update` | heavy |
| DELETE | `/analysis/detection_rules/{id}/inputs/{input-id}` | Delete custom detection rule input | `analysis:delete` | heavy |

## Audit Logs

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/audit_logs` | List all audit logs (paginated, no prev pages). Params: `user_id`, `auditable_type`, `from_date`, `to_date`, `auditable_action`, `order`, `page_token`, `max` (1-500, default 25) | `audit_log:read` | heavy |
| GET | `/audit_logs/config_change` | List config change audit logs. Params: `from_date`, `to_date`, `page_token`, `max` | `audit_log:read` | heavy |
| POST | `/audit_logs/search` | Search audit logs. Body: `auditable_action[]`, `auditable_type[]`, `range` (start/end), `source` (type, user_id[]), `order`. Params: `page_token` (60s expiry), `max` (1-500) | `audit_log:read` | heavy |

## Cases

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/cases` | List all cases. Params: `page_token`, `max`, `status` (open/closed) | `cases:read` | medium |
| POST | `/cases` | Create a case. Body: `name` (required), `description` | `cases:create` | medium |
| GET | `/cases/{id}` | Get a case by id | `cases:read` | medium |
| PUT | `/cases/{id}` | Update a case. Body: `name`, `description` | `cases:update` | medium |
| GET | `/cases/{id}/records` | List records in a case. Params: `page_token`, `max` | `cases:read` | medium |
| POST | `/cases/{id}/records` | Add records to a case. Body: `record_ids` (array of ints) | `cases:update` | medium |
| DELETE | `/cases/{id}/records` | Remove records from a case. Body: `record_ids` (array of ints) | `cases:update` | medium |
| PUT | `/cases/{id}/managers` | Add manager to a case. Body: `user_id` (required) | `cases:update` | medium |
| DELETE | `/cases/{id}/managers/{user_id}` | Remove manager from a case | `cases:update` | medium |
| PUT | `/cases/{id}/close` | Close a case. Body: `resolution` (required) | `cases:update` | medium |
| PUT | `/cases/{id}/open` | Open a case | `cases:update` | medium |

## Directory Groups

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/directory_groups` | List all directory groups. Params: `page_token`, `max`, `include_identities` (bool, default true) | `directory_group:read` | light |
| POST | `/directory_groups` | Create a directory group. Body: `name`, `external_id`, `description` | `directory_group:create` | light |
| GET | `/directory_groups/{id}` | Get a directory group by id. Params: `include_identities` | `directory_group:read` | light |
| PUT | `/directory_groups/{id}` | Update a directory group. Body: `name`, `external_id`, `description` | `directory_group:update` | light |
| DELETE | `/directory_groups/{id}` | Delete a directory group | `directory_group:delete` | light |
| POST | `/directory_groups/{id}/identities` | Bulk-add existing identities. Body: array of identity IDs | `directory_group:update` | light |
| GET | `/directory_groups/{id}/identities` | List identities in a directory group. Params: `page_token`, `max` | `directory_group:read` | light |
| POST | `/directory_groups/{id}/identity` | Create new identity in a directory group. Body: `name`, `email`, `phone_number`, `external_id` | `directory_group:update` | light |
| DELETE | `/directory_groups/{id}/identity/{identity_id}` | Remove identity from a directory group | `directory_group:update` | light |
| POST | `/directory_groups/upload` | Upload CSV of directory groups & identities. Body: multipart `file` | `directory_group:update` | light |

## Identities

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/identities` | List all identities. Params: `page_token`, `max`, `query`, `field_name` (email/name/phone_number/external_id/id) | `identities:read` | light |
| PUT | `/identities` | Merge identities (sync). Body: `identity_ids[]`, `target_identity_id` | `identities:update` | heavy |
| POST | `/identities` | Create an identity. Body: `name`, `email`, `phone_number`, `external_id`, `extra_attributes[]` (+ date fields) | `identities:create` | light |
| PUT | `/identities/merge/async` | Merge identities (async). Body: `identity_ids[]`, `target_identity_id`, `reset_and_reenter_reason` | `identities:update` | heavy |
| GET | `/identities/merge/async/{uuid}` | Get async merge status | `identities:update` | heavy |
| GET | `/identities/search` | Search identities. Params: `date_type`, `start`, `end`, `managed`, `page_token`, `max` | `identities:read` | light |
| GET | `/identities/{id}` | Get an identity by id | `identities:read` | light |
| PUT | `/identities/{id}` | Update an identity. Body: `name`, `email`, `phone_number`, `external_id` (+ date fields) | `identities:update` | light |
| DELETE | `/identities/{id}` | Delete an identity (fails if identity has connections) | `identities:delete` | light |
| POST | `/identities/{id}/extra_attributes` | Add extra attributes (max 50). Body: `extra_attributes[]` (field, value, source, dates) | `identities:update` | heavy |
| PUT | `/identities/{id}/extra_attributes` | Update extra attributes (max 50). Body: `extra_attributes[]` (id required) | `identities:update` | heavy |
| GET | `/identities/{id}/supervision_spaces` | List identity's supervision spaces (beta) | `supervision_spaces:read` | heavy |
| GET | `/identities/{id}/risk` | Get identity risk log. Params: `page_token`, `max` | `identities:read` | light |
| POST | `/identities/{id}/risk` | Flag identity as risky. Body: `datum_id`, `risky`, `comment` | `identities:update` | light |
| GET | `/identities/extra_attributes/{id}` | Get an extra attribute by id | `identities:read` | light |
| PUT | `/identities/extra_attributes/{id}` | Update an extra attribute. Body: `field`, `value`, dates | `identities:update` | light |
| DELETE | `/identities/extra_attributes/{id}` | Delete an extra attribute | `identities:update` | light |
| PUT | `/identities/extra_attributes/{id}/make_primary` | Make an extra attribute primary (swaps values) | `identities:update` | light |

## Data Ingestion

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/ingestion/exists` | Check if data exists. Params: `hash_sha256[]` or `identity_data[]` (max 20 each) | `ingestion:read` | light |
| POST | `/ingestion/integration/{id}/ai_interactions` | Upload AI interaction. multipart/form-data: `meta` (JSON), `ai_interaction` (JSON) | `ingestion:upload` | heavy |
| POST | `/ingestion/integration/{id}/audio` | Upload audio. multipart/form-data: `meta` (JSON), `data` (file). Headers: `X-Thetalake-Metaonly`, `X-Thetalake-Content-Type` | `ingestion:upload` | heavy |
| POST | `/ingestion/integration/{id}/chat` | Upload chat. multipart/form-data: `meta` (JSON), `chat` (JSON with app, conversation, participants, messages) | `ingestion:upload` | heavy |
| POST | `/ingestion/integration/{id}/document` | Upload document. multipart/form-data: `meta` (JSON), `data` (file) | `ingestion:upload` | heavy |
| POST | `/ingestion/integration/{id}/email` | Upload email. multipart/form-data: `meta` (JSON), `data` (.eml, Content-Type: message/rfc822) | `ingestion:upload` | heavy |
| POST | `/ingestion/integration/{id}/other` | Upload other file. multipart/form-data: `meta` (JSON), `data` (file) | `ingestion:upload` | heavy |
| GET | `/ingestion/integration/{id}/state` | Get integration state | `ingestion:read` | heavy |
| PUT | `/ingestion/integration/{id}/state` | Update integration state. Body: `internal` (JSON), `last_run`, `status` | `ingestion:update` | heavy |
| POST | `/ingestion/integration/{id}/video` | Upload video. multipart/form-data: `meta` (JSON), `data` (file) | `ingestion:upload` | heavy |
| GET | `/ingestion/quota` | Get upload quota. Params: `from` (YYYY-MM-DD), `to` | `ingestion:read` | heavy |

## Integrations

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/integrations` | List all integrations | `integrations:read` | heavy |
| GET | `/integrations/{id}` | Get an integration by id | `integrations:read` | heavy |
| GET | `/integrations/{id}/run_history` | Get run history. Params: `start`, `end` (date-time), `page_token`, `max` | `integrations:read` | heavy |
| GET | `/integrations/user_installs` | Get user install status. Params: `integration_type` (required, e.g. ms_teams), `tenant_id` (required), `account_user_id`, `email` | `integrations:read` | minimal |
| GET | `/integrations/{id}/installed_users` | List installed users. Params: `page_token`, `max` | `integrations:read` | heavy |

## Labels

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/labels` | List all labels | `labels:read` | heavy |
| POST | `/labels` | Create a label. Body: `short_name`, `long_name`, `background_color` (hex), `hidden` (bool) | `labels:create` | heavy |
| GET | `/labels/{id}` | Get a label by id | `labels:read` | heavy |
| PUT | `/labels/{id}` | Update a label. Body: `short_name`, `long_name`, `background_color`, `hidden` | `labels:update` | heavy |
| DELETE | `/labels/{id}` | Delete a label | `labels:delete` | heavy |
| POST | `/labels/{label_id}/records/{record_id}` | Apply a label to a record | `labels:use` | heavy |
| DELETE | `/labels/{label_id}/records/{record_id}` | Remove a label from a record | `labels:use` | heavy |

## Legal Hold

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/legal_hold` | List all legal holds | `legal_hold:read` | medium |
| POST | `/legal_hold` | Create a legal hold. Body: `name` (required), `description` | `legal_hold:create` | heavy |
| GET | `/legal_hold/{id}` | Get a legal hold by id | `legal_hold:read` | heavy |
| PUT | `/legal_hold/{id}` | Update a legal hold. Body: `name`, `description` | `legal_hold:update` | heavy |
| GET | `/legal_hold/{id}/logs` | Get legal hold logs | `legal_hold:read` | heavy |
| GET | `/legal_hold/roles` | List legal hold roles | `legal_hold:read` | medium |
| GET | `/legal_hold/{id}/rules` | List rules for a legal hold. Params: `page_token`, `max` | `legal_hold:read` | medium |
| POST | `/legal_hold/{id}/rules` | Create a rule. Body: `identity_id` (required), `roles[]` (required, from /legal_hold/roles), `start_date`, `end_date` | `legal_hold:update` | heavy |
| PUT | `/legal_hold/{id}/rules/{rule_id}` | Update a legal hold rule. Same body as POST | `legal_hold:update` | heavy |
| DELETE | `/legal_hold/{id}/rules/{rule_id}` | Delete a legal hold rule | `legal_hold:delete` | heavy |

## Org Units

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/org_units` | List all org units | `org_units:read` | heavy |
| GET | `/org_units/current` | Get the current org unit | `org_units:read` | heavy |
| GET | `/org_units/{id}` | Get an org unit by id | `org_units:read` | heavy |
| PUT | `/org_units/{id}` | Update an org unit. Body: `allow_anonymous_via_shared_links`, `analysis_supervision_space_ids[]`, `audit_log_retention_period`, `default_org_timezone`, `delete_on_expiration`, `fallback_language`, `preferred_languages[]`, `use_name_matcher`, `use_owner_only_space_matcher` | `org_units:update` | heavy |
| PUT | `/org_units/{id}/switch` | Switch to an org unit (changes context for subsequent API calls). Returns 403 ForbiddenOrgChange if not a member | none | heavy |

## Reconciliation

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| POST | `/reconciliation` | Reconcile records. Body: `range` (type, start, end; max 7 days), `queries[]` (platform (required), attribute (name+value), media_types, integration_id, includes_timestamp; max 500) | `reconciliation:read` | medium |
| POST | `/reconciliation/count` | Count records by platform. Body: `platform`, `integration_id`, `start`, `end`, `type` (create_date/upload_date) | `reconciliation:read` | medium |

## Records

> Full documentation with response schemas: [`records-api.md`](records-api.md)

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/records/{id}/archive_handles` | Get archive handles for a record (id or UUID) | `records:read` | heavy |
| GET | `/records/{id}/comments` | Get comments for a record (id or UUID) | `comments:read` | medium |
| POST | `/records/{id}/comments` | Create a comment on a record. Body: `comment` (required), `parent_id` (optional, for replies) | `comments:create` | medium |
| PUT | `/records/{id}/comments/{comment_id}` | Update a comment. Body: `comment` (required) | `comments:update` | medium |
| DELETE | `/records/{id}/comments/{comment_id}` | Delete a comment | `comments:delete` | medium |
| GET | `/records/{id}/content` | Download original record content as binary (**licensed**) | `records:read` | heavy |
| GET | `/records/{id}/policy_hits` | Get policy hits/detections for a record (**licensed**) | `records:read` | heavy |
| GET | `/records/{id}/sentences` | Get sentences/transcribed text for a record (**licensed**) | `records:read` | heavy |
| GET | `/records/{id}/shareable_link` | Get a shareable link for a record (id or UUID) | `records:read` | heavy |
| GET | `/records/{id}/workflow_history` | Get workflow history for a record (id or UUID) | `workflows:read` | heavy |
| GET | `/records/quota` | Get download quota info (bytes allotted/used/remaining, reset date) | `records:read` | medium |

## Retention Libraries

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/retention_libraries` | List all retention libraries. Params: `page_token`, `max` | `retention_libraries:read` | heavy |
| POST | `/retention_libraries` | Create a retention library. Body: `name` (required), `storage_account_id` (required), `description`, `external_id`, `sec_compliant_storage_enabled`, `retention_period_enabled`, `retention_period_days`, `retain_in_review` | `retention_libraries:create` | heavy |
| GET | `/retention_libraries/{id}` | Get a retention library by id | `retention_libraries:read` | heavy |
| PUT | `/retention_libraries/{id}` | Update a retention library. Same fields as POST (all optional) | `retention_libraries:update` | heavy |
| DELETE | `/retention_libraries/{id}` | Delete a retention library | `retention_libraries:delete` | heavy |

## Reviews

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/reviews/escalated_comments` | List escalated comments. Params: `start` (date-time), `end` (date-time) | `comments:read` | heavy |

## Roles

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/roles` | List all roles | `roles:read` | heavy |

## Search

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| POST | `/search/records` | Search records (max 10,000). Body: complex — see `search-api.md`. Params: `page_token`, `max` (0-100, default 25) | `search:create` | heavy + dynamic |
| POST | `/search/records/ids` | Search records by IDs (up to 100). Body: `id[]` or `uuid[]`, `sort`. No date restriction | `search:create` | heavy |
| GET | `/search/saved` | List saved searches. Params: `types` (required: history/private/workflow/security_filter), `page_token`, `max` | `search:read` | heavy |
| GET | `/search/saved/{id}` | Run a saved search by ID. Params: `page_token`, `max` | `search:read` | heavy |
| POST | `/search/saved/{id}/reset_and_reenter` | Reset & reenter records to workflow (max 20,000). Body: `reason` (required) | `search:reset` | heavy |

## Storage Accounts

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/storage_accounts` | List all storage accounts | `storage_accounts:read` | heavy |

## Supervision Spaces

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/supervision_spaces` | List all supervision spaces. Params: `page_token`, `max` (1-500) | `supervision_spaces:read` | heavy |
| POST | `/supervision_spaces` | Create. Body: `name`, `description`, `all_participants`, `all_users`, `directory_group_ids[]`, `integration_ids[]`, `media_type_ids[]` (1=Video,2=Audio,3=Chat,4=Attachment,5=Email), `retention_library_ids[]`, `external_id`, `hard_enforce`, `supervision_space_priority` | `supervision_spaces:create` | heavy |
| GET | `/supervision_spaces/{id}` | Get by id (detailed) | `supervision_spaces:read` | heavy |
| PUT | `/supervision_spaces/{id}` | Update (same body as POST) | `supervision_spaces:update` | heavy |
| DELETE | `/supervision_spaces/{id}` | Delete | `supervision_spaces:delete` | heavy |
| POST | `/supervision_spaces/{id}/directory_groups` | Add directory groups. Body: array of IDs | `supervision_spaces:update` | heavy |
| DELETE | `/supervision_spaces/{id}/directory_groups` | Remove directory groups. Body: array of IDs | `supervision_spaces:update` | heavy |
| POST | `/supervision_spaces/{id}/identities` | Add identities. Body: array of identity IDs (max 500) | `supervision_spaces:update` | heavy |
| POST | `/supervision_spaces/{id}/participants` | Add participants. Body: `participants_text` (semi-CSV: name, email, phone per line) | `supervision_spaces:update` | heavy |
| DELETE | `/supervision_spaces/{id}/participants` | Remove participants. Body: `identity_ids[]` | `supervision_spaces:update` | heavy |
| POST | `/supervision_spaces/{id}/user_groups` | Add user groups. Body: array of IDs | `supervision_spaces:update` | heavy |
| DELETE | `/supervision_spaces/{id}/user_groups` | Remove user groups. Body: array of IDs | `supervision_spaces:update` | heavy |
| POST | `/supervision_spaces/{id}/users` | Add users. Body: array of user IDs | `supervision_spaces:update` | heavy |
| DELETE | `/supervision_spaces/{id}/users` | Remove users. Body: array of user IDs | `supervision_spaces:update` | heavy |

## Token

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/token/context` | Get token context (validates token, shows permissions, expiry, data center) | — | light |

## User Groups

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/user_groups` | List all user groups | `user_groups:read` | heavy |
| POST | `/user_groups` | Create a user group. Body: `name`, `description`, `external_id`, `category_ids[]` | `user_groups:create` | heavy |
| GET | `/user_groups/{id}` | Get a user group by id | `user_groups:read` | heavy |
| PUT | `/user_groups/{id}` | Update a user group. Body: `name`, `description`, `external_id`, `category_ids[]` | `user_groups:update` | heavy |
| DELETE | `/user_groups/{id}` | Delete a user group | `user_groups:delete` | heavy |
| PUT | `/user_groups/{id}/add_users` | Add users to a group. Body: array of user IDs | `user_groups:update` | heavy |
| PUT | `/user_groups/{id}/remove_users` | Remove users from a group. Body: array of user IDs | `user_groups:update` | heavy |

## Users

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/users` | List all users | `users:read` | heavy |
| POST | `/users` | Create a user. Body: `name`, `email`, `password`, `password_confirmation`, `role_id`, `search_id` | `users:create` | heavy |
| GET | `/users/me` | Get current user | `users:read` | heavy |
| GET | `/users/{id}` | Get a user by id | `users:read` | heavy |
| PUT | `/users/{id}` | Update a user. Body: `name`, `email`, `role_id`, `search_id` | `users:update` | heavy |
| DELETE | `/users/{id}` | Delete a user | `users:delete` | heavy |
| PUT | `/users/{id}/disable` | Disable a user | `users:disable` | heavy |
| PUT | `/users/{id}/enable` | Enable a user | `users:disable` | heavy |

## Workflows

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/workflows` | List all workflows | `workflows:read` | medium |
| GET | `/workflows/{id}` | Get a workflow by id (includes states + events) | `workflows:read` | medium |
| GET | `/workflows/queue` | List records in workflow queues. Params: `state_type` (open/closed/in_progress), `max`, `page_token` | `workflows:read` | medium |
| GET | `/workflows/record/{id}` | Get workflow actions for a record (id or UUID) — current state, available actions, assigned user | `workflows:read` | heavy |
| PUT | `/workflows/record/{id}` | Perform workflow action on a record. Body: `action_id`, `assign_to_user_id`, `comment` (all required) | `workflows:use` | heavy |
| GET | `/workflows/swrv_rules` | List all SWRV rules (ordered by priority) | `swrv_rules:read` | heavy |
| POST | `/workflows/swrv_rules` | Create SWRV rule. Body: `name`, `description`, `input_sources[]`, `policy_id`, `workflow_id`, `retention_library_id`, `supervision_space_id`, `priority` | `swrv_rules:create` | heavy |
| GET | `/workflows/swrv_rules/{id}` | Get a SWRV rule by id | `swrv_rules:read` | heavy |
| PUT | `/workflows/swrv_rules/{id}` | Update SWRV rule (same body as POST) | `swrv_rules:update` | medium |
| DELETE | `/workflows/swrv_rules/{id}` | Delete a SWRV rule | `workflows:delete` | medium |

## Workspaces

> Full documentation with response schemas: [`workspaces-api.md`](workspaces-api.md)

| Method | Path | Summary | Permission | Rate Limit |
|--------|------|---------|------------|------------|
| GET | `/workspaces` | List all workspaces | `workspaces:read` | heavy |
| GET | `/workspaces/current` | Get the current workspace | `workspaces:read` | heavy |
| GET | `/workspaces/{id}` | Get a workspace by id (full config, users, languages) | `workspaces:read` | heavy |
| PUT | `/workspaces/{id}` | Update a workspace. Body: `allow_anonymous_via_shared_links`, `analysis_supervision_space_ids[]`, `audit_log_retention_period`, `default_workspace_timezone`, `delete_on_expiration`, `fallback_language`, `preferred_languages[]`, `use_name_matcher`, `use_owner_only_space_matcher` | `workspaces:update` | heavy |
| PUT | `/workspaces/{id}/switch` | Switch to a workspace (changes context for subsequent API calls) | none | heavy |
| PUT | `/workspaces/{id}/users` | Add a user to a workspace. Body: `user_id` (required) | none | heavy |
| DELETE | `/workspaces/{id}/users/{user_id}` | Remove a user from a workspace | none | heavy |

---

## Common Response Format

All responses follow this structure:
```json
{
  "status_code": 200,
  "status_string": "OK",
  "request_id": "uuid-here",
  ...resource-specific fields...
}
```

## Error Codes

| Code | Name | Meaning |
|------|------|---------|
| 400 | Bad Request | Missing or malformed request body/query |
| 401 | Unauthorized | Missing or invalid JWT/OAuth token |
| 403 | Forbidden | Incorrect scopes/permissions on the API key |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Resource already exists |
| 415 | Unsupported Media Type | File content type not supported (ingestion) |
| 422 | Unprocessable Entity | Unable to process (bad upload, expired search) |
| 423 | Locked | Resource is locked |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error — include `request_id` in support ticket |
| 503 | Service Unavailable | Service temporarily unavailable |

## Pagination Pattern

Paginated endpoints use token-based pagination:
- Request: `?page_token=<token>&max=<limit>`
- Response includes `paging.next_page_token` and `paging.prev_page_token` (nullable)
- Default page size is 25 for most endpoints
- Some endpoints don't support previous pages (audit_logs, search)
- Tokens are base64-encoded and have an expiry time

## Date Formats

- **date-time**: RFC3339 format — `2024-01-15T14:30:00.000Z`
- **date**: RFC3339 full-date — `2024-01-15`
- All dates are **inclusive** in ranges
