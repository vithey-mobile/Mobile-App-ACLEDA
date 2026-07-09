# Chat Service — DB Schema

Database: `chat_db`

Use Flyway migrations under `src/main/resources/db/migration/`.

- `V1__init_chat_schema.sql` — base tables
- `V2__message_media_and_reply.sql` — `message_type`, `file_id`, `reply_to`, `client_message_id`

## Tables

### `conversations`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `status` | varchar(32) | `PENDING`, `ACTIVE`, `BLOCKED`, `DECLINED` |
| `created_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |

### `conversation_participants`

| Column | Type | Rules |
| --- | --- | --- |
| `conversation_id` | UUID | FK → conversations |
| `user_id` | UUID | indexed |
| `role` | varchar(32) | `REQUESTER`, `RECIPIENT` |
| `joined_at` | timestamptz | not null |

Primary key: `(conversation_id, user_id)`.

Optional: store sorted pair `(participant1_id, participant2_id)` on `conversations` with unique constraint to prevent duplicate threads.

### `messages`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `conversation_id` | UUID | indexed |
| `sender_id` | UUID | indexed |
| `text` | text | nullable for pure media |
| `message_type` | varchar(16) | `TEXT`, `IMAGE`, `FILE` — default `TEXT` |
| `file_id` | UUID | nullable; references file-service metadata |
| `reply_to_message_id` | UUID | nullable FK → messages.id |
| `client_message_id` | varchar(64) | nullable; unique per (conversation_id, sender_id) |
| `status` | varchar(32) | `SENT`, `DELIVERED`, `READ` |
| `deleted_at` | timestamptz | nullable soft-delete |
| `created_at` | timestamptz | not null |

Unique index (partial): `(conversation_id, sender_id, client_message_id)` WHERE `client_message_id IS NOT NULL`.

### `blocks`

| Column | Type | Rules |
| --- | --- | --- |
| `blocker_id` | UUID | |
| `blocked_id` | UUID | |
| `created_at` | timestamptz | |

Unique: `(blocker_id, blocked_id)`.

### `user_reports`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `reporter_id` | UUID | |
| `reported_id` | UUID | |
| `reason` | text | not null |
| `created_at` | timestamptz | |

## Indexes

- `conversation_participants.user_id`
- `messages.conversation_id, messages.created_at DESC`
- `messages.sender_id`
- `blocks.blocker_id, blocks.blocked_id`

## What is NOT in PostgreSQL

| Data | Store |
| --- | --- |
| Online status | Redis `chat:presence:{userId}` |
| Typing state | Redis `chat:typing:{conv}:{user}` |
| Recent message window | Redis `chat:recent:{conv}` |
| File binary | MinIO via file-service |
| FCM tokens | notification-service DB |

## V2 migration sketch

```sql
ALTER TABLE messages
  ADD COLUMN message_type varchar(16) NOT NULL DEFAULT 'TEXT',
  ADD COLUMN file_id uuid,
  ADD COLUMN reply_to_message_id uuid REFERENCES messages(id),
  ADD COLUMN client_message_id varchar(64),
  ADD COLUMN deleted_at timestamptz;

CREATE UNIQUE INDEX uq_messages_client_id
  ON messages (conversation_id, sender_id, client_message_id)
  WHERE client_message_id IS NOT NULL;
```
