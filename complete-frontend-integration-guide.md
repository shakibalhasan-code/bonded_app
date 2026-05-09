# Home Route Frontend Integration Guide

Audience: mobile app and frontend developers

Scope: only the combined home endpoint.

Base URL:

```text
{{url}} = baseuRL
```

Auth:

```http
Authorization: Bearer ACCESS_TOKEN
```

## 1. Endpoint

- Method: GET
- Route: /api/v1/home
- Access: Private (authenticated user required)

Mounted from:

- `src/module/home/home.route.ts`
- `src/routes/index.ts`

## 2. Request

## 2.1 Query Parameters

All query fields are optional.

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `lat` | string | No | User latitude for nearby bond suggestions |
| `lng` | string | No | User longitude for nearby bond suggestions |
| `maxDistance` | string | No | Max distance filter (used by nearby bond lookup) |

Validation behavior:

1. Query object is strict.
2. Only `lat`, `lng`, `maxDistance` are accepted.
3. Unknown query keys will fail validation.

Example request:

```http
GET /api/v1/home?lat=23.8103&lng=90.4125&maxDistance=15000 -It could be filerting as well. 
Authorization: Bearer ACCESS_TOKEN
```

## 3. Response

Success status:

- HTTP 200

Success envelope:

```json
{
  "success": true,
  "message": "Home feed fetched successfully",
  "data": {
    "circles": {
      "posts": [],
      "circles": []
    },
    "events": {
      "events": [],
      "message": "No event"
    },
    "bondSuggestions": []
  }
}
```

Top-level response sections:

1. `circles`
2. `events`
3. `bondSuggestions`

## 4. Circles Section Behavior

Returned shape:

```json
{
  "circles": {
    "posts": [],
    "circles": []
  }
}
```

## 4.1 `circles.posts` rules

1. Backend first finds circles where current user is an accepted member.
2. If user has joined circles:
   - returns up to 2 latest top-level posts (`parentPost: null`, `isDeleted: false`) across those joined circles.
3. If user has not joined any circle:
   - returns empty `posts`.

## 4.2 `circles.circles` rules

Always returns discovery list of public circles:

1. `visibility = public`
2. `isDeleted = false`
3. `isActive = true`
4. limit 6
5. sort priority:
   - `memberCount` descending
   - then `createdAt` descending

## 5. Events Section Behavior

Returned shape:

```json
{
  "events": {
    "events": [],
    "message": "No event"
  }
}
```

Important:

- `message` appears only when no upcoming events are found.

## 5.1 Selection priority

Backend applies strict fallback order:

1. Find upcoming public in-person events first.
2. If none found, fallback to upcoming public virtual/bonded_live events.
3. If still none found:
   - `events: []`
   - `message: "No event"`

## 5.2 Event eligibility rules

Event must satisfy all:

1. `visibility = public`
2. `status in [active, live]`
3. Event type matches the current step:
   - step 1: in-person
   - step 2 fallback: virtual or bonded_live
4. Event start datetime must be >= now (upcoming only)

## 5.3 “Closest” rule used by backend

For this endpoint, closest upcoming is interpreted by earliest upcoming datetime:

1. parse from `eventDate` (`DD/MM/YYYY`) + start of `eventTime` (`HH:MM-HH:MM`)
2. filter upcoming
3. sort ascending by parsed start datetime
4. return max 3

## 6. Bond Suggestions Behavior

Returned shape:

```json
{
  "bondSuggestions": []
}
```

Target count:

- up to 3 users

## 6.1 Primary strategy: nearby users

Backend first calls nearby-people logic using:

1. authenticated user id
2. optional `lat`, `lng`, `maxDistance`
3. fixed pagination: page=1, limit=3

If nearby returns one or more items:

- those nearby items are returned (max 3).

## 6.2 Fallback strategy: random eligible users

If nearby returns empty:

1. backend builds exclusion set
2. samples random eligible users (`$sample`) with limit 3

Eligibility filters for random fallback:

1. Exclude self
2. Exclude users with pending or accepted bond relation with current user
3. Exclude blocked relationships (both directions)
4. `isDeleted = false`
5. `isBlocked = false`
6. `profileCompleted = true`

## 6.3 Random fallback output mapping

Random candidate response includes user preview fields such as:

- `_id`
- `fullName`
- `username`
- `avatar`
- `bio`
- `city`
- `country`
- `gender`
- `dateOfBirth` (formatted as `DD-MM-YYYY` when available)
- `connectionType`
- `averageRating`
- `reviewCount`
- `profileCompleted`
- `interests`
- `distanceMeters` set to `null` for random fallback rows

## 7. Practical Frontend Handling

## 7.1 Rendering rules

1. Circle posts carousel/list:
   - render from `data.circles.posts`
   - if empty, show no-post state
2. Public circle suggestions:
   - render from `data.circles.circles`
3. Events block:
   - render from `data.events.events`
   - if empty and `data.events.message` exists, show that message
4. Bond suggestions:
   - render from `data.bondSuggestions`
   - can contain nearby or random fallback users

## 7.2 Suggested empty-state checks

1. `data.circles.posts.length === 0`
2. `data.circles.circles.length === 0`
3. `data.events.events.length === 0`
4. `data.bondSuggestions.length === 0`

## 8. Error Scenarios

Common failure outcomes:

1. 401 Unauthorized:
   - missing/invalid access token
2. 400 Bad Request:
   - invalid query shape (strict validation failure)
3. 500 Internal Server Error:
   - database/service runtime failure

## 9. Example Full Success Payload

```json
{
  "success": true,
  "message": "Home feed fetched successfully",
  "data": {
    "circles": {
      "posts": [
        {
          "_id": "683d00112233445566778899",
          "content": "Welcome to our circle",
          "author": {
            "_id": "683d00aa2233445566778899",
            "fullName": "Alice"
          },
          "circle": {
            "_id": "683d00bb2233445566778899",
            "name": "Founders Circle"
          }
        }
      ],
      "circles": [
        {
          "_id": "683d00cc2233445566778899",
          "name": "Public Networking Circle",
          "visibility": "public"
        }
      ]
    },
    "events": {
      "events": [
        {
          "_id": "683d00dd2233445566778899",
          "title": "Startup Meetup",
          "type": "in-person",
          "eventDate": "20/05/2026",
          "eventTime": "18:00-20:00"
        }
      ]
    },
    "bondSuggestions": [
      {
        "_id": "683d00ee2233445566778899",
        "fullName": "Bob",
        "city": "Dhaka",
        "distanceMeters": 1200
      }
    ]
  }
}
```

