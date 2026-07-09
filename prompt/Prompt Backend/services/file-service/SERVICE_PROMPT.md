# File Service — Complete API Design

> Read `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`.  
> **Scope:** Backend REST API only — upload/download via MinIO.

## Identity

| Item | Value |
|------|-------|
| Path | `backend/services/file-service/` |
| Port | 8083 |
| Eureka | `file-service` |
| Storage | MinIO (S3-compatible) |
| Metadata DB | `auth_db` or dedicated `file_metadata` table in lightweight PG optional |
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
    ├── service/FileStorageService.java, FileMetadataService.java
    ├── repository/FileMetadataRepository.java
    ├── entity/FileMetadata.java
    ├── dto/response/FileUploadResponse.java, FileMetadataResponse.java
    ├── mapper/FileMapper.java
    ├── security/CurrentUserProvider.java
    └── exception/GlobalExceptionHandler.java
```

## Entity FileMetadata

`id` UUID, `owner_user_id`, `file_name`, `file_type` AVATAR|CV|POSTER|VIDEO, `mime_type`, `size_bytes`, `bucket`, `object_key`, `created_at`, `deleted_at`

## Complete API (all JWT)

| Method | Path | Input | Response | HTTP |
|--------|------|-------|----------|------|
| POST | `/api/v1/files/upload` | multipart: `file`, `type` | File metadata + url | 201 |
| GET | `/api/v1/files/{fileId}` | — | Metadata + presigned url | 200 |
| GET | `/api/v1/files/{fileId}/download` | — | Binary stream | 200 |
| DELETE | `/api/v1/files/{fileId}` | — | — | 204 |

**Upload response:**
```json
{
  "data": {
    "file_id": "uuid",
    "file_name": "resume.pdf",
    "file_type": "CV",
    "mime_type": "application/pdf",
    "size_bytes": 102400,
    "url": "http://localhost:9000/cvs/...",
    "created_at": "2026-01-01T00:00:00Z"
  }
}
```

## Business logic

| Step | Logic |
|------|-------|
| Upload | Validate MIME whitelist per `type` → generate object key `{bucket}/{userId}/{uuid}/{filename}` → MinIO put → save metadata |
| Download | Verify caller owns file OR file referenced in public post (optional) → presigned URL 1h |
| Delete | Owner only (`X-User-Id` == `owner_user_id`) → soft delete metadata + MinIO remove |

## MIME whitelist

| Type | Allowed |
|------|---------|
| AVATAR | image/jpeg, image/png, image/webp |
| CV | application/pdf, application/msword, docx |
| POSTER | image/jpeg, image/png |
| VIDEO | video/mp4, video/quicktime |

## MinIO buckets

`avatars`, `cvs`, `posters`, `videos` — create on startup if missing.

## Errors

| Case | HTTP |
|------|------|
| File not found | 404 |
| Not owner on delete | 403 |
| Invalid MIME | 400 |
| File too large (>50MB video, >10MB other) | 400 |

## Testing

Testcontainers MinIO; upload+download integration; delete forbidden for non-owner.

## Output

Runnable file-service on **8083**.
