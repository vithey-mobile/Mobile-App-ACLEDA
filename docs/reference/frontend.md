# Frontend Reference — Flutter

## Stack

| Tool | Use |
|------|-----|
| Flutter SDK | Android + iOS |
| Dart | Language |
| GetX | State, routing, DI |
| Dio | REST API |

## Key packages by screen

| Package | Screens |
|---------|---------|
| `flutter_secure_storage` | Auth, Splash |
| `shared_preferences` | Settings, Onboarding, theme |
| `file_picker` | Apply CV |
| `image_picker` | Create Post |
| `video_player` | Home, Post Detail |
| `cached_network_image` | Feed, Profile |
| `flutter_pdfview` | Preview CV, Applicant CV |
| `intl` | Finance, dates |
| `lottie` | Splash, Onboarding, empty states |
| `shimmer` | Home, Profile, Finance lists |
| `socket_io_client` | Chat Detail |
| `url_launcher` | Profile (Telegram, Facebook) |

## Folder structure

```text
aub_connect_app/lib/
├── core/
│   ├── constants/     # colors, routes, API endpoints
│   ├── theme/         # light + dark
│   ├── network/       # Dio client
│   ├── storage/       # secure + local
│   ├── utils/
│   └── widgets/       # REUSABLE components
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── modules/           # one folder per screen
└── routes/
```

## Module pattern (every screen)

```text
modules/<feature>/
  <feature>_screen.dart
  <feature>_controller.dart
  <feature>_binding.dart
  widgets/
```

## Cursor prompts

See `Prompt Frontend/KICKOFF_PROMPT.md` and `Prompt Frontend/v1/`.

## Local API URL

| Platform | `API_BASE_URL` |
|----------|----------------|
| Android emulator | `http://10.0.2.2:8080/api/v1` |
| iOS simulator | `http://localhost:8080/api/v1` |
| Physical device | Your PC LAN IP |
