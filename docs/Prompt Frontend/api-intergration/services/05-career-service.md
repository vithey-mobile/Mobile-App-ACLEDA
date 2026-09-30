# 05 — Career Service Integration Contract

> **Target Service:** `career-service`  
> **Direct Port:** `8085` | **Gateway Base URLs:** `http://localhost:8080/api/v1/job-applications`, `http://localhost:8080/api/v1/users/me/cv`  
> **Database:** `career_db` | **Naming Convention:** `snake_case` (Jackson globally configured)

---

## 1. User CV / Resume Management

Students can upload a default CV in the app once and attach it across job applications.

### 1.1 Get My Saved CV
- **Method / Path:** `GET /api/v1/users/me/cv`
- **Auth:** Bearer JWT required

#### Response Schema (`200 OK`)
```json
{
  "data": {
    "user_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "cv_file_id": "e5c707fa-3b91-4e4b-97e3-0d32d3f23a19",
    "file_name": "bora_tech_cv_2026.pdf",
    "updated_at": "2026-09-14T08:00:00Z"
  }
}
```

---

### 1.2 Set or Update My CV
- **Method / Path:** `PUT /api/v1/users/me/cv`
- **Auth:** Bearer JWT required
- **Prerequisite:** Upload PDF to `file-service` (`POST /api/v1/files/upload?type=CV`) to obtain `file_id`.

#### Request Schema
```json
{
  "cv_file_id": "e5c707fa-3b91-4e4b-97e3-0d32d3f23a19"
}
```

#### Response Schema (`200 OK`)
Returns updated `UserCvResponse` in `{ "data": { ... } }`.

---

## 2. Job Applications

### 2.1 Apply for a Job Post
- **Method / Path:** `POST /api/v1/job-applications`
- **Auth:** Bearer JWT required
- **Headers:** `Authorization: Bearer <access_token>`, `Content-Type: application/json`, `Idempotency-Key: <client-uuid>` (optional but recommended)

#### Request Schema
| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `job_post_id` | `string` | Yes | UUID of the post (from `content-service` where `type == "JOB"`) |
| `cv_file_id` | `string` | Yes | UUID of the CV file from `file-service` |
| `cover_note` | `string` | No | Cover letter / note from applicant |

```json
{
  "job_post_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "cv_file_id": "e5c707fa-3b91-4e4b-97e3-0d32d3f23a19",
  "cover_note": "I am passionate about Flutter mobile banking systems and eager to contribute."
}
```

#### Response Schema (`201 Created`)
```json
{
  "data": {
    "application_id": "41c6ee38-7208-410e-8f5b-117cfbd9c235",
    "job_post_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "job_title": "Junior Flutter Developer",
    "organization": "ACLEDA Bank Plc.",
    "applicant": {
      "user_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
      "full_name": "Bora Tech",
      "avatar_url": "http://localhost:19000/vithey/avatars/bora.png"
    },
    "cv_file_id": "e5c707fa-3b91-4e4b-97e3-0d32d3f23a19",
    "cv_file_name": "bora_tech_cv_2026.pdf",
    "status": "SUBMITTED",
    "cover_note": "I am passionate about Flutter mobile banking systems...",
    "applied_at": "2026-09-14T08:15:00Z",
    "review_started_at": null,
    "decided_at": null,
    "reviewer_note": null
  }
}
```

---

### 2.2 List Applications
- **Method / Path:** `GET /api/v1/job-applications`
- **Auth:** Bearer JWT required

#### Query Parameters
| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `job_post_id` | `string` | No | If provided by the employer/author, lists applicants for that job. If omitted by a student, lists their own submitted applications. |
| `page` | `integer`| No (default: 1) | Page index |
| `limit` | `integer`| No (default: 20)| Limit per page |

#### Response Schema (`200 OK`)
```json
{
  "data": [
    {
      "application_id": "41c6ee38-7208-410e-8f5b-117cfbd9c235",
      "job_post_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "job_title": "Junior Flutter Developer",
      "organization": "ACLEDA Bank Plc.",
      "applicant": {
        "user_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
        "full_name": "Bora Tech",
        "avatar_url": "http://localhost:19000/vithey/avatars/bora.png"
      },
      "cv_file_id": "e5c707fa-3b91-4e4b-97e3-0d32d3f23a19",
      "cv_file_name": "bora_tech_cv_2026.pdf",
      "status": "UNDER_REVIEW",
      "cover_note": "I am passionate about Flutter mobile banking...",
      "applied_at": "2026-09-14T08:15:00Z",
      "review_started_at": "2026-09-14T09:00:00Z",
      "decided_at": null,
      "reviewer_note": null
    }
  ]
}
```

---

### 2.3 Get Application Detail
- **Method / Path:** `GET /api/v1/job-applications/{applicationId}`
- **Auth:** Bearer JWT required (Applicant or Job Poster)

Returns single `JobApplicationResponse` in `{ "data": { ... } }`.

---

### 2.4 Preview Application CV
Allows the employer or applicant to obtain an authorized preview URL for the submitted CV.

- **Method / Path:** `GET /api/v1/job-applications/{applicationId}/cv-preview`
- **Auth:** Bearer JWT required

#### Response Schema (`200 OK`)
```json
{
  "data": {
    "application_id": "41c6ee38-7208-410e-8f5b-117cfbd9c235",
    "cv_file_id": "e5c707fa-3b91-4e4b-97e3-0d32d3f23a19",
    "file_name": "bora_tech_cv_2026.pdf",
    "preview_url": "http://localhost:19000/vithey/cvs/preview.pdf?X-Amz-Expires=3600...",
    "expires_at": "2026-09-14T09:15:00Z"
  }
}
```

---

### 2.5 Update Application Status (Employer Flow)
- **Method / Path:** `PATCH /api/v1/job-applications/{applicationId}/status`
- **Auth:** Bearer JWT required (Job poster / company only)

#### Request Schema
| Field | Type | Required | Values |
| :--- | :--- | :--- | :--- |
| `status` | `string` | Yes | `"SUBMITTED"`, `"UNDER_REVIEW"`, `"ACCEPTED"`, `"REJECTED"` |
| `reviewer_note` | `string` | No | Feedback / response message to student |

```json
{
  "status": "ACCEPTED",
  "reviewer_note": "Congratulations! We invite you for a technical interview on Friday at 2:00 PM."
}
```

#### Response Schema (`200 OK`)
Returns updated `JobApplicationResponse` in `{ "data": { ... } }`.
