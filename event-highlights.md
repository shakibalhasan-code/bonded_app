# Bonded Event Highlights - App Integration Guide

> Audience: mobile app / frontend developers
> Scope: app-facing event detail and event highlight APIs for public and circle events
> Not covered here: admin APIs, external events, Eventbrite, GetYourGuide

This document explains how to load event details and work with event highlights for both public events and circle events.

## 1. Overview

The Event Highlights feature is available only for app-created events.

- Public app events are supported.
- Circle app events are supported.
- External events are not supported.

The same highlight endpoints are used for both public and circle events:

- `GET {{url}}/events/public/highlights`
- `GET {{url}}/circles/:circleId/highlights`
- `GET {{url}}/events/:eventId/highlights`
- `GET {{url}}/events/highlights/:highlightId`
- `POST {{url}}/events/:eventId/highlights`

The difference between public and circle events is the access rule, not the highlight route path.

## 2. Authentication

All event detail and highlight APIs are private.

Required header:

```http
Authorization: Bearer ACCESS_TOKEN
```

## 3. Event Types and Access Rules

| Event type | Event details endpoint | Who can view event details | Who can view highlights | Who can create highlights |
| --- | --- | --- | --- | --- |
| Public event | `GET /api/v1/events/:eventId` | Any authenticated user | Any authenticated user | Only the event creator |
| Circle event | `GET /api/v1/circles/:circleId/events/:eventId` | Accepted circle members only | Accepted circle members only | Only the event creator |

Important:

- `GET /api/v1/events/:eventId` is only for public app events.
- Circle event details must be loaded from `GET /api/v1/circles/:circleId/events/:eventId`.
- Highlight routes are shared between public and circle events.

## 4. Related Event Detail APIs

### Public event details

- Endpoint: `GET {{url}}/events/:eventId`
- Purpose: fetch one public app event by ID
- Access: any authenticated user

Example:

```http
GET /api/v1/events/6818a8b9d3f0c57f7e0c1111
Authorization: Bearer ACCESS_TOKEN
```

Success response shape:

```json
{
  "success": true,
  "message": "Event fetched successfully",
  "data": {
    "_id": "6818a8b9d3f0c57f7e0c1111",
    "title": "Sunset Rooftop Mixer",
    "visibility": "public",
    "host": "6818a899d3f0c57f7e0c1001"
  }
}
```

### Circle event details

- Endpoint: `GET {{url}}/circles/:circleId/events/:eventId`
- Purpose: fetch one circle event by ID
- Access: accepted circle members only

Example:

```http
GET /api/v1/circles/6818b111d3f0c57f7e0c2001/events/6818b2a9d3f0c57f7e0c2002
Authorization: Bearer ACCESS_TOKEN
```

Success response shape:

```json
{
  "success": true,
  "message": "Circle event fetched successfully",
  "data": {
    "_id": "6818b2a9d3f0c57f7e0c2002",
    "title": "Private Strategy Dinner",
    "visibility": "circle",
    "circleId": "6818b111d3f0c57f7e0c2001",
    "host": "6818a899d3f0c57f7e0c1001"
  }
}
```

## 5. Highlight APIs

## 5.1 List all public event highlights

- Endpoint: `GET {{url}}/events/public/highlights`
- Purpose: list highlights across all public events
- Access: any authenticated user
- Query params:
  - `page`: optional
  - `limit`: optional

Example:

```http
GET /api/v1/events/public/highlights?page=1&limit=20
Authorization: Bearer ACCESS_TOKEN
```

Success response shape:

```json
{
  "success": true,
  "message": "Public event highlights fetched successfully",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 42,
    "totalPage": 3
  },
  "data": [
    {
      "_id": "6818c2a9d3f0c57f7e0c3001",
      "event": {
        "_id": "6818a8b9d3f0c57f7e0c1111",
        "title": "Sunset Rooftop Mixer",
        "visibility": "public"
      },
      "creator": {
        "_id": "6818a899d3f0c57f7e0c1001",
        "fullName": "Host User"
      },
      "images": [],
      "videos": [
        {
          "url": "uploads/videos/event-highlight-1.mp4",
          "durationSeconds": 12
        }
      ],
      "caption": "Recap video",
      "taggedAttendees": [],
      "taggedCircles": [],
      "createdAt": "2026-05-05T00:15:00.000Z",
      "updatedAt": "2026-05-05T00:15:00.000Z"
    }
  ]
}
```

