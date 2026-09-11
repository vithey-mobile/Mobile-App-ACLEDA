# GLM 5.3 Flash — Prompt 00 of 5+1 (SHARED — RUN FIRST)

Copy everything below the line into a **new** GLM chat. Finish this before opening 01–05.

---

You are a Flutter data-layer agent in the Vithey repo. Implement **shared mock AI layer only**. Do not build full screens except tiny stubs if a type is missing. Do not touch backend or `ai_core`.

## Read first

1. `prompt/Prompt Al/run-glm-flash/COMMON_CONTEXT.md`
2. `prompt/Prompt Al/AI_REQUIREMENTS_AND_TASKS.md` (shared tasks S1–S7 + all 5 blocks overview)
3. Existing: `vithey_app/lib/data/models/ai_cv_draft.dart`, `ai_cv_fixtures.dart`, `ai_repository.dart`, `cv_repository.dart`, `feature_flags.dart`, `.env.example`

## Goal

One mock-first foundation so prompts 01–05 can ship UI without fighting over flags/models.

## Do this

### 1) Feature flags

In `vithey_app/lib/core/config/feature_flags.dart` + `vithey_app/.env.example`:

- Keep `USE_MOCK_AI`
- Add (default **true** in dev / `.env.example`):
  - `USE_AI_CV`
  - `USE_AI_FEED`
  - `USE_AI_SKILLS`
  - `USE_AI_JOB_MATCH`

When `USE_MOCK_AI=true`, repositories must never call live `/ai/**`.

### 2) Models (create if missing)

Under `vithey_app/lib/data/models/`:

| Model | Fields (minimum) |
|-------|------------------|
| `AiCvDraft` | already exists — ensure sections match COMMON_CONTEXT; do not break Apply AI CV |
| `AiJobMatchResult` | `score` 0–100, `label`, `matchedSkills`, `gapSkills`, `reasons` (list), `disclaimer` |
| `AiSkillScore` | `skillName`, `selfPercent`, `aiScore`, `signals` optional |
| `AiCareerReadiness` | `overallScore`, `topSkills` (list of AiSkillScore), `suggestions` (top 3 strings) |
| `AiFeedRecommendation` | `postId`, `relevance` 0–100, `reason` optional |

### 3) Fixtures

Create/extend:

- `ai_cv_fixtures.dart` — already exists; keep AI-CV-07 (profile-only facts)
- `ai_job_match_fixtures.dart` — rule-based overlap for mock jobs `post-10`, `post-19`, `post-20` vs current user skills
- `ai_skill_fixtures.dart` — career readiness for `mock-user` from `UserFixtures.mockItSkills`
- `ai_feed_fixtures.dart` — ordered post IDs for “For You” with reasons (boost jobs matching skills)

### 4) AiRepository API (mock implementations)

Add methods that **only** return fixtures + short delays:

```dart
Future<AiCvDraft> generateCvDraft(); // exists
Future<AiJobMatchResult> matchJob({required String jobPostId, String? cvFileId});
Future<AiCareerReadiness> skillScores();
Future<List<AiFeedRecommendation>> feedRecommendations({int limit = 20});
```

No Dio. Comment `// Live: POST /ai/jobs/{id}/match` etc. for later.

### 5) CvRepository

Keep `generateCvDraftFromProfile` + `saveDraftAsCv`. Do not remove Apply AI CV wiring.

## Stop when

- Flags + models + fixtures + repository methods compile
- `dart analyze` clean on touched files
- Print a short inventory of new types/methods

Do **not** implement Profile/Home/Chatbot UI in this chat.
