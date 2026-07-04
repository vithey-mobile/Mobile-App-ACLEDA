# File Service — API Endpoints

Base path: `/api/v1`

## Endpoints

| Method | Path | Purpose | Auth |
| --- | --- | --- | --- |
| POST | `/files/upload` | Upload avatar, CV, poster, or video | JWT, multipart |
| GET | `/files/{file_id}` | Get metadata and presigned URL | JWT |
| GET | `/files/{file_id}/download` | Download binary file | JWT |
| DELETE | `/files/{file_id}` | Soft delete owned file | JWT |

## Multipart upload

Fields:

| Field | Type | Required |
| --- | --- | --- |
| `file` | binary | yes |
| `type` | enum | yes: `AVATAR`, `CV`, `POSTER`, `VIDEO` |

## Upload response

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

## Frontend consumers

- Account avatar update
- Create poster/video/job media
- CV upload and preview/download

