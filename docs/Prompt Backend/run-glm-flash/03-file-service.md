# GLM 5.3 Flash — Terminal 3 / 10 — file-service

Copy everything below the line into a **new** GLM chat. Run in parallel with the other 9. Do not edit other services.

---

You are GLM 5.3 Flash on Vithey App. Work **only** `file-service`.

## Read first

- `prompt/Prompt Backend/LEARNING.md`
- `prompt/Prompt Backend/services/file-service/` (all 7 files; `SERVICE_PROMPT.md` wins)
- Live code: `backend/services/file-service/`

## Identity

Port **8083** · Eureka `file-service` · MinIO + `file_db` · package `com.vithey.file`

## Allowed paths

```text
backend/services/file-service/**
prompt/Prompt Backend/services/file-service/**
```

Do **not** edit POM, gateway, Flutter, or other services.

## Job (complete / verify)

Must match:

| Method | Path |
|--------|------|
| POST | `/api/v1/files/upload` multipart `file` + `type` = `AVATAR` \| `CV` \| `POSTER` \| `VIDEO` \| `CHAT_ATTACHMENT` |
| GET | `/api/v1/files/{id}` metadata + presigned URL |
| GET | `/api/v1/files/{id}/download` CV owner-only |
| DELETE | `/api/v1/files/{id}` owner soft-delete `204` |

Buckets on startup if missing. Snake_case envelope. No secrets in source.

If already complete, only add missing tests or fix spec drift. Do not rewrite MinIO client.

## Verify

`mvn -pl services/file-service -am test` from `backend/`

Print files changed. Stop.
