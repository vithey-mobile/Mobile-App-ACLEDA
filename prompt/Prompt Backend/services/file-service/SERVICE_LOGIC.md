# File Service — Service Logic

## Ownership

Owns physical files in MinIO and file metadata. It does not own posts, profile avatar assignment, CV records, or permissions beyond file ownership/public metadata.

## Core flows

| Flow | Logic |
| --- | --- |
| Upload | Validate MIME and size, choose bucket by `type`, generate object key, upload to MinIO, save metadata. |
| Metadata | Return metadata plus presigned URL if caller can access the file. |
| Download | Stream binary or redirect/presign URL; private CV files require owner or authorized service flow. |
| Delete | Owner only, soft delete metadata, remove MinIO object when safe. |

## MIME and size rules

| Type | Allowed MIME | Max size |
| --- | --- | --- |
| `AVATAR` | image/jpeg, image/png, image/webp | 10 MB |
| `CV` | application/pdf, application/msword, docx | 10 MB |
| `POSTER` | image/jpeg, image/png, image/webp | 10 MB |
| `VIDEO` | video/mp4, video/quicktime | 50 MB |

## Buckets

- `avatars`
- `cvs`
- `posters`
- `videos`

Create buckets on startup if missing in local/dev.

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Missing file | `VALIDATION_ERROR` | 400 |
| Invalid MIME | `INVALID_FILE_TYPE` | 400 |
| File too large | `FILE_TOO_LARGE` | 400 |
| File not found | `NOT_FOUND` | 404 |
| Non-owner delete | `FORBIDDEN` | 403 |

