# File Service — DB Schema

Database: `file_db`

Flyway migrations:

- `src/main/resources/db/migration/V1__init_file_schema.sql`
- `src/main/resources/db/migration/V2__Drop_unused_file_metadata_indexes.sql`
- `src/main/resources/db/migration/V3__File_type_size_checks_and_owner_active_index.sql`

## Tables

### `file_metadata`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `owner_user_id` | UUID | not null |
| `file_name` | varchar(255) | original file name |
| `file_type` | varchar(32) | `AVATAR`, `CV`, `POSTER`, `VIDEO`, `CHAT_ATTACHMENT` |
| `mime_type` | varchar(160) | not null |
| `size_bytes` | bigint | not null |
| `bucket` | varchar(64) | not null |
| `object_key` | text | unique, not null |
| `created_at` | timestamptz | not null |
| `deleted_at` | timestamptz | nullable |

## Indexes / constraints (current)

- Unique: `uq_file_metadata_object_key` on `(object_key)`

## V2 notes

Dropped unused indexes:

- `idx_file_metadata_owner_user_id`
- `idx_file_metadata_file_type`
- `idx_file_metadata_active`

## V3 notes

- Replaces the V1 `file_type` check constraint with the current enum values (`AVATAR`, `CV`, `POSTER`, `VIDEO`, `CHAT_ATTACHMENT`)
- Replaces the `size_bytes > 0` check (drop + re-add under the same name)
- Ensures the partial index `idx_file_metadata_owner_active` (owner + `deleted_at IS NULL`) exists

## Storage mapping

- `bucket` column: e.g. `avatars`, `cvs`, `posters`, `videos`, `chat-attachments`
- Stored `object_key` (bucket is **not** in the key):

```text
<owner_user_id>/<file_id>/<safe_file_name>
```
