# Home Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `04` |
| Route | `Routes.HOME` |
| Flutter module | `lib/modules/home/` |
| Backend service(s) | `content-service` |
| Auth required | Yes |
| Competition feature | **Social feed** |

## Purpose

Show a social feed (Facebook-style) with video, poster, and job posts.

## Open from

- Auth success, Splash (logged in), bottom navigation

## Main UI

| Element | Description |
|---------|-------------|
| App bar | Logo, notification icon, optional search |
| Feed list | Scrollable posts |
| Post card | Avatar, name, time, content, media |
| Action bar | Like, comment, share, follow |
| Job post | Extra **Apply** button |
| FAB / nav | Create Post, Chat, Profile |
| Bottom nav | Home, Create, Chat, Notifications, Profile |

## Post types

| Type | Content |
|------|---------|
| Video | Thumbnail + inline player |
| Poster | Image |
| Job | Title, description, Apply CTA |

## User actions

| Action | Result |
|--------|--------|
| Pull to refresh | Reload feed |
| Scroll end | Load more (pagination) |
| Like | Toggle reaction API |
| Comment | Open Post Detail |
| Follow | Toggle follow API |
| Apply (job) | Navigate to Apply CV |
| Tap avatar | Profile |
| Tap post | Post Detail |

## Logic & behavior

- `GET /api/v1/posts?page&limit`
- Shimmer skeleton while loading
- Empty state if no posts
- Infinite scroll pagination

## Navigation

| From | Action | To |
|------|--------|-----|
| Home | Tap post | Post Detail |
| Home | Apply | Apply CV |
| Home | Create | Create Post |
| Home | Nav icons | Chat, Notification, Profile |

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v1/posts` | Paginated feed |
| POST | `/api/v1/posts/{id}/reactions` | Like toggle |
| POST | `/api/v1/users/{id}/follow` | Follow toggle |

## Reusable widgets

| Widget | Location |
|--------|----------|
| `UserAvatar` | `core/widgets/user_avatar.dart` |
| `PostCard`, `VideoPostCard`, `JobPostCard` | `modules/home/widgets/` |
| `ShimmerListTile` | `core/widgets/shimmer_list_tile.dart` |

## Status checklist

- [ ] UX/UI designed
- [ ] Frontend implemented
- [ ] API integrated
