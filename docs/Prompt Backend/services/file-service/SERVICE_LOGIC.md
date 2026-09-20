# File Service — Service Logic

## Ownership

Owns physical files in MinIO and file metadata. It does not own posts, profile avatar assignment, CV records, or permissions beyond file ownership/public metadata.

## Core flows

| Flow | Logic |
| --- | --- |
| Upload | Validate MIME and size, choose bucket by `type`, generate object key `{owner}/{fileId}/{safeName}`, MinIO put (outside DB TX), save metadata. |
| Metadata | Any authenticated user; return metadata plus 1h URL signed with `MINIO_PUBLIC_ENDPOINT`. |
| Download | Stream binary (`Content-Disposition: attachment`). CV is owner-only; AVATAR/POSTER/VIDEO allowed for any authenticated user. |
| Delete | Owner only: soft-delete metadata first, then MinIO remove (outside DB TX). |

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

## MinIO endpoints

| Config | Purpose |
| --- | --- |
| `vithey.minio.endpoint` / `MINIO_ENDPOINT` | Internal storage client (Docker: `http://minio:9000`) |
| `vithey.minio.public-endpoint` / `MINIO_PUBLIC_ENDPOINT` | Presigned URL host clients can open (local: `http://localhost:19000`) |

Upload/download/delete use the internal client. Presigned URLs are signed with the public endpoint so browser/mobile clients can fetch objects.

## Delete order

Soft-delete metadata first (owner check), then remove the MinIO object. If object removal fails after soft-delete, the file stays unavailable via API (preferred over active metadata pointing at a missing object).

## Performance notes (local Docker)

Measured after moving MinIO I/O outside DB transactions and adding Hikari timeouts:

| Endpoint | Scenario | Approx. time |
| --- | --- | --- |
| `GET /api/v1/files/{id}` | metadata + presign, warm | ~15–21 ms avg (x20) |
| `POST /api/v1/files/upload` | small PNG AVATAR | ~25–30 ms warm; first call higher |
| Validation / auth failures | missing part, bad token | ~12–25 ms |

Do not hold a DB connection across `putObject` / `getPresignedObjectUrl` / `removeObject`.

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Missing file / type / invalid UUID or enum | `VALIDATION_ERROR` | 400 |
| Invalid MIME | `INVALID_FILE_TYPE` | 400 |
| File too large | `FILE_TOO_LARGE` | 400 |
| File not found | `NOT_FOUND` | 404 |
| Non-owner delete / non-owner CV download | `FORBIDDEN` | 403 |
| Missing/invalid JWT | `UNAUTHORIZED` | 401 |

