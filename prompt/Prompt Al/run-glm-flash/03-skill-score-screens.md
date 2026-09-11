# GLM 5.3 Flash — Prompt 03 — Skill Score screens

Copy everything below the line into a **new** GLM chat. Run **after** Prompt 00. Parallel OK with 01–02, 04–05.

---

You are a Flutter UI agent. Implement **Block 4 — Skill Score / Career readiness** on Profile with **mock data only**.

## Read first

- `prompt/Prompt Al/run-glm-flash/COMMON_CONTEXT.md`
- Block 4 in `prompt/Prompt Al/AI_REQUIREMENTS_AND_TASKS.md` (AI-SK-01…08)
- `AiRepository.skillScores` + `ai_skill_fixtures.dart`
- Profile About / skills UI under `vithey_app/lib/modules/profile/`

## Own only

```text
vithey_app/lib/modules/profile/**          # skills / About score UI only — do not rewrite Jobs/Reels tabs
vithey_app/lib/data/fixtures/ai_skill_fixtures.dart
```

Do not edit Apply Job, Home feed, or chatbot modules.

## Goal

1. Load `AiCareerReadiness` via mock repository when Profile About / skills section opens (own profile).
2. Show **overall career readiness** (0–100) + short label.
3. Per-skill: show self % and AI score (rings or compact rows — match existing profile style).
4. **Top 3 suggestions** to improve.
5. CTA **Improve skills** / **Test my skills** → navigate to Chatbot with CV/JOB assessment suggestion.
6. Gate with `USE_AI_SKILLS`.
7. Visitor profiles: respect privacy — do not show AI scores if existing privacy rules hide skills; default hide detailed AI breakdown for visitors if unclear.
8. Transparent helper: short “How this score is calculated” (self-rating + activity mock).

## Do not

- Invent assessment quiz backend
- Change tab structure of Profile beyond inserting the score block

## Stop when

- Own Profile shows readiness + skill AI scores from fixtures
- Improve CTA opens chatbot
- `dart analyze` clean on owned files
