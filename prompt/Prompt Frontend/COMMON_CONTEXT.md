# Vithey App — Frontend Common Context

## Objective

Build a production-quality Flutter mobile app for AUB students combining social feed, job applications, student finance, private chat, AI assistant, and notifications. The app must be modular, testable screen-by-screen, and built around **reusable components** composed into feature pages.

## App Identity

| Item             | Value                                                                                 |
| ---------------- | ------------------------------------------------------------------------------------- |
| App name         | **Vithey App**                                                                        |
| Package / folder | `vithey_app/` (repo folder); `pubspec.yaml` name: `aub_connect_app`                   |
| Audience         | AUB students + youth users                                                            |
| Competition      | [ACLEDA Bank App Competition 2026](https://www.acledabank.com.kh/sl/app-competition/) |

## Brand assets (official)

| Asset | Source (repo) | App path | Use |
|-------|---------------|----------|-----|
| **App logo** | `Prompt Frontend/screen image/auth/logo app.png` | `assets/images/brand/logo_app.png` | Splash, Auth, app bar |
| Onboarding Screen | `Prompt Frontend/screen image/auth/Onboarding Screen.png` | reference only | Onboarding layout (3 slides) |

**On foundation setup:** copy `screen image/auth/logo app.png` → `assets/images/brand/logo_app.png` and register in `pubspec.yaml`.

**Code constant** (`lib/core/constants/app_assets.dart`):
```dart
class AppAssets {
  static const logoApp = 'assets/images/brand/logo_app.png';
}
```

**Reusable widget:** `lib/core/widgets/app_logo.dart` — `AppLogo(size: 120)` wraps `Image.asset(AppAssets.logoApp)`.

### Shared teal wave background (Onboarding → Auth)

**Remember this style** — Auth (and similar entry screens) should reuse the **same or very similar** layered wavy background as Onboarding v2. Do not invent a new wave language for Auth.

| Item | Value |
|------|-------|
| **Canonical implementation** | `vithey_app/lib/modules/onboarding/widgets/onboarding_background.dart` |
| **Prompt detail** | `Screen prompt/auth/02-onboarding-prompt-version-2.md` → Fixed background / keyframes |
| **Reference images** | `screen image/auth/Onboarding Screen.png`, `screen image/auth/image.png` |

**Layers (back → front):**

1. White page base  
2. Light teal rear wave — `AppColors.authWaveRear` ≈ `#6AD6D2`  
3. Teal front wave — `AppColors.authHeaderTeal` ≈ `#2FC5C1`

**Wave rules:**

- Soft organic wavy bottom edges (not half-circle / straight cut / busy random S-wave)
- Teal + light teal use **staggered** width keyframes (separate X arrays)
- Max gap between the two edges ≈ **10% of screen height**
- Background stays **fixed** behind scrolling/paging content
- Prefer extracting a shared widget later (e.g. `core/widgets/vithey_wave_background.dart`) when Auth is updated; until then, treat Onboarding’s painter + keyframe tables as the source of truth

**When building Auth:** match these colors and the same wavy rhythm; Auth may crop/scale the wave height (e.g. shorter header) but should keep the same teal / light-teal / white language and similar curve feel.

1. **Social Feed** — video, poster, and job posts with like, comment, mention, follow
2. **Job Apply** — upload CV and apply to job posts
3. **Profile** — user info, social links, content tabs, CV preview
4. **Finance** — tuition payment history, status, alerts (verified AUB students only)
5. **Student Verification** — unlock finance feature
6. **Private Chat** — message requests, accept-before-chat privacy
7. **AI Chatbot** — CV, job, interview, student support, finance Q&A
8. **Notifications** — likes, comments, mentions, follows, chat, payments, jobs
9. **Global Search** — Facebook-style search with recent users, grouped results (people, posts, jobs, videos)
10. **Settings** — account, privacy, theme, language, logout

## Mandatory Tech Stack

| Package                                          | Use For                               |
| ------------------------------------------------ | ------------------------------------- |
| Flutter SDK                                      | Whole app                             |
| GetX                                             | State, routing, DI                    |
| Dio                                              | REST API                              |
| flutter_secure_storage                           | JWT / refresh token                   |
| shared_preferences                               | Theme, language, onboarding seen      |
| cached_network_image                             | Feed images, avatars, posters         |
| intl                                             | Dates, currency (finance)             |
| file_picker                                      | CV upload                             |
| image_picker                                     | Image/video post upload               |
| video_player                                     | Video posts                           |
| flutter_pdfview or syncfusion_flutter_pdfviewer  | CV PDF preview                        |
| open_filex                                       | Open CV in device app                 |
| permission_handler                               | Camera, storage                       |
| lottie                                           | Splash, onboarding, empty states      |
| shimmer                                          | Feed/profile/finance loading skeleton |
| connectivity_plus                                | Offline banner                        |
| url_launcher                                     | Telegram, Facebook links              |
| flutter_dotenv                                   | API base URL                          |
| logger                                           | Debug logging                         |
| crypto / encrypt                                 | Optional extra security               |
| socket_io_client or web_socket_channel           | Real-time chat STOMP (see `Screen prompt/chat/05`) |
| isar + isar_flutter_libs                         | Offline chat cache (conversations, messages, outbox) |
| firebase_messaging + flutter_local_notifications | Push notifications (chat, social, jobs, payments, AI) + OS tray display |
| Auth0 Flutter                                    | OAuth2 login (optional, auth screen)  |
| shadcn_flutter ^0.0.52                           | Shadcn UI components (requires Dart ≥3.3, Flutter ≥3.22) |
| flutter_markdown                                   | AI chatbot Markdown rendering (Vithey AI)               |
| share_plus                                         | Share AI answer action                                  |

## UI component system

- **Primary:** `shadcn_flutter` widgets (`Button`, `TextField`, `AlertDialog`, `Switch`, `Card`, etc.)
- **Adapters:** `lib/core/widgets/custom_button.dart`, `custom_text_field.dart`, `confirm_dialog.dart` wrap Shadcn for common patterns
- **Theme:** `GetMaterialApp` + `shad.Theme` injected via `builder` in `lib/app.dart`; color schemes use `ColorSchemes.lightSlate` / `darkSlate`
- **Do not** use raw Material `ElevatedButton`, `TextButton`, `OutlinedButton`, `AlertDialog`, or `TextFormField` in feature code — use Shadcn or core adapters instead

**Vithey AI (new design):** full spec in `Screen prompt/chatbot/README.md` — suggestion chips above composer, chevron new-chat, simplified history drawer with trash, logo+dots thinking row, `flutter_markdown`, streaming-ready repository.

**Private Chat (Telegram/Messenger-style):** full spec in `Screen prompt/chat/README.md` — `web_socket_channel` STOMP, Isar offline cache, FCM push, read receipts, reply/copy/delete.

## Architecture Rules

### 1. Layer responsibilities

| Layer                       | Responsibility                     | Must NOT                 |
| --------------------------- | ---------------------------------- | ------------------------ |
| `modules/*/widgets/`        | Screen-specific UI composition     | Call Dio directly        |
| `core/widgets/`             | Reusable UI across 2+ screens      | Contain business logic   |
| `modules/*_controller.dart` | UI state, user actions, navigation | Build large widget trees |
| `data/repositories/`        | Data orchestration, error mapping  | Render UI                |
| `data/services/`            | Raw API / WebSocket calls          | Hold widget state        |
| `data/models/`              | JSON ↔ Dart models                 | API calls                |
| `core/network/`             | Dio setup, interceptors, tokens    | Feature logic            |
| `routes/`                   | GetX pages and bindings            | Business rules           |

### 1.1 Modern stack layers (2025–2026)

Bootstrap and cross-cutting concerns live under `lib/core/` — **not** scattered in `main.dart` or feature modules.

| Layer | Path | Responsibility |
| ----- | ---- | -------------- |
| **Config** | `core/config/app_config.dart`, `environment.dart`, `feature_flags.dart` | `.env` / `--dart-define` URLs, timeouts, `APP_ENV`, all `USE_MOCK_*` and `ENABLE_*` flags |
| **DI** | `core/di/app_bindings.dart` | Single `AppBindings.init()` registers services, repositories, session, Isar, FCM, chat hub |
| **Session** | `core/session/current_user_service.dart` | Authenticated user, `userId`, `postAuthor` — use instead of hardcoded `mock-user` |
| **Errors** | `core/errors/app_exception.dart`, `error_mapper.dart` | Dio/service exceptions → typed `AppException` + user-facing messages |
| **Constants** | `core/constants/mock_identities.dart` | Demo IDs used only when mock auth/API is enabled |
| **Network** | `core/network/dio_client.dart`, `api_service.dart` | Dio + interceptors; reads `AppConfig.instance` |

**Rules:**
- `main.dart` only calls `AppBindings.init()` then `runApp`.
- Repositories inject `FeatureFlags` + `CurrentUserService`; never read `dotenv` directly.
- UI/controllers use `Get.find<FeatureFlags>()` or repository statics (`ProfileRepository.currentUserId`) — not raw env strings.

### 2. GetX module pattern (every feature)

```text
modules/<feature>/
  <feature>_screen.dart      # Scaffold + composes widgets
  <feature>_controller.dart  # GetxController
  <feature>_binding.dart     # Bindings / lazyPut
  widgets/                   # Feature-only widgets
```

### 3. Reusable component rules

- If a widget appears on **2 or more screens**, move it to `lib/core/widgets/`.
- Pages **compose** widgets; they do not inline 200-line `build()` methods.
- Pass data via constructor parameters; avoid global state except through GetX controllers.
- Shared components must support **light and dark theme** via `Theme.of(context)` (or the app semantic tokens).
- Naming: `CustomButton`, `PostCard`, `UserAvatar` — clear, prefixed when global.

### 3.1 Shadcn Flutter (UI Design System)

The frontend UI must follow a **single design system** and avoid building random one-off widgets.

**Use these first (already in the codebase):**
- `lib/core/widgets/` reusable components (buttons, text fields, loaders, empty/error states, dialogs, etc.)
- `lib/core/theme/app_semantic_colors.dart` semantic colors (`context.appColors.*`) for theme-aware surfaces/text/borders

**Do not:**
- Hardcode `Colors.white`/`Colors.black`/random `Color(0x...)` in screens
- Recreate “new button styles” per feature screen

**Optional (only if present in `pubspec.yaml`):**
- `shadcn_ui` or `shadcn_flutter` widgets. If you use them, keep the same architecture: screens compose widgets; controllers handle state; repositories/services call APIs.

### 4. Required core reusable widgets (build in foundation)

| Widget             | Used By                                |
| ------------------ | -------------------------------------- |
| `CustomButton`     | Auth, create post, apply CV, settings  |
| `CustomTextField`  | Auth, forms, comment input, search     |
| `LoadingWidget`    | Splash, submit actions                 |
| `EmptyStateWidget` | Feed, notifications, chat, finance     |
| `AppErrorWidget`   | All API-driven screens                 |
| `ShimmerListTile`  | Home, profile, finance lists           |
| `UserAvatar`       | Feed, profile, chat, comments          |
| `AppAppBar`        | Most inner screens                     |
| `SectionHeader`    | Profile tabs, settings groups          |
| `StatusBadge`      | Finance payment status, message status |
| `ConfirmDialog`    | Logout, block user, delete actions     |
| `OfflineBanner`    | App-wide connectivity                  |

### 5. Theme and UX rules

- Light Mode and Dark Mode required (competition UX rule).
- Primary brand feel: modern, youth-friendly, clean — not a clone of Facebook/Instagram.
- Minimum tap target: 48×48 logical pixels.
- Use consistent spacing scale: 4, 8, 12, 16, 24, 32.
- Skeleton loading on all list screens.
- Empty states with illustration (Lottie) and CTA where appropriate.
- Page transitions: GetX default or `CupertinoPageTransition` for iOS feel.

### 6. Navigation map

```text
Splash → (token?) Home : Onboarding → Auth → Home

Home (bottom nav or drawer):
  - Feed (Home)
  - Create Post
  - Chat
  - Notifications
  - Profile

From Feed:
  - Post Detail
  - Apply CV (job posts)
  - Other user Profile

From Profile:
  - Preview CV
  - Applicant CV Preview (job poster)
  - Settings
  - Student Verification → Finance

Global access:
  - Search (Home app bar → AppRoutes.search)
  - AI Chatbot (FAB or nav item)
  - Settings
```

### 7. Screen summary (from product spec)

| #   | Screen               | Main Purpose                              |
| --- | -------------------- | ----------------------------------------- |
| 1   | Splash               | Logo + check login token                  |
| 2   | Onboarding           | 3 slides intro (first-time only)          |
| 3   | Auth                 | Login, register, OAuth2                   |
| 4   | Home                 | Social feed (video, poster, job)          |
| 5   | Create Post          | New video / poster / job post             |
| 6   | Post Detail          | Full post + comments + apply              |
| 7   | Apply CV             | Upload CV for job application             |
| 8   | Preview CV           | View/download user CV                     |
| 9   | Profile              | Wavy header, About/Videos/Posters/Jobs/Applied Jobs — see `Screen prompt/profile/README.md` |
| 10  | Finance              | Payment history + alerts (verified only)  |
| 11  | Student Verification | Verify AUB student → unlock finance       |
| 12  | Chat                 | Chat list + message requests              |
| 13  | Chat Detail          | Send/receive messages                     |
| 14  | AI Chatbot           | AI Q&A assistant                          |
| 15  | Notification         | Facebook-style inbox — see `Screen prompt/notification/README.md` |
| 16  | Search               | Facebook-style global search — see `Screen prompt/search/README.md` |
| 17  | Settings             | Account, privacy, theme, language, logout |
| 18  | Applicant CV Preview | Job poster views applicant CVs            |

## Repo Layout

```text
vithey_app/
├── android/
├── ios/
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   ├── network/
│   │   ├── storage/
│   │   ├── utils/
│   │   └── widgets/          # ← REUSABLE COMPONENTS
│   ├── data/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── services/
│   ├── modules/              # ← ONE FOLDER PER SCREEN/FEATURE
│   └── routes/
├── test/
├── pubspec.yaml
└── README.md
```

## API Integration Rules

- Base URL from `.env`: `API_BASE_URL`
- Attach JWT in Dio interceptor from `SecureStorageService`
- On `401`: attempt refresh token once, else redirect to Auth
- Parse standard error envelope and show user-friendly message via `AppErrorWidget` or snackbar
- List endpoints: support `page`, `limit`, handle pagination in controllers
- File upload: multipart via `UploadService`

## Key Endpoints (reference — see Project Overview.txt for full spec)

| Domain        | Examples                                                        |
| ------------- | --------------------------------------------------------------- |
| Auth          | `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh` |
| Users         | `GET /users/me`, `GET /users/{id}`, `PATCH /users/me`, `GET /users/search` |
| Posts         | `GET /posts`, `POST /posts`, `GET /posts/{id}`                  |
| Comments      | `GET /posts/{id}/comments`, `POST /posts/{id}/comments`         |
| Reactions     | `POST /posts/{id}/reactions`                                    |
| Jobs          | `POST /job-applications`, `GET /job-applications`               |
| Files         | `POST /files/upload`                                            |
| Finance       | `GET /fees`, `GET /payments`                                    |
| Verification  | `POST /students/verify`                                         |
| Chat          | `GET /conversations`, `GET /message-requests`, `GET/POST /conversations/{id}/messages` |
| AI            | `POST /ai/chat`                                                 |
| Notifications | `GET /notifications`                                            |

## Testing Expectations

- Widget tests for each reusable `core/widgets/` component
- Controller unit tests with mocked repositories
- One widget test per screen verifying main UI elements render

## Documentation

Each module prompt may ask for brief inline dartdoc on public widgets. Root `README.md` covers setup, env, and run instructions.

## Standardization Rule

- Build the standard project structure first (`00-foundation-prompt.md`).
- Every screen prompt adds only its module folder + route registration.
- Never copy-paste `CustomButton` or `CustomTextField` into a screen file.
- Compose pages from `core/widgets/` + `modules/<feature>/widgets/`.
- The goal is a clean app where new screens are mostly wiring and composition.