## 5.2 List all highlights for a circle

- Endpoint: `GET {{url}}/circles/:circleId/highlights`
- Purpose: list highlights across all events inside one circle
- Access: accepted circle members only
- Query params:
  - `page`: optional
  - `limit`: optional

Example:

```http
GET /api/v1/circles/6818b111d3f0c57f7e0c2001/highlights?page=1&limit=20
Authorization: Bearer ACCESS_TOKEN
```

Success response shape:

```json
{
  "success": true,
  "message": "Circle event highlights fetched successfully",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 18,
    "totalPage": 1
  },
  "data": [
    {
      "_id": "6818d2a9d3f0c57f7e0c3010",
      "event": {
        "_id": "6818b2a9d3f0c57f7e0c2002",
        "title": "Private Strategy Dinner",
        "visibility": "circle",
        "circleId": "6818b111d3f0c57f7e0c2001"
      },
      "creator": {
        "_id": "6818a899d3f0c57f7e0c1001",
        "fullName": "Host User"
      },
      "images": [
        {
          "url": "uploads/images/circle-highlight-1.webp"
        }
      ],
      "videos": [],
      "caption": "Highlights from the circle dinner",
      "taggedAttendees": [],
      "taggedCircles": [
        {
          "_id": "6818b111d3f0c57f7e0c2001",
          "name": "Founders Inner Circle"
        },
        {
          "_id": "6818b111d3f0c57f7e0c2005",
          "name": "Investors Circle"
        }
      ],
      "createdAt": "2026-05-05T00:30:00.000Z",
      "updatedAt": "2026-05-05T00:30:00.000Z"
    }
  ]
}
```

## 5.3 List event highlights

- Endpoint: `GET {{url}}/events/:eventId/highlights`
- Purpose: list all highlights for an event
- Access:
  - public event: any authenticated user
  - circle event: accepted circle members only
- Response: not paginated

Example:

```http
GET /api/v1/events/6818a8b9d3f0c57f7e0c1111/highlights
Authorization: Bearer ACCESS_TOKEN
```

Success response shape:

```json
{
  "success": true,
  "message": "Event highlights fetched successfully",
  "data": [
    {
      "_id": "6818c2a9d3f0c57f7e0c3001",
      "event": {
        "_id": "6818a8b9d3f0c57f7e0c1111",
        "title": "Sunset Rooftop Mixer",
        "visibility": "public"
      },
      "creator": {
        "_id": "6818a899d3f0c57f7e0c1001",
        "fullName": "Host User"
      },
      "images": [
        {
          "url": "uploads/images/event-highlight-1.webp"
        }
      ],
      "videos": [],
      "caption": "Best moments from tonight",
      "taggedAttendees": [
        {
          "_id": "6818d111d3f0c57f7e0c4001",
          "fullName": "Tagged Guest"
        }
      ],
      "taggedCircles": [],
      "createdAt": "2026-05-05T00:15:00.000Z",
      "updatedAt": "2026-05-05T00:15:00.000Z"
    }
  ]
}
```

## 5.4 Get one highlight by ID

- Endpoint: `GET {{url}}/events/highlights/:highlightId`
- Purpose: fetch one highlight directly by highlight ID
- Access:
  - public event: any authenticated user
  - circle event: accepted circle members only

Example:

```http
GET /api/v1/events/highlights/6818c2a9d3f0c57f7e0c3001
Authorization: Bearer ACCESS_TOKEN
```

Success response shape:

