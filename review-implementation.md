# Event Review API Documentation

## Overview

Users who purchased a ticket for an event can leave a review with a rating (1-5) and a text comment. Each user can only review an event once, even if they purchased multiple tickets.

---

## API Endpoints

Base URL: `/api/v1/reviews`

All endpoints require authentication via Bearer token.

---

### 1. Create a Review

**`POST /api/v1/reviews/events/:eventId`**

#### Request

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `eventId` (URL param) | string | Yes | The event ID (MongoDB ObjectId) |
| `rating` (body) | integer | Yes | Rating from 1 to 5 |
| `comment` (body) | string | Yes | Review text (cannot be empty) |

#### Request Body (JSON)

```json
{
  "rating": 5,
  "comment": "Amazing event! Had a great time."
}
```

#### Success Response (201)

```json
{
  "success": true,
  "message": "Review created successfully",
  "data": {
    "_id": "664f1a2b3c4d5e6f7a8b9c0d",
    "eventId": "664f1a2b3c4d5e6f7a8b9c0e",
    "reviewerId": "664f1a2b3c4d5e6f7a8b9c0f",
    "hostId": "664f1a2b3c4d5e6f7a8b9c10",
    "rating": 5,
    "comment": "Amazing event! Had a great time.",
    "createdAt": "2026-05-14T10:30:00.000Z",
    "updatedAt": "2026-05-14T10:30:00.000Z"
  }
}
```

#### Error Responses

| Status | Message | When |
|--------|---------|------|
| 404 | "Event not found" | Event ID doesn't exist |
| 403 | "Only ticket holders can leave a review" | User has no active ticket for this event |
| 409 | "You have already reviewed this event" | User already submitted a review for this event |
| 400 | Validation error | Rating not 1-5, or comment empty |

---

### 2. Get Event Reviews

**`GET /api/v1/reviews/events/:eventId`**

#### Request

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `eventId` (URL param) | string | Yes | The event ID |
| `page` (query param) | integer | No | Page number (default: 1) |
| `limit` (query param) | integer | No | Items per page (default: 20, max: 100) |

#### Example Request

```
GET /api/v1/reviews/events/664f1a2b3c4d5e6f7a8b9c0e?page=1&limit=20
```

#### Success Response (200)

```json
{
  "success": true,
  "message": "Reviews retrieved successfully",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 111,
    "totalPage": 6
  },
  "data": {
    "summary": {
      "totalReviews": 111,
      "averageRating": 4.5,
      "ratingDistribution": {
        "1": 3,
        "2": 8,
        "3": 10,
        "4": 40,
        "5": 50
      }
    },
    "reviews": [
      {
        "_id": "664f1a2b3c4d5e6f7a8b9c0d",
        "rating": 5,
        "comment": "Amazing event! Had a great time.",
        "createdAt": "2026-05-14T10:30:00.000Z",
        "reviewer": {
          "_id": "664f1a2b3c4d5e6f7a8b9c0f",
          "fullName": "John Doe",
          "username": "johndoe",
          "avatar": "https://s3.amazonaws.com/avatars/john.jpg",
          "email": "john@example.com"
        }
      }
    ],
    "meta": {
      "page": 1,
      "limit": 20,
      "total": 111,
      "totalPage": 6
    }
  }
}
```

#### Response Fields

**`summary`** - Aggregated review stats for the event

| Field | Type | Description |
|-------|------|-------------|
| `totalReviews` | integer | Total number of reviews |
| `averageRating` | float | Average rating (rounded to 1 decimal, e.g. 4.5) |
| `ratingDistribution` | object | Count of reviews for each rating level |

**`ratingDistribution`** - How many reviews each rating received

| Key | Type | Description |
|-----|------|-------------|
| `1` | integer | Number of 1-star reviews |
| `2` | integer | Number of 2-star reviews |
| `3` | integer | Number of 3-star reviews |
| `4` | integer | Number of 4-star reviews |
| `5` | integer | Number of 5-star reviews |

**`reviews[]`** - Array of review objects (newest first)

