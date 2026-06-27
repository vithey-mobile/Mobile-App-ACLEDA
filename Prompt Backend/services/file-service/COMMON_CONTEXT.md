# File Service — Common Context

## Service Role
Centralized file upload, storage, and download via MinIO object storage.

## Identity
| Item | Value |
|------|-------|
| Eureka name | `file-service` |
| Port | 8083 |
| Storage | MinIO buckets |
| Package | `com.vithey.file` |

## Buckets
| Bucket | Content |
|--------|---------|
| `avatars` | Profile images |
| `cvs` | PDF, DOC, DOCX |
| `posters` | Image posts |
| `videos` | Video posts |

## Max File Sizes
- Avatar: 5 MB
- CV: 10 MB
- Poster: 10 MB
- Video: 100 MB

## API Prefix
`/api/v1/files/**`

## Used By
Content Service, Career Service, User-Profile Service
