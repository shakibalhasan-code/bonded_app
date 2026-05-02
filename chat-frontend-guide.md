# Bonded Chat — Frontend Integration Guide

> **Audience**: Flutter developer implementing real-time chat.
> **Rule**: Text messages → socket only. Media (image/audio/video) → REST upload, then backend emits socket automatically.

---

## 1. Connection

**Socket URL**: `http://SERVER:5002`

The backend tries three token sources in this order. Use whichever option your socket client supports:

**Option 1 — auth object (recommended)**
```json
{
  "auth": { "token": "ACCESS_TOKEN" }
}
```

**Option 2 — Authorization header**
```json
{
  "extraHeaders": { "Authorization": "Bearer ACCESS_TOKEN" }
}
```
The `Bearer ` prefix is stripped automatically if present.

**Option 3 — query string**
Connect to `https://nwqs97k3-5002.asse.devtunnels.ms?token=ACCESS_TOKEN`

All three options accept a raw token or a `Bearer <token>` string.

On successful connect, the server automatically joins the socket to a personal room `user:<userId>` (you don't need to do anything). The server immediately pushes two events to the connected user:
- `chat:unread-summary` — total unread message/conversation counts
- `notification:unread-count` — app notification count

---

## 2. REST Endpoints

**Base URL**: `https://nwqs97k3-5002.asse.devtunnels.ms/api/v1`  
**All REST requests require**: `Authorization: Bearer ACCESS_TOKEN`

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/auth/login` | Login, get `accessToken` |
| POST | `/chat/direct/:userId` | Create or get direct conversation with a user |
| POST | `/chat/support` | Create or get support conversation |
| GET | `/chat/conversations` | List all conversations (paginated, default 20, max 100) |
| GET | `/chat/conversations/:id/messages` | Load message history (paginated, default 20, max 100) |
| **POST** | **`/chat/conversations/:id/messages`** | **Send media message (multipart/form-data)** |
| PATCH | `/chat/conversations/:id/read` | Mark conversation as read |
| GET | `/chat/unread-summary` | Get unread counts |

> **Bond requirement**: Direct conversations (`POST /chat/direct/:userId`) and messages in direct conversations can only be created/sent between users who have an **accepted bond** relationship. Attempting to message a non-bonded user returns `403 Forbidden`.

---

## 3. Events Overview

### Client → Server (emit)

| Event | When |
|-------|------|
| `conversation:join` | User opens a chat thread screen |
| `conversation:leave` | User closes / navigates away from a chat thread |
| `message:send` | Send a **text** message |
| `conversation:read` | User has read the conversation |
| `conversation:typing:start` | User started typing |
| `conversation:typing:stop` | User stopped typing |

### Server → Client (listen)

| Event | Scope | When |
|-------|-------|------|
| `conversation:message:new` | Conversation room (joined) | New message while thread is open |
| `receive-message` | User personal channel | New message while NOT in that thread |
| `conversation:typing` | Conversation room (joined) | Other user typing |
| `chat:unread-summary` | User channel | Unread counts updated |
| `notification:unread-count` | User channel | App notification count changed |
| `presence:update` | Global | User online/offline status changed |

> **Delivery guarantee**: the backend sends either `conversation:message:new` OR `receive-message` for the same message — never both. No dedup needed on client.

---

## 4. Text Message Flow (Socket Only)

### Step 1 — Open conversation screen

Emit `conversation:join`. The ack returns the conversation object + last messages.

**Emit payload**:
```json
{
  "conversationId": "CONVERSATION_ID",
  "limit": 50
}
```

**Ack response**:
```json
{
  "success": true,
  "data": {
    "conversation": {
      "_id": "CONVERSATION_ID",
      "kind": "direct",
      "participantKey": "direct:USER_A_ID:USER_B_ID",
      "counterpart": { "_id": "...", "fullName": "...", "username": "...", "avatar": "..." },
      "participants": [ { "_id": "...", "fullName": "...", "username": "...", "avatar": "...", "bio": "...", "city": "...", "country": "...", "interests": [] } ],
      "lastMessage": "Hello world",
      "lastMessageType": "text",
      "lastMessageAt": "...",
      "lastMessageSender": "SENDER_USER_ID",
      "unreadCount": 2,
      "createdAt": "...",
      "updatedAt": "..."
    },
    "messages": [
      {
        "_id": "MSG_ID",
        "chat": "CONVERSATION_ID",
        "sender": { "_id": "...", "fullName": "...", "username": "...", "avatar": "...", "bio": "...", "city": "...", "country": "...", "interests": [] },
        "content": "Hi",
        "type": "text",
        "mediaUrl": null,
        "readBy": ["USER_ID"],
        "createdAt": "...",
        "updatedAt": "...",
        "isOwnMessage": false
      }
    ],
    "meta": { "page": 1, "limit": 50, "total": 24, "totalPage": 1 }
  }
}
```

> **Messages sort order**: returned oldest-first (chronological). Fetch with `limit` (default 20, max 100) and `page` for history pagination. Append older pages above the current message list.

### Step 2 — Send text message

Emit `message:send`. The ack returns the created message.

**Emit payload**:
```json
{
  "conversationId": "CONVERSATION_ID",
  "content": "Hello world",
  "type": "text"
}
```
`type` is optional — defaults to `"text"`.

**Ack response**:
```json
{
  "success": true,
  "data": {
    "conversation": {
      "_id": "CONVERSATION_ID",
      "kind": "direct",
      "participantKey": "direct:USER_A_ID:USER_B_ID",
      "counterpart": { "_id": "...", "fullName": "...", "username": "...", "avatar": "..." },
      "participants": [ { "_id": "...", "fullName": "...", "username": "...", "avatar": "...", "bio": "...", "city": "...", "country": "...", "interests": [] } ],
      "lastMessage": "Hello world",
      "lastMessageType": "text",
      "lastMessageAt": "...",
      "lastMessageSender": "SENDER_USER_ID",
      "unreadCount": 0,
      "createdAt": "...",
      "updatedAt": "..."
    },
    "message": {
      "_id": "MSG_ID",
      "chat": "CONVERSATION_ID",
      "content": "Hello world",
      "type": "text",
      "mediaUrl": null,
      "sender": { "_id": "...", "fullName": "...", "username": "...", "avatar": "...", "bio": "...", "city": "...", "country": "...", "interests": [] },
      "readBy": ["SENDER_USER_ID"],
      "createdAt": "...",
      "updatedAt": "...",
      "isOwnMessage": true
    }
  }
}
```

### Step 3 — Receive messages

Listen to `conversation:message:new` while the thread screen is open.

**Payload**:
```json
{
  "conversation": {
    "_id": "CONVERSATION_ID",
    "kind": "direct",
    "participantKey": "direct:USER_A_ID:USER_B_ID",
    "lastMessage": "Hello world",
    "lastMessageType": "text",
    "lastMessageAt": "...",
    "lastMessageSender": "SENDER_USER_ID",
    "unreadCount": 0,
    "counterpart": { "_id": "...", "fullName": "...", "username": "...", "avatar": "..." },
    "participants": [ { "_id": "...", "fullName": "...", "username": "...", "avatar": "...", "bio": "...", "city": "...", "country": "...", "interests": [] } ],
    "createdAt": "...",
    "updatedAt": "..."
  },
  "message": {
    "_id": "MSG_ID",
    "chat": "CONVERSATION_ID",
    "sender": { "_id": "...", "fullName": "...", "username": "...", "avatar": "...", "bio": "...", "city": "...", "country": "...", "interests": [] },
    "content": "Hello world",
    "type": "text",
    "mediaUrl": null,
    "readBy": ["SENDER_USER_ID"],
    "createdAt": "...",
    "updatedAt": "...",
    "isOwnMessage": false
  }
}
```

### Step 4 — Close conversation screen

Emit `conversation:leave`:
```json
{ "conversationId": "CONVERSATION_ID" }
```

---

## 5. Media Message Flow (REST → Socket)

For images, audio, and video. **Do not use socket for media upload.**

### Step 1 — Upload via REST

`POST /api/v1/chat/conversations/:conversationId/messages`  
Content-Type: `multipart/form-data`

| Form field | Description |
|------------|-------------|
| `image` | Image file (jpg, png, webp, etc.) |
| `media` | Audio or video file (mp3, aac, mp4, mov, etc.) |
| `content` | Optional caption text (plain form field or inside `data` JSON) |
| `data` | Optional: JSON string with body fields, e.g. `{"content":"caption"}` |

Only one file per request.

**Example form-data**:
```
image:  [file]
data:   {"content":"Optional caption"}
```
OR
```
media:  [audio.mp3]
```
`type` is auto-detected from the file MIME type (`image`, `audio`, `video`). You can override it with a `type` form field.

**REST response** (201):
```json
{
  "success": true,
  "message": "Message sent successfully",
  "data": {
    "conversation": {
      "_id": "CONVERSATION_ID",
      "kind": "direct",
      "participantKey": "direct:USER_A_ID:USER_B_ID",
      "lastMessage": "[Image]",
      "lastMessageType": "image",
      "lastMessageAt": "...",
      "lastMessageSender": "SENDER_USER_ID",
      "unreadCount": 0,
      "counterpart": { "_id": "...", "fullName": "...", "username": "...", "avatar": "..." },
      "participants": [ { "_id": "...", "fullName": "...", "username": "...", "avatar": "...", "bio": "...", "city": "...", "country": "...", "interests": [] } ],
      "createdAt": "...",
      "updatedAt": "..."
    },
    "message": {
      "_id": "MSG_ID",
      "chat": "CONVERSATION_ID",
      "content": "[Image]",
      "type": "image",
      "mediaUrl": "uploads/images/filename.webp",
      "sender": { "_id": "...", "fullName": "...", "username": "...", "avatar": "...", "bio": "...", "city": "...", "country": "...", "interests": [] },
      "readBy": ["SENDER_USER_ID"],
      "createdAt": "...",
      "updatedAt": "...",
      "isOwnMessage": true
    }
  }
}
```

> **Note**: `message.content` is `"[Image]"`, `"[Audio]"`, or `"[Video]"` when no caption is provided. If a caption is included, `content` holds the caption text.

Access media file at: `http://SERVER:5002/uploads/images/filename.webp` or `http://SERVER:5002/uploads/medias/filename.mp3`

### Step 2 — Recipient receives socket event automatically

After the REST call succeeds, the backend emits to the recipient automatically. No extra socket emit needed from client.

- If recipient **has the thread open** → receives `conversation:message:new` (same full payload structure as text)
- If recipient **does not have the thread open** → receives `receive-message` (compact payload, see below)

---

## 6. `receive-message` Event (Inbox Notification)

This arrives when a new message comes in and the recipient is **not** in that conversation thread screen.

Use this to update the conversation list / badge counts on the home screen.

**Payload** (compact — no full participant list):
```json
{
  "conversation": {
    "_id": "CONVERSATION_ID",
    "kind": "direct",
    "participantKey": "direct:USER_A_ID:USER_B_ID",
    "lastMessage": "[Audio]",
    "lastMessageType": "audio",
    "lastMessageAt": "2026-05-02T11:10:18.953Z",
    "lastMessageSender": "SENDER_USER_ID",
    "unreadCount": 3,
    "counterpart": {
      "_id": "...",
      "fullName": "John Doe",
      "username": "johndoe",
      "avatar": "uploads/images/avatar.webp"
    }
  },
  "message": {
    "_id": "...",
    "chat": "CONVERSATION_ID",
    "content": "[Audio]",
    "type": "audio",
    "mediaUrl": "uploads/medias/voice.mp3",
    "createdAt": "2026-05-02T11:10:18.953Z",
    "sender": {
      "_id": "...",
      "fullName": "John Doe",
      "username": "johndoe",
      "avatar": "uploads/images/avatar.webp"
    }
  }
}
```

**`lastMessage` / `content` previews**: `[Image]`, `[Audio]`, `[Video]`, `[Message]` for media types; actual text for text type.

---

## 7. Typing Indicators

### Emit (start/stop)
```json
{ "conversationId": "CONVERSATION_ID" }
```
Events: `conversation:typing:start` / `conversation:typing:stop`

### Listen: `conversation:typing`
```json
{
  "conversationId": "CONVERSATION_ID",
  "userId": "TYPING_USER_ID",
  "isTyping": true
}
```

---

## 8. Mark as Read

### Via socket
Emit `conversation:read`:
```json
{ "conversationId": "CONVERSATION_ID" }
```

**Ack response**:
```json
{
  "success": true,
  "data": {
    "totalUnreadMessages": 3,
    "totalUnreadConversations": 1
  }
}
```

### Via REST
`PATCH /api/v1/chat/conversations/:conversationId/read`

Both reset the unread count for the conversation and broadcast an updated `chat:unread-summary` event back to the user.

---

## 9. Unread Summary

Event: `chat:unread-summary` (auto-pushed on connect and on read/send)

```json
{
  "totalUnreadMessages": 5,
  "totalUnreadConversations": 2
}
```

---

## 10. Presence

Event: `presence:update`

```json
{
  "userId": "USER_ID",
  "isOnline": true
}
```

---

## 11. Error Handling

### Socket ack errors
All socket emits return an ack. On failure:
```json
{
  "success": false,
  "message": "conversationId is required"
}
```

### REST errors
```json
{
  "success": false,
  "message": "Conversation not found",
  "errorMessages": [{ "path": "", "message": "Conversation not found" }]
}
```

Common HTTP codes: `400` bad request, `401` unauthorized, `403` forbidden, `404` not found, `500` server error.

---

## 12. Quick Reference — Full Flow Summary

```
APP START
  │
  ├─ POST /auth/login  →  save accessToken
  │
  ├─ Connect socket with auth.token
  │     └─ Listen: chat:unread-summary, notification:unread-count (auto on connect)
  │
  ├─ HOME SCREEN
  │     ├─ GET /chat/conversations  →  render conversation list
  │     └─ Listen: receive-message  →  update list + badge on new message
  │
  └─ CHAT THREAD SCREEN
        ├─ POST /chat/direct/:userId  →  get conversationId
        ├─ Emit: conversation:join  →  ack has history
        │
        ├─ TEXT MESSAGE
        │     ├─ Emit: conversation:typing:start / stop
        │     ├─ Emit: message:send  →  ack has created message
        │     └─ Listen: conversation:message:new  →  append to list
        │
        ├─ MEDIA MESSAGE
        │     ├─ POST /chat/conversations/:id/messages  (multipart)
        │     │     └─ REST response has message + mediaUrl
        │     └─ Listen: conversation:message:new  →  recipient sees media
        │
        ├─ Emit: conversation:read  (on scroll / focus)
        └─ Emit: conversation:leave  (on screen close)
```