```json
{
  "success": true,
  "message": "Event highlight fetched successfully",
  "data": {
    "_id": "6818c2a9d3f0c57f7e0c3001",
    "event": {
      "_id": "6818a8b9d3f0c57f7e0c1111",
      "title": "Sunset Rooftop Mixer",
      "visibility": "public"
    },
    "creator": {
      "_id": "6818a899d3f0c57f7e0c1001",
      "fullName": "Host User"
    },
    "images": [
      {
        "url": "uploads/images/event-highlight-1.webp"
      }
    ],
    "videos": [],
    "caption": "Best moments from tonight",
    "taggedAttendees": [
      {
        "_id": "6818d111d3f0c57f7e0c4001",
        "fullName": "Tagged Guest"
      }
    ],
    "taggedCircles": [],
    "createdAt": "2026-05-05T00:15:00.000Z",
    "updatedAt": "2026-05-05T00:15:00.000Z"
  }
}
```

## 5.5 Create a highlight

- Endpoint: `POST {{url}}/events/:eventId/highlights`
- Purpose: create a new highlight for a public event or circle event
- Access: only the event creator can create highlights
- Content type: `multipart/form-data`

Example:

```http
POST /api/v1/events/6818a8b9d3f0c57f7e0c1111/highlights
Authorization: Bearer ACCESS_TOKEN
Content-Type: multipart/form-data
```

Success response shape:

```json
{
  "success": true,
  "message": "Event highlight created successfully",
  "data": {
    "_id": "6818c2a9d3f0c57f7e0c3001",
    "event": {
      "_id": "6818a8b9d3f0c57f7e0c1111",
      "title": "Sunset Rooftop Mixer",
      "visibility": "public"
    },
    "creator": {
      "_id": "6818a899d3f0c57f7e0c1001",
      "fullName": "Host User"
    },
    "images": [
      {
        "url": "uploads/images/event-highlight-1.webp"
      }
    ],
    "videos": [],
    "caption": "Best moments from tonight",
    "taggedAttendees": [
      {
        "_id": "6818d111d3f0c57f7e0c4001",
        "fullName": "Tagged Guest"
      }
    ],
    "taggedCircles": [],
    "createdAt": "2026-05-05T00:15:00.000Z",
    "updatedAt": "2026-05-05T00:15:00.000Z"
  }
}
```

## 6. Create Highlight Request Fields

The create-highlight endpoint accepts multipart form fields plus uploaded files.

### Supported text fields

- `caption`: optional string, max length `5000`
- `taggedAttendees`: optional array of user IDs, max `50`
- `taggedCircles`: optional array of circle IDs, max `50`
- `videoDurationsSeconds`: optional array of integers, max `10`

Multipart field notes:

- for repeated attendee tags, send repeated `taggedAttendees` fields
- for repeated circle tags, send repeated `taggedCircles` fields
- for repeated video durations, send repeated `videoDurationsSeconds` fields
- for compatibility, the backend also accepts `taggedAttendees[]`, `taggedCircles[]`, `videoDurationsSeconds[]`, and the legacy single-value `taggedCircle`
- if there is only one attendee tag, one circle tag, or one video duration, a single field value is also accepted
- if your client wants to send a text array value, JSON-array strings are also accepted, for example `taggedAttendees=["id1","id2"]` or `taggedCircles=["circle1","circle2"]`
- if your client prefers one JSON field plus files, you can send a `data` field containing JSON and upload files in the same multipart request

### Supported file fields

- `image`: optional image uploads, max `15`
- `video`: optional video uploads, max `10`

At least one `image` or one `video` is required.

### Video duration rules

If `videoDurationsSeconds` is sent:

- each value must be an integer
- minimum value is `1`
- maximum value is `30`
- maximum array length is `10`

### Tag array rules

- `taggedAttendees` may be omitted or sent as an empty array
- `taggedCircles` may be omitted or sent as an empty array
- both arrays accept valid Mongo ID strings only
- duplicate IDs are de-duplicated by the backend before saving

Response note:

- the API response always returns `taggedAttendees` and `taggedCircles` as arrays

## 7. Allowed Upload Types

### Image types

- `image/jpeg`
- `image/png`
- `image/jpg`
- `image/heif`
- `image/heic`
- `image/tiff`
- `image/webp`
- `image/avif`

### Video types

