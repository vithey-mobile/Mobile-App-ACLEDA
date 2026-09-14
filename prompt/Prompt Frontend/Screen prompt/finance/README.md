# Finance Prompt Index

Prompts live **directly in this folder** (no `v0` / `v1`).

## Folder layout

| Path | Contents |
| --- | --- |
| `01`–`04` | Screen prompts |
| `update.md` | As-built ayheng finance / verification / transaction |
| `README.md` | This index |

## Reading order

1. [`01.verify_from.md`](01.verify_from.md) — Student Verification Form  
2. [`02.pending_verify.md`](02.pending_verify.md) — Verification Status  
3. [`03.finance_home.md`](03.finance_home.md) — Finance Home (**20px** pad; list amount = **total with fees**)  
4. [`04.detail_invoice.md`](04.detail_invoice.md) — Invoice / Transaction detail  

## Ownership

| Prompt | Owns |
|---|---|
| Verification Form | Student ID upload, submit |
| Verification Status | Lifecycle, polling, role refresh |
| Finance Home | Gate, balance, paycheck, transactions |
| Invoice Detail | Breakdown, totals, PDF, report |

## Acceptance

- [x] Verification form / status / finance home / invoice as built
- [x] Transaction list shows **total** (base + processing + late)
- [x] Finance **20px** horizontal padding
- [x] Unverified users gated to verification
