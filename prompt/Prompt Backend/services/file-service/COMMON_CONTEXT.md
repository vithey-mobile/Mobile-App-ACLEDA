# File Service — Common Context

## Service Role
Centralized file upload, storage, and download via MinIO object storage, with metadata in PostgreSQL `file_db`.

## Identity
| Item | Value |
|------|-------|
| Eureka name | `file-service` |
| Port | 8083 |
| Storage | MinIO buckets + `file_db` metadata |
| Package | `com.vithey.file` |

## Buckets
| Bucket | Content |
|--------|---------|
| `avatars` | Profile images |
| `cvs` | PDF, DOC, DOCX |
| `posters` | Image posts |
| `videos` | Video posts |

## Max File Sizes
- Avatar: 10 MB
- CV: 10 MB
- Poster: 10 MB
- Video: 50 MB

## MinIO public URLs
Presigned URLs are signed with `MINIO_PUBLIC_ENDPOINT` / `vithey.minio.public-endpoint` (local Docker default `http://localhost:19000`) so browsers/mobile can open them. Internal I/O uses `MINIO_ENDPOINT` (`http://minio:9000` in Docker).

## API Prefix
`/api/v1/files/**`

## Used By
Content Service, Career Service, User-Profile Service
