# Finance Prompt Index

**UI status: v1 complete** in `vithey_app` (`lib/modules/finance/`, `lib/modules/student_verification/`).

Use this folder as the single source of truth for student verification and Finance.

## Folder layout

| Path | Contents |
| --- | --- |
| `v0/` | Archive — original finance prompts |
| `v1/` | **Current implemented UI** (`*-v1.md`) |
| Root | `update.md` (applied redesign brief), this README |

Do **not** treat `update.md` as a new build task — balance-card / paycheck / transaction UI is already in `v1` + app code.

## Reading order

1. Student Verification Form:
   - Current UI: [`v1/01.verify_from-v1.md`](v1/01.verify_from-v1.md) — `Verification Screen 1.png` / `2.png`
   - Archive: [`v0/01.verify_from.md`](v0/01.verify_from.md)
2. Verification Status:
   - Current UI: [`v1/02.pending_verify-v1.md`](v1/02.pending_verify-v1.md) — `Verification Status Screen.png`
   - Archive: [`v0/02.pending_verify.md`](v0/02.pending_verify.md)
3. Finance Home:
   - Current UI: [`v1/03.finance_home-v1.md`](v1/03.finance_home-v1.md)
   - Archive: [`v0/03.finance_home.md`](v0/03.finance_home.md)
4. Invoice Detail:
   - Current UI: [`v1/04.detail_invoice-v1.md`](v1/04.detail_invoice-v1.md) — `Transaction.png`
   - Archive: [`v0/04.detail_invoice.md`](v0/04.detail_invoice.md)

## Ownership boundaries

| Prompt | Owns |
|---|---|
| Verification Form | Student ID/email/password UI, document upload states, submit CTA |
| Verification Status | Lifecycle, polling, role refresh, Finance provisioning |
| Finance Home | Access gate, balance card, paycheck strip, transaction list |
| Invoice Detail | Breakdown, totals, private PDF download, report CTA |

Avoid duplicating invoice logic in Finance Home or form/status logic in Finance screens. All flows use authoritative server status and stable IDs.

## Acceptance checklist (v1 release)

- [x] Verification form matches **v1** images
- [x] Status screen pending matches **v1**
- [x] Finance home matches **v1** (balance card, paycheck, transactions)
- [x] Invoice preview matches **v1**
- [x] Unverified users gated to verification
- [x] Dark mode readable on verification, status, finance, invoice
- [ ] `USE_MOCK_API=false` works against gateway when backend ready
- [x] Routes: `studentVerification`, `verificationStatus`, `finance`
