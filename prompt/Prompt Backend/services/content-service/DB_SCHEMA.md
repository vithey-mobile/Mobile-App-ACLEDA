# Content Service — DB Schema

Database: `content_db`

Flyway migrations:

- `src/main/resources/db/migration/V1__init_content_schema.sql`
- `src/main/resources/db/migration/V2__Content_indexes_checks_and_drop_dead.sql`
- `src/main/resources/db/migration/V3__Restore_reaction_and_mention_indexes.sql`

## Tables

### `posts`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `author_id` | UUID | not null |
| `type` | varchar(32) | CHECK: `VIDEO`, `POSTER`, `JOB` |
| `content` | text | nullable |
| `media_file_id` | UUID | nullable (required for VIDEO/POSTER at API layer) |
| `job_title` | varchar(180) | nullable |
| `job_description` | text | nullable |
| `job_requirement` | text | nullable |
| `job_deadline` | date | nullable |
| `created_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |
| `deleted_at` | timestamptz | nullable (soft delete) |

### `comments`

`id` UUID PK, `post_id` UUID FK → `posts`, `author_id` UUID, `text` text, `created_at` timestamptz.

### `mentions`

`id` UUID PK, `comment_id` UUID FK → `comments`, `mentioned_user_id` UUID.

### `reactions`

`id` UUID PK, `post_id` UUID FK → `posts`, `user_id` UUID, `created_at` timestamptz.

Unique: `(post_id, user_id)`.

### `follows`

`id` UUID PK, `follower_id` UUID, `following_id` UUID, `created_at` timestamptz.

Unique: `(follower_id, following_id)`.

## Indexes / constraints (current)

- `idx_posts_author_created_active` on `(author_id, created_at DESC)` WHERE `deleted_at IS NULL`
- `idx_comments_post_created` on `(post_id, created_at DESC)`
- `idx_reactions_post` on `(post_id)` — restored in V3 (needed for count-by-post)
- `idx_mentions_comment` on `(comment_id)` — restored in V3
- `idx_follows_follower_created` on `(follower_id, created_at DESC)`
- `idx_follows_following_created` on `(following_id, created_at DESC)`
- Unique: `uq_reactions_post_user`, `uq_follows_pair`
- CHECK: `chk_posts_type` (`VIDEO` \| `POSTER` \| `JOB`)

## Migration notes

**V2:** Soft-delete-aware post index; follow composites; dropped several indexes including `idx_reactions_post` / mention indexes that were still useful for hot paths.

**V3:** Restores `idx_reactions_post` and `idx_mentions_comment` for batch enrichment and mention lookups.
