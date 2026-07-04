# Career Service — API Endpoints

Base path: `/api/v1`

All endpoints require JWT.

## Job applications

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/job-applications` | Apply to a job post |
| GET | `/job-applications` | Current user's applications |
| GET | `/job-applications?job_post_id={id}` | Applicants for one job post, poster only |
| GET | `/job-applications/{id}` | Application detail |
| PATCH | `/job-applications/{id}/status` | Poster updates applicant status |

## User CV

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/users/me/cv` | Current user's saved CV metadata |
| PUT | `/users/me/cv` | Set/update saved default CV |

Gateway must route `/users/me/cv` here before generic `/users/**`.

## Apply request

```json
{ "job_post_id": "uuid", "cv_file_id": "uuid", "cover_note": "I am interested..." }
```

## Status request

```json
{ "status": "REVIEWED" }
```

Allowed statuses: `PENDING`, `REVIEWED`, `ACCEPTED`, `REJECTED`.

