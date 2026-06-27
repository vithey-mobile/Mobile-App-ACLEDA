# Apply CV Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `07` |
| Route | `Routes.APPLY_CV` |
| Flutter module | `lib/modules/apply_cv/` |
| Backend service(s) | `career-service`, `file-service` |
| Auth required | Yes |
| Competition feature | **Job / CV** |

## Purpose

Upload a CV file and submit a **job application** for a job post.

## Open from

- Home (job card Apply), Post Detail (job posts)

## Main UI

| Element | Description |
|---------|-------------|
| Job summary | Title from `jobPostId` |
| Upload zone | Large dashed area + upload icon |
| File preview | Name, size, type after pick |
| Submit button | Disabled until file selected |

## User actions

| Action | Result |
|--------|--------|
| Pick file | `file_picker` — PDF, DOC, DOCX (max 10MB) |
| Remove file | Clear selection |
| Submit | Upload → apply → success dialog → back |

## Logic & behavior

- Route args: `jobPostId`
- `POST /files/upload` (type=CV) → `POST /job-applications`
- One application per user per job (409 from API)

## Navigation

| From | Action | To |
|------|--------|-----|
| Apply CV | Success | Back to post |
| Apply CV | Cancel | Back |

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/v1/files/upload` | CV file |
| POST | `/api/v1/job-applications` | `job_post_id`, `cv_file_id` |

## Status checklist

- [ ] UX/UI designed
- [ ] Frontend implemented
- [ ] Upload + apply API works
