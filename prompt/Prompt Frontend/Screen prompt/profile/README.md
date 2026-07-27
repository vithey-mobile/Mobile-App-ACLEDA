# Profile Prompt Index

Use this folder as the single source of truth for the Profile module.

## Folder layout

| Path | Contents |
| --- | --- |
| `v0/` | All original profile prompts (including `poster_job/`) |
| `v1/` | Redesigned prompts only when an update ships (`*-v1.md`) |
| Root | `update.md`, this README only |

Do **not** modify `update.md` when implementing v1.

## Usage model (Poster / Applier)

There is **no role picker**. Everyone gets the same Profile UI; **Jobs** and **Applied Jobs** differ by usage:

| Prompt label | Usage | Typical data |
| --- | --- | --- |
| **Poster (HR)** | Posts jobs, reviews applicants | Jobs filled; Applied Jobs empty |
| **Applier (Student)** | Applies with CV | Applied Jobs filled; Jobs empty |

- In prompts, say **Poster** / **Applier** (or HR / Student) — **do not** use real display names.
- Mock: logged-in session = Poster; a separate fixture user = Applier (applications on Poster jobs, no JOB posts).
- Do not gate tabs by a stored role. Ownership still controls Edit / Apply / View List.

## Current v1 work

| Status | Prompt | Reference |
| --- | --- | --- |
| Home shell | [`v1/01.profile_home-v1.md`](v1/01.profile_home-v1.md) | `Own Profile (Home).png` |
| About tab | [`v1/02.profile.about-v1.md`](v1/02.profile.about-v1.md) | `Own Profile (About).png` |
| Videos | [`v1/03.profile_video-v1.md`](v1/03.profile_video-v1.md) | `Own Profile (Video).png` |
| Posters | [`v1/04.profile_poster-v1.md`](v1/04.profile_poster-v1.md) | `Own Profile (Posters).png` |
| Jobs | [`v1/05.profile_job-v1.md`](v1/05.profile_job-v1.md) | `Own Profile (CV).png` |
| Applied Jobs | [`v1/06.profile_applied_jobs-v1.md`](v1/06.profile_applied_jobs-v1.md) | `Own Profile (Applied Job).png` |
| Edit personal info | [`v1/07.profile_edit_info-v1.md`](v1/07.profile_edit_info-v1.md) | `Profile (Edit info) 2.png` + `Edited Content.png` |
| Applicant Detail | [`v1/poster_job/03.applicant_detail-v1.md`](v1/poster_job/03.applicant_detail-v1.md) | `Job List Detail.png` + `My_CV.png` |

Other screens (API, remaining `poster_job/`, own CV) stay on **v0** until their updates are added later.

## What home v1 changed (`update.md`)

| Area | Focus |
| --- | --- |
| Cover | Lighter teal; decor darker than cover |
| Avatar | Larger |
| Actions | Smaller; Edit primary; Verify light grey; Share icon-only |
| Tabs / padding | Tighter tabs; 20px horizontal |

## What about v1 changes

| Area | Focus |
| --- | --- |
| Skills | Keep rings; polish spacing/colors to About mock |
| Details | Separate titled sections: Personal details, Work, Education, Links, Contact info |
| Padding | 20px horizontal (with shell) |
| Logic | v0 API / mock / visitor privacy unchanged |

## What edit v1 changes (`update.md` + `Edited Content.png`)

| Area | Focus |
| --- | --- |
| Header action | **Add** (create only) — not inline Edit |
| Item tap | Opens bottom sheet for **that item only** |
| Sheet | Handle, 20px pad, Submit (teal) + Cancel (grey) |
| Fields | Per-section sets (Work: Position + Workplace*) |
| Sync | Footer Save → About + header refresh |

## Original reading order (v0)

| # | Prompt |
|---|--------|
| 1 | [`v0/01.profile_home.md`](v0/01.profile_home.md) |
| 2 | [`v0/02.profile.about.md`](v0/02.profile.about.md) |
| 3 | [`v0/03.profile_video.md`](v0/03.profile_video.md) |
| 4 | [`v0/04.profile_poster.md`](v0/04.profile_poster.md) |
| 5 | [`v0/05.profile_job.md`](v0/05.profile_job.md) |
| 6 | [`v0/06.profile_applied_jobs.md`](v0/06.profile_applied_jobs.md) |
| 7 | [`v0/07.profile_edit_info.md`](v0/07.profile_edit_info.md) |
| 8 | [`v0/08.profile_api_backend.md`](v0/08.profile_api_backend.md) |
| 9 | [`v0/09.preview_own_cv.md`](v0/09.preview_own_cv.md) |
| 10+ | [`v0/poster_job/01`…](v0/poster_job/) (list poster → applicants → detail → CV → feedback) |

## Acceptance checklist

### Home v1
- [ ] Matches home shell + `update.md` button/cover rules

### About v1
- [ ] Section stack matches `Own Profile (About).png`
- [ ] Skills rings + separate detail sections
- [ ] Visitor contact privacy preserved
- [ ] `flutter analyze` clean on touched files

### Jobs / Applied Jobs usage
- [ ] Poster mock: Jobs populated; Applied Jobs empty
- [ ] Applier fixture: no JOB posts; appears in Poster Application List
- [ ] Prompts use Poster/Applier wording only (no real names)

## Output

Implement Home v1 then About v1. Add further `v1/*-v1.md` files when those screens are updated.
