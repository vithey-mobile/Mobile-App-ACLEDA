# Shared context — Vithey AI UI (mock-first)

Read this before any numbered prompt. Do not invent a sixth AI product.

## Five blocks

| Block | Name | Primary screens |
|-------|------|-----------------|
| 1 | Auto Create CV | Apply Step 1 + `/apply-cv/ai-create` + Profile CV |
| 2 | Smart Feed | Home mixed feed |
| 3 | Chatbot Q&A | `modules/chatbot/` |
| 4 | Skill Score | Profile About / skills |
| 5 | Job Match Score | Apply Review + poster applicants |

Full IDs: `prompt/Prompt Al/AI_REQUIREMENTS_AND_TASKS.md`

## Mock-first contract (Flutter)

| Concern | Approach |
|---------|----------|
| Flags | Extend `FeatureFlags` + `.env.example`: `USE_MOCK_AI`, `USE_AI_CV`, `USE_AI_FEED`, `USE_AI_SKILLS`, `USE_AI_JOB_MATCH` (all default true in dev) |
| Data | Fixtures under `vithey_app/lib/data/fixtures/` — no Dio to `/ai/**` while mock |
| Repository | `AiRepository` returns fixtures; later swap to `AiService` without rewriting screens |
| `ai_core` | Python StandardCV shape is the **target** for draft fields; do not call Python from Flutter in this pack |
| Backend | Java `ai-service` endpoints are documentation only for naming |

## Standard CV sections (align UI + fixtures)

From `ai_core` StandardCV — keep Flutter draft compatible:

- contact (name, email, phone, location, links)
- summary
- experience
- education
- projects
- skills (grouped list OK as string list in mock)
- optional: certifications / languages (mock may omit)

## App paths

```text
vithey_app/lib/
  core/config/feature_flags.dart
  data/fixtures/ai_*.dart , application_fixtures.dart , post_fixtures.dart , user_fixtures.dart
  data/repositories/ai_repository.dart , cv_repository.dart , post_repository.dart , profile_repository.dart
  modules/jobs/          # Apply + ai_cv
  modules/profile/       # skills, applicants, CV entry
  modules/home/          # feed
  modules/chatbot/       # Vithey AI chat
```

## Parallel safety

After Prompt **00**:

- Prompt 01 may edit `modules/jobs/**` + Profile CV entry widgets only
- Prompt 02 may edit Apply review widgets + `job_applicants*` / applicant detail AI panel only
- Prompt 03 may edit Profile skills / About score widgets only
- Prompt 04 may edit Home feed ranking UI / controller only
- Prompt 05 may edit `modules/chatbot/**` only

Do **not** edit another prompt’s folder. Shared fixtures: only append new files named clearly (`ai_job_match_fixtures.dart`, `ai_skill_fixtures.dart`, `ai_feed_fixtures.dart`) — do not rewrite Prompt 00’s core files unless 00 left a stub.

## UI kit

Use existing Vithey widgets. Prefer Teal primary. No new purple theme. No dashboard clutter on Apply / Profile.
