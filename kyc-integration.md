# Bonded Creator Verification - App Integration Guide

> Audience: mobile app / frontend developers
> Scope: creator verification fee, purchase verification, and Stripe Connect onboarding
> Not covered here: admin setup of Apple/Google product IDs and webhook delivery

This document replaces the old selfie/document KYC flow.

The active creator verification flow is now:

- pay the creator verification fee through Apple or Google billing
- verify that purchase with the backend
- finish Stripe Connect onboarding

The user only becomes a verified creator after both steps are complete.

## 1. Routes Used By The App

Base URL:

```text
{{url}} = https://YOUR_HOST/api/v1
```

Private routes in this guide require:

```http
Authorization: Bearer ACCESS_TOKEN
```

Public routes in this guide:

- `GET {{url}}/store-products?purpose=creator-verification&platform=apple`
- `GET {{url}}/store-products?purpose=creator-verification&platform=google`

Main routes:

- `GET {{url}}/kyc/me`
- `GET {{url}}/store-products?purpose=creator-verification&platform=apple`
- `GET {{url}}/store-products?purpose=creator-verification&platform=google`
- `POST {{url}}/kyc/me/verification/verify-purchase`
- `POST {{url}}/stripe-connect/me`
- `GET {{url}}/stripe-connect/me/status`
- `GET {{url}}/user/me`

Routes the new app flow should not use anymore:

- `POST {{url}}/kyc/me/selfie`
- `POST {{url}}/kyc/me/document`

## 2. Verification Status Values

`creatorVerificationStatus` uses these values:

- `unpaid`: the user has not completed the verification fee purchase
- `fee_paid`: the purchase was verified, but Stripe Connect has not started yet
- `connect_pending`: the purchase was verified and a Stripe account exists, but onboarding is not complete yet
- `verified`: fee purchase is verified and Stripe Connect is fully completed
- `suspended`: reserved for future enforcement cases

Recommended frontend rule:

- treat the user as payout-ready only when `creatorVerificationStatus === "verified"` and `payoutEligible === true`

## 3. Step 1 - Load The Current Verification State

Use `GET {{url}}/kyc/me` to decide what screen or CTA to show.

Example request:

```http
GET /api/v1/kyc/me
Authorization: Bearer ACCESS_TOKEN
```

Example success response:

```json
{
  "success": true,
  "message": "KYC status fetched",
  "data": {
    "creatorVerificationStatus": "unpaid",
    "creatorVerificationFeePaidAt": null,
    "creatorVerificationFeePlatform": null,
    "creatorVerificationTransactionId": null,
    "stripeConnectCompletedAt": null,
    "creatorVerifiedAt": null,
    "payoutEligible": false,
    "stripeConnect": {
      "connected": false,
      "chargesEnabled": false,
      "payoutsEnabled": false,
      "detailsSubmitted": false,
      "accountId": null,
      "creatorVerificationStatus": "unpaid",
      "payoutEligible": false
    },
    "verificationFee": {
      "amount": 9.99,
      "currency": "USD",
      "purchasePurpose": "creator-verification"
    }
  }
}
```

Field meanings:

- `creatorVerificationStatus`: the current backend-owned state machine value
- `creatorVerificationFeePaidAt`: when the store fee was accepted by the backend
- `creatorVerificationFeePlatform`: `apple` or `google`
- `creatorVerificationTransactionId`: the purchase ID the backend stored
- `stripeConnectCompletedAt`: when Stripe Connect became fully usable
- `creatorVerifiedAt`: when the user first became fully verified
- `payoutEligible`: whether payouts are allowed right now
- `verificationFee.amount` and `verificationFee.currency`: display values for the paywall screen

## 4. Step 2 - Fetch The Store Product ID

The verification fee product ID is admin-managed. The app should fetch it from the product catalog instead of hardcoding it.

Apple example:

```http
GET /api/v1/store-products?purpose=creator-verification&platform=apple
```

Google example:

```http
GET /api/v1/store-products?purpose=creator-verification&platform=google
```

Example response:

```json
{
  "success": true,
  "message": "Active store products fetched successfully",
  "data": [
    {
      "_id": "6820a1234567890abcdef111",
      "platform": "apple",
      "purpose": "creator-verification",
      "productType": "consumable",
      "productId": "bonded.creator.verification.9_99",
      "displayName": "Creator Verification",
      "description": "One-time verification fee",
      "price": 9.99,
      "currency": "USD",
      "billingInterval": null,
      "planCode": null,
      "isActive": true,
      "createdAt": "2026-05-07T11:00:00.000Z",
      "updatedAt": "2026-05-07T11:00:00.000Z"
    }
  ]
}
```

Frontend rule:

- use `productId` from this response when starting the native Apple or Google purchase
- do not hardcode the verification fee SKU in the client

## 5. Step 3 - Run The Native Store Purchase

The actual purchase happens in the native billing SDK.

Backend does not start the Apple or Google payment sheet for you.

The app should:

1. fetch the active product from `/store-products`
2. open the native purchase flow using that `productId`
3. wait for the native SDK to return the completed transaction token
4. send that token to the backend

Required native output to send back:

- Apple: `appleTransactionId`
- Google: `googlePurchaseToken`

## 6. Step 4 - Verify The Purchase With The Backend

