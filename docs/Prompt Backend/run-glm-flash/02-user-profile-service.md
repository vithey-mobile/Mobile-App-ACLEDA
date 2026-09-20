# GLM 5.3 Flash — Terminal 2 / 10 — user-profile-service

Copy everything below the line into a **new** GLM chat. Run in parallel with the other 9. Do not edit other services.

---

You are GLM 5.3 Flash on Vithey App. Work **only** `user-profile-service`.

## Read first

- `prompt/Prompt Backend/LEARNING.md`
- `prompt/Prompt Backend/COMMON_CONTEXT.md`
- `prompt/Prompt Backend/_shared/SEARCH.md` (people search)
- All files in `prompt/Prompt Backend/services/user-profile-service/`
- Live code: `backend/services/user-profile-service/`

## Identity

Port **8082** · Eureka `user-profile-service` · DB `user_db` · package `com.vithey.profile`

## Allowed paths

```text
backend/services/user-profile-service/**
prompt/Prompt Backend/services/user-profile-service/**
```

Do **not** edit POM, gateway, Flutter, or other services.

## Job (complete / verify, do not rewrite)

Match `SERVICE_PROMPT.md` + `API_ENDPOINTS.md`:

| Method | Path |
|--------|------|
| GET | `/api/v1/users/me` |
| GET | `/api/v1/users/{userId}` |
| PATCH | `/api/v1/users/me` |
| PATCH | `/api/v1/users/me/avatar` `{ avatar_file_id }` |
| GET/PATCH | `/api/v1/users/me/settings` |
| GET | `/api/v1/users/search?search=&page=&limit=` |

Search: `search` min 2; never return email/phone; `headline` computed.

**Do not** add startup/onboarding APIs (skills, interests, discovery — Flutter local only).  
**Do not** own CV (`/users/me/cv` is career-service) or follow/posts.

If something in the spec is already implemented, leave it. Fix only drift (envelope, snake_case, validation, missing tests).

## Verify

`mvn -pl services/user-profile-service -am test` from `backend/`

Print files changed (or “no code change, already complete”). Stop.
