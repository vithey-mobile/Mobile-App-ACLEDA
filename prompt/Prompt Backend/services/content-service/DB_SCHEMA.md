# Content Service — DB Schema

Database: `content_db`

Use Flyway migration: `src/main/resources/db/migration/V1__init_content_schema.sql`

## Tables

### `posts`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | UUID | PK |
| `author_id` | UUID | indexed |
| `type` | varchar(32) | `VIDEO`, `POSTER`, `JOB` |
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

`id` UUID PK, `post_id` UUID indexed, `author_id` UUID indexed, `text` text, `created_at` timestamptz.

### `mentions`

`id` UUID PK, `comment_id` UUID indexed, `mentioned_user_id` UUID indexed.

### `reactions`

`id` UUID PK, `post_id` UUID indexed, `user_id` UUID indexed, `created_at` timestamptz.

Unique: `(post_id, user_id)`.

### `follows`

`id` UUID PK, `follower_id` UUID indexed, `following_id` UUID indexed, `created_at` timestamptz.

Unique: `(follower_id, following_id)`.

## Indexes

- `posts.author_id, posts.created_at`
- `comments.post_id, comments.created_at`
- `reactions.post_id`
- `follows.follower_id`, `follows.following_id`

