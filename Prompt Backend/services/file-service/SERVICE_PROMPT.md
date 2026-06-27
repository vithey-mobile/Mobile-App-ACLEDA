# File Service — Service Prompt

Build the File microservice with MinIO integration.

## API Endpoints
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/files/upload` | JWT | Multipart upload |
| GET | `/api/v1/files/{fileId}` | JWT | Get metadata + download URL |
| GET | `/api/v1/files/{fileId}/download` | JWT | Stream/download file |
| DELETE | `/api/v1/files/{fileId}` | JWT | Delete (owner only) |

## Upload Request
`multipart/form-data`:
- `file` — binary
- `type` — enum: `AVATAR`, `CV`, `POSTER`, `VIDEO`

## Upload Response
```json
{
  "data": {
    "file_id": "uuid",
    "file_name": "resume.pdf",
    "file_type": "CV",
    "mime_type": "application/pdf",
    "size_bytes": 102400,
    "url": "http://minio:9000/cvs/uuid/resume.pdf",
    "created_at": "2026-01-01T00:00:00Z"
  }
}
```

## Implementation
- MinIO Java SDK (`io.minio:minio`)
- Optional `FileMetadata` entity in PostgreSQL or in-memory for MVP
- Validate MIME type and extension whitelist
- Generate UUID object key: `{bucket}/{userId}/{uuid}/{filename}`
- Pre-signed URLs for download (expiry 1 hour)

## Security
- Verify `X-User-Id` matches uploader on delete
- Virus scan hook (optional placeholder interface)

## Required Modules
- `FileController`, `FileStorageService`, `MinioConfig`
- `GlobalExceptionHandler`, OpenAPI, tests with Testcontainers MinIO

## Output
Runnable file-service on port 8083.
