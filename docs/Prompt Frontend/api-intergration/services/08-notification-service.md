# 08 — Notification Service Integration Contract

> **Target Service:** `notification-service`  
> **Direct Port:** `8088` | **Gateway Base URL:** `http://localhost:8080/api/v1/notifications`  
> **Database:** `notification_db` | **Event Broker:** RabbitMQ consumer | **Naming Convention:** `snake_case`

---

## 1. Notifications Feed

### 1.1 List In-App Notifications
- **Method / Path:** `GET /api/v1/notifications`
- **Auth:** Bearer JWT required

#### Query Parameters
| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `page` | `integer` | No | 1 | Page number |
| `limit` | `integer` | No | 20 | Page size |
| `is_read` | `boolean` | No | - | Filter by read status (`true` or `false`) |

#### Response Schema (`200 OK`)
```json
{
  "data": [
    {
      "id": "89ab0123-cdef-4567-89ab-0123456789cd",
      "notification_id": "89ab0123-cdef-4567-89ab-0123456789cd",
      "type": "SOCIAL",
      "event": "post.reacted",
      "title": "New reaction",
      "body": "Bora Tech liked your capstone project poster.",
      "is_read": false,
      "created_at": "2026-09-14T08:35:00Z",
      "read_at": null,
      "reference_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "reference_type": "POST",
      "actor": {
        "id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
        "full_name": "Bora Tech",
        "avatar_url": "http://localhost:19000/vithey/avatars/bora.png"
      },
      "destination": {
        "screen": "POST_DETAIL",
        "post_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
      },
      "dedupe_key": "post_like:a1b2c3d4:9b1deb4d"
    },
    {
      "id": "456789ab-cdef-0123-4567-89abcdef0123",
      "notification_id": "456789ab-cdef-0123-4567-89abcdef0123",
      "type": "CAREER",
      "event": "application.accepted",
      "title": "Application Accepted!",
      "body": "ACLEDA Bank has accepted your application for Junior Flutter Developer.",
      "is_read": true,
      "created_at": "2026-09-14T08:00:00Z",
      "read_at": "2026-09-14T08:10:00Z",
      "reference_id": "41c6ee38-7208-410e-8f5b-117cfbd9c235",
      "reference_type": "JOB_APPLICATION",
      "actor": {
        "id": "f984000a-38f4-46e5-a047-019d20a66ce0",
        "full_name": "ACLEDA HR Team",
        "avatar_url": "http://localhost:19000/vithey/avatars/acleda.png"
      },
      "destination": {
        "screen": "APPLICATION_DETAIL",
        "application_id": "41c6ee38-7208-410e-8f5b-117cfbd9c235"
      },
      "dedupe_key": null
    }
  ]
}
```

---

### 1.2 Get Unread Notification Count
Used for showing the badge badge counter in the app navigation bar.

- **Method / Path:** `GET /api/v1/notifications/unread-count`
- **Auth:** Bearer JWT required

#### Response Schema (`200 OK`)
```json
{
  "data": {
    "unread_count": 3
  }
}
```

---

### 1.3 Mark Single Notification as Read
- **Method / Path:** `PATCH /api/v1/notifications/{notificationId}/read`
- **Auth:** Bearer JWT required

Returns the updated `NotificationResponse` in `{ "data": { ... } }`.

---

### 1.4 Mark All Notifications as Read
- **Method / Path:** `PATCH /api/v1/notifications/read-all`
- **Auth:** Bearer JWT required

#### Response Schema (`200 OK`)
```json
{
  "data": {
    "updated_count": 3
  }
}
```

---

### 1.5 Delete Notification
- **Method / Path:** `DELETE /api/v1/notifications/{notificationId}`
- **Auth:** Bearer JWT required

**Response:** `204 No Content`

---

## 2. Device Push Token Registration

Connects the Flutter device's FCM / APNs token to the backend for mobile push alerts.

### 2.1 Register Device Token
- **Method / Path:** `POST /api/v1/notifications/devices`
- **Auth:** Bearer JWT required

#### Request Schema
| Field | Type | Required | Values |
| :--- | :--- | :--- | :--- |
| `token` | `string` | Yes | FCM / APNs device token |
| `platform` | `string` | Yes | `"ANDROID"`, `"IOS"`, `"WEB"` |

```json
{
  "token": "fcm_token_sample_string_value_from_firebase_messaging",
  "platform": "ANDROID"
}
```

#### Response Schema (`201 Created`)
```json
{
  "data": {
    "token": "fcm_token_sample_string_value_from_firebase_messaging",
    "platform": "ANDROID",
    "registered_at": "2026-09-14T08:45:00Z"
  }
}
```

---

### 2.2 Unregister Device Token (On Logout)
- **Method / Path:** `DELETE /api/v1/notifications/devices/{token}`
- **Auth:** Bearer JWT required

**Response:** `204 No Content`
