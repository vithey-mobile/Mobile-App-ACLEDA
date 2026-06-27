# Student Verification Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `11` |
| Route | `Routes.STUDENT_VERIFICATION` |
| Flutter module | `lib/modules/student_verification/` |
| Backend service(s) | `auth-service` |
| Auth required | Yes |

## Purpose

Verify user is a **real AUB student** to unlock Finance feature.

## Open from

- Finance gate, Profile, Settings

## Main UI

| Element | Description |
|---------|-------------|
| Illustration | University / ID card |
| Student ID field | Text input |
| University email/phone | Text input |
| Submit button | With loading state |
| Info text | Why verification is needed |

## User actions

| Action | Result |
|--------|--------|
| Submit | API verify → success or error |

## Logic & behavior

- Validate student ID and email format
- Success: set `isStudentVerified`, role → STUDENT
- Navigate to Finance or back with result
- Failure: show error message

## Navigation

| From | Action | To |
|------|--------|-----|
| Verification | Success | Finance |

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/v1/students/verify` | `student_id`, `university_email` |

## Status checklist

- [ ] UX/UI designed
- [ ] API integrated
- [ ] Finance unlock tested
