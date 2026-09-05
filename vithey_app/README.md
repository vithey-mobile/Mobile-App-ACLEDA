# Vithey App (Flutter)

AUB student mobile app — social feed, jobs, finance, chat, AI chatbot, notifications.

## Tech stack

- Flutter + GetX
- Dio (API via gateway `http://localhost:8080/api/v1`)
- Light + Dark theme

## Setup

```powershell
cd "D:\project\Acleda Mobile App\vithey_app"
copy .env.example .env
flutter pub get
flutter run
```

### Android emulator API URL

Edit `.env`:

```env
API_BASE_URL=http://10.0.2.2:8080/api/v1
```

### Mock auth (UI dev without backend)

```env
USE_MOCK_AUTH=true
```

Set `USE_MOCK_AUTH=false` when testing real login against the gateway.

Set `USE_MOCK_API=false` when testing the real posts feed against the gateway.

### Physical device on same Wi‑Fi

Use your PC LAN IP instead of `localhost`.

## Project structure

```text
lib/
  core/       # theme, network, storage, reusable widgets
  data/       # models, repositories, services
  modules/    # one folder per screen/feature
  routes/     # GetX pages
```

## Build order (from prompts)

1. ✅ Foundation (`Screen prompt/00-foundation-prompt.md`)
2. ✅ Auth flow (`auth/01-splash` → `09-startup-3`)
3. ✅ Media feed — Home, poster/video/job cards, comments, share, create post
4. ✅ Post detail — full post, comments, @mentions, video player, Apply CV
5. ✅ Profile — shell, About/Posters/Videos/Jobs tabs, applicants, CV preview
6. ✅ Upload CV — job context, file picker, saved CV, submit pipeline
7. ✅ Finance — verification form/status, Finance Home, invoice preview
8. ✅ Chat — conversation list, message thread, participant profile
9. ✅ Chatbot — Vithey AI shell, history drawer, composer, responses
10. ✅ Notifications — inbox, All/Unread filters, action sheet, routing
11. ✅ Settings — home, account, privacy, security, change password, help, about

## Backend

Ensure Docker backend is running:

```powershell
cd "D:\project\Acleda Mobile App\backend"
.\scripts\verify-docker.ps1
```
