# Vithey App — Frontend Kickoff Prompt

You are building the **Vithey App** Flutter mobile frontend for the ACLEDA Bank AUB App Competition. Use the provided context files and work **one screen/module at a time**.

## Read First
1. `COMMON_CONTEXT.md`
2. The specific screen prompt you are about to execute (in `v1/`)

## Competition Context
- Target users: AUB students and general youth users
- Platform: Flutter mobile app (Android + iOS)
- Must include: Register/Login, Settings, Light + Dark mode, at least 5 features
- Official rules: [ACLEDA App Competition](https://www.acledabank.com.kh/sl/app-competition/)
- Full product spec: `Project Overview.txt` in the repo root

## Rules
- **Frontend only.** Do not build backend code in this pass.
- Use **Flutter** with **GetX** for state management, routing, and dependency injection.
- Use **Dio** for HTTP API calls.
- Use **flutter_secure_storage** for tokens; **shared_preferences** for theme, language, onboarding flags.
- Support **Light Mode** and **Dark Mode**.
- Build **complete runnable UI code**, not placeholders or `// TODO` stubs.
- **Reuse components:** put shared UI in `lib/core/widgets/`; screen-specific UI in `lib/modules/<feature>/widgets/`.
- Mock API responses when backend is unavailable, but structure repositories/services so real API integration is a drop-in swap.
- Match the folder structure defined in `COMMON_CONTEXT.md` exactly.
- Follow UX from `Project Overview.txt` for each screen.

## Recommended Execution Order
1. `v1/00-foundation-prompt.md` — project skeleton, theme, routing, core reusable widgets
2. `v1/01-splash-prompt.md`
3. `v1/02-onboarding-prompt.md`
4. `v1/03-auth-prompt.md`
5. `v1/04-home-prompt.md`
6. `v1/05-create-post-prompt.md`
7. `v1/06-post-detail-prompt.md`
8. `v1/07-apply-cv-prompt.md`
9. `v1/08-preview-cv-prompt.md`
10. `v1/09-profile-prompt.md`
11. `v1/10-finance-prompt.md`
12. `v1/11-student-verification-prompt.md`
13. `v1/12-chat-prompt.md`
14. `v1/13-chat-detail-prompt.md`
15. `v1/14-chatbot-prompt.md`
16. `v1/15-notification-prompt.md`
17. `v1/16-settings-prompt.md`
18. `v1/17-applicant-cv-preview-prompt.md`

## Working Style
- Build one module fully before moving to the next.
- Each module must have: `*_screen.dart`, `*_controller.dart`, `*_binding.dart`, and `widgets/` folder.
- Register routes in `lib/routes/app_pages.dart` after each module.
- Verify the screen navigates correctly from the previous flow.
- Reuse existing `core/widgets/` before creating new widgets.
- Do not duplicate buttons, text fields, loading states, or empty states across screens.

## Output Quality
- Use typed Dart models in `lib/data/models/`.
- Keep controllers thin; put API logic in repositories/services.
- Use `Obx` / `GetBuilder` appropriately with GetX.
- Add shimmer/skeleton loading for list screens.
- Add empty states and error states using shared widgets.
- Keep widgets small and composable.
- Support Khmer + English strings via `app_strings.dart` keys.
- Animations: use subtle transitions (page routes, button feedback, list items).

## API Assumption
- Base URL: `http://localhost:8080/api/v1` (dev) — configurable via `.env`
- Auth header: `Authorization: Bearer <access_token>`
- Response envelope: `{ "data": ..., "meta": ... }` or `{ "error": { "code", "message", "details" } }`
- See `Project Overview.txt` API Design section for endpoint details when wiring real calls.
