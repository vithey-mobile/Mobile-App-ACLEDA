# 01 — Auth Service Integration Contract

> **Target Service:** `auth-service`  
> **Direct Port:** `8081` | **Gateway Base URL:** `http://localhost:8080/api/v1/auth` & `http://localhost:8080/api/v1/students`  
> **Database:** `auth_db` | **Naming Convention:** `snake_case` (Jackson globally configured)

---

## 1. Register New Account

- **Method / Path:** `POST /api/v1/auth/register`
- **Auth:** Public (No token required)
- **Headers:** `Content-Type: application/json`

### Request Schema
| Field | Type | Required | Constraints / Description |
| :--- | :--- | :--- | :--- |
| `email` | `string` | Yes | Valid email format |
| `phone` | `string` | Yes | Max 32 chars (e.g. `+85512345678`) |
| `password` | `string` | Yes | 8 to 72 chars |
| `full_name` | `string` | Yes | Max 160 chars |
| `role` | `string` | Yes | Enum: `"USER"`, `"COMPANY"` |

```json
{
  "email": "bora.student@aub.edu.kh",
  "phone": "+85512345678",
  "password": "SecurePassword123!",
  "full_name": "Bora Tech",
  "role": "USER"
}
```

### Response Schema (`201 Created`)
```json
{
  "data": {
    "user": {
      "user_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
      "email": "bora.student@aub.edu.kh",
      "phone": "+85512345678",
      "full_name": "Bora Tech",
      "role": "USER",
      "is_student_verified": false,
      "is_email_verified": false
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refresh_token": "def50200...",
      "expires_in": 900
    }
  }
}
```

---

## 2. Login

- **Method / Path:** `POST /api/v1/auth/login`
- **Auth:** Public
- **Headers:** `Content-Type: application/json`

### Request Schema
| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `email_or_phone` | `string` | Yes | Email address or phone number |
| `password` | `string` | Yes | Account password |

```json
{
  "email_or_phone": "bora.student@aub.edu.kh",
  "password": "SecurePassword123!"
}
```

### Response Schema (`200 OK`)
```json
{
  "data": {
    "user": {
      "user_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
      "email": "bora.student@aub.edu.kh",
      "phone": "+85512345678",
      "full_name": "Bora Tech",
      "role": "USER",
      "is_student_verified": false,
      "is_email_verified": true
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refresh_token": "def50200...",
      "expires_in": 900
    }
  }
}
```

---

## 3. Refresh Access Token

- **Method / Path:** `POST /api/v1/auth/refresh`
- **Auth:** Public
- **Headers:** `Content-Type: application/json`

### Request Schema
| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `refresh_token` | `string` | Yes | Current refresh token |

```json
{
  "refresh_token": "def50200..."
}
```

### Response Schema (`200 OK`)
```json
{
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "def50200_new_token...",
    "expires_in": 900
  }
}
```

---

## 4. Get Current User Identity

- **Method / Path:** `GET /api/v1/auth/me`
- **Auth:** Bearer JWT required
- **Headers:** `Authorization: Bearer <access_token>`

### Response Schema (`200 OK`)
```json
{
  "data": {
    "user_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "email": "bora.student@aub.edu.kh",
    "phone": "+85512345678",
    "full_name": "Bora Tech",
    "role": "STUDENT",
    "is_student_verified": true,
    "is_email_verified": true
  }
}
```

---

## 5. Verify AUB Student

- **Method / Path:** `POST /api/v1/students/verify`
- **Auth:** Bearer JWT required (`USER` role account)
- **Headers:** `Authorization: Bearer <access_token>`, `Content-Type: application/json`

### Request Schema
| Field | Type | Required | Constraints |
| :--- | :--- | :--- | :--- |
| `student_id` | `string` | Yes | AUB Student ID (max 64 chars) |
| `university_email` | `string` | Yes | Must end in `@aub.edu.kh` |

```json
{
  "student_id": "AUB-2024-00123",
  "university_email": "bora.student@aub.edu.kh"
}
```

### Response Schema (`200 OK`)
```json
{
  "data": {
    "user_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "student_id": "AUB-2024-00123",
    "university_email": "bora.student@aub.edu.kh",
    "role": "STUDENT",
    "is_student_verified": true,
    "status": "VERIFIED",
    "verified_at": "2026-09-14T08:30:00Z"
  }
}
```

---

## 6. Password Reset Flow

### 6.1 Start Password Reset
- **Method / Path:** `POST /api/v1/auth/forgot-password`
- **Auth:** Public

```json
{
  "email": "bora.student@aub.edu.kh"
}
```
**Response (`200 OK`):**
```json
{
  "data": {
    "message": "If the email exists, a password reset was started."
  }
}
```

### 6.2 Complete Password Reset
- **Method / Path:** `POST /api/v1/auth/reset-password`
- **Auth:** Public

```json
{
  "token": "reset-token-uuid-or-code",
  "new_password": "NewSecurePassword123!"
}
```
**Response (`200 OK`):**
```json
{
  "data": {
    "message": "Password reset successfully."
  }
}
```

### 6.3 Change Password (Logged In)
- **Method / Path:** `PATCH /api/v1/auth/me/password`
- **Auth:** Bearer JWT required

```json
{
  "current_password": "OldPassword123!",
  "new_password": "NewSecurePassword123!"
}
```
**Response (`200 OK`):**
```json
{
  "data": {
    "message": "Password changed successfully."
  }
}
```

---

## 7. Logout

- **Method / Path:** `POST /api/v1/auth/logout`
- **Auth:** Optional / Public
- **Headers:** `Content-Type: application/json`

```json
{
  "refresh_token": "def50200..."
}
```
**Response:** `204 No Content`

---

## 8. Common Error Responses

```json
{
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid email/phone or password",
    "details": null
  }
}
```

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Validation error",
    "details": [
      {
        "field": "password",
        "message": "size must be between 8 and 72"
      }
    ]
  }
}
```
