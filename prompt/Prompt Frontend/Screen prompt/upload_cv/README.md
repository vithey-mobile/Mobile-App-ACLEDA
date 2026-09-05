# Upload CV Prompt Index

This folder is the single source of truth for applying to a job with a CV.

- [`01.upload_cv.md`](01.upload_cv.md) — job context and description, applicant cover note, saved/update/application-only CV selection, private document upload, submission, and Home Applied-state synchronization.

## Core modes

1. Use the saved default CV.
2. Update the saved CV, with explicit consent.
3. Upload a document for this application only.

The flow always uses a canonical `jobPostId`, keeps CV documents private, and never silently discards the applicant's written description.
