# Content Service — Service Logic

## Ownership

Owns social feed posts, comments, reactions, mentions, and follow graph.

Does not own profile fields, media bytes, CV applications, or notifications.

## Core flows

| Flow | Logic |
| --- | --- |
| Feed | Return posts from followed users plus self, ordered by newest, paginated. |
| Create post | Validate post type; validate `media_file_id` for VIDEO/POSTER through file-service; save post; publish `post.created`. |
| Job post | Store job metadata on post so career-service can verify job ownership/application target. |
| Comment | Save comment, parse provided mention IDs, publish `comment.added` and `mention.created`. |
| Reaction | Toggle one reaction per user/post, publish `reaction.added` only on insert. |
| Follow | Reject self-follow, enforce unique pair, publish `follow.created`. |

## Events published

- `post.created`
- `comment.added`
- `reaction.added`
- `follow.created`
- `mention.created`

## Frontend alignment

- Home feed uses `GET /posts`.
- Post cards use reaction and comment counts from `PostResponse`.
- Create poster/video uses file upload first, then `POST /posts`.
- Create job stores `job_meta` for application flow.

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Post not found | `NOT_FOUND` | 404 |
| Not post owner | `FORBIDDEN` | 403 |
| Invalid media file | `INVALID_FILE` | 400 |
| Self follow | `BUSINESS_RULE_VIOLATION` | 422 |

