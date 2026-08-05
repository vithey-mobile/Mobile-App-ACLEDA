# Profile — Prompt Index

**UI status: implemented** in `vithey_app/lib/modules/profile/`.

Prompts live **directly in this folder** (no `v0` / `v1`).

## Folder layout

| Path | Contents |
| --- | --- |
| `01`–`07` + `poster_job/` | Screen prompts |
| `update.md` | As-built ayheng profile/skills/cover/tabs (source of truth) |
| `README.md` | This index |

## Product goal

- Cover redesign (`ProfileCoverRedesign`) — teal + wave + avatar
- Stats: Likes · Followers · Following
- Owner vs visitor actions
- **5 tabs** @ **20px** padding: About, Videos, Posters, Jobs, Applied Jobs
- Skills with watermark logos; Coding drill-down in edit
- Job owner flows: applicants, CV preview, accept/reject

## Backend

| Component | Service | Port |
|-----------|---------|------|
| Profile | `user-profile-service` | 8082 |
| Avatar | `file-service` | 8083 |
| Posts / likes / follows | `content-service` | 8084 |
| Saved CV | `career-service` | 8085 |

Backend prompts: `Prompt Backend/services/user-profile-service/`

## Reading order

| # | Prompt | Delivers |
|---|--------|----------|
| 1 | [`01.profile_home.md`](01.profile_home.md) | Shell, cover, stats, actions, tabs |
| 2 | [`02.profile.about.md`](02.profile.about.md) | Skills, personal, links, contact |
| 3 | [`03.profile_video.md`](03.profile_video.md) | Videos tab |
| 4 | [`04.profile_poster.md`](04.profile_poster.md) | Posters tab |
| 5 | [`05.profile_job.md`](05.profile_job.md) | Jobs tab |
| 6 | [`06.profile_applied_jobs.md`](06.profile_applied_jobs.md) | Applied Jobs tab |
| 7 | [`07.profile_edit_info.md`](07.profile_edit_info.md) | Edit personal info |
| 8 | [`poster_job/03.applicant_detail.md`](poster_job/03.applicant_detail.md) | Applicant detail |

Job application wizard: [`../job_apply/README.md`](../job_apply/README.md).

## Tab visibility

| Tab | Own | Visitor |
|-----|-----|---------|
| About / Videos / Posters / Jobs | Yes | Yes |
| Applied Jobs | Yes | Hidden |

## Module paths

`text
lib/modules/profile/
  profile_screen.dart
  edit_profile_screen.dart
  widgets/profile_cover_redesign.dart
  widgets/profile_tabs.dart
  widgets/profile_skills.dart
  widgets/skill_icon.dart
  widgets/profile_section_sheets.dart
  ...
`
