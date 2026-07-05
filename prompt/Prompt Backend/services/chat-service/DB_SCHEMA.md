# Chat Service — DB Schema

Database: `chat_db`

Use Flyway migration: `src/main/resources/db/migration/V1__init_chat_schema.sql`

## Tables

### `conversations`

`id` UUID PK, `status` varchar(32), `created_at` timestamptz, `updated_at` timestamptz.

Status: `PENDING`, `ACTIVE`, `BLOCKED`, `DECLINED`.

### `conversation_participants`

`conversation_id` UUID, `user_id` UUID, `role` varchar(32), `joined_at` timestamptz.

Primary key: `(conversation_id, user_id)`.

### `messages`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `conversation_id` | UUID | indexed |
| `sender_id` | UUID | indexed |
| `text` | text | not null |
| `status` | varchar(32) | `SENT`, `DELIVERED`, `READ` |
| `created_at` | timestamptz | not null |

### `blocks`

`blocker_id` UUID, `blocked_id` UUID, `created_at` timestamptz.

Unique: `(blocker_id, blocked_id)`.

### `user_reports`

`id` UUID PK, `reporter_id` UUID, `reported_id` UUID, `reason` text, `created_at` timestamptz.

## Indexes

- `conversation_participants.user_id`
- `messages.conversation_id, messages.created_at`
- `blocks.blocker_id, blocks.blocked_id`

