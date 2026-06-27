# Post Detail Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `06` |
| Route | `Routes.POST_DETAIL` |
| Flutter module | `lib/modules/post_detail/` |
| Backend service(s) | `content-service` |
| Auth required | Yes |

## Purpose

Show full post content, comments with @mentions, and job apply action.

## Open from

- Home feed, Profile tabs

## Main UI

| Element | Description |
|---------|-------------|
| Full post | Video player / image / job details |
| Action bar | Like, comment count, follow |
| Comment list | User avatar, text, time |
| Comment input | Text field + send, @mention support |
| Apply CV button | Job posts only |

## User actions

| Action | Result |
|--------|--------|
| Like | Toggle reaction |
| Follow author | Toggle follow |
| Write comment | POST comment, support @mentions |
| Apply CV | Navigate to Apply CV with `postId` |
| Play video | Inline `video_player` |

## Logic & behavior

- Load post by `postId` from route arguments
- Paginated comments
- Mention autocomplete when typing `@`

## Navigation

| From | Action | To |
|------|--------|-----|
| Post Detail | Apply CV | Apply CV |
| Post Detail | Back | Previous screen |

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v1/posts/{id}` | Post detail |
| GET | `/api/v1/posts/{id}/comments` | Comments |
| POST | `/api/v1/posts/{id}/comments` | New comment |

## Status checklist

- [ ] UX/UI designed
- [ ] Frontend implemented
- [ ] Comments + mentions work
