# File Service API

Base path: `/api/v1`

All endpoints require JWT authentication.

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/files/upload` | Upload avatar, CV, poster, or video |
| GET | `/files/{file_id}` | Metadata and presigned URL |
| GET | `/files/{file_id}/download` | Download binary file |
| DELETE | `/files/{file_id}` | Soft delete owned file |

## Upload fields

| Field | Type | Required |
| --- | --- | --- |
| `file` | multipart file | yes |
| `type` | `AVATAR`, `CV`, `POSTER`, `VIDEO` | yes |

## Buckets

- `avatars`
- `cvs`
- `posters`
- `videos`
