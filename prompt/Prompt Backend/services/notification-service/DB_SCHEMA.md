# Notification Service — DB Schema

Database: `notification_db`

Use Flyway migrations:

- `V1__init_notification_schema.sql` — base tables
- `V2__notification_ui_upgrade.sql` — UI contract fields (see **`UPGRADE_FOR_UI.md`**)

## Tables

### `notifications`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | indexed — recipient |
| `type` | varchar(32) | notification type enum |
| `event` | varchar(64) | RabbitMQ event name e.g. `reaction.added` |
| `title` | varchar(180) | not null |
| `body` | text | not null |
| `reference_id` | UUID | nullable — legacy; prefer `destination` |
| `reference_type` | varchar(64) | nullable — legacy |
| `destination` | jsonb | structured deep-link payload |
| `actor_id` | UUID | nullable |
| `actor_name` | varchar(120) | nullable — denormalized |
| `actor_avatar_url` | text | nullable |
| `dedupe_key` | varchar(180) | nullable — unique per user when set |
| `is_read` | boolean | default false |
| `read_at` | timestamptz | nullable |
| `created_at` | timestamptz | not null |

### `device_tokens`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | indexed |
| `fcm_token` | text | unique, not null |
| `platform` | varchar(16) | `ANDROID`, `IOS` |
| `created_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |

## Indexes

- `notifications (user_id, created_at DESC)`
- `notifications (user_id, is_read, created_at DESC)` — unread filter
- unique partial `notifications (user_id, dedupe_key) WHERE dedupe_key IS NOT NULL`
- `device_tokens (user_id)`
- unique `device_tokens (fcm_token)`

## `destination` JSON (example)

```json
{
  "reference_type": "POST",
  "reference_id": "uuid",
  "post_id": "uuid",
  "comment_id": "uuid",
  "conversation_id": "uuid",
  "job_post_id": "uuid",
  "application_id": "uuid",
  "payment_id": "uuid",
  "ai_thread_id": "uuid"
}
```

Only include keys relevant to the notification type.
