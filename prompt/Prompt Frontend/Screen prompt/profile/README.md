# Profile — Prompt Index (Facebook / Vithey Style)

**UI status: v1 complete** in `vithey_app/lib/modules/profile/`.

Complete specification for the **user profile module** matching `Prompt Frontend/screen image/profile/`.

## Folder layout

| Path | Contents |
| --- | --- |
| `v0/` | Archive — original profile prompts |
| `v1/` | **Current implemented UI** (`*-v1.md`) |
| Root | `update.md` (edit-profile bottom-sheet brief — applied in v1 edit flow), this README |

Implement and maintain **`v1/` only**.

## Product goal

Deliver a production-quality profile experience:

- **Wavy teal cover header** with decorative tech icons
- Large overlapping circular avatar
- Stats row: **Likes · Followers · Following**
- Owner vs visitor action buttons
- **5 scrollable tabs:** About, Videos, Posters, Jobs, Applied Jobs
- Bottom navigation with Profile tab active (via MainShell)
- Job owner flows: applicants list, CV preview, accept/reject

## Backend stack (profile data)

| Component | Service | Port |
|-----------|---------|------|
| Profile read/update | `user-profile-service` | 8082 |
| Avatar file | `file-service` (type `AVATAR`) | 8083 |
| Posts / likes / follows | `content-service` | 8084 |
| Saved CV | `career-service` | 8085 |

API contract: [`v0/08.profile_api_backend.md`](v0/08.profile_api_backend.md) (API doc; still valid)  
Backend prompts: `Prompt Backend/services/user-profile-service/`

## Visual references

| Screen | Asset |
|--------|-------|
| Own profile — About | `Own Profile (About).png` |
| Own profile — Posters | `Own Profile (Posters).png` |
| Own profile — Videos | `Own Profile (Video).png` |
| Own profile — Jobs | `Own Profile (CV).png` |
| Own profile — Applied Jobs | `Own Profile (Applied Job).png` |
| Visitor profile — About | `View Profile (About).png` |
| Edit personal info | `Profile (Update Information).png` |
| Application list (owner) | `Application list screen.png` |
| Applicant detail / CV | `Job List Detail.png` |
| Feedback submitted | `Feed back submitted.png` |

## Reading order (v1)

| # | Prompt | Delivers |
|---|--------|----------|
| 1 | [`v1/01.profile_home-v1.md`](v1/01.profile_home-v1.md) | Shell, wavy header, stats, actions, 5 tabs |
| 2 | [`v1/02.profile.about-v1.md`](v1/02.profile.about-v1.md) | Skills, personal details, links, contact |
| 3 | [`v1/03.profile_video-v1.md`](v1/03.profile_video-v1.md) | Videos tab |
| 4 | [`v1/04.profile_poster-v1.md`](v1/04.profile_poster-v1.md) | Posters tab |
| 5 | [`v1/05.profile_job-v1.md`](v1/05.profile_job-v1.md) | Jobs tab |
| 6 | [`v1/06.profile_applied_jobs-v1.md`](v1/06.profile_applied_jobs-v1.md) | Applied Jobs tab |
| 7 | [`v1/07.profile_edit_info-v1.md`](v1/07.profile_edit_info-v1.md) | Edit personal info (Add / tap-to-edit sheets) |
| 8 | [`v1/poster_job/03.applicant_detail-v1.md`](v1/poster_job/03.applicant_detail-v1.md) | Applicant detail |

Related archive job flows still useful: `v0/poster_job/*`, `v0/09.preview_own_cv.md`.  
Job application wizard: [`../job_apply/README.md`](../job_apply/README.md).

## Tab visibility matrix

| Tab | Own profile | Visitor profile |
|-----|-------------|-----------------|
| About | Yes | Yes |
| Videos | Yes | Yes |
| Posters | Yes | Yes |
| Jobs | Yes (owner management) | Yes (Apply when eligible) |
| Applied Jobs | Yes | Hidden |

## Module architecture (implemented)

```text
lib/modules/profile/
  profile_screen.dart
  profile_controller.dart
  profile_binding.dart
  edit_profile_screen.dart
  job_applicants_screen.dart
  applicant_detail_screen.dart
  cv_screens.dart
  widgets/
    profile_wavy_header.dart
    profile_tabs.dart
    profile_video_card.dart
    ...
```

## Acceptance checklist (v1 release)

- [x] Wavy teal header + avatar + stats
- [x] Owner / visitor actions
- [x] 5 scrollable tabs; Applied Jobs hidden for visitors
- [x] About / Videos / Posters / Jobs / Applied Jobs UIs
- [x] Edit profile info (v1 bottom-sheet Add / edit)
- [x] Applicant list / detail / CV preview routes
- [x] Wired into MainShell Profile tab

## Output

Maintain the profile module via **v1** prompts. Extend existing `lib/modules/profile/` — do not rewrite from scratch.
