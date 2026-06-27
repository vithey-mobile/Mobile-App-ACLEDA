# Preview CV Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `08` |
| Route | `Routes.PREVIEW_CV` |
| Flutter module | `lib/modules/preview_cv/` |
| Backend service(s) | `career-service`, `file-service` |
| Auth required | Yes |

## Purpose

Preview and download the user's **CV document**.

## Open from

- Profile → View CV icon

## Main UI

| Element | Description |
|---------|-------------|
| CV preview area | PDF viewer or doc placeholder |
| File name | In app bar or header |
| Download button | Save / open with device app |
| Empty state | "No CV uploaded yet" |

## File types

PDF, DOC, DOCX

## User actions

| Action | Result |
|--------|--------|
| Download | `open_filex` or save to device |
| Back | Return to Profile |

## Logic & behavior

- Load CV metadata for current user (or `userId` arg)
- PDF: `flutter_pdfview` / syncfusion viewer
- DOC/DOCX: show info + open externally
- Empty: link to upload CV if own profile

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v1/users/me/cv` | CV metadata + URL |
| GET | `/api/v1/files/{id}/download` | File stream |

## Status checklist

- [ ] UX/UI designed
- [ ] PDF preview works
- [ ] Empty state handled
