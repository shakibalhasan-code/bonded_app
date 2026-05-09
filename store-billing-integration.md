# Bonded Store Billing - Frontend Integration Guide

> Audience: mobile app / frontend developers
> Scope: paid circles, paid events, Stripe in-person settlement, product catalog lookup, and shared Apple/Google verification
> Not covered here: admin dashboard setup and Stripe dashboard operations

This guide explains the active digital billing architecture so the frontend can integrate without reading Postman collections.

Important billing scope:

- digital purchases in this backend use Apple App Store billing and Google Play billing receipt verification
- this is not a card-wallet Apple Pay or Google Pay charge flow through Stripe

## 1. Platform Rules

Use this table as the source of truth for which payment system to show.

| Feature | Free case | Paid case | Payment system |
| --- | --- | --- | --- |
| Circle join | direct join | approved tier required | Apple / Google store billing |
| Public event booking | confirm immediately | depends on event type | Stripe for in-person, Apple / Google for virtual / bonded_live |
| Circle event booking | confirm immediately | depends on event type | Stripe for in-person, Apple / Google for virtual / bonded_live |
| Creator verification fee | not applicable | one-time fee | Apple / Google store billing |
| Host Pro subscription | not applicable | recurring product | Apple / Google store billing |

Important backend rules:

- paid circles and paid virtual or bonded_live events must use approved price tiers
- in-person paid events still use Stripe
- store-billed virtual and bonded_live bookings can use quantities greater than `1`, but the verified Apple or Google purchase quantity must match the booking quantity exactly

## 2. Shared Catalog Endpoints

Base URL:

```text
{{url}} = https://YOUR_HOST/api/v1
```

Private routes in this guide require:

```http
Authorization: Bearer ACCESS_TOKEN
```

Public routes in this guide:

- `GET /api/v1/store-products/tiers`
- `GET /api/v1/store-products`
- `GET /api/v1/store-products/resolve`

### 2.1 Get approved digital tiers

```http
GET /api/v1/store-products/tiers
```

Example response:

```json
{
  "success": true,
  "message": "Approved digital price tiers fetched successfully",
  "data": [4.99, 9.99, 14.99, 19.99]
}
```

Use this for creator-side pricing pickers.

### 2.2 List active products for a purpose

Examples:

```http
GET /api/v1/store-products?purpose=circle-join&platform=apple
GET /api/v1/store-products?purpose=virtual-event-ticket&platform=google
```

Example response:

