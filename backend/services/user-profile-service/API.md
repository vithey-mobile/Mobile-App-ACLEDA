# User Profile Service API

Base path: `/api/v1`

All endpoints require JWT authentication.

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/users/me` | Current user profile and settings summary |
| GET | `/users/{user_id}` | Public profile |
| PATCH | `/users/me` | Update current profile |
| PATCH | `/users/me/avatar` | Set avatar file id |
| GET | `/users/me/settings` | Current user settings |
| PATCH | `/users/me/settings` | Update settings |
| GET | `/users/search` | Search users by name |

## Events consumed

| Event | Action |
| --- | --- |
| `user.registered` | Create profile and default settings |
