# 07 — Chat Service Integration Contract

> **Target Service:** `chat-service`  
> **Direct Port:** `8087` | **Gateway Base URLs:** `http://localhost:8080/api/v1/conversations`, `http://localhost:8080/api/v1/message-requests`, `http://localhost:8080/api/v1/messages`  
> **WebSocket URL:** `ws://localhost:8080/ws` (STOMP Protocol)  
> **Database:** `chat_db` | **Cache & PubSub:** Redis | **Naming Convention:** `snake_case`

---

## 1. REST Endpoints

### 1.1 List My Conversations
- **Method / Path:** `GET /api/v1/conversations?page=1&limit=20`
- **Auth:** Bearer JWT required

#### Response Schema (`200 OK`)
```json
{
  "data": [
    {
      "conversation_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
      "partner": {
        "user_id": "f984000a-38f4-46e5-a047-019d20a66ce0",
        "full_name": "Jane Doe",
        "avatar_url": "http://localhost:19000/vithey/avatars/jane.png"
      },
      "status": "ACCEPTED",
      "unread_count": 2,
      "last_message": {
        "message_id": "3b2a1c0d-ef98-4321-abcd-0123456789ab",
        "sender_id": "f984000a-38f4-46e5-a047-019d20a66ce0",
        "text": "See you at the campus library!",
        "message_type": "TEXT",
        "created_at": "2026-09-14T08:30:00Z"
      },
      "updated_at": "2026-09-14T08:30:00Z"
    }
  ]
}
```

`status` Enum values:
- `"PENDING"` (Awaiting acceptance from recipient)
- `"ACCEPTED"` (Active conversation)
- `"DECLINED"` (Declined message request)
- `"BLOCKED"` (Blocked by user)

---

### 1.2 Start Message Request
Initiates a new conversation or message request with another student.

- **Method / Path:** `POST /api/v1/conversations/request`
- **Auth:** Bearer JWT required

#### Request Schema
```json
{
  "target_user_id": "f984000a-38f4-46e5-a047-019d20a66ce0",
  "initial_message": "Hi Jane, I saw your post regarding the Flutter study group."
}
```

#### Response Schema (`201 Created`)
Returns `ConversationResponse` in `{ "data": { ... } }`.

---

### 1.3 Accept / Decline / Block Conversation
- `POST /api/v1/conversations/{conversationId}/accept`
- `POST /api/v1/conversations/{conversationId}/decline`
- `POST /api/v1/conversations/{conversationId}/block`
- **Auth:** Bearer JWT required

**Response (`200 OK`):** Returns updated `ConversationResponse`.

---

### 1.4 List Pending Message Requests
- **Method / Path:** `GET /api/v1/message-requests`
- **Auth:** Bearer JWT required

Returns `List<ConversationResponse>` of incoming unaccepted requests.

---

### 1.5 List Conversation Messages
- **Method / Path:** `GET /api/v1/conversations/{conversationId}/messages?page=1&limit=20`
- **Auth:** Bearer JWT required

#### Response Schema (`200 OK`)
```json
{
  "data": [
    {
      "message_id": "3b2a1c0d-ef98-4321-abcd-0123456789ab",
      "conversation_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
      "sender_id": "f984000a-38f4-46e5-a047-019d20a66ce0",
      "text": "See you at the campus library!",
      "message_type": "TEXT",
      "file_id": null,
      "file_url": null,
      "status": "READ",
      "created_at": "2026-09-14T08:30:00Z"
    },
    {
      "message_id": "2a1b0c9d-8e7f-6a5b-4c3d-2e1f0a9b8c7d",
      "conversation_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
      "sender_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
      "text": "Here are the notes from today's lecture",
      "message_type": "FILE",
      "file_id": "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54",
      "file_url": "http://localhost:19000/vithey/chat/notes.pdf",
      "status": "READ",
      "created_at": "2026-09-14T08:25:00Z"
    }
  ]
}
```

