# Career Service — Common Context

## Service Role
Job applications, CV file references, application status, and applicant review for job posters.

## Identity
| Item | Value |
|------|-------|
| Eureka name | `career-service` |
| Port | 8085 |
| Database | `career_db` |
| Package | `com.vithey.career` |

## Entities
- `JobApplication` — id, postId, applicantId, cvFileId, status (PENDING/REVIEWED/ACCEPTED/REJECTED), appliedAt
- `ApplicantCv` — id, userId, cvFileId, fileName, isDefault

## Events Published
`job.application.submitted`, `job.application.status_changed`

## API Prefix
`/api/v1/job-applications/**`, `/api/v1/users/me/cv/**`

## Authorization
- Applicant: submit application, view own applications
- Job poster (COMPANY role or post owner): view applicants for their posts
- Update application status: post owner only
