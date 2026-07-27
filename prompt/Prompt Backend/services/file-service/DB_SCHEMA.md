# File Service — DB Schema

Database: `file_db`

Flyway migrations:

- `src/main/resources/db/migration/V1__init_file_schema.sql`
- `src/main/resources/db/migration/V2__Drop_unused_file_metadata_indexes.sql`

## Tables

### `file_metadata`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `owner_user_id` | UUID | not null |
| `file_name` | varchar(255) | original file name |
| `file_type` | varchar(32) | `AVATAR`, `CV`, `POSTER`, `VIDEO` |
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

## Storage mapping

MinIO object key pattern:

```text
<bucket>/<owner_user_id>/<file_id>/<safe_file_name>
```
