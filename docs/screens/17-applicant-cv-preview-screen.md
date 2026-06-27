# Applicant CV Preview Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `17` |
| Route | `Routes.APPLICANT_CV_PREVIEW` |
| Flutter module | `lib/modules/applicant_cv_preview/` |
| Backend service(s) | `career-service`, `file-service` |
| Auth required | Yes (job poster) |

## Purpose

Let **job posters** view CV files submitted by applicants.

## Open from

- Profile (job poster), job post management

## Main UI

| Element | Description |
|---------|-------------|
| Applicant list | Name, date, status badge, View CV button |
| CV viewer | Full-screen PDF/doc preview |
| Empty state | No applicants yet |
| Status update | Optional accept/reject (poster) |

## Application status

PENDING, REVIEWED, ACCEPTED, REJECTED

## User actions

| Action | Result |
|--------|--------|
| View CV | Open applicant CV viewer |
| Update status | PATCH application status |

## Logic & behavior

- `jobPostId` from route arguments
- Reuse `CvDocumentViewer` from Preview CV module
- Only post owner can view applicants

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v1/job-applications?job_post_id=` | Applicant list |
| PATCH | `/api/v1/job-applications/{id}/status` | Update status |
| GET | `/api/v1/files/{id}/download` | CV file |

## Status checklist

- [ ] UX/UI designed
- [ ] List + viewer work
- [ ] Poster authorization enforced
