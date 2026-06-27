# API Overview

## Base URLs

| Environment | URL |
|-------------|-----|
| Local (gateway) | `http://localhost:8080/api/v1` |
| Production | `https://<your-gateway-domain>/api/v1` |

## Authentication

```http
Authorization: Bearer <access_token>
```

- Public: `/auth/register`, `/auth/login`, `/auth/refresh`
- Access token TTL: 15 minutes
- Refresh token: use `/auth/refresh`

## Error format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [{ "field": "email", "message": "Invalid email" }]
  }
}
```

## Pagination

Query: `?page=1&limit=20&sort=-created_at`

Response includes `meta`: `page`, `limit`, `total`, `total_pages`

## Endpoint index by domain

### Auth (`auth-service`)
| Method | Path |
|--------|------|
| POST | `/auth/register` |
| POST | `/auth/login` |
| POST | `/auth/refresh` |
| POST | `/auth/logout` |
| POST | `/students/verify` |

### Users (`user-profile-service`)
| Method | Path |
|--------|------|
| GET | `/users/me` |
| GET | `/users/{id}` |
| PATCH | `/users/me` |
| PATCH | `/users/me/settings` |

### Posts (`content-service`)
| Method | Path |
|--------|------|
| GET/POST | `/posts` |
| GET | `/posts/{id}` |
| GET/POST | `/posts/{id}/comments` |
| POST | `/posts/{id}/reactions` |
| POST/DELETE | `/users/{id}/follow` |

### Jobs (`career-service`)
| Method | Path |
|--------|------|
| POST | `/job-applications` |
| GET | `/job-applications` |
| GET | `/users/me/cv` |

### Finance (`finance-service`)
| Method | Path |
|--------|------|
| GET | `/payments` |
| GET | `/payments/alerts` |
| GET | `/fees` |

### Chat (`chat-service`)
| Method | Path |
|--------|------|
| GET | `/conversations` |
| GET/POST | `/conversations/{id}/messages` |
| GET | `/message-requests` |

### AI (`ai-service`)
| Method | Path |
|--------|------|
| POST | `/ai/chat` |

### Notifications (`notification-service`)
| Method | Path |
|--------|------|
| GET | `/notifications` |
| PATCH | `/notifications/{id}/read` |

### Files (`file-service`)
| Method | Path |
|--------|------|
| POST | `/files/upload` |
| GET | `/files/{id}/download` |

## Screen → API quick map

| Screen | Main endpoints |
|--------|----------------|
| Auth | `/auth/register`, `/auth/login` |
| Home | `GET /posts` |
| Create Post | `POST /files/upload`, `POST /posts` |
| Apply CV | `POST /job-applications` |
| Profile | `GET /users/{id}` |
| Finance | `GET /payments`, `/payments/alerts` |
| Verification | `POST /students/verify` |
| Chat | `GET /conversations` |
| AI Chatbot | `POST /ai/chat` |
| Notifications | `GET /notifications` |

Full API detail: see archived export `archive/Project-Overview-raw.txt` (API Design section) or implement per `Prompt Backend` service prompts.
