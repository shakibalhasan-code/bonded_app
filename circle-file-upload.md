# Bonded Circle Post File Upload - Developer Guide

> Audience: mobile app / frontend developers
> Scope: circle post and comment creation endpoints and their file upload behaviour
> Not covered here: circle cover image upload, event highlights, chat media

This document explains how to attach media and arbitrary files when creating a circle post or comment, including the field names, size limits, response shape, and required environment variables.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Authentication](#2-authentication)
3. [Endpoint](#3-endpoint)
4. [Request Format](#4-request-format)
5. [Supported Fields](#5-supported-fields)
6. [Response Shape](#6-response-shape)
7. [S3 URL Structure](#7-s3-url-structure)
8. [Size Limits](#8-size-limits)
9. [Environment Variables](#9-environment-variables)
10. [Frontend Integration Checklist](#10-frontend-integration-checklist)
11. [Error Reference](#11-error-reference)

---

## 1. Overview

Circle posts and comments support mixed-media attachments: images, videos, audio, and any arbitrary file (PDF, ZIP, DOCX, etc.).

Uploaded files are stored directly in S3. The API response returns HTTPS S3 URLs — there are no local paths in any post response.

**What changed in this release:**

- Any file type is now accepted via the `file` multipart field (previously only image / video / audio were supported)
- Attachment URLs in responses are now S3 HTTPS URLs (`https://{bucket}.s3.{region}.amazonaws.com/...`) instead of relative `uploads/` paths
- Temp files are deleted from the server immediately after upload to S3

**What did NOT change:**

- The response schema shape — same field names and nesting as before
- Endpoint path, method, and auth requirements
- Image / video / audio field names and behaviour

---

## 2. Authentication

All circle post endpoints are private.

Required header:

```http
Authorization: Bearer ACCESS_TOKEN
```

---

## 3. Endpoint

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/circles/:circleId/posts` | Create a circle post with optional media |
| `POST` | `/api/v1/circles/:circleId/posts/:postId/comments` | Create a comment/reply with optional media |

**Path parameter:**

| Parameter | Type | Description |
| --- | --- | --- |
| `circleId` | string (ObjectId) | The circle where the post/comment is created. The authenticated user must be an accepted member. |
| `postId` | string (ObjectId) | Required only for comment creation endpoint. |

---

## 4. Request Format

The request must be sent as `multipart/form-data`. JSON-only (application/json) is not supported when attaching files.

```http
Content-Type: multipart/form-data
```

### Fields

| Field name | Type | Required | Notes |
| --- | --- | --- | --- |
| `content` | text (string) | No | Post body text. May be omitted if at least one file is attached. |
| `image` | file | No | One or more images (JPEG, PNG, WEBP, HEIC, AVIF, TIFF). Max per file: configurable (default 10 MB). |
| `video` | file | No | One or more videos (MP4, MOV, WEBM, AVI, MPEG). Max per file: configurable (default 100 MB). |
| `audio` | file | No | One or more audio files (MP3, WAV, AAC, M4A, OGG). Max per file: configurable (default 50 MB). |
| `file` | file | No | One or more files of **any MIME type** (PDF, ZIP, DOCX, etc.). Max per file: configurable (default 50 MB). |

Notes:

- All four file fields may be combined in a single request (e.g. one image + one PDF).
- The server enforces a maximum of 10 files per field name.

### Example (curl)

```bash
curl -X POST https://api.example.com/api/v1/circles/CIRCLE_ID/posts \
  -H "Authorization: Bearer ACCESS_TOKEN" \
  -F "content=Check out this document" \
  -F "file=@/path/to/report.pdf" \
  -F "image=@/path/to/photo.jpg"
```

---

## 5. Supported Fields

### `image` — images only

Accepted MIME types: `image/jpeg`, `image/png`, `image/jpg`, `image/heif`, `image/heic`, `image/tiff`, `image/webp`, `image/avif`

### `video` — videos only

Accepted MIME types: `video/mp4`, `video/quicktime`, `video/webm`, `video/x-msvideo`, `video/mpeg`

### `audio` — audio only

Accepted MIME types: `audio/mpeg`, `audio/wav`, `audio/aac`, `audio/mp4`, `audio/x-m4a`, `audio/ogg`

### `file` — any MIME type

No MIME restriction. Use this field for documents, archives, spreadsheets, or any file that does not fit the typed fields above. The backend stores the original MIME type reported by the client.

---

## 6. Response Shape

```json
{
  "success": true,
  "statusCode": 201,
  "message": "Post created successfully",
  "data": {
    "_id": "684a1c2f9e4b0a12f34c5678",
    "circle": "6818a8b9d3f0c57f7e0c1111",
    "author": "6818a899d3f0c57f7e0c1001",
    "content": "Check out this document",
    "media": [
      {
        "url": "https://my-bucket.s3.eu-west-1.amazonaws.com/circles/6818a8b9.../posts/files/3f9b1e2a-....pdf",
        "type": "file",
        "mimeType": "application/pdf",
        "size": 204800
      },
      {
        "url": "https://my-bucket.s3.eu-west-1.amazonaws.com/circles/6818a8b9.../posts/images/a1b2c3d4-....jpg",
        "type": "image",
        "mimeType": "image/jpeg",
        "size": 98304
      }
    ],
    "likesCount": 0,
    "commentsCount": 0,
    "createdAt": "2025-06-12T10:30:00.000Z",
    "updatedAt": "2025-06-12T10:30:00.000Z"
  }
}
```

### `media` array item fields

| Field | Type | Values | Description |
| --- | --- | --- | --- |
| `url` | string | HTTPS S3 URL | Direct URL to the uploaded file. |
| `type` | string | `"image"` \| `"video"` \| `"audio"` \| `"file"` | Media category — determined by which multipart field the file was sent on. |
| `mimeType` | string | e.g. `"application/pdf"` | Original MIME type reported by the client. |
| `size` | number | bytes | File size in bytes as stored. |

> `thumbnailUrl` may also appear on video items if a thumbnail was generated (not currently enabled).

---

## 7. S3 URL Structure

Files are stored in S3 under the following key patterns:

| Field | S3 key pattern |
| --- | --- |
| `image` | `circles/{circleId}/posts/images/{uuid}.{ext}` |
| `video` | `circles/{circleId}/posts/videos/{uuid}.{ext}` |
| `audio` | `circles/{circleId}/posts/audio/{uuid}.{ext}` |
| `file` | `circles/{circleId}/posts/files/{uuid}.{ext}` |

Full URL format: `https://{BUCKET}.s3.{REGION}.amazonaws.com/{key}`

Each file gets a globally unique UUID filename (via `crypto.randomUUID()`), so collisions are not possible even without including the post ID in the path.

---

## 8. Size Limits

Per-file size limits are configurable via environment variables (see section 9). Defaults:

| Field | Default limit |
| --- | --- |
| `image` | 10 MB |
| `video` | 100 MB |
| `audio` | 50 MB |
| `file` | 50 MB |

If a file exceeds its field limit the server returns HTTP 400 with a descriptive message:

```json
{
  "success": false,
  "statusCode": 400,
  "message": "\"report.pdf\" exceeds the file size limit of 50MB"
}
```

---

## 9. Environment Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `AWS_ACCESS_KEY_ID` | **Yes** | — | AWS IAM key with S3 `PutObject` and `DeleteObject` permissions. |
| `AWS_SECRET_ACCESS_KEY` | **Yes** | — | AWS IAM secret key. |
| `AWS_REGION` | **Yes** | — | AWS region where the bucket lives, e.g. `eu-west-1`. |
| `AWS_S3_BUCKET` | **Yes** | — | S3 bucket name. |
| `UPLOAD_FILE_MAX_MB` | No | `50` | Per-file size cap for the `file` field (arbitrary files). Integer MB. |
| `UPLOAD_IMAGE_MAX_MB` | No | `10` | Per-file size cap for `image`. |
| `UPLOAD_VIDEO_MAX_MB` | No | `100` | Per-file size cap for `video`. |
| `UPLOAD_AUDIO_MAX_MB` | No | `50` | Per-file size cap for `audio`. |

All four AWS variables must be set. If any are missing the S3 upload will fail at runtime.

---

## 10. Frontend Integration Checklist

- [ ] Use `multipart/form-data` encoding — **not** `application/json`
- [ ] Send images on field name `image`, videos on `video`, audio on `audio`
- [ ] Send any other file type (PDF, ZIP, DOCX, etc.) on field name **`file`**
- [ ] Do not set the `Content-Type` header manually — let the HTTP client set it with the multipart boundary
- [ ] `content` text field is optional if at least one file is attached
- [ ] `media[].url` values are now HTTPS S3 URLs — render them directly (no base URL prepend needed)
- [ ] `media[].type` tells you how to render the item: `"image"` → `<img>`, `"video"` → `<video>`, `"audio"` → `<audio>`, `"file"` → download link / document viewer
- [ ] Show file name using the filename from your local picker — the server does not preserve the original filename in the URL
- [ ] No changes needed on read paths (GET endpoints for posts) — the response shape is identical

---

## 11. Error Reference

| HTTP status | `message` excerpt | Cause |
| --- | --- | --- |
| `400` | `Unsupported image type` | Wrong MIME on `image` field |
| `400` | `Unsupported video type` | Wrong MIME on `video` field |
| `400` | `Unsupported audio type` | Wrong MIME on `audio` field |
| `400` | `exceeds the ... size limit of ...MB` | File is too large for its field |
| `400` | `Too many files uploaded for field` | More than 10 files on a single field |
| `401` | `Unauthorized` | Missing or invalid Bearer token |
| `403` | `Forbidden` | User is not an accepted member of the circle |
| `500` | `Internal server error` | S3 upload failure (check AWS credentials and bucket policy) |
