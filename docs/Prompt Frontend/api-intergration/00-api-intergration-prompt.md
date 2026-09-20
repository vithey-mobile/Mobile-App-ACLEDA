# 00 - Live API Integration Prompt

Wire the Flutter app to the **live Vithey backend API** through API Gateway.

> Read first:
> 1. `Prompt Frontend/api-intergration/integration-contract.md`
> 2. `Prompt Frontend/api-intergration/api-overview.md`
> 3. `Prompt Frontend/COMMON_CONTEXT.md`
> 4. Relevant screen prompts in `Prompt Frontend/Screen prompt/`

## Goal

Replace mock-only data paths with real Dio services, repositories, token handling, file upload, pagination, WebSocket chat, and notification registration while preserving existing UI modules.

## Scope

| In scope | Out of scope |
|----------|--------------|
| Flutter networking layer | Backend implementation |
| Dio interceptors | Changing API contracts |
| Repository wiring | Redesigning screen UI |
| Auth refresh/logout | Creating new screens |
| File uploads | Hard-coded test data |
| WebSocket chat client | Fake notification payloads |
| FCM device token registration | Admin panel |

## Required Environment

Create/update:

```text
vithey_app/.env
```

```env
API_BASE_URL=http://localhost:8080/api/v1
USE_MOCK_AUTH=false
USE_MOCK_API=false
```

Platform values:

| Platform | API base URL |
|----------|--------------|
| Android emulator | `http://10.0.2.2:8080/api/v1` |
| iOS simulator | `http://localhost:8080/api/v1` |
| Physical device | `http://<PC-LAN-IP>:8080/api/v1` |

## Files To Create / Update

```text
lib/core/constants/
  api_endpoints.dart

lib/core/network/
  dio_client.dart
  api_service.dart
  api_response.dart
  api_exception.dart
  network_interceptor.dart

lib/core/storage/
  secure_storage_service.dart
  local_storage_service.dart

lib/data/services/
  auth_service.dart
  upload_service.dart
  post_service.dart
  profile_service.dart
  cv_service.dart
  finance_service.dart
  chat_service.dart
  chatbot_service.dart
  notification_service.dart
  websocket_chat_service.dart

lib/data/repositories/
  auth_repository.dart
  post_repository.dart
  profile_repository.dart
  cv_repository.dart
  finance_repository.dart
  chat_repository.dart
  chatbot_repository.dart
  notification_repository.dart
```

Do not call Dio directly from widgets or controllers. Controllers call repositories only.

## API Endpoint Constants

`api_endpoints.dart` paths are **relative to** `API_BASE_URL`; do not include `/api/v1`.

```dart
class ApiEndpoints {
  static const authRegister = '/auth/register';
  static const authLogin = '/auth/login';
  static const authRefresh = '/auth/refresh';
  static const authLogout = '/auth/logout';
  static const authMe = '/auth/me';
  static const studentVerify = '/students/verify';

  static const usersMe = '/users/me';
  static String userById(String id) => '/users/$id';
  static const userSettings = '/users/me/settings';

  static const filesUpload = '/files/upload';
  static String fileDownload(String id) => '/files/$id/download';

  static const posts = '/posts';
  static String postById(String id) => '/posts/$id';
  static String postComments(String id) => '/posts/$id/comments';
  static String postReactions(String id) => '/posts/$id/reactions';
  static String followUser(String id) => '/users/$id/follow';

  static const jobApplications = '/job-applications';
  static const myCv = '/users/me/cv';

  static const payments = '/payments';
  static const paymentAlerts = '/payments/alerts';
  static const fees = '/fees';

  static const conversations = '/conversations';
  static const conversationRequest = '/conversations/request';
  static const messageRequests = '/message-requests';
  static String conversationMessages(String id) => '/conversations/$id/messages';
  static String markMessageRead(String id) => '/messages/$id/read';

  static const aiChat = '/ai/chat';
  static const aiSessions = '/ai/sessions';
  static String aiSessionMessages(String id) => '/ai/sessions/$id/messages';

  static const notifications = '/notifications';
  static const notificationUnreadCount = '/notifications/unread-count';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const notificationReadAll = '/notifications/read-all';
  static const notificationDevices = '/notifications/devices';
}
```

## Response Envelope

Parse exactly:

```json
{ "data": {} }
```

```json
{ "data": [], "meta": { "page": 1, "limit": 20, "total": 50, "total_pages": 3 } }
```

```json
{ "error": { "code": "VALIDATION_ERROR", "message": "...", "details": [] } }
```

## Dio Client Requirements

`dio_client.dart` must:

