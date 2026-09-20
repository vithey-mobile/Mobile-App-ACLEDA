# File Service — API Endpoints

Base path: `/api/v1`

## Endpoints

| Method | Path | Purpose | Auth | HTTP |
| --- | --- | --- | --- | --- |
| POST | `/files/upload` | Upload avatar, CV, poster, or video | JWT, multipart | 201 |
| GET | `/files/{file_id}` | Get metadata and 1h presigned URL | JWT (any authenticated) | 200 |
| GET | `/files/{file_id}/download` | Stream binary file | JWT; CV owner-only | 200 |
| DELETE | `/files/{file_id}` | Soft delete owned file | JWT, owner only | 204 |

## Multipart upload

Fields:

| Field | Type | Required |
| --- | --- | --- |
| `file` | binary | yes |
| `type` | enum | yes: `AVATAR`, `CV`, `POSTER`, `VIDEO`, `CHAT_ATTACHMENT` |

## Upload response (`FileUploadResponse`)

```json
{
  "data": {
    "file_id": "uuid",
    "file_name": "avatar.png",
    "file_type": "AVATAR",
    "mime_type": "image/png",
    "size_bytes": 24576,
    "url": "http://localhost:19000/avatars/<owner>/<file_id>/avatar.png?X-Amz-Algorithm=...",
    "created_at": "2026-07-27T15:00:00Z"
  },
  "meta": null,
  "error": null
}
```

## Metadata response (`FileMetadataResponse`)

Same shape as upload, except the type field is JSON `"type"` (not `"file_type"`):

```json
{
  "data": {
    "file_id": "uuid",
    "file_name": "avatar.png",
    "type": "AVATAR",
    "mime_type": "image/png",
    "size_bytes": 24576,
    "url": "http://localhost:19000/avatars/...",
    "created_at": "2026-07-27T15:00:00Z"
  }
}
```

Presigned URLs use `MINIO_PUBLIC_ENDPOINT` (local Docker default `http://localhost:19000`) and expire in **1 hour**.

## Download ACL

| Type | Who can download |
| --- | --- |
| `CV` | Owner only → otherwise `FORBIDDEN` 403 |
| `AVATAR`, `POSTER`, `VIDEO` | Any authenticated user |

Download streams bytes (`Content-Disposition: attachment`); it does not redirect to a presigned URL.

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Missing `file` / `type`, bad UUID/enum | `VALIDATION_ERROR` | 400 (`error.details[{field,message}]`) |
| Invalid MIME | `INVALID_FILE_TYPE` | 400 |
| File too large | `FILE_TOO_LARGE` | 400 |
| Missing/invalid JWT | `UNAUTHORIZED` | 401 |
| Non-owner delete / non-owner CV download | `FORBIDDEN` | 403 |
| Not found or soft-deleted | `NOT_FOUND` | 404 |

Multipart validation returns **400** (not gateway `/error` 401) because `/error` is permitted and skipped by the JWT filter.

## Testing

- Postman (local): `postman/File-Module.postman_collection.json` + `Vithey-Local.postman_environment.json`
- Swagger: `http://localhost:8083/swagger-ui.html`
- Gateway base: `http://localhost:8080`

## Frontend consumers

- Account avatar update (`file_id` → profile `PATCH /users/me/avatar`)
- Create poster/video/job media
- CV upload and preview/download
- **Chat** image/file attachments (`CHAT_ATTACHMENT` → MinIO bucket `chat-attachments/`)