`message_type` Enum values:
- `"TEXT"`, `"IMAGE"`, `"FILE"`, `"SYSTEM"`

`status` Enum values:
- `"SENT"`, `"DELIVERED"`, `"READ"`

---

### 1.6 Send Message (REST Fallback)
- **Method / Path:** `POST /api/v1/conversations/{conversationId}/messages`
- **Auth:** Bearer JWT required

#### Request Schema
```json
{
  "text": "Hello, are you free to review code?",
  "message_type": "TEXT",
  "file_id": null
}
```

#### Response Schema (`201 Created`)
Returns created `MessageResponse` in `{ "data": { ... } }`.

---

### 1.7 Mark Messages as Read
- **Single:** `PATCH /api/v1/messages/{messageId}/read`
- **Batch:** `POST /api/v1/conversations/{conversationId}/messages/read` with `{ "message_ids": ["uuid1", "uuid2"] }`

---

### 1.8 Partner Online Presence
- **Method / Path:** `GET /api/v1/conversations/{conversationId}/presence`

#### Response Schema (`200 OK`)
```json
{
  "data": {
    "user_id": "f984000a-38f4-46e5-a047-019d20a66ce0",
    "is_online": true,
    "last_seen": "2026-09-14T08:35:00Z"
  }
}
```

---

### 1.9 Report User
- **Method / Path:** `POST /api/v1/users/{userId}/report`
- **Auth:** Bearer JWT required

```json
{
  "reason": "HARASSMENT",
  "description": "Inappropriate messages in direct chat"
}
```

**Response (`201 Created`):**
```json
{
  "data": {
    "report_id": "d0e1f2a3-b4c5-6789-0123-456789abcdef",
    "status": "SUBMITTED",
    "created_at": "2026-09-14T08:40:00Z"
  }
}
```

---

## 2. WebSocket Real-Time Integration (STOMP)

- **Handshake Endpoint:** `ws://localhost:8080/ws` (or `ws://localhost:8080/ws/chat`)
- **Connection Header:** `Authorization: Bearer <access_token>`

### 2.1 Subscriptions (Incoming to Flutter)

| Destination | Payload Type | Description |
| :--- | :--- | :--- |
| `/user/queue/messages` | `StompMessagePayload` | Real-time messages, typing indicators, and read receipts |
| `/user/queue/presence` | `StompPresencePayload` | Online/offline presence notifications |

#### Incoming Message Frame Example (`/user/queue/messages`)
```json
{
  "type": "MESSAGE",
  "conversation_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "message_id": "3b2a1c0d-ef98-4321-abcd-0123456789ab",
  "sender_id": "f984000a-38f4-46e5-a047-019d20a66ce0",
  "text": "Let's meet at 3 PM.",
  "message_type": "TEXT",
  "file_id": null,
  "status": "DELIVERED",
  "created_at": "2026-09-14T08:35:00Z"
}
```

#### Incoming Typing Frame Example
```json
{
  "type": "TYPING",
  "conversation_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "user_id": "f984000a-38f4-46e5-a047-019d20a66ce0",
  "is_typing": true
}
```

---

### 2.2 Publications (Outgoing from Flutter)

| Destination | Payload | Purpose |
| :--- | :--- | :--- |
| `/app/chat.send` | `ChatSendPayload` | Send message instantly via WebSocket |
| `/app/chat.typing` | `TypingRequest` | Broadcast typing status to partner |
| `/app/chat.read` | `ChatReadPayload` | Emit read receipt for message |
| `/app/chat.heartbeat`| `{}` | Keep presence alive (every 30s) |

#### Sending Message (`/app/chat.send`)
```json
{
  "conversation_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "text": "Hello, got it!",
  "message_type": "TEXT",
  "file_id": null
}
```

#### Emitting Typing (`/app/chat.typing`)
```json
{
  "conversation_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "is_typing": true
}
```
