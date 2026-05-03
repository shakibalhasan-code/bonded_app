# Circles API — Frontend Integration Guide

## Authentication

All endpoints require a valid JWT access token in the `Authorization` header.

```
Authorization: Bearer <access_token>
```

---

## List Circles

### `GET /api/v1/circles`

Returns a paginated list of circles. Every circle object includes an **`isJoined`** boolean that indicates whether the authenticated user is an accepted member of that circle.

### Use `isJoined` to conditionally render UI:

| `isJoined` | Suggested UI action |
|---|---|
| `false` | Show **"Join Circle"** button |
| `true` | Show **"View Circle"** button / navigate directly |

---

### Query Parameters

| Parameter | Type | Required | Values | Default | Description |
|---|---|---|---|---|---|
| `scope` | string | No | `all` `public` `private` `created` `joined` `my` | `all` | Filters which circles to return (see scopes below) |
| `category` | string | No | `music` `sports` `art` `tech` `food` `travel` `wellness` `gaming` `fashion` `film` `business` `education` `lifestyle` `community` `other` | — | Filter by interest category |
| `tier` | string | No | `global` `local` | — | Filter by circle tier |
| `visibility` | string | No | `public` `private` | — | Filter by visibility |
| `joinStatus` | string | No | `lock` `unlock` | — | Filter by whether new members can freely join |
| `city` | string | No | any | — | Filter by city (exact match) |
| `searchTerm` | string | No | any | — | Full-text search on circle name and description |
| `page` | number | No | ≥ 1 | `1` | Pagination page number |
| `limit` | number | No | ≥ 1 | `100` | Number of results per page |
| `sortBy` | string | No | `name` `createdAt` `memberCount` | `createdAt` | Field to sort by |
| `sortOrder` | string | No | `asc` `desc` | `desc` | Sort direction |

---

### Scope Values

| Scope | Returns |
|---|---|
| `all` | Every active circle (public and private), regardless of membership |
| `public` | Only circles with `visibility: "public"` |
| `private` | Only circles with `visibility: "private"` |
| `created` | Only circles created by the authenticated user |
| `joined` | Only circles where the user is an accepted member (does NOT include circles they created) |
| `my` | Circles the user created **or** is a member of (union of `created` + `joined`) |

> **Tip:** For the home/discovery screen, use `scope=all` or `scope=public`. For the user's personal dashboard, use `scope=my`.

---

### Response Shape

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Circles fetched successfully",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 143,
    "totalPage": 8
  },
  "data": [
    {
      "_id": "664abc123def456789012345",
      "name": "Nairobi Tech Circle",
      "slug": "nairobi-tech-circle",
      "description": "A circle for tech enthusiasts in Nairobi.",
      "coverImage": "https://cdn.example.com/circles/nairobi-tech.jpg",
      "category": "tech",
      "hashtags": ["tech", "nairobi", "coding"],
      "interests": [
        { "_id": "...", "name": "Software Development", "slug": "software-development", "category": "tech" }
      ],
      "visibility": "public",
      "tier": "local",
      "joinStatus": "unlock",
      "isPaid": false,
      "price": 0,
      "city": "Nairobi",
      "region": "Nairobi County",
      "memberCount": 312,
      "postCount": 87,
      "shareCount": 14,
      "maxFreeMembers": 0,
      "densityThreshold": 50,
      "creator": "664000000000000000000001",
      "isActive": true,
      "isDeleted": false,
      "createdAt": "2025-11-10T08:00:00.000Z",
      "updatedAt": "2026-04-20T14:30:00.000Z",
      "isJoined": true
    }
  ]
}
```

> **Note:** For `private` circles, `densityThreshold` is always returned as `null` regardless of the actual value.

---

### Key Response Fields

| Field | Type | Description |
|---|---|---|
| `_id` | string | Unique circle ID |
| `name` | string | Circle display name |
| `slug` | string | URL-friendly identifier (use in deep links) |
| `coverImage` | string \| null | Cover image URL |
| `category` | string | Interest category |
| `visibility` | `"public"` \| `"private"` | Who can see this circle |
| `tier` | `"global"` \| `"local"` | Whether the circle is location-based or global |
| `joinStatus` | `"lock"` \| `"unlock"` | `"lock"` = join requires approval; `"unlock"` = open join |
| `isPaid` | boolean | Whether joining requires payment |
| `price` | number | Price in smallest currency unit (0 if free) |
| `memberCount` | number | Total accepted members |
| `densityThreshold` | number \| null | Auto-split threshold (null for private circles) |
| **`isJoined`** | **boolean** | **`true` if the authenticated user is an accepted member of this circle** |

---

### Sample Requests

#### Discover all public circles (default — browse/discovery)
```
GET /api/v1/circles?scope=public&page=1&limit=20
```

#### My circles (dashboard tab)
```
GET /api/v1/circles?scope=my&page=1&limit=20
```

#### Circles I've joined (not created)
```
GET /api/v1/circles?scope=joined&page=1&limit=20
```

#### Filter by category + city
```
GET /api/v1/circles?scope=public&category=tech&city=Nairobi&page=1&limit=10
```

#### Search for circles with keyword
```
GET /api/v1/circles?searchTerm=football&scope=all&page=1&limit=20
```

#### Open circles only (no approval required)
```
GET /api/v1/circles?joinStatus=unlock&scope=public&page=1&limit=20
```

---

### Pagination

The `meta` object tells you the total number of results and pages:

```json
"meta": {
  "page": 1,
  "limit": 20,
  "total": 143,
  "totalPage": 8
}
```

To fetch the next page, increment `page` by 1. Stop when `page > totalPage`.

---

### Error Responses

| Status | Meaning |
|---|---|
| `401 Unauthorized` | Missing or invalid `Authorization` token |
| `400 Bad Request` | Invalid query parameter value (e.g. unknown `scope`) |
| `500 Internal Server Error` | Unexpected server error |

```json
{
  "success": false,
  "statusCode": 401,
  "message": "Unauthorized"
}
```
