# Create Post Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `05` |
| Route | `Routes.CREATE_POST` |
| Flutter module | `lib/modules/create_post/` |
| Backend service(s) | `content-service`, `file-service` |
| Auth required | Yes |

## Purpose

Let users create new **video**, **poster**, or **job** posts.

## Open from

- Home FAB or navigation

## Main UI

| Element | Description |
|---------|-------------|
| Post type selector | Chips: Video \| Poster \| Job |
| Text input | Caption / description |
| Upload area | Video or image picker |
| Job form | Title, description, requirement, deadline |
| Publish button | Sticky bottom CTA |

## User actions

| Action | Result |
|--------|--------|
| Select type | Show matching form |
| Pick file | Preview thumbnail |
| Publish | Upload file → create post → back to Home |

## Logic & behavior

- Video/image: `image_picker` + `permission_handler`
- Upload via `POST /api/v1/files/upload` then `POST /api/v1/posts`
- Validate required fields per type
- Show upload progress bar

## Navigation

| From | Action | To |
|------|--------|-----|
| Create Post | Success | Home (refresh feed) |
| Create Post | Back | Home |

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/v1/files/upload` | Multipart media |
| POST | `/api/v1/posts` | Create post with `media_file_id` |

## Status checklist

- [ ] UX/UI designed
- [ ] Frontend implemented
- [ ] File upload works
