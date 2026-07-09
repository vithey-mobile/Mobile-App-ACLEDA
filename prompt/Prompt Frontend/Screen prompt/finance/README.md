# Finance Prompt Index

Use this folder as the single source of truth for student verification and Finance.

## Reading order

1. [`01.verify_from.md`](01.verify_from.md) — submit student verification.
2. [`02.pending_verify.md`](02.pending_verify.md) — not submitted, pending, verified, rejected, and provisioning states.
3. [`03.finance_home.md`](03.finance_home.md) — verified-student dashboard and payments.
4. [`04.detail_invoice.md`](04.detail_invoice.md) — secure payment breakdown and PDF invoice.

## Ownership boundaries

| Prompt | Owns |
|---|---|
| Verification Form | Student ID/email/document submission and credential safety |
| Verification Status | Lifecycle, polling, role refresh, Finance provisioning |
| Finance Home | Access gate, summary, payment list, pagination |
| Invoice Detail | Breakdown, totals, private PDF download |

Avoid duplicating invoice logic in Finance Home or form/status logic in Finance screens. All flows use authoritative server status and stable IDs.

## Acceptance checklist (release gate)

- [ ] Verification form matches `verify student finance.png`
- [ ] Status screen covers pending, verified, rejected per `pending verify.png` / `verify success.png` / `verify unsuccess.png`
- [ ] Finance home matches `finance home.png` — summary, receipts, See All
- [ ] Invoice preview matches `preview invoice.png` — breakdown, PDF download
- [ ] Unverified users gated to verification (no broken Finance screen)
- [ ] Dark mode readable on status cards and invoice sheet
- [ ] `USE_MOCK_API=false` works against gateway when backend ready
- [ ] `flutter analyze` zero errors on touched files
