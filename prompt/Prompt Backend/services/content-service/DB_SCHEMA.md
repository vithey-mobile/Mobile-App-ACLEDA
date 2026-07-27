# Content Service — DB Schema

Database: `content_db`

Flyway migrations:

- `src/main/resources/db/migration/V1__init_content_schema.sql`
- `src/main/resources/db/migration/V2__Content_indexes_checks_and_drop_dead.sql`

## Tables

### `posts`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `author_id` | UUID | not null |
| `type` | varchar(32) | CHECK: `VIDEO`, `POSTER`, `JOB` |
| `content` | text | nullable |
| `media_file_id` | UUID | nullable |
| `job_title` | varchar(180) | nullable |
| `job_description` | text | nullable |
| `job_requirement` | text | nullable |
| `job_deadline` | date | nullable |
| `created_at` | timestamptz | not null |
| `updated_at` | timestamptz | not null |
| `deleted_at` | timestamptz | nullable |

### `comments`

`id` UUID PK, `post_id` UUID, `author_id` UUID, `text` text, `created_at` timestamptz.

### `mentions`

`id` UUID PK, `comment_id` UUID, `mentioned_user_id` UUID.

### `reactions`

`id` UUID PK, `post_id` UUID, `user_id` UUID, `created_at` timestamptz.

Unique: `(post_id, user_id)`.

### `follows`

`id` UUID PK, `follower_id` UUID, `following_id` UUID, `created_at` timestamptz.

Unique: `(follower_id, following_id)`.

## Indexes / constraints (current)

- `idx_posts_author_created_active` on `(author_id, created_at DESC)` WHERE `deleted_at IS NULL`
- `idx_comments_post_created` on `(post_id, created_at DESC)`
- `idx_follows_follower_created` on `(follower_id, created_at DESC)`
- `idx_follows_following_created` on `(following_id, created_at DESC)`
- Unique: `uq_reactions_post_user`, `uq_follows_pair`
- CHECK: `chk_posts_type`

## V2 notes

- Feed index is soft-delete aware (`deleted_at IS NULL`).
- Follow indexes are composites on `(…, created_at DESC)`.
- Dropped unused: `idx_posts_created`, `idx_posts_author_created`, `idx_follows_follower`, `idx_follows_following`, `idx_comments_author`, `idx_reactions_post`, `idx_mentions_comment`, `idx_mentions_user`.
