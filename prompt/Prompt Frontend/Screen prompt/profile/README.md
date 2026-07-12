# Profile — Prompt Index (Facebook / Vithey Style)

Complete specification for the **user profile module** matching `Prompt Frontend/screen image/profile/`.

## Product goal

Deliver a production-quality profile experience:

- **Wavy teal cover header** with decorative tech icons
- Large overlapping circular avatar
- Stats row: **Likes · Followers · Following**
- Owner vs visitor action buttons
- **5 scrollable tabs:** About, Videos, Posters, Jobs, Applied Jobs
- Bottom navigation with Profile tab active
- Job owner flows: applicants list, CV preview, accept/reject

## Backend stack (profile data)

| Component | Service | Port |
|-----------|---------|------|
| Profile read/update | `user-profile-service` | 8082 |
| Avatar file | `file-service` (type `AVATAR`) | 8083 |
| Posts / likes / follows | `content-service` | 8084 |
| Saved CV | `career-service` | 8085 |

API contract: [`06.profile_api_backend.md`](06.profile_api_backend.md)  
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
| Legacy shell | `profile_home.png`, `profile_about.png`, `profile_video.png`, `profile_job.png` |

## Reading order

| # | Prompt | Delivers |
|---|--------|----------|
| 1 | [`01.profile_home.md`](01.profile_home.md) | Shell, wavy header, stats, actions, 5 tabs, owner/visitor |
| 2 | [`02.profile.about.md`](02.profile.about.md) | Skills rings, personal details, links, contact |
| 3 | [`03.profile_poster.md`](03.profile_poster.md) | Posters tab — feed-style cards |
| 4 | [`profile_video.md`](profile_video.md) | Videos tab — thumbnail + play overlay |
| 5 | [`profile_job.md`](profile_job.md) | Jobs tab — owner cards + applicant count |
| 6 | [`04.profile_applied_jobs.md`](04.profile_applied_jobs.md) | Applied Jobs tab (own profile only) |
| 7 | [`05.profile_edit_info.md`](05.profile_edit_info.md) | Edit personal info screen |
| 8 | [`06.profile_api_backend.md`](06.profile_api_backend.md) | **REST contract** — read/update/avatar/settings, v1 field matrix |
| 9 | [`poster_job/list_poster_job.md`](poster_job/list_poster_job.md) | Owner job management list |
| 10 | [`poster_job/list_cv_apply_job.md`](poster_job/list_cv_apply_job.md) | Application list per job |
| 11 | [`poster_job/applicant_detail.md`](poster_job/applicant_detail.md) | Applicant CV / experience detail |
| 12 | [`poster_job/preview_cv.md`](poster_job/preview_cv.md) | Secure CV preview + Accept/Reject |
| 13 | [`preview_own_cv.md`](preview_own_cv.md) | Own saved CV preview |

Job application flow: [`../job_apply/README.md`](../job_apply/README.md).

## Tab visibility matrix

| Tab | Own profile | Visitor profile |
|-----|-------------|-----------------|
| About | ✅ | ✅ |
| Videos | ✅ | ✅ |
| Posters | ✅ | ✅ |
| Jobs | ✅ (owner management) | ✅ (Apply when eligible) |
| Applied Jobs | ✅ | ❌ hidden |

## Ownership boundaries

| File | Owns |
|------|------|
| Profile Home | Shell, wavy header, avatar, stats, action row, tab bar |
| About | Skills, personal details, public links |
| Posters | `type=POSTER` feed cards |
| Videos | `type=VIDEO` thumbnail list |
| Jobs | `type=JOB` cards; owner **View List** / visitor **Apply** |
| Applied Jobs | Current user's submitted applications |
| Update Information | Owner edit form — v1 fields per `06.profile_api_backend.md` |
| Applicants | Owner-only list per job post |
| Applicant detail | Experience/education timeline + decisions |

## Module architecture (target)

```text
lib/modules/profile/
  profile_screen.dart
  profile_controller.dart
  profile_binding.dart
  edit_profile_screen.dart
  edit_profile_controller.dart
  job_applicants_screen.dart
  applicant_detail_screen.dart
  widgets/
    profile_wavy_header.dart
    profile_avatar.dart
    profile_stats_row.dart
    profile_action_row.dart
    profile_tab_bar.dart
    profile_skills_row.dart
    profile_personal_details.dart
    profile_video_card.dart
    profile_job_card.dart
    profile_applied_job_empty.dart
```

## Acceptance checklist

- [ ] Wavy teal header matches `Own Profile (About).png`
- [ ] Stats show Likes / Followers / Following with K formatting
- [ ] Owner: Edit profile info + Verify student + Share
- [ ] Visitor: Follow + Message + Share
- [ ] 5 scrollable tabs; Applied Jobs hidden for visitors
- [ ] About: circular skill progress rings + personal details
- [ ] Videos: play overlay thumbnail cards
- [ ] Jobs owner: "5 Application" badge + View List
- [ ] Applied Jobs empty state matches reference
- [ ] Edit personal info matches `Profile (Update Information).png`
- [ ] Application list matches `Application list screen.png`
- [ ] `flutter analyze` zero errors

## Output

Implement the full profile module by following prompts **01 → 06** then job/applicant sub-prompts. Extend existing `lib/modules/profile/` — do not rewrite from scratch.