- Load `API_BASE_URL` from `.env`
- Set connect/read/write timeouts
- Attach `Authorization: Bearer <access_token>` when token exists
- Attach `X-Request-ID` for tracing
- On `401`, call `/auth/refresh` once
- Save new tokens after refresh
- Retry original request once
- If refresh fails, clear secure storage and navigate to `Routes.AUTH`
- Convert backend error envelope to `ApiException`

## Auth Integration

`AuthRepository` owns:

| Method | Endpoint | Behavior |
|--------|----------|----------|
| `login(emailOrPhone, password)` | `POST /auth/login` | Save tokens + user |
| `register(...)` | `POST /auth/register` | Save tokens + user |
| `refresh()` | `POST /auth/refresh` | Rotate refresh token |
| `logout()` | `POST /auth/logout` | Best effort remote logout + local clear |
| `me()` | `GET /auth/me` or `/users/me` | Load current user |

Token storage:

- `access_token` and `refresh_token` in `flutter_secure_storage`
- Never store JWT in `shared_preferences`
- Clear tokens on logout, refresh failure, or account switch

## Domain Repository Wiring

| Repository | Service | Main endpoints |
|------------|---------|----------------|
| `PostRepository` | content | `/posts`, comments, reactions, follows |
| `ProfileRepository` | user-profile | `/users/me`, `/users/{id}`, settings |
| `CvRepository` | career + file | `/users/me/cv`, `/files/{id}/download` |
| `FinanceRepository` | finance | `/payments`, `/payments/alerts`, `/fees` |
| `ChatRepository` | chat | `/conversations`, `/message-requests`, messages |
| `ChatbotRepository` | ai | `/ai/chat`, `/ai/sessions` |
| `NotificationRepository` | notification | `/notifications`, read/unread/device token |

Each repository must:

- Return typed models, not raw `Map`
- Accept pagination params where applicable
- Map backend errors to UI-safe messages
- Keep mock fallback only behind `USE_MOCK_API=true`

## File Upload

`UploadService.uploadFile()`:

- Uses multipart `POST /files/upload`
- Sends fields:
  - `file`: binary
  - `type`: `AVATAR`, `CV`, `POSTER`, `VIDEO`
- Returns `file_id`, `file_name`, `file_type`, `mime_type`, `size_bytes`, `url`

Used by:

- Avatar update → profile
- CV upload → career
- Create poster/video → content

## Pagination

All list controllers must:

- Track `page`, `limit`, `totalPages`
- Stop loading when `page >= totalPages`
- Preserve existing items on pagination error
- Support pull-to-refresh resetting to page 1
- De-duplicate by stable ID

## WebSocket Chat

Use `web_socket_channel` or `socket_io_client` according to foundation dependency choice.

Connect:

```text
ws://localhost:8080/ws
```

Subscribe:

```text
/user/queue/messages
```

Rules:

- Include JWT in handshake headers where supported
- Reconnect with backoff
- Refresh token before reconnect if needed
- Insert received messages into the active conversation cache
- Mark messages read through `PATCH /messages/{id}/read`
- Do not fake online status unless backend provides presence

## Notifications / FCM

When Firebase is configured:

1. Request permission
2. Get FCM token
3. Register token:

```http
POST /notifications/devices
```

```json
{ "fcm_token": "...", "platform": "ANDROID" }
```

Foreground push should update:

- Notification list cache
- Home unread badge
- Related screen if currently open

If Firebase is not configured, hide push registration errors in dev but keep in-app notifications working.

## Screen Integration Checklist

| Screen / flow | Required live API |
|---------------|-------------------|
| Auth / Register | login, register, refresh, logout |
| Startup profile | `/users/me`, `/users/me/settings` |
| Home feed | posts, reactions, comments, follow |
| Create post | file upload + create post |
| Post detail | post detail + comments |
| Upload CV / Apply | file upload + job application |
| Profile | public profile + user's posts/jobs/CV |
| Finance | verify gate + payments/fees/alerts |
| Chat | conversations, requests, messages, WebSocket |
| Chatbot | ai chat, sessions, messages |
| Notifications | list, unread count, mark read, device token |
| Settings | settings read/update, logout |

## Testing

Required tests:

- `DioClient` attaches token
- `DioClient` refreshes once on 401
- Refresh failure clears session and routes Auth
- Error envelope maps to `ApiException`
- Multipart upload sends correct fields
- Repository parses paginated response
- Auth repository saves tokens

Manual smoke test:

```bash
curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email_or_phone":"test@aub.edu.kh","password":"SecurePass1!"}'
```

Then run Flutter:

```bash
flutter run --dart-define-from-file=.env
```

## Output

The app uses live backend APIs through the gateway, with no direct backend URLs in widgets/controllers and no mock data unless `USE_MOCK_API=true`.

