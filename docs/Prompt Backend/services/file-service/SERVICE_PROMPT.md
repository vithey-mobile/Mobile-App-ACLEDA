# File Service — Complete API Design

> Read `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`.  
> **Scope:** Backend REST API only — upload/download via MinIO + `file_db` metadata.

## Identity

| Item | Value |
|------|-------|
| Path | `backend/services/file-service/` |
| Port | 8083 |
| Eureka | `file-service` |
| Storage | MinIO (S3-compatible) |
| Metadata DB | `file_db` / table `file_metadata` |
| Package | `com.vithey.file` |

## Spring Cloud + tools

Eureka, Config, **MinIO Java SDK** (`io.minio:minio`), JPA (metadata), Flyway, springdoc. No RabbitMQ.

## Folder structure

```text
services/file-service/
└── src/main/java/com/vithey/file/
    ├── FileServiceApplication.java
    ├── config/MinioConfig.java, SecurityConfig.java, OpenApiConfig.java
    ├── controller/FileController.java
    ├── service/
    │   ├── FileStorageService.java
    │   ├── FileMetadataService.java
    │   ├── FileMetadataPersistence.java
    │   └── FileValidationService.java
    ├── repository/FileMetadataRepository.java
    ├── entity/FileMetadata.java, StoredFileType.java
    ├── dto/response/FileUploadResponse.java, FileMetadataResponse.java
    ├── mapper/FileMapper.java
    ├── security/
    │   ├── JwtProvider.java
    │   ├── JwtAuthenticationFilter.java
    │   ├── CurrentUser.java
    │   └── CurrentUserProvider.java
    ├── exception/ApiException.java, ErrorCode.java, GlobalExceptionHandler.java
    └── util/ApiResponseWrapper.java
```

Snake_case JSON via `application.yml` (no `JacksonConfig`).

## Entity FileMetadata

`id` UUID, `owner_user_id`, `file_name`, `file_type` AVATAR|CV|POSTER|VIDEO, `mime_type`, `size_bytes`, `bucket`, `object_key`, `created_at`, `deleted_at`

Object key format: `{ownerUserId}/{fileId}/{safeFileName}` — **bucket is a separate column**, not part of the key.

## Complete API (all JWT)

| Method | Path | Input | Response | HTTP |
|--------|------|-------|----------|------|
| POST | `/api/v1/files/upload` | multipart: `file`, `type` | Upload metadata + url | 201 |
| GET | `/api/v1/files/{fileId}` | — | Metadata + presigned url (`type` field) | 200 |
| GET | `/api/v1/files/{fileId}/download` | — | Binary stream | 200 |
| DELETE | `/api/v1/files/{fileId}` | — | — | 204 |

**Upload response:**
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
  }
}
```

## Business logic

| Step | Logic |
|------|-------|
| Upload | Validate MIME/size → choose bucket by `type` → MinIO `putObject` (outside DB TX) → save metadata |
| Metadata | Any authenticated user; return metadata + 1h URL signed with `MINIO_PUBLIC_ENDPOINT` |
| Download | Stream bytes; **CV owner-only**; AVATAR/POSTER/VIDEO any authenticated user |
| Delete | Owner only → soft-delete metadata first → then MinIO `removeObject` (outside DB TX) |

Auth: Bearer JWT and/or gateway `X-User-*` headers via `CurrentUserProvider`.

## MIME whitelist + max size

| Type | Allowed MIME | Max |
|------|--------------|-----|
| AVATAR | image/jpeg, image/png, image/webp | 10 MB |
| CV | application/pdf, application/msword, docx | 10 MB |
| POSTER | image/jpeg, image/png, image/webp | 10 MB |
| VIDEO | video/mp4, video/quicktime | 50 MB |

## MinIO

Buckets (create on startup if missing): `avatars`, `cvs`, `posters`, `videos`.

| Config | Purpose |
|--------|---------|
| `MINIO_ENDPOINT` | Internal client (Docker: `http://minio:9000`) |
| `MINIO_PUBLIC_ENDPOINT` | Presign host clients open (local: `http://localhost:19000`) |
| `MINIO_ACCESS_KEY` / `MINIO_SECRET_KEY` | Credentials |
| `MINIO_BUCKETS` | Comma-separated bucket list |

`MinioConfig` exposes `minioStorageClient` + `minioPresignClient`.

## Config / env

Also: `FILE_DB_URL`, `FILE_DB_USERNAME`, `FILE_DB_PASSWORD`, `VITHEY_JWT_SECRET`, Hikari `connection-timeout: 3000`.

`/error` is `permitAll` and skipped by JWT filter so multipart binding failures return **400**, not secured **401**.

## Errors

| Case | Code | HTTP |
|------|------|------|
| Missing file/type, bad UUID/enum | `VALIDATION_ERROR` | 400 |
| Invalid MIME | `INVALID_FILE_TYPE` | 400 |
| File too large | `FILE_TOO_LARGE` | 400 |
| Missing/invalid JWT | `UNAUTHORIZED` | 401 |
| Not owner on delete / CV download | `FORBIDDEN` | 403 |
| File not found / deleted | `NOT_FOUND` | 404 |
| Unexpected | `INTERNAL_ERROR` | 500 |

## Testing

- Postman: `postman/File-Module.postman_collection.json`
- Swagger: `http://localhost:8083/swagger-ui.html`
- Unit: `FileValidationServiceTest`; optional Testcontainers MinIO

## Output

Runnable file-service on **8083**.
