# 00 - Foundation Prompt

Build the base Flutter project skeleton for **Vithey App** (`aub_connect_app`).

## Goal
Create the repository structure, theme system, routing, network layer, storage, and **all core reusable widgets** so each screen module can be built independently by composing shared components.

## Must Use
- Flutter SDK (stable)
- GetX
- Dio
- flutter_secure_storage
- shared_preferences
- flutter_dotenv
- intl
- cached_network_image
- lottie
- shimmer
- connectivity_plus
- logger

## Must Not Use
- Backend code
- Placeholder `// TODO` without working UI fallback
- Inline duplicate button/text-field code in screen files
- Provider, Bloc, or Riverpod (use GetX only)

## Root Files to Create
- `pubspec.yaml` with all dependencies from `COMMON_CONTEXT.md`
- `lib/main.dart`
- `lib/app.dart`
- `.env.example` with `API_BASE_URL=http://localhost:8080/api/v1`
- `README.md` with setup and run steps
- `analysis_options.yaml`
- Asset folders: `assets/images/`, `assets/icons/`, `assets/fonts/`

## Core Structure to Create

### Constants (`lib/core/constants/`)
- `app_colors.dart` — primary, secondary, surface, error, success, payment status colors
- `app_strings.dart` — English keys (structure for Khmer later)
- `app_routes.dart` — route name constants
- `api_endpoints.dart` — path constants matching API v1

### Theme (`lib/core/theme/`)
- `light_theme.dart`
- `dark_theme.dart`
- `app_theme.dart` — `ThemeMode` switch helper

### Network (`lib/core/network/`)
- `dio_client.dart` — base Dio, timeouts, auth interceptor, error interceptor
- `api_response.dart` — generic `ApiResponse<T>`, `PaginatedResponse<T>`, `ApiError`
- `api_service.dart` — thin wrapper for GET/POST/PUT/DELETE

### Storage (`lib/core/storage/`)
- `secure_storage_service.dart` — save/read/delete access + refresh tokens
- `local_storage_service.dart` — theme, language, onboarding flag, user prefs

### Utils (`lib/core/utils/`)
- `validators.dart` — email, phone, password, required
- `date_formatter.dart` — relative time, currency (KHR/USD)
- `permission_helper.dart`
- `file_picker_helper.dart`

### Reusable Widgets (`lib/core/widgets/`) — REQUIRED
Build fully styled, theme-aware widgets:

| File | Responsibility |
|------|----------------|
| `custom_button.dart` | Primary, secondary, outline, loading state, disabled |
| `custom_text_field.dart` | Label, hint, obscure toggle, validator, error text |
| `loading_widget.dart` | Centered spinner / Lottie loader |
| `empty_state_widget.dart` | Icon/Lottie + title + subtitle + optional action button |
| `app_error_widget.dart` | Error message + retry button |
| `shimmer_list_tile.dart` | Skeleton for list loading |
| `user_avatar.dart` | Network image with fallback initials |
| `app_app_bar.dart` | Consistent app bar with back, title, actions |
| `section_header.dart` | Section title + optional trailing |
| `status_badge.dart` | Paid, unpaid, pending, overdue, sent, read |
| `confirm_dialog.dart` | Reusable confirmation dialog |
| `offline_banner.dart` | Top banner when no connectivity |

Each widget must:
- Accept `Key? key` and required data via constructor
- Work in light and dark mode
- Have a brief dartdoc comment

### Routes (`lib/routes/`)
- `app_routes.dart` — route constants
- `app_pages.dart` — initial `GetMaterialApp` pages list (splash only initially; other routes added by later prompts)

### Data layer stubs (`lib/data/`)
- Empty `models/`, `repositories/`, `services/` folders with `.gitkeep` or one example model `user_model.dart`

### App entry
- `main.dart` — load dotenv, init storage, run app
- `app.dart` — `GetMaterialApp`, theme mode from storage, initial route splash, `ConnectivityWrapper` with `OfflineBanner`

## Foundation Rules
- Register GetX bindings lazily per route (pattern for later modules).
- Dio interceptor reads token from `SecureStorageService`.
- Theme toggle persisted in `LocalStorageService`.
- Use `AppColors` and `ThemeData` — no hardcoded random colors in widgets.
- Export commonly used widgets via optional `lib/core/widgets/widgets.dart` barrel file.

## Output
Generate complete runnable skeleton. App must launch to a placeholder Splash route that shows logo + `LoadingWidget`. No `// TODO implement later` for core widgets — they must be functional.

## Non-negotiable Structure Rules
- Use the exact folder layout from `COMMON_CONTEXT.md`.
- All reusable UI lives in `core/widgets/`.
- Screen modules are added in later prompts only.
- Do not put feature business logic in `core/`.