After the native purchase succeeds, call:

```http
POST /api/v1/kyc/me/verification/verify-purchase
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
```

Apple request body:

```json
{
  "platform": "apple",
  "appleTransactionId": "2000000899991111"
}
```

Google request body:

```json
{
  "platform": "google",
  "googlePurchaseToken": "abcd1234-google-purchase-token"
}
```

Example success response:

```json
{
  "success": true,
  "message": "Creator verification purchase verified successfully",
  "data": {
    "purchase": {
      "purchaseId": "6820b1234567890abcdef222",
      "status": "verified",
      "platform": "apple",
      "productId": "bonded.creator.verification.9_99",
      "transactionId": "2000000899991111",
      "verifiedAt": "2026-05-07T11:20:00.000Z",
      "stripeConnect": {
        "connected": false,
        "chargesEnabled": false,
        "payoutsEnabled": false,
        "detailsSubmitted": false,
        "accountId": null,
        "creatorVerificationStatus": "fee_paid",
        "payoutEligible": false
      }
    },
    "status": {
      "creatorVerificationStatus": "fee_paid",
      "creatorVerificationFeePaidAt": "2026-05-07T11:20:00.000Z",
      "creatorVerificationFeePlatform": "apple",
      "creatorVerificationTransactionId": "2000000899991111",
      "stripeConnectCompletedAt": null,
      "creatorVerifiedAt": null,
      "payoutEligible": false,
      "stripeConnect": {
        "connected": false,
        "chargesEnabled": false,
        "payoutsEnabled": false,
        "detailsSubmitted": false,
        "accountId": null,
        "creatorVerificationStatus": "fee_paid",
        "payoutEligible": false
      },
      "verificationFee": {
        "amount": 9.99,
        "currency": "USD",
        "purchasePurpose": "creator-verification"
      }
    }
  }
}
```

Possible `purchase.status` values from the backend:

- `verified`: first successful verification
- `already_processed`: the purchase was already accepted earlier

Frontend rule:

- after success, change the CTA from `Pay verification fee` to `Continue Stripe setup`

## 7. Step 5 - Start Stripe Connect Onboarding

After fee verification succeeds, call:

```http
POST /api/v1/stripe-connect/me
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
```

Empty body is fine:

```json
{}
```

Example success response:

```json
{
  "success": true,
  "message": "Stripe connect onboarding link generated",
  "data": {
    "accountId": "acct_1ABCDEF123456789",
    "onboardingUrl": "https://connect.stripe.com/setup/s/abc123",
    "expiresAt": "2026-05-07T12:00:00.000Z"
  }
}
```

Frontend rule:

- open `onboardingUrl` in webview or external browser
- after the user returns, refresh `GET /stripe-connect/me/status`

If the user tries this before the purchase is verified, backend returns `403`.

## 8. Step 6 - Poll Stripe Connect Status

Use:

```http
GET /api/v1/stripe-connect/me/status
Authorization: Bearer ACCESS_TOKEN
```

Example response after onboarding is complete:

```json
{
  "success": true,
  "message": "Stripe connect status fetched",
  "data": {
    "connected": true,
    "chargesEnabled": true,
    "payoutsEnabled": true,
    "detailsSubmitted": true,
    "accountId": "acct_1ABCDEF123456789",
    "creatorVerificationStatus": "verified",
    "payoutEligible": true
  }
}
```

Frontend rule:

- treat the creator as verified only when this route reports `creatorVerificationStatus: "verified"` and `payoutEligible: true`

## 9. Fields Also Returned In `/user/me`

The main profile response now includes the creator verification fields too.

Relevant fields to watch in `GET {{url}}/user/me`:

- `creatorVerificationStatus`
- `creatorVerificationFeePaidAt`
- `creatorVerificationFeePlatform`
- `creatorVerificationTransactionId`
- `stripeConnectCompletedAt`
- `creatorVerifiedAt`
- `payoutEligible`

Use `/user/me` when the app already needs the full profile. Use `/kyc/me` when the screen only cares about verification state.

## 10. UI Recommendations

- show creator verification as a 2-step checklist: `Pay verification fee` and `Finish Stripe Connect`
- do not show selfie upload or document upload in the new app flow
- after purchase verification, show a persistent `Continue Stripe setup` CTA until onboarding is complete
- unlock paid creator actions only after `creatorVerificationStatus === "verified"`
- if `payoutEligible === false`, do not show payout actions

## 11. Common Error Cases

- `403`: verification fee must be paid before Stripe Connect onboarding can begin
- `400`: Apple or Google receipt/token is missing or invalid
- `404`: store product not found or user not found
- `already_processed`: the purchase was already accepted before

## 12. Minimal Client Checklist

Before release, the app should support all of the following:

- fetch current creator verification state from `GET /kyc/me`
- fetch active Apple and Google creator verification products from `/store-products`
- run native Apple purchase flow
- run native Google purchase flow
- verify Apple purchase with `POST /kyc/me/verification/verify-purchase`
- verify Google purchase with `POST /kyc/me/verification/verify-purchase`
- launch Stripe Connect from `POST /stripe-connect/me`
- poll `GET /stripe-connect/me/status`
- refresh `/user/me` after verification state changes
- hide the old selfie/document UI from the new app flow