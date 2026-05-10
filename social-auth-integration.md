# Social Auth Integration

## Overview

The backend now exposes a dedicated social login endpoint that verifies Google, Apple, and Facebook tokens server-side before issuing Bonded JWTs.

Existing email/password login remains unchanged:

- `POST /api/v1/auth/login` for email or phone + password
- `POST /api/v1/auth/social-login` for Google, Apple, and Facebook

Do not send trusted profile data instead of provider tokens. The backend only trusts the provider token verification result for identity fields such as provider ID and email.

## Endpoint

`POST /api/v1/auth/social-login`

## Supported Request Fields

The endpoint accepts both camelCase and snake_case token field names to reduce frontend changes.

Common fields:

- `provider`: `google`, `apple`, or `facebook`
- `fullName` or `full_name`: optional profile hint, mainly useful for Apple first-time sign-in
- `avatar`: optional profile hint

Device metadata is accepted and ignored for now:

- `deviceId` / `device_id`
- `deviceType` / `device_type`
- `deviceName` / `device_name`
- `appVersion` / `app_version`

## Provider Payloads

### Google

Preferred payload:

```json
{
  "provider": "google",
  "idToken": "GOOGLE_ID_TOKEN"
}
```

Also accepted:

```json
{
  "provider": "google",
  "id_token": "GOOGLE_ID_TOKEN"
}
```

### Facebook

```json
{
  "provider": "facebook",
  "accessToken": "FACEBOOK_ACCESS_TOKEN"
}
```

Also accepted:

```json
{
  "provider": "facebook",
  "access_token": "FACEBOOK_ACCESS_TOKEN"
}
```

### Apple

```json
{
  "provider": "apple",
  "identityToken": "APPLE_IDENTITY_TOKEN",
  "fullName": "Jane Doe"
}
```

Also accepted:

```json
{
  "provider": "apple",
  "identity_token": "APPLE_IDENTITY_TOKEN",
  "authorization_code": "OPTIONAL_APPLE_AUTH_CODE",
  "full_name": "Jane Doe"
}
```

## Backend Behavior

1. The backend verifies the provider token with Google, Apple, or Facebook.
2. If the provider ID is already linked to an existing account, the backend logs that user in.
3. If no provider ID match exists but the provider returns a trusted verified email that matches an existing account, the backend links that provider to the existing account.
4. Otherwise, the backend creates a new account and returns Bonded access and refresh tokens.

## Account Linking Rules

- Linking only happens when the provider returns a trusted email and that email is considered verified by the provider flow.
- Existing email/password users can add Google, Apple, or Facebook login without creating duplicate accounts.
- Existing profile fields such as `fullName` and `avatar` are only backfilled when blank; social login does not overwrite user-edited profile data.

## Response Shape

The endpoint returns the same auth token structure used by the current auth module:

```json
{
  "success": true,
  "message": "google login successful",
  "data": {
    "accessToken": "APP_ACCESS_TOKEN",
    "refreshToken": "APP_REFRESH_TOKEN",
    "user": {
      "_id": "...",
      "email": "user@example.com",
      "fullName": "Jane Doe",
      "avatar": "https://..."
    },
    "isCompleteProfile": false,
    "isNewUser": true
  }
}
```

## Provider Notes

- Google login requires an ID token. Access token-only login is not supported.
- Facebook login uses the Graph API to validate the user access token against the configured app.
- Apple may only return email and name on the first successful sign-in. The frontend should send `fullName` when Apple provides it so the backend can store it during first account creation.

## Required Environment Variables

Set these in the backend environment before enabling social login in the app:

```env
GOOGLE_OAUTH_CLIENT_IDS=...
APPLE_SIGN_IN_CLIENT_IDS=...
FACEBOOK_APP_ID=...
FACEBOOK_APP_SECRET=...
```