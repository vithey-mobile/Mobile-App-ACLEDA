# Notification Service — DB Schema

Database: `notification_db`

Flyway migrations:

- `src/main/resources/db/migration/V1__init_notification_schema.sql`
- `src/main/resources/db/migration/V2__Notification_type_and_platform_checks.sql`

## Tables

### `notifications`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | indexed |
| `type` | varchar(32) | CHECK: `LIKE`, `COMMENT`, `MENTION`, `FOLLOW`, `CHAT`, `CHAT_REQUEST`, `PAYMENT`, `JOB` |
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
| `platform` | varchar(16) | CHECK: `ANDROID`, `IOS` |
| `created_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |

## Indexes / constraints (current)

- `idx_notifications_user_created` on `(user_id, created_at DESC)`
- `idx_notifications_user_read` on `(user_id, is_read)`
- `idx_device_tokens_user` on `(user_id)`
- Unique: `uq_device_tokens_fcm_token`
- CHECK: `chk_notifications_type`, `chk_device_tokens_platform`

## V2 notes

- Added CHECK constraints for notification `type` and device `platform` enums.
