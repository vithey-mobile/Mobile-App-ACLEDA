# Vithey App — Frontend Kickoff Prompt

You are building the **Vithey App** Flutter mobile frontend for the ACLEDA Bank AUB App Competition. Use the provided context files and work **one screen/module at a time**.

## Read First
1. `Prompt Frontend/api-intergration/integration-contract.md` — API contract with backend
2. `COMMON_CONTEXT.md`
3. The specific screen prompt in `Screen prompt/`

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
- Each screen file in `Screen prompt/` contains product/design requirements and implementation instructions.

## Recommended Execution Order
1. `Screen prompt/00-foundation-prompt.md` — project skeleton, theme, routing, core reusable widgets
2. `Screen prompt/auth/01-splash-prompt.md` through `auth/09-startup-3-prompt.md` in order
3. `Screen prompt/media/README.md` — Home, all card types, comments, share, create
4. `Screen prompt/media/05.post_detail.md`
5. `Screen prompt/profile/README.md` — Profile, applicants, CV previews
6. `Screen prompt/upload_cv/README.md` — Job description, CV update/upload, application
7. `Screen prompt/finance/README.md` — Verification, status, Finance Home, invoice detail
8. `Screen prompt/chat/README.md` — Conversation list, thread, participant profile
9. `Screen prompt/chatbot/README.md`
10. `Screen prompt/notification/01-notification-prompt.md`
11. `Screen prompt/setting/README.md`

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
- See `Prompt Frontend/api-intergration/api-overview.md` for endpoint details.
