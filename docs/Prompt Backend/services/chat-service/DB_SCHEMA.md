# Chat Service — DB Schema

Database: `chat_db`

Flyway migrations:

- `src/main/resources/db/migration/V1__init_chat_schema.sql`
- `src/main/resources/db/migration/V2__Chat_indexes_checks_and_drop_dead.sql`

## Tables

### `conversations`

`id` UUID PK, `status` varchar(32), `created_at` timestamptz, `updated_at` timestamptz.

Status CHECK: `PENDING`, `ACTIVE`, `BLOCKED`, `DECLINED`.

### `conversation_participants`

`conversation_id` UUID, `user_id` UUID, `role` varchar(32), `joined_at` timestamptz.

Primary key: `(conversation_id, user_id)`.

Role CHECK: `REQUESTER`, `RECIPIENT`.

### `messages`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `conversation_id` | UUID | indexed with `created_at` |
| `sender_id` | UUID | not null |
| `text` | text | not null |
| `status` | varchar(32) | CHECK: `SENT`, `DELIVERED`, `READ` |
| `created_at` | timestamptz | not null |

### `blocks`

`blocker_id` UUID, `blocked_id` UUID, `created_at` timestamptz.

Unique / PK: `(blocker_id, blocked_id)`.

### `user_reports`

`id` UUID PK, `reporter_id` UUID, `reported_id` UUID, `reason` text, `created_at` timestamptz.

## Indexes / constraints (current)

- `idx_conversations_updated_at` on `(updated_at DESC)`
- `idx_conversations_status` on `(status)`
- `idx_conversation_participants_user` on `(user_id)`
- `idx_messages_conversation_created` on `(conversation_id, created_at DESC)`
- `idx_blocks_blocked` on `(blocked_id)`
- CHECK: `chk_conversations_status`, `chk_conversation_participants_role`, `chk_messages_status`

## V2 notes

- Added conversation status/updated indexes and enum CHECKs.
- Dropped unused indexes: `idx_messages_sender`, `idx_blocks_blocker`, `idx_user_reports_reporter`, `idx_user_reports_reported`.
