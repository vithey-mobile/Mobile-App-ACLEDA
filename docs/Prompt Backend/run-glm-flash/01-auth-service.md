# GLM 5.3 Flash — Terminal 1 / 10 — auth-service

Copy everything below the line into a **new** GLM chat. Run in parallel with the other 9. Do not edit other services.

---

You are GLM 5.3 Flash on Vithey App. Work **only** `auth-service`.

## Read first

- `prompt/Prompt Backend/LEARNING.md`
- `prompt/Prompt Backend/COMMON_CONTEXT.md`
- `prompt/Prompt Backend/SERVICE_BLUEPRINT.md`
- `prompt/Prompt Frontend/api-intergration/integration-contract.md`
- All files in `prompt/Prompt Backend/services/auth-service/` (`SERVICE_PROMPT.md` is authoritative)
- Live code: `backend/services/auth-service/`

## Identity

Port **8081** · Eureka `auth-service` · DB `auth_db` · package `com.vithey.auth`

## Allowed paths

```text
backend/services/auth-service/**
prompt/Prompt Backend/services/auth-service/**
```

Do **not** edit `backend/pom.xml`, gateway YAML, Flutter, or any other service.

## Job (upgrade, do not rewrite)

Java already exists. Add the Flutter gap:

`PATCH /api/v1/auth/me/password`

Body: `{ "current_password", "new_password" }`  
JWT / `X-User-Id` required.  
`200` `{ "data": { "message": "..." } }`  
Wrong current → `401 INVALID_CREDENTIALS`  
Weak new password → `400 VALIDATION_ERROR`

Logic: BCrypt-verify current → hash new → save. Match existing password rules from register/reset.

Keep existing register, login, refresh, forgot/reset, verify-email, logout, `GET /auth/me`, `POST /students/verify`.

**Do not** implement Google OAuth (Flutter: coming soon).

## Verify

- Unit test: wrong current password; happy path
- `mvn -pl services/auth-service -am test` from `backend/`
- Update auth `API_ENDPOINTS.md` / `SERVICE_PROMPT.md` / `SERVICE_LOGIC.md` if they still omit change-password

Print files changed. Stop.
