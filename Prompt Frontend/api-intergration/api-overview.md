# API Overview

> **Authoritative contract:** [`integration-contract.md`](integration-contract.md)  
> Paths below are **relative to** `API_BASE_URL` (`http://localhost:8080/api/v1`).  
> Backend controllers use the full path including `/api/v1`.

## Base URLs

| Environment | `API_BASE_URL` |
|-------------|----------------|
| Local gateway | `http://localhost:8080/api/v1` |
| Android emulator | `http://10.0.2.2:8080/api/v1` |
| iOS simulator | `http://localhost:8080/api/v1` |
| Production | `https://<gateway-domain>/api/v1` |

## Authentication

```http
Authorization: Bearer <access_token>
```

| Type | Endpoints |
|------|-----------|
| Public | `/auth/register`, `/auth/login`, `/auth/refresh`, `/auth/forgot-password`, `/auth/reset-password` |
| Protected | All other endpoints |

- Access token TTL: **15 minutes**
- Refresh: `POST /auth/refresh` with `{ "refresh_token": "..." }`
- On `401`: refresh once, then redirect to Auth screen

## Response envelope

**Success:** `{ "data": ... }` or `{ "data": [...], "meta": { "page", "limit", "total", "total_pages" } }`  
**Error:** `{ "error": { "code", "message", "details": [{ "field", "message" }] } }`

## Pagination

Query: `?page=1&limit=20&sort=-created_at`

## Auth (`auth-service`)

| Method | Path | Auth |
|--------|------|------|
| POST | `/auth/register` | Public |
| POST | `/auth/login` | Public |
| POST | `/auth/refresh` | Public |
| POST | `/auth/logout` | JWT |
| GET | `/auth/me` | JWT |
| POST | `/students/verify` | JWT |

## Users (`user-profile-service`)

| Method | Path | Auth |
|--------|------|------|
| GET | `/users/me` | JWT |
| GET | `/users/{id}` | JWT |
| PATCH | `/users/me` | JWT |
| PATCH | `/users/me/avatar` | JWT |
| GET | `/users/me/settings` | JWT |
| PATCH | `/users/me/settings` | JWT |
| GET | `/users/search?search=` | JWT |

## Files (`file-service`)

| Method | Path | Auth |
|--------|------|------|
| POST | `/files/upload` | JWT (multipart: `file`, `type`) |
| GET | `/files/{id}` | JWT |
| GET | `/files/{id}/download` | JWT |
| DELETE | `/files/{id}` | JWT |

`type` enum: `AVATAR`, `CV`, `POSTER`, `VIDEO`

## Posts & social (`content-service`)

| Method | Path | Auth |
|--------|------|------|
| GET/POST | `/posts` | JWT |
| GET | `/posts/{id}` | JWT |
| GET/POST | `/posts/{id}/comments` | JWT |
| POST | `/posts/{id}/reactions` | JWT |
| POST | `/users/{id}/follow` | JWT |
| DELETE | `/users/{id}/follow` | JWT |
| GET | `/users/{id}/followers` | JWT |
| GET | `/users/{id}/following` | JWT |

> Gateway routes `/users/*/follow` to **content-service** before generic `/users/**` (see integration contract).

## Jobs & CV (`career-service`)

| Method | Path | Auth |
|--------|------|------|
| POST | `/job-applications` | JWT |
| GET | `/job-applications` | JWT |
| GET | `/job-applications?job_post_id={id}` | JWT (poster) |
| GET | `/job-applications/{id}` | JWT |
| PATCH | `/job-applications/{id}/status` | JWT (poster) |
| GET | `/users/me/cv` | JWT |
| PUT | `/users/me/cv` | JWT |

> Gateway routes `/users/me/cv` to **career-service** before generic `/users/**`.

## Finance (`finance-service`)

| Method | Path | Auth |
|--------|------|------|
| GET | `/payments` | JWT (`STUDENT` role) |
| GET | `/payments/alerts` | JWT (`STUDENT`) |
| GET | `/fees` | JWT (`STUDENT`) |

Returns `403` if user is not a verified student.

## Chat (`chat-service`)

| Method | Path | Auth |
|--------|------|------|
| GET | `/conversations` | JWT |
| POST | `/conversations/request` | JWT |
| POST | `/conversations/{id}/accept` | JWT |
| POST | `/conversations/{id}/decline` | JWT |
| POST | `/conversations/{id}/block` | JWT |
| GET | `/message-requests` | JWT |
| GET/POST | `/conversations/{id}/messages` | JWT |
| PATCH | `/messages/{id}/read` | JWT |

WebSocket: STOMP at `/ws` — subscribe `/user/queue/messages`

## AI (`ai-service`)

| Method | Path | Auth |
|--------|------|------|
| POST | `/ai/chat` | JWT |
| GET | `/ai/sessions` | JWT |
| GET | `/ai/sessions/{id}/messages` | JWT |
| DELETE | `/ai/sessions/{id}` | JWT |
| POST | `/ai/cv/suggest` | JWT |

`topic` enum: `CV`, `JOB`, `INTERVIEW`, `STUDENT`, `FINANCE`

## Notifications (`notification-service`)

| Method | Path | Auth |
|--------|------|------|
| GET | `/notifications` | JWT |
| PATCH | `/notifications/{id}/read` | JWT |

## Screen → API map

| Screen | Main endpoints |
|--------|----------------|
| Auth | `/auth/register`, `/auth/login` |
| Home | `GET /posts`, `POST /posts/{id}/reactions`, `POST /users/{id}/follow` |
| Create Post | `POST /files/upload`, `POST /posts` |
| Post Detail | `GET /posts/{id}`, comments, reactions |
| Apply CV | `POST /files/upload`, `POST /job-applications` |
| Preview CV | `GET /users/me/cv`, `GET /files/{id}/download` |
| Profile | `GET /users/{id}` |
| Finance | `GET /payments`, `/payments/alerts`, `/fees` |
| Verification | `POST /students/verify` |
| Chat | `GET /conversations`, `GET /message-requests` |
| Chat Detail | `GET/POST /conversations/{id}/messages` |
| AI Chatbot | `POST /ai/chat`, `GET /ai/sessions/{id}/messages` |
| Notifications | `GET /notifications` |
| Settings | `GET/PATCH /users/me/settings`, `POST /auth/logout` |
| Applicant CV | `GET /job-applications?job_post_id=` |

Full service detail: each `Prompt Backend/services/<service>/` folder now includes `API_ENDPOINTS.md`, `FOLDER_STRUCTURE.md`, `SERVICE_LOGIC.md`, `DB_SCHEMA.md`, `KICKOFF_PROMPT.md`, `COMMON_CONTEXT.md`, and `SERVICE_PROMPT.md`.
