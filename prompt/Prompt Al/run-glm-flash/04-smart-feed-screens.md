# GLM 5.3 Flash — Prompt 04 — Smart Feed screens

Copy everything below the line into a **new** GLM chat. Run **after** Prompt 00. Parallel OK with 01–03, 05.

---

You are a Flutter UI agent. Implement **Block 2 — Personalized / Smart Feed** on Home with **mock data only**.

## Read first

- `prompt/Prompt Al/run-glm-flash/COMMON_CONTEXT.md`
- Block 2 in `prompt/Prompt Al/AI_REQUIREMENTS_AND_TASKS.md` (AI-FEED-01…08)
- `AiRepository.feedRecommendations` + `ai_feed_fixtures.dart`
- `vithey_app/lib/modules/home/home_controller.dart`, `mixed_post_feed.dart`

## Own only

```text
vithey_app/lib/modules/home/home_controller.dart
vithey_app/lib/modules/home/widgets/mixed_post_feed.dart
vithey_app/lib/modules/home/widgets/**   # optional For You chip / reason line — keep thin
vithey_app/lib/data/fixtures/ai_feed_fixtures.dart
vithey_app/lib/data/repositories/post_repository.dart  # ONLY if needed to reorder mock feed — prefer controller-side merge
```

Do not edit Apply, Profile skills, chatbot.

## Goal

1. When `USE_AI_FEED` + mock AI: Home initial feed uses recommendation order (post IDs from fixtures) merged with existing `PostFixtures` / repository posts.
2. Keep pull-to-refresh + pagination working (fallback chronological if recommendations empty — AI-FEED-07).
3. Optional light UI: “For You” label or one muted reason chip on first recommended job (“Because your skills include Flutter”) — **not** a heavy dashboard.
4. Boost apply-eligible jobs that match user skills near the top (fixtures already should; enforce in merge).
5. Respect blocks/privacy if already implemented; do not show deleted posts.

## Do not

- Add a second Home tab unless minimal chips (All / For You) fit existing header without redesigning Home chrome
- Call real ranking APIs

## Stop when

- Cold start Home shows mock ranked mix with jobs near top for Apply testing
- Refresh still works
- `dart analyze` clean on owned files
