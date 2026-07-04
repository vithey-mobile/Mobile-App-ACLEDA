# Profile Prompt Index

Use this folder as the single source of truth for Profile, profile content, job applications, and CV flows.

## Reading order

1. [`01.profile_home.md`](01.profile_home.md) — shared profile shell and owner/visitor behavior.
2. [`02.profile.about.md`](02.profile.about.md) — personal/public information.
3. [`03.profile_poster.md`](03.profile_poster.md) — regular poster list.
4. [`profile_video.md`](profile_video.md) — video list.
5. [`profile_job.md`](profile_job.md) — public/owner Jobs tab.
6. [`poster_job/list_poster_job.md`](poster_job/list_poster_job.md) — owner job management/list.
7. [`poster_job/list_cv_apply_job.md`](poster_job/list_cv_apply_job.md) — applicants for one job.
8. [`poster_job/preview_cv.md`](poster_job/preview_cv.md) — secure applicant CV/detail/decision.
9. [`preview_own_cv.md`](preview_own_cv.md) — current user's saved CV preview.

Job application upload is owned by [`../upload_cv/README.md`](../upload_cv/README.md).

## Ownership boundaries

| File | Owns |
|---|---|
| Profile Home | Shell, header, stats, Follow/Message vs owner actions, tabs |
| About | Public/private personal fields and links |
| Posters | User POSTER pagination/cards |
| Videos | User VIDEO pagination/playback thumbnails |
| Jobs | User JOB tab and visitor/owner action mapping |
| Owner jobs | Manage/select owned job posts |
| Applicants | Owner-only applications for one job |
| Applicant CV | Secure preview, detail, Accept/Decline |
| Own CV | Preview/download current user's saved CV |

Avoid duplicating detailed behavior between files. Use stable user, post, job, application, and file IDs everywhere.
