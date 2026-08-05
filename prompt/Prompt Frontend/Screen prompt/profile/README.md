# Profile — Prompt Index (Facebook / Vithey Style)

**UI status: v1 complete** in `vithey_app/lib/modules/profile/`.

Complete specification for the **user profile module** matching `Prompt Frontend/screen image/profile/`.

## Folder layout

| Path | Contents |
| --- | --- |
| `v0/` | Archive — original profile prompts |
| `v1/` | **Current implemented UI** (`*-v1.md`) |
| Root | [`update.md`](update.md) — **as-built ayheng profile/skills/cover/tabs** (source of truth), this README |

Implement and maintain **`v1/` only**.

## Product goal

Deliver a production-quality profile experience:

- **Cover redesign** (`ProfileCoverRedesign`) — teal + wave + overlapping avatar
- Stats row: **Likes · Followers · Following**
- Owner vs visitor action buttons
- **5 scrollable tabs** with **20px** horizontal padding: About, Videos, Posters, Jobs, Applied Jobs
- Skills rings with **~30% logo watermarks**; Coding drill-down in edit
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
    profile_cover_redesign.dart   # active cover
    profile_wavy_header.dart      # backup
    profile_tabs.dart
    profile_skills.dart
    skill_icon.dart
    profile_section_sheets.dart
    profile_video_card.dart
    ...
```

## Acceptance checklist (v1 release)

- [x] Cover redesign + avatar + stats
- [x] Owner / visitor actions
- [x] 5 scrollable tabs @ 20px padding; Applied Jobs bordered cards
- [x] About skills with watermark logos
- [x] Edit profile: Coding skills, system %, immediate skill persist, Remove sheets
- [x] Applicant list / detail / CV preview routes
- [x] Wired into MainShell Profile tab
- [x] AppLogo white circle (shared)

## Output

Maintain the profile module via **v1** prompts. Extend existing `lib/modules/profile/` — do not rewrite from scratch.
