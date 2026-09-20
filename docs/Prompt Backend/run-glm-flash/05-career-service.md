# GLM 5.3 Flash — Terminal 5 / 10 — career-service

Copy everything below the line into a **new** GLM chat. Run in parallel with the other 9. Do not edit other services.

---

You are GLM 5.3 Flash on Vithey App. Work **only** `career-service`.

## Read first

- `prompt/Prompt Backend/LEARNING.md`
- `prompt/Prompt Backend/services/career-service/`
- `vithey_app/lib/data/repositories/cv_repository.dart` (`getApplicantCvDownloadUrl`)
- Live code: `backend/services/career-service/`

## Identity

Port **8085** · Eureka `career-service` · DB `career_db` · package `com.vithey.career`

## Allowed paths

```text
backend/services/career-service/**
prompt/Prompt Backend/services/career-service/**
```

Do **not** edit POM, gateway, Flutter, or other services.

## Job (upgrade)

Add Flutter gap:

`GET /api/v1/job-applications/{applicationId}/cv-preview`

Who: **applicant** or **job poster** (same ownership check as list-by-job).  
`200`:

```json
{
  "data": {
    "application_id": "uuid",
    "cv_file_id": "uuid",
    "cv_file_name": "resume.pdf",
    "download_url": "https://..."
  }
}
```

Resolve `download_url` via existing `FileServiceClient`. Flutter also accepts `url`.  
`404` missing application · `403` stranger.

Keep apply / list / status / `GET|PUT /users/me/cv`.

**Do not** add `/api/v1/jobs/**`. Job listings are content-service `GET /posts?type=JOB`.

Update career `API_ENDPOINTS.md` / `SERVICE_PROMPT.md` / `SERVICE_LOGIC.md`.

## Verify

- Test: applicant OK; stranger 403
- `mvn -pl services/career-service -am test` from `backend/`

Print files changed. Stop.
