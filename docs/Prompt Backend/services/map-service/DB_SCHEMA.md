# Map Service — DB Schema

Database: `map_db`

Flyway migrations:

- `src/main/resources/db/migration/V1__init_map_schema.sql`

## Tables

### `place_favorites`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | not null |
| `google_place_id` | varchar(255) | not null |
| `name` | varchar(255) | not null |
| `address` | varchar(512) | nullable |
| `latitude` | double precision | not null |
| `longitude` | double precision | not null |
| `category` | varchar(64) | nullable |
| `photo_url` | varchar(1024) | nullable |
| `created_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |

Unique: `(user_id, google_place_id)`.

Indexes:

- `idx_place_favorites_user_created` on `(user_id, created_at DESC)`

### `place_search_history`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `user_id` | UUID | not null |
| `query` | varchar(100) | nullable |
| `category` | varchar(64) | nullable |
| `latitude` | double precision | not null |
| `longitude` | double precision | not null |
| `radius_m` | int | not null, default 1500 |
| `created_at` | timestamptz | not null |

Indexes:

- `idx_place_search_history_user_created` on `(user_id, created_at DESC)`

## Notes

- Nearby/search result caching uses **Redis**, not PostgreSQL, in v1.
- Optional later table `place_snapshots` may store detail JSON with `expires_at` if Redis is unavailable — not required for v1.
- Do not store Google API keys or session tokens in the database.