- `video/mp4`
- `video/quicktime`
- `video/webm`
- `video/x-msvideo`
- `video/mpeg`

## 8. Multipart Example

### Public event highlight example

```bash
curl --request POST '{{url}}/events/6818a8b9d3f0c57f7e0c1111/highlights' \
  --header 'Authorization: Bearer ACCESS_TOKEN' \
  --form 'caption=Best moments from tonight' \
  --form 'taggedAttendees=6818d111d3f0c57f7e0c4001' \
  --form 'taggedAttendees=6818d111d3f0c57f7e0c4002' \
  --form 'taggedCircles=6818b111d3f0c57f7e0c2001' \
  --form 'taggedCircles=6818b111d3f0c57f7e0c2005' \
  --form 'image=@./highlight-photo-1.jpg' \
  --form 'image=@./highlight-photo-2.png' \
  --form 'video=@./highlight-video-1.mp4' \
  --form 'videoDurationsSeconds=12'
```

### Circle event highlight example

```bash
curl --request POST '{{url}}/events/6818b2a9d3f0c57f7e0c2002/highlights' \
  --header 'Authorization: Bearer ACCESS_TOKEN' \
  --form 'caption=Private dinner recap' \
  --form 'taggedCircles=6818b111d3f0c57f7e0c2001' \
  --form 'taggedCircles=6818b111d3f0c57f7e0c2005' \
  --form 'taggedAttendees=6818d111d3f0c57f7e0c4001' \
  --form 'image=@./circle-highlight-1.jpg'
```

Alternative JSON-array style in multipart is also accepted:

```bash
curl --request POST '{{url}}/events/6818a8b9d3f0c57f7e0c1111/highlights' \
  --header 'Authorization: Bearer ACCESS_TOKEN' \
  --form 'caption=Best moments from tonight' \
  --form 'taggedAttendees=["6818d111d3f0c57f7e0c4001","6818d111d3f0c57f7e0c4002"]' \
  --form 'taggedCircles=["6818b111d3f0c57f7e0c2001","6818b111d3f0c57f7e0c2005"]' \
  --form 'image=@./highlight-photo-1.jpg'
```

## 9. Highlight Object Fields

Each highlight record contains:

- `_id`
- `event` (populated event object)
- `creator` (populated user object)
- `videos`
- `images`
- `caption`
- `taggedAttendees` (populated user objects)
- `taggedCircles` (array of populated circle objects)
- `createdAt`
- `updatedAt`

Video object fields:

- `url`
- `durationSeconds`

Image object fields:

- `url`

## 10. Error Cases the App Must Handle

Common backend validation and permission errors:

- `401 Unauthorized`
  - missing or invalid access token
- `403 Forbidden`
  - `Only the event creator can add highlights`
  - user is not allowed to view a circle event highlight because they are not an accepted circle member
- `404 Not Found`
  - `Public event not found`
  - `Circle event not found`
  - `Event not found`
  - `Event highlight not found`
- `400 Bad Request`
  - `At least one image or video is required to create a highlight`
  - invalid Mongo ID in path or body

## 11. Recommended App Flow

### Public event flow

1. Load event details with `GET /events/:eventId`.
2. Load highlights with `GET /events/:eventId/highlights`.
3. If the authenticated user is the event creator, show create-highlight UI.
4. Upload highlight with `POST /events/:eventId/highlights`.
5. Refresh list or fetch the created highlight again.

### Circle event flow

1. Load event details with `GET /circles/:circleId/events/:eventId`.
2. Load highlights with `GET /events/:eventId/highlights`.
3. If the authenticated user is the event creator, show create-highlight UI.
4. If the user is not an accepted circle member, do not allow highlight viewing.
5. Upload highlight with `POST /events/:eventId/highlights`.
6. Refresh list or fetch the created highlight again.

## 12. Important Notes

- Highlights are available only for app events.
- External events do not support highlights.
- The same highlight API path is used for both public and circle events.
- The event type is enforced by backend access logic, not by separate highlight route paths.
- For circle events, the frontend should already know the `circleId` from the circle event detail flow, but highlight routes still use only `eventId`.
