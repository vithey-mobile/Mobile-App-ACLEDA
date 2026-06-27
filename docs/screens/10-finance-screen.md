# Finance Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `10` |
| Route | `Routes.FINANCE` |
| Flutter module | `lib/modules/finance/` |
| Backend service(s) | `finance-service` |
| Auth required | Yes (**STUDENT** role) |
| Competition feature | **Finance** |

## Purpose

Show university **payment history**, status, and **deadline alerts** for verified AUB students.

## Open from

- Main nav (after verification), Student Verification success

## Main UI

| Element | Description |
|---------|-------------|
| Alert card | Upcoming payments (7 days) |
| Payment list | Fee name, amount, due date, status badge |
| Verification gate | Shown if not verified — CTA to verify |
| Pull to refresh | Reload data |

## Payment status

| Status | Meaning |
|--------|---------|
| PAID | Completed |
| UNPAID | Not yet paid |
| PENDING | Processing |
| OVERDUE | Past due date |

## User actions

| Action | Result |
|--------|--------|
| Verify CTA | Student Verification screen |
| Refresh | Reload payments |

## Logic & behavior

- Block access unless `isStudentVerified` / `STUDENT` role
- Format currency with `intl` (KHR)
- Highlight overdue in red

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v1/payments` | History |
| GET | `/api/v1/payments/alerts` | Due soon |

## Status checklist

- [ ] UX/UI designed
- [ ] Verification gate works
- [ ] Payment list + alerts
