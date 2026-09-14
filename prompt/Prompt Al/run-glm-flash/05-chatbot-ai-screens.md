# GLM 5.3 Flash — Prompt 05 — Chatbot AI screens + deep links

Copy everything below the line into a **new** GLM chat. Run **after** Prompt 00. Parallel OK with 01–04.

---

You are a Flutter UI agent. Polish **Block 3 — Vithey AI Chatbot** for the other AI blocks, **mock only**.

## Read first

- `prompt/Prompt Al/run-glm-flash/COMMON_CONTEXT.md`
- Block 3 in `prompt/Prompt Al/AI_REQUIREMENTS_AND_TASKS.md` (AI-BOT-01…10)
- `vithey_app/lib/modules/chatbot/**`
- `vithey_app/lib/data/fixtures/ai_fixtures.dart`, `ai_repository.dart`

## Own only

```text
vithey_app/lib/modules/chatbot/**
vithey_app/lib/data/fixtures/ai_fixtures.dart   # append suggestions / mock replies only
vithey_app/lib/routes/app_pages.dart            # only if chatbot args need a typed route arg
```

## Goal

1. Keep sessions / history / send / mock replies working.
2. Ensure topics cover: CV, JOB, INTERVIEW, STUDENT, FINANCE, **MEDIA** (add if missing).
3. Empty-state suggestion chips include:
   - Help me write a CV
   - How do I apply for this job?
   - Test my Flutter skills
   - Explain poster vs job post
4. Accept navigation arguments (if missing, add a small `ChatbotArgs` with optional `initialPrompt` / `topic`) so Profile/Apply **Improve** CTAs can open with a prefilled prompt.
5. Actions on assistant bubbles: copy (required); regenerate (mock — re-call send with same user text) if easy.
6. Gate streaming UI only if already partially there — do **not** implement real SSE; mock chunk optional and skippable.
7. Finance answers: mock reply should stay generic unless student-verified flag on current user fixtures says verified.

## Do not

- Rewrite entire chatbot visual language
- Call live LLM
- Edit Apply/Profile/Home except documenting the deep-link arg contract in a short comment on `ChatbotArgs`

## Stop when

- Suggestions + MEDIA topic + deep-link initial prompt work in mock
- `dart analyze` clean on owned files
