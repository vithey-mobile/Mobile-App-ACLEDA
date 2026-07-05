# File Service Architecture

## Responsibility

Owns MinIO object storage and file metadata in `file_db`.

Does not own posts, profile avatar assignment, CV application records, or business permissions outside file ownership.

## Dependencies

- PostgreSQL `file_db`
- MinIO from shared infrastructure
- Eureka for service discovery
- Config Server for shared configuration

## Access rules

- Upload: authenticated user becomes `owner_user_id`
- Metadata: any authenticated user can read active files
- Download: owner always allowed; CV downloads are owner-only
- Delete: owner only

## Object layout

```text
<bucket>/<owner_user_id>/<file_id>/<safe_file_name>
```