```json
{
  "success": true,
  "message": "Active store products fetched successfully",
  "data": [
    {
      "_id": "6820c1234567890abcdef333",
      "platform": "apple",
      "purpose": "circle-join",
      "productType": "consumable",
      "productId": "bonded.circle.join.9_99",
      "displayName": "Circle Access",
      "description": "Join one paid circle",
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

### 2.3 Resolve a single product for a platform and price

Use this when the app wants to pre-resolve a tier before submission.

```http
GET /api/v1/store-products/resolve?platform=apple&purpose=virtual-event-ticket&price=9.99
```

Example response:

```json
{
  "success": true,
  "message": "Store product resolved successfully",
  "data": {
    "product": {
      "platform": "apple",
      "purpose": "virtual-event-ticket",
      "productType": "consumable",
      "productId": "bonded.virtual.ticket.9_99",
      "displayName": "Virtual Event Ticket",
      "description": "One virtual event ticket",
      "price": 9.99,
      "currency": "USD",
      "billingInterval": null,
      "planCode": null,
      "isActive": true,
      "createdAt": "2026-05-07T11:00:00.000Z",
      "updatedAt": "2026-05-07T11:00:00.000Z"
    },
    "normalization": {
      "submittedPrice": 9.99,
      "normalizedPrice": 9.99,
      "exactMatch": true,
      "approvedTiers": [4.99, 9.99, 14.99, 19.99]
    }
  }
}
```

Frontend note:

- for paid circle joins and paid virtual-event bookings, prefer the dedicated booking and join endpoints because they also return the correct `referenceId`

## 3. Paid Circle Join Flow

### Step 1 - Ask the backend which store products to show

The route path is legacy, but the response is no longer a Stripe PaymentIntent.

```http
POST /api/v1/circles/:circleId/join/payment-intent
Authorization: Bearer ACCESS_TOKEN
```

No body is required.

Example response:

```json
{
  "success": true,
  "message": "Store purchase requirements fetched successfully",
  "data": {
    "paymentFlow": "store",
    "purpose": "circle-join",
    "referenceId": "6820d1234567890abcdef444",
    "amount": 9.99,
    "currency": "USD",
    "products": {
      "apple": {
        "platform": "apple",
        "productId": "bonded.circle.join.9_99",
        "displayName": "Circle Access",
        "price": 9.99,
        "currency": "USD"
      },
      "google": {
        "platform": "google",
        "productId": "bonded.circle.join.9_99.google",
        "displayName": "Circle Access",
        "price": 9.99,
        "currency": "USD"
      }
    },
    "verificationEndpoint": "/api/v1/iap/verify"
  }
}
```

### Step 2 - Run the native Apple or Google purchase

Use the platform-specific `productId` from the response above.

### Step 3 - Confirm the paid join with the backend

Apple request:

```http
POST /api/v1/circles/:circleId/join/confirm
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
```

```json
{
  "platform": "apple",
  "appleTransactionId": "2000000900011111"
}
```

Google request:

```json
{
  "platform": "google",
  "googlePurchaseToken": "circle-google-purchase-token"
}
```

Example success response:

```json
{
  "success": true,
  "message": "Paid circle purchase verified successfully",
  "data": {
    "purchaseId": "6820d2234567890abcdef555",
    "status": "verified",
    "platform": "apple",
    "productId": "bonded.circle.join.9_99",
    "transactionId": "2000000900011111",
    "circleId": "6820d1234567890abcdef444",
    "joined": true
  }
}
```

## 4. Public Event Booking Flow

Book a public event with:

```http
POST /api/v1/bookings/events/:eventId
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
```

Request body:

```json
{
  "quantity": 2
}
```

Possible backend behaviors:

- free event: booking is confirmed immediately
- paid in-person event: Stripe client secret is returned
- paid virtual or bonded_live event: Apple and Google product IDs are returned

### Free event response

```json
{
  "success": true,
  "message": "Booking created successfully",
  "data": {
    "bookingId": "6820e1234567890abcdef666",
    "status": "confirmed"
  }
}
```

### Paid in-person event response

```json
{
  "success": true,
  "message": "Booking created successfully",
  "data": {
    "bookingId": "6820e1234567890abcdef666",
    "status": "pending",
    "reservationExpiresAt": "2026-05-07T12:15:00.000Z",
    "paymentIntentId": "pi_123",
    "clientSecret": "pi_123_secret_456"
  }
}
```

### 4.1 Exact client completion flow for paid in-person events

1. Call the booking endpoint and store `bookingId`, `paymentIntentId`, `clientSecret`, and `reservationExpiresAt`.
2. Confirm the returned `clientSecret` in the Stripe mobile SDK.
3. After the Stripe SDK reports success, the preferred completion path is to let Stripe call `POST /api/v1/webhook/stripe` and allow the backend to settle the booking automatically.
4. If the app needs immediate backend sync right after Stripe success, call the manual settle endpoint below.

Manual settle request:

```http
POST /api/v1/payments/settle/stripe
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
```

```json
{
  "paymentIntentId": "pi_123"
}
```

Manual settle success response when the backend records the payment now:

```json
{
  "success": true,
  "message": "Payment settled successfully",
  "data": {
    "paymentIntentId": "pi_123",
    "status": "settled",
    "bookingId": "6820e1234567890abcdef666",
    "transactionId": "6821001234567890abcdef888"
  }
}
```

Manual settle response when Stripe or a previous manual call already created the transaction:

```json
{
  "success": true,
  "message": "Payment settled successfully",
  "data": {
    "paymentIntentId": "pi_123",
    "status": "already_settled",
    "transactionId": "6821001234567890abcdef888"
  }
}
```

Manual settle response when the PaymentIntent succeeded but the reservation expired before settlement:

```json
{
  "success": true,
  "message": "Payment settled successfully",
  "data": {
    "paymentIntentId": "pi_123",
    "status": "reservation_expired",
    "bookingId": "6820e1234567890abcdef666"
  }
}
```

Other possible `data.status` values from the same endpoint:

- `already_paid`: the booking was already marked paid before this call
- `ignored_booking_state`: the booking is no longer `pending`; the response also includes `bookingStatus`

Important backend behavior:

- if the PaymentIntent is not yet `succeeded`, the backend returns HTTP `400` with message `Payment is not completed yet`
- `POST /api/v1/payments/settle/stripe` is idempotent and safe to retry with the same `paymentIntentId`
- after a `settled`, `already_settled`, or `already_paid` result, the backend has already issued the ticket automatically

### 4.2 Stripe webhook outcomes for paid in-person events

Important:

- frontend must never call `POST /api/v1/webhook/stripe`
- Stripe sends this server-to-server request with the `Stripe-Signature` header and the raw request body
- when the signature is valid, the backend returns HTTP `200` with `success: true` for handled webhook outcomes, even when the booking result is `already_settled`, `ignored`, or `reservation_expired`

Webhook response when Stripe sends `payment_intent.succeeded` and the backend settles the booking:

```json
{
  "success": true,
  "message": "Stripe webhook handled",
  "data": {
    "received": true,
    "eventType": "payment_intent.succeeded",
    "result": {
      "paymentIntentId": "pi_123",
      "status": "settled",
      "bookingId": "6820e1234567890abcdef666",
      "transactionId": "6821001234567890abcdef888"
    }
  }
}
```

Webhook response when Stripe sends `payment_intent.succeeded` after the booking was already settled earlier:

```json
{
  "success": true,
  "message": "Stripe webhook handled",
  "data": {
    "received": true,
    "eventType": "payment_intent.succeeded",
    "result": {
      "paymentIntentId": "pi_123",
      "status": "already_settled",
      "transactionId": "6821001234567890abcdef888"
    }
  }
}
```

Webhook response when Stripe sends `payment_intent.payment_failed`:

```json
{
  "success": true,
  "message": "Stripe webhook handled",
  "data": {
    "received": true,
    "eventType": "payment_intent.payment_failed",
    "result": {
      "paymentIntentId": "pi_123",
      "status": "failed",
      "bookingId": "6820e1234567890abcdef666"
    }
  }
}
```

Webhook response when Stripe sends `payment_intent.payment_failed` after the booking was already moved out of `pending`:

```json
{
  "success": true,
  "message": "Stripe webhook handled",
  "data": {
    "received": true,
    "eventType": "payment_intent.payment_failed",
    "result": {
      "paymentIntentId": "pi_123",
      "status": "ignored"
    }
  }
}
```

Possible `data.result.status` values for `payment_intent.succeeded` webhook handling:

- `settled`
- `already_settled`
- `already_paid`
- `ignored_booking_state`
- `reservation_expired`

Client handling rules:

- `settled`, `already_settled`, `already_paid`: treat the booking as successful and open the success screen or fetch `/api/v1/tickets/my`
- `reservation_expired`: show that the reservation expired and ask the user to create a new booking
- `ignored_booking_state`: refresh app state before showing success because the booking is no longer in the normal pending flow
- `failed`: show payment failed and let the user retry by creating a new booking

### Paid virtual or bonded_live event response

```json
{
  "success": true,
  "message": "Booking created successfully",
  "data": {
    "bookingId": "6820e1234567890abcdef666",
    "status": "pending",
    "reservationExpiresAt": "2026-05-07T12:15:00.000Z",
    "paymentFlow": "store",
    "purpose": "virtual-event-ticket",
    "referenceId": "6820e1234567890abcdef666",
    "quantity": 2,
    "unitPrice": 9.99,
    "totalAmount": 19.98,
    "currency": "USD",
    "products": {
      "apple": {
        "platform": "apple",
        "productId": "bonded.virtual.ticket.9_99",
        "displayName": "Virtual Event Ticket",
        "price": 9.99,
        "currency": "USD"
      },
      "google": {
        "platform": "google",
        "productId": "bonded.virtual.ticket.9_99.google",
        "displayName": "Virtual Event Ticket",
        "price": 9.99,
        "currency": "USD"
      }
    },
    "verificationEndpoint": "/api/v1/iap/verify"
  }
}
```

Frontend rule:

- keep the booking `quantity` and the verified store purchase quantity aligned; the backend rejects mismatches
- do not treat Apple App Store billing or Google Play billing as a Stripe wallet flow

## 5. Circle Event Booking Flow

The circle event booking flow is the same as the public flow, but the route is:

```http
POST /api/v1/circles/:circleId/events/:eventId/bookings
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
```

Body:

```json
{
  "quantity": 2
}
```

Extra access rule:

- the user must already be an accepted member of the circle

If the circle event is paid and `type` is `in_person`, the response `data` shape matches the public paid in-person booking flow above. The only response-envelope difference is the top-level message:

```json
{
  "success": true,
  "message": "Circle event booking created successfully",
  "data": {
    "bookingId": "6820e1234567890abcdef666",
    "status": "pending",
    "reservationExpiresAt": "2026-05-07T12:15:00.000Z",
    "paymentIntentId": "pi_123",
    "clientSecret": "pi_123_secret_456"
  }
}
```

The same `POST /api/v1/payments/settle/stripe` and `POST /api/v1/webhook/stripe` outcomes described in section `4.1` and section `4.2` apply to circle in-person events.

## 6. Finalize A Virtual Ticket Purchase With The Shared IAP Route

After the native purchase finishes, call:

```http
POST /api/v1/iap/verify
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
```

Apple virtual ticket request:

```json
{
  "platform": "apple",
  "purpose": "virtual-event-ticket",
  "referenceId": "BOOKING_ID",
  "appleTransactionId": "2000000900022222"
}
```

Google virtual ticket request:

```json
{
  "platform": "google",
  "purpose": "virtual-event-ticket",
  "referenceId": "BOOKING_ID",
  "googlePurchaseToken": "virtual-event-google-token"
}
```

Example success response:

```json
{
  "success": true,
  "message": "Store purchase verified successfully",
  "data": {
    "purchaseId": "6820f1234567890abcdef777",
    "status": "verified",
    "platform": "apple",
    "productId": "bonded.virtual.ticket.9_99",
    "transactionId": "2000000900022222",
    "bookingId": "6820e1234567890abcdef666",
    "paid": true
  }
}
```

When this succeeds, backend marks the booking as paid and issues the ticket automatically.

## 7. Purchase History, Sales History, And Tickets

These routes are useful for profile, wallet, and order-history screens.

### 7.1 Purchase history

```http
GET /api/v1/payments/purchases?page=1&limit=20
Authorization: Bearer ACCESS_TOKEN
```

Supported query params:

- `page`
- `limit`
- `days`
- `startDate`
- `endDate`
- `provider` = `stripe | apple | google`
- `purpose` = `creator-verification | circle-join | virtual-event-ticket | host-pro-subscription`
- `status`

This route returns a buyer timeline that merges:

- Stripe event bookings
- free confirmed bookings
- Apple / Google creator verification purchases
- Apple / Google circle join purchases
- Apple / Google virtual event ticket purchases
- Apple / Google Host Pro subscriptions

Exact response envelope:

```json
{
  "success": true,
  "message": "Purchase history fetched successfully",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 2,
    "totalPage": 1
  },
  "data": [
    {
      "id": "store:6820f1234567890abcdef777",
      "source": "store-purchase",
      "purchaseType": "virtual-event-ticket",
      "provider": "apple",
      "status": "verified",
      "amount": 19.98,
      "unitAmount": 9.99,
      "currency": "USD",
      "quantity": 2,
      "productId": "bonded.virtual.ticket.9_99",
      "transactionId": "2000000900022222",
      "referenceId": "6820e1234567890abcdef666",
      "bookingId": "6820e1234567890abcdef666",
      "event": {
        "eventId": "6820d1234567890abcdef444",
        "title": "Founder Roundtable Live",
        "visibility": "public",
        "eventDate": "20/05/2026",
        "eventTime": "18:00-19:00",
        "venueName": null,
        "city": null,
        "country": null
      },
      "createdAt": "2026-05-07T12:02:10.000Z"
    },
    {
      "id": "booking:682101234567890abcdef999",
      "source": "booking",
      "purchaseType": "event-ticket",
      "provider": "stripe",
      "status": "paid",
      "amount": 29.98,
      "currency": "USD",
      "quantity": 2,
      "bookingId": "682101234567890abcdef999",
      "stripePaymentIntentId": "pi_123",
      "event": {
        "eventId": "6820aa234567890abcdef000",
        "title": "Founders Dinner",
        "visibility": "public",
        "eventDate": "22/05/2026",
        "eventTime": "19:00-21:00",
        "venueName": "Bonded Hall",
        "city": "New York",
        "country": "USA"
      },
      "createdAt": "2026-05-06T18:20:00.000Z"
    }
  ]
}
```

Frontend parsing rules:

- `source = booking` means a direct booking timeline item; these can be `provider = stripe` or `provider = free`
- `source = store-purchase` means an Apple or Google verified purchase
- free bookings return `status = free_confirmed` and `amount = 0`
- circle-join purchases return a `circle` object instead of an `event` object
- creator-verification and host-pro-subscription purchases do not include `event` or `circle`; subscriptions can include `expiresAt`

### 7.2 Sales history

```http
GET /api/v1/payments/sales?page=1&limit=20
Authorization: Bearer ACCESS_TOKEN
```

Supported query params:

- `page`
- `limit`
- `days`
- `startDate`
- `endDate`
- `provider` = `stripe | apple | google`
- `referenceType` = `event-ticket | circle-join | subscription | payout | refund | apple-iap`
- `status`

Common `status` values for this route come from the transaction ledger:

- `pending`
- `on_hold`
- `available`
- `paid_out`
- `failed`
- `refunded`

Exact response envelope:

```json
{
  "success": true,
  "message": "Sales history fetched successfully",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPage": 1
  },
  "data": [
    {
      "saleId": "6821001234567890abcdef888",
      "provider": "stripe",
      "status": "on_hold",
      "referenceType": "event-ticket",
      "referenceId": "6820e1234567890abcdef666",
      "transactionId": "pi_123",
      "grossAmount": 29.98,
      "platformFee": 6,
      "processorFee": 0.87,
      "hostNetAmount": 23.11,
      "currency": "USD",
      "quantity": 2,
      "event": {
        "eventId": "6820d1234567890abcdef444",
        "title": "Founders Dinner",
        "visibility": "public",
        "eventDate": "22/05/2026",
        "eventTime": "19:00-21:00",
        "venueName": "Bonded Hall",
        "city": "New York",
        "country": "USA"
      },
      "createdAt": "2026-05-07T12:05:00.000Z",
      "releaseAt": "2026-05-21T00:00:00.000Z",
      "payoutAt": null
    }
  ]
}
```

Frontend parsing rules:

- event-ticket sales include `quantity` and `event`
- circle-join sales include `circle` instead of `event`
- `transactionId` comes from `stripePaymentIntentId`, `appleTransactionId`, or `googleTransactionId` depending on provider

### 7.3 Get my tickets

```http
GET /api/v1/tickets/my?page=1&limit=20
Authorization: Bearer ACCESS_TOKEN
```

Only query params supported here are `page` and `limit`.

Exact response envelope:

```json
{
  "success": true,
  "message": "Tickets fetched successfully",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPage": 1
  },
  "data": [
    {
      "_id": "6821022234567890abcdef111",
      "bookingId": "6820e1234567890abcdef666",
      "eventId": "6820d1234567890abcdef444",
      "attendeeId": "6820a1234567890abcdef111",
      "eventVisibility": "public",
      "quantity": 2,
      "status": "active",
      "paymentStatus": "paid",
      "currency": "USD",
      "subtotal": 19.98,
      "tax": 0,
      "total": 19.98,
      "ticketNumber": "ETK-1746620000000-AB12CD34",
      "qrPayload": "{\"ticketNumber\":\"ETK-1746620000000-AB12CD34\",\"bookingId\":\"6820e1234567890abcdef666\",\"eventId\":\"6820d1234567890abcdef444\",\"attendeeId\":\"6820a1234567890abcdef111\"}",
      "eventSnapshot": {
        "title": "Founder Roundtable Live",
        "eventDate": "20/05/2026",
        "eventTime": "18:00-19:00",
        "venueName": null,
        "address": null,
        "city": null,
        "country": null,
        "coverImage": "https://cdn.example.com/events/founder-roundtable.png"
      },
      "attendeeSnapshot": {
        "fullName": "John Carter",
        "email": "john@example.com",
        "phone": "+15551234567",
        "phoneCountryCode": "+1",
        "country": "USA",
        "city": "New York",
        "address": "12 Main Street"
      },
      "paymentSnapshot": {
        "provider": "apple",
        "appleTransactionId": "2000000900022222"
      },
      "createdAt": "2026-05-07T12:02:15.000Z",
      "updatedAt": "2026-05-07T12:02:15.000Z",
      "seatCount": 2,
      "qrCodeValue": "{\"ticketNumber\":\"ETK-1746620000000-AB12CD34\",\"bookingId\":\"6820e1234567890abcdef666\",\"eventId\":\"6820d1234567890abcdef444\",\"attendeeId\":\"6820a1234567890abcdef111\"}"
    }
  ]
}
```

Frontend note:

- one booking produces one ticket card
- the app should render the QR from `qrCodeValue`
- the app should render the seat count from `seatCount`
- `quantity` is still returned for backward compatibility
- `paymentSnapshot` fields vary by provider: Stripe tickets expose `stripePaymentIntentId`, Apple tickets expose `appleTransactionId`, and Google tickets expose `googleTransactionId`

### 7.4 Get booked events summary

```http
GET /api/v1/tickets/booked-events
Authorization: Bearer ACCESS_TOKEN
```

This route is not paginated. It returns one entry per event, even if the attendee has multiple ticket lookups for that same event.

Exact response envelope:

```json
{
  "success": true,
  "message": "Booked events fetched successfully",
  "data": [
    {
      "eventId": "6820d1234567890abcdef444",
      "eventVisibility": "public",
      "title": "Founder Roundtable Live",
      "eventDate": "20/05/2026",
      "eventTime": "18:00-19:00",
      "venueName": null,
      "address": null,
      "city": null,
      "country": null,
      "coverImage": "https://cdn.example.com/events/founder-roundtable.png",
      "ticketCount": 2,
      "seatCount": 2,
      "paymentStatus": "paid"
    }
  ]
}
```

The booked-event summary also includes `seatCount` so the app can show `1 seat`, `2 seats`, and so on without opening the full ticket detail first.

### 7.5 Get one ticket by ID

```http
GET /api/v1/tickets/:ticketId
Authorization: Bearer ACCESS_TOKEN
```

Use this when the app opens a dedicated ticket detail screen.

Exact response envelope:

```json
{
  "success": true,
  "message": "Ticket fetched successfully",
  "data": {
    "_id": "6821022234567890abcdef111",
    "bookingId": "6820e1234567890abcdef666",
    "eventId": "6820d1234567890abcdef444",
    "attendeeId": "6820a1234567890abcdef111",
    "eventVisibility": "public",
    "quantity": 2,
    "status": "active",
    "paymentStatus": "paid",
    "currency": "USD",
    "subtotal": 19.98,
    "tax": 0,
    "total": 19.98,
    "ticketNumber": "ETK-1746620000000-AB12CD34",
    "qrPayload": "{\"ticketNumber\":\"ETK-1746620000000-AB12CD34\",\"bookingId\":\"6820e1234567890abcdef666\",\"eventId\":\"6820d1234567890abcdef444\",\"attendeeId\":\"6820a1234567890abcdef111\"}",
    "eventSnapshot": {
      "title": "Founder Roundtable Live",
      "eventDate": "20/05/2026",
      "eventTime": "18:00-19:00",
      "venueName": null,
      "address": null,
      "city": null,
      "country": null,
      "coverImage": "https://cdn.example.com/events/founder-roundtable.png"
    },
    "attendeeSnapshot": {
      "fullName": "John Carter",
      "email": "john@example.com",
      "phone": "+15551234567",
      "phoneCountryCode": "+1",
      "country": "USA",
      "city": "New York",
      "address": "12 Main Street"
    },
    "paymentSnapshot": {
      "provider": "apple",
      "appleTransactionId": "2000000900022222"
    },
    "createdAt": "2026-05-07T12:02:15.000Z",
    "updatedAt": "2026-05-07T12:02:15.000Z",
    "seatCount": 2,
    "qrCodeValue": "{\"ticketNumber\":\"ETK-1746620000000-AB12CD34\",\"bookingId\":\"6820e1234567890abcdef666\",\"eventId\":\"6820d1234567890abcdef444\",\"attendeeId\":\"6820a1234567890abcdef111\"}"
  }
}
```

This response includes both the app-facing aliases and the original stored fields:

- `seatCount`
- `qrCodeValue`
- `quantity`
- `qrPayload`

## 8. Creator-Side Rules For Paid Circles And Paid Virtual Events

### 8.1 Paid circle create or update

Routes:

- `POST /api/v1/circles`
- `PATCH /api/v1/circles/:circleId`

Relevant fields:

- `isPaid`
- `price`

Example create payload:

```json
{
  "name": "Premium Entrepreneurs Circle",
  "category": "business-networking",
  "visibility": "private",
  "description": "Members-only founder room",
  "isPaid": true,
  "price": 9.99,
  "interestSlugs": ["entrepreneurship"],
  "city": "New York"
}
```

Backend rules:

- creator must already be fully verified
- price must be one of the approved digital tiers
- both Apple and Google products must exist for that tier
- backend stores the normalized tier price, not an arbitrary custom value

### 8.2 Paid public or circle event create or update

Public event route:

- `POST /api/v1/events`

Circle event routes:

- `POST /api/v1/circles/:circleId/events`
- `PATCH /api/v1/circles/:circleId/events/:eventId`

Relevant fields:

- `type`
- `isPaid`
- `ticketPrice`
- `currency`
- `virtualLink` for `virtual` and `bonded_live`

Example paid virtual event payload:

```json
{
  "title": "Founder Roundtable Live",
  "description": "Private digital meetup",
  "category": "networking",
  "type": "virtual",
  "eventDate": "20/05/2026",
  "eventTime": "18:00-19:00",
  "totalSeats": 50,
  "isPaid": true,
  "ticketPrice": 9.99,
  "currency": "USD",
  "virtualLink": "https://meet.example.com/roundtable"
}
```

Backend rules:

- paid virtual and bonded_live events must use approved digital tiers
- both Apple and Google products must exist for that exact tier
- paid in-person events can still use Stripe and do not need store catalog products

## 9. Generic `/iap/verify` Purpose Rules

Supported purposes:

- `creator-verification`
- `circle-join`
- `virtual-event-ticket`
- `host-pro-subscription`

Reference ID rules:

- `creator-verification`: no `referenceId` required
- `circle-join`: `referenceId` must be the circle ID when using the generic route directly
- `virtual-event-ticket`: `referenceId` must be the booking ID
- `host-pro-subscription`: no `referenceId` required

Platform token rules:

- `platform: "apple"` requires `appleTransactionId`
- `platform: "google"` requires `googlePurchaseToken`

## 10. Backend-Only Notification Routes

These routes are not app-facing and should not be called by the mobile client:

- `POST /api/v1/iap/notifications/apple`
- `POST /api/v1/iap/notifications/google`

They exist for Apple App Store Server Notifications and Google RTDN webhook delivery.

## 11. Common Error Cases

- `400`: product mismatch, quantity mismatch, invalid transaction token, locked circle, wrong purpose/reference combination
- `400`: booking reservation expired before payment settlement or purchase verification completed
- `403`: user is not allowed to book or join that resource
- `404`: booking, event, circle, or store product was not found
- `409`: already a member of the circle
- `already_processed`: the same purchase was already accepted earlier

## 12. Minimal Client Checklist

Before release, the app should support all of the following:

- fetch approved digital tiers from `/store-products/tiers`
- fetch active store products from `/store-products`
- handle free circle joins without native billing
- handle paid circle joins through Apple and Google billing
- handle free public and circle event bookings
- handle paid in-person event bookings through Stripe
- handle paid virtual and bonded_live event bookings through Apple and Google billing
- render purchase history from `/payments/purchases`
- render seller earnings history from `/payments/sales`
- render ticket screens from `/tickets/my`, `/tickets/booked-events`, and `/tickets/:ticketId`
- render one QR code per ticket booking and show the seat count on the same ticket card
- call `/iap/verify` after the native purchase succeeds
- respect the `referenceId` returned by the backend
- keep the verified store purchase quantity equal to the booking quantity