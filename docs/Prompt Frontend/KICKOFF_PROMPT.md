# Vithey App — Frontend Kickoff Prompt

You are building and maintaining the **Vithey App** Flutter mobile frontend for
the ACLEDA Bank AUB App Competition. Use the provided context files and work
**one screen/module or one focused refactor batch at a time**.

## Read First
1. `Prompt Frontend/api-intergration/integration-contract.md` — API contract with backend
2. `COMMON_CONTEXT.md`
3. The specific screen prompt in `Screen prompt/`

## Competition Context
- Target users: AUB students and general youth users
- Platform: Flutter mobile app (Android + iOS)
- Must include: Register/Login, Settings, Light + Dark mode, at least 5 features
- Official rules: [ACLEDA App Competition](https://www.acledabank.com.kh/sl/app-competition/)
- Product summary: `Prompt Frontend/00-project-summary.md`

## Rules
- **Frontend only.** Do not build backend code in this pass.
- Use **Flutter** with **GetX** for state management, routing, and dependency injection.
- Use **Dio** for HTTP API calls.
- Use **flutter_secure_storage** for tokens; **shared_preferences** for theme, language, onboarding flags.
- Support **Light Mode** and **Dark Mode**.
- Build **complete runnable UI code**, not placeholders or `// TODO` stubs.
- **Reuse components:** put shared UI in `lib/core/widgets/`; screen-specific UI in `lib/modules/<feature>/widgets/`.
- **UI system (Shadcn Flutter style):** build screens by composing the existing shared components and design tokens. Do not recreate ad-hoc buttons/cards/forms per screen.
- **No harmful hard-coding:** configuration, URLs, routes, assets, identity,
  domain limits, repeated strings, colors, spacing, and durations belong in
  their appropriate config, constants, localization, fixture, or theme layer.
  Do not mechanically replace clear one-off layout literals.
- **Safe cleanup only:** remove unused code, assets, or dependencies only after
  proving they are unreachable through analyzer output, full-project searches,
  routes/bindings, platform configuration, assets, generated-code inputs, and
  tests.
- For an existing-project audit or cleanup, follow
  `03-flutter-code-audit-and-refactor.md`.
- Mock API responses when backend is unavailable, but structure repositories/services so real API integration is a drop-in swap.
- Match the folder structure defined in `COMMON_CONTEXT.md` exactly.
- Each screen file in `Screen prompt/` contains product/design requirements and implementation instructions.

## Shadcn Flutter Components (Design System Rule)

This repo already contains a reusable component system under:

- `vithey_app/lib/core/widgets/` (buttons, fields, loaders, empty/error states, dialogs, badges, avatars, etc.)
- `vithey_app/lib/core/theme/` (light/dark theme + semantic tokens)

**Mandatory rule:** any new UI must use the existing shared components first. Only create a new shared component if it’s reused by 2+ screens, and it must be theme-aware.

### If you are using a pub.dev Shadcn package

If the app has `shadcn_ui` or `shadcn_flutter` installed in `pubspec.yaml`, you may use those widgets too, but still follow the architecture rules (screens compose; logic stays in controllers/repositories).

Recommended packages (installed in this repo):
- `shadcn_flutter: ^0.0.52` — requires **Dart ≥3.3** and **Flutter ≥3.22** (project uses Flutter 3.44+)
- Incremental adoption: keep `GetMaterialApp` for routing; inject `shad.Theme` via `builder` in `lib/app.dart`

## Recommended Execution Order
1. `Screen prompt/00-foundation-prompt.md` — project skeleton, theme, routing, core reusable widgets
2. `Screen prompt/auth/01-splash-prompt.md` through `auth/09-startup-3-prompt.md` in order
3. `Screen prompt/media/README.md` — Home, all card types, comments, share, create
4. `Screen prompt/media/05.post_detail.md`
5. `Screen prompt/profile/README.md` — Profile, applicants, CV previews
6. `Screen prompt/job_apply/README.md` — Apply Job wizard (upload → review → success) + Apply Status timeline
7. `Screen prompt/finance/README.md` — Verification, status, Finance Home, invoice detail
8. `Screen prompt/chat/README.md` — Conversation list, thread, participant profile
9. `Screen prompt/chatbot/README.md` — **new design** (chevron app bar, suggestion rows, trash-only drawer, logo+dots thinking)
10. `Screen prompt/search/README.md` — Global search, grouped results, local recents
11. `Screen prompt/notification/README.md` — Facebook-style inbox, FCM, 9 types, Isar
12. `Screen prompt/setting/README.md`

## Mock API flags (`.env`)

| Flag | Default | Controls |
|------|---------|----------|
| `USE_MOCK_API` | `false` | Global mock fallback for repositories |
| `USE_MOCK_AUTH` | `false` | Auth / register |
| `USE_MOCK_SEARCH` | `false` | Search module |
| `USE_MOCK_AI` | `false` | AI chatbot only (overrides `USE_MOCK_API` when set) |
| `USE_MOCK_CHAT` | `true` | Private chat (Isar + simulated STOMP) |
| `USE_MOCK_NOTIFICATIONS` | `true` | Notification inbox |

## Working Style
- Build one module fully before moving to the next.
- Each module must have: `*_screen.dart`, `*_controller.dart`, `*_binding.dart`, and `widgets/` folder.
- Register routes in `lib/routes/app_pages.dart` after each module.
- Verify the screen navigates correctly from the previous flow.
- Reuse existing `core/widgets/` before creating new widgets.
- Do not duplicate buttons, text fields, loading states, or empty states across screens.
- Search before extracting. Keep feature-only widgets local; promote a widget
  to `core/widgets/` only when independent features share the same contract.
- Refactor in small batches and preserve current behavior. Do not rewrite a
  working feature only to make its folder structure resemble an older prompt.

## Output Quality
- Use typed Dart models in `lib/data/models/`.
- Keep controllers thin; put API logic in repositories/services.
- Use `Obx` / `GetBuilder` appropriately with GetX.
- Add shimmer/skeleton loading for list screens.
- Add empty states and error states using shared widgets.
- Keep widgets small and composable.
- Support Khmer + English strings via `app_strings.dart` keys.
- Animations: use subtle transitions (page routes, button feedback, list items).
- Before handoff, format touched files, run `flutter analyze`, run relevant
  tests, and report any pre-existing failures separately.

## API Assumption

See `Prompt Frontend/api-intergration/integration-contract.md` for base URL, auth header, and response envelope.
