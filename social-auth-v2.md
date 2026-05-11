# Social Login API v2 (MVP)

## Endpoint

```
POST /api/v1/auth/social-login
```

## Providers

| Provider   | What to send                  | Verified by backend? |
|------------|-------------------------------|----------------------|
| Google     | `email`, `fullName`, `avatar` | No (trust client)    |
| Apple      | `email`, `fullName`, `avatar` | No (trust client)    |
| Facebook   | `accessToken`                 | Yes (Graph API)      |

---

## Google Login

After the user signs in with Google on the device, send the user's info directly. No ID token needed.

### Request

```json
{
  "provider": "google",
  "email": "user@gmail.com",
  "fullName": "John Doe",
  "avatar": "https://lh3.googleusercontent.com/photo.jpg"
}
```

| Field      | Type   | Required | Notes                              |
|------------|--------|----------|------------------------------------|
| provider   | string | yes      | Must be `"google"`                 |
| email      | string | yes      | User's Google email                |
| fullName   | string | no       | User's display name                |
| avatar     | string | no       | URL to profile picture             |

### Mobile flow

1. User taps "Sign in with Google"
2. Google SDK returns user profile (email, name, photo URL)
3. Send those fields to `POST /api/v1/auth/social-login`
4. Done

---

## Apple Login

Same as Google — send the user info directly. Apple only provides the full name on the first sign-in, so cache it on the device if needed.

### Request

```json
{
  "provider": "apple",
  "email": "user@privaterelay.appleid.com",
  "fullName": "Jane Doe",
  "avatar": null
}
```

| Field      | Type   | Required | Notes                                          |
|------------|--------|----------|------------------------------------------------|
| provider   | string | yes      | Must be `"apple"`                              |
| email      | string | yes      | User's Apple email (may be a relay address)    |
| fullName   | string | no       | Only available on first authorization           |
| avatar     | string | no       | Apple does not provide an avatar                |

### Mobile flow

1. User taps "Sign in with Apple"
2. Apple SDK returns identity token + user info (on first auth)
3. Extract email and fullName from the response
4. Send to `POST /api/v1/auth/social-login`
5. Cache `fullName` locally — Apple won't send it again

---

## Facebook Login

Facebook still requires a valid access token. The backend verifies it against the Facebook Graph API.

### Request

```json
{
  "provider": "facebook",
  "accessToken": "EAAI..."
}
```

| Field       | Type   | Required | Notes                        |
|-------------|--------|----------|------------------------------|
| provider    | string | yes      | Must be `"facebook"`         |
| accessToken | string | yes      | Facebook user access token   |

### Mobile flow

1. User taps "Sign in with Facebook"
2. Facebook SDK returns an access token
3. Send the token to `POST /api/v1/auth/social-login`
4. Backend verifies the token and fetches profile from Facebook

---

## Response

### Success (existing user) — `200 OK`

```json
{
  "success": true,
  "message": "google login successful",
  "data": {
    "accessToken": "eyJhbGci...",
    "refreshToken": "eyJhbGci...",
    "user": { ... },
    "isCompleteProfile": true,
    "isNewUser": false
  }
}
```

### Success (new user) — `201 Created`

```json
{
  "success": true,
  "message": "google login successful",
  "data": {
    "accessToken": "eyJhbGci...",
    "refreshToken": "eyJhbGci...",
    "user": { ... },
    "isCompleteProfile": false,
    "isNewUser": true
  }
}
```

### Key response fields

| Field             | Type    | Description                                      |
|-------------------|---------|--------------------------------------------------|
| accessToken       | string  | JWT access token — use for authenticated requests |
| refreshToken      | string  | Use to refresh the access token                  |
| user              | object  | Full user profile object                         |
| isCompleteProfile | boolean | Whether the user has completed their profile      |
| isNewUser         | boolean | `true` if this was a registration, `false` if login |

---

## Error Responses

### `400 Bad Request` — missing required field

```json
{
  "success": false,
  "message": "Email is required when provider is google"
}
```

### `401 Unauthorized` — account not active

```json
{
  "success": false,
  "message": "Your account is not active"
}
```

---

## Notes

- Google and Apple logins are email-based. If a user already has an account with the same email, the social provider gets linked to the existing account automatically.
- Social login users skip email/phone verification — their email is auto-verified.
- Facebook requires the `FACEBOOK_APP_ID` and `FACEBOOK_APP_SECRET` env vars to be configured on the backend. Contact the backend team to set these up.