| Field | Type | Description |
|-------|------|-------------|
| `_id` | string | Review ID |
| `rating` | integer | Rating (1-5) |
| `comment` | string | Review text |
| `createdAt` | string (ISO 8601) | When the review was created |
| `reviewer._id` | string | Reviewer's user ID |
| `reviewer.fullName` | string | Reviewer's full name |
| `reviewer.username` | string | Reviewer's username |
| `reviewer.avatar` | string | Reviewer's avatar URL |
| `reviewer.email` | string | Reviewer's email address |

**`meta`** - Pagination info

| Field | Type | Description |
|-------|------|-------------|
| `page` | integer | Current page number |
| `limit` | integer | Items per page |
| `total` | integer | Total number of reviews |
| `totalPage` | integer | Total number of pages |

---

### 3. Event Detail Response (Updated)

Both `GET /api/v1/events/:eventId` and `GET /api/v1/circles/:circleId/events/:eventId` now include a `review` field in the response.

#### New Field: `review`

```json
{
  "...other event fields...",
  "hostDetails": {
    "fullName": "Event Host",
    "username": "eventhost",
    "avatar": "https://...",
    "averageRating": 4.5,
    "reviewCount": 111
  },
  "review": {
    "totalReviews": 111,
    "averageRating": 4.5
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `review.totalReviews` | integer | Total number of reviews for this event |
| `review.averageRating` | float | Average rating for this event |

---

## Error Response Format

All errors follow this format:

```json
{
  "success": false,
  "message": "Error message here",
  "errorSources": []
}
```

---

## Eligibility Rules

1. **Ticket Required**: Only users with an active ticket (`status: "active"`) for the event can leave a review
2. **One Review Per User**: Each user can only review an event once (enforced by unique database index)
3. **Any Ticket Status**: Active, cancelled, or refunded tickets are checked -- only `active` tickets qualify
4. **Both Event Types**: Works for both public events and circle events

---

## Caching Behavior

- Review summaries and lists are cached in Redis for **120 seconds**
- After creating a new review, caches are automatically invalidated
- Event detail responses query the database directly (no cache delay)

---

## Data Model Reference

### Review Document

```
{
  _id:          ObjectId (auto-generated)
  eventId:      ObjectId -> Event (required)
  reviewerId:   ObjectId -> User (required)
  hostId:       ObjectId -> User (required, denormalized)
  rating:       Number 1-5 (required)
  comment:      String (required)
  createdAt:    Date (auto)
  updatedAt:    Date (auto)
}
```

### Indexes

| Index | Type | Purpose |
|-------|------|---------|
| `{ eventId: 1, reviewerId: 1 }` | Unique | Prevent duplicate reviews |
| `{ eventId: 1, createdAt: -1 }` | Non-unique | Fast review listing by event |
| `{ hostId: 1, createdAt: -1 }` | Non-unique | Host rating aggregation |

---

## Frontend Implementation Notes

### Review Card Widget

For each review in the list, display:
- **Reviewer avatar** (circular, ~40px)
- **Reviewer full name** (bold)
- **Reviewer email** (smaller, gray)
- **Time ago** (e.g., "4 months ago" from `createdAt`)
- **Star rating** (filled/empty stars, 1-5)
- **Comment text**

### Summary Section

At the top of the reviews page, display:
- **Large average rating number** (e.g., "4.8")
- **Star visualization** (e.g., 5 filled stars based on average)
- **Total review count** (e.g., "(4.8k reviews)")
- **Rating distribution bars** (horizontal bars for each rating 1-5, width proportional to count)

### Rating Distribution Bar Width

To calculate bar width as a percentage:

```
barWidthPercentage = (countForRating / maxCountAmongAllRatings) * 100
```

This ensures the highest-rated bar is always 100% width, and others scale proportionally.

### "Write a Review" Button

Show the "Write a Review" button only if:
1. The user has an active ticket for this event
2. The user has NOT already reviewed this event

Note: You may need a separate check or include this info in a future endpoint. For now, attempt to create a review and handle the 409 (already reviewed) error gracefully.

### Pagination

The reviews list is paginated. Use `page` and `limit` query params. The `meta.totalPage` tells you how many pages exist. Implement "Load More" or infinite scroll as needed.
