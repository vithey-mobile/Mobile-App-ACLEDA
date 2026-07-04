# Notification Service — DB Schema

Database: `notification_db`

Use Flyway migration: `src/main/resources/db/migration/V1__init_notification_schema.sql`

## Tables

### `notifications`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | indexed |
| `type` | varchar(32) | notification type |
| `title` | varchar(180) | not null |
| `body` | text | not null |
| `reference_id` | UUID | nullable |
| `reference_type` | varchar(64) | nullable |
| `is_read` | boolean | default false |
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

- `notifications.user_id, notifications.created_at`
- `notifications.user_id, notifications.is_read`
- `device_tokens.user_id`
- unique `device_tokens.fcm_token`

