# Finance Screen UI Update

> **Status: applied (v1 UI complete).**  
> Canonical specs: [`v1/03.finance_home-v1.md`](v1/03.finance_home-v1.md) and siblings. Do not re-scaffold v0→v1 folders.

## Objective

Update the **Finance Screen** UI.

Follow the same workflow used for previous UI updates:

- Create a **v0** folder containing the original implementation.
- Create a **v1** folder containing the redesigned implementation.
- Move the related files into the appropriate folders.
- Keep the existing functionality unless explicitly stated otherwise.

---

# Balance Card Redesign

## Remove Existing Content

Remove the current balance card design.

---

## New Balance Card

Update the balance card with the following layout:

- Replace the current content with the new design.
- Add a **wallet icon** on the **right side** of the card.
- Move the **"Due In"** information below the **Balance**.
- Add a **"Pay Now"** button at the bottom of the card.

---

# Total Paycheck Section

Below the balance card:

- Add a new **Total Paycheck** section.
- Follow the provided UI design.

---

# Transaction List

Update the transaction items:

- Remove the filled background behind the transaction icon.
- Remove the filled background behind the transaction status.
- Keep the remaining transaction layout unchanged unless required by the new design.

---

# Notes

- Preserve all existing business logic.
- Reuse existing widgets where possible.
- Avoid duplicate implementations.
- Focus only on UI updates.
- Keep the code clean and maintainable.
