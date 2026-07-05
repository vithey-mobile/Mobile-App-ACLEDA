# Content Service API

Base path: `/api/v1`

All endpoints require JWT (or gateway `X-User-*` headers).

## Posts

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/posts?page=&limit=` | Home feed (followed users + self) |
| POST | `/posts` | Create VIDEO, POSTER, or JOB post |
| GET | `/posts/{postId}` | Post detail |
| DELETE | `/posts/{postId}` | Delete own post |
| GET | `/users/{userId}/posts?type=` | User profile post list |

## Comments

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/posts/{postId}/comments` | Paginated comments |
| POST | `/posts/{postId}/comments` | Add comment and mentions |

## Reactions

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/posts/{postId}/reactions` | Toggle like/reaction |
| GET | `/posts/{postId}/reactions` | Count and current user's state |

## Follows

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/users/{userId}/follow` | Follow user |
| DELETE | `/users/{userId}/follow` | Unfollow user |
| GET | `/users/{userId}/followers` | Followers list |
| GET | `/users/{userId}/following` | Following list |

## Events published

- `post.created`
- `comment.added`
- `reaction.added`
- `follow.created`
- `mention.created`
