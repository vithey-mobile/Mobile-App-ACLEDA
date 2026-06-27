# Vithey App — Frontend Common Context

## Objective

Build a production-quality Flutter mobile app for AUB students combining social feed, job applications, student finance, private chat, AI assistant, and notifications. The app must be modular, testable screen-by-screen, and built around **reusable components** composed into feature pages.

## App Identity

| Item             | Value                                                                                 |
| ---------------- | ------------------------------------------------------------------------------------- |
| App name         | **Vithey App**                                                                        |
| Package / folder | `vithey_app`                                                                          |
| Audience         | AUB students + youth users                                                            |
| Competition      | [ACLEDA Bank App Competition 2026](https://www.acledabank.com.kh/sl/app-competition/) |

## Core Features (Competition + Product)

1. **Social Feed** — video, poster, and job posts with like, comment, mention, follow
2. **Job Apply** — upload CV and apply to job posts
3. **Profile** — user info, social links, content tabs, CV preview
4. **Finance** — tuition payment history, status, alerts (verified AUB students only)
5. **Student Verification** — unlock finance feature
6. **Private Chat** — message requests, accept-before-chat privacy
7. **AI Chatbot** — CV, job, interview, student support, finance Q&A
8. **Notifications** — likes, comments, mentions, follows, chat, payments, jobs
9. **Settings** — account, privacy, theme, language, logout

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
| socket_io_client or web_socket_channel           | Real-time chat (when backend ready)   |
| firebase_messaging + flutter_local_notifications | Push (when backend ready)             |
| Auth0 Flutter                                    | OAuth2 login (optional, auth screen)  |

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
- Shared components must support **light and dark theme** via `Theme.of(context)`.
- Naming: `CustomButton`, `PostCard`, `UserAvatar` — clear, prefixed when global.

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
  - AI Chatbot (FAB or nav item)
  - Settings
```

### 7. Screen summary (from product spec)

| #   | Screen               | Main Purpose                              |
| --- | -------------------- | ----------------------------------------- |
| 1   | Splash               | Logo + check login token                  |
| 2   | Onboarding           | 2 slides intro (first-time only)          |
| 3   | Auth                 | Login, register, OAuth2                   |
| 4   | Home                 | Social feed (video, poster, job)          |
| 5   | Create Post          | New video / poster / job post             |
| 6   | Post Detail          | Full post + comments + apply              |
| 7   | Apply CV             | Upload CV for job application             |
| 8   | Preview CV           | View/download user CV                     |
| 9   | Profile              | Info, videos, posters, CV tabs            |
| 10  | Finance              | Payment history + alerts (verified only)  |
| 11  | Student Verification | Verify AUB student → unlock finance       |
| 12  | Chat                 | Chat list + message requests              |
| 13  | Chat Detail          | Send/receive messages                     |
| 14  | AI Chatbot           | AI Q&A assistant                          |
| 15  | Notification         | All notification types                    |
| 16  | Settings             | Account, privacy, theme, language, logout |
| 17  | Applicant CV Preview | Job poster views applicant CVs            |

## Repo Layout

```text
aub_connect_app/
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
| Users         | `GET /users/me`, `GET /users/{id}`, `PATCH /users/me`           |
| Posts         | `GET /posts`, `POST /posts`, `GET /posts/{id}`                  |
| Comments      | `GET /posts/{id}/comments`, `POST /posts/{id}/comments`         |
| Reactions     | `POST /posts/{id}/reactions`                                    |
| Jobs          | `POST /job-applications`, `GET /job-applications`               |
| Files         | `POST /files/upload`                                            |
| Finance       | `GET /fees`, `GET /payments`                                    |
| Verification  | `POST /students/verify`                                         |
| Chat          | `GET /conversations`, `POST /messages`                          |
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
