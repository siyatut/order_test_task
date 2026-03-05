# Flutter Test Task – Create Order

Simple Flutter implementation of order creation via REST API.

## Implemented

- `Order` model with `fromJson`
- Custom `ApiException`
- `createOrder()` API method with:
  - async/await
  - timeout (10s)
  - HTTP 200 handling
  - HTTP 400+ error handling
  - no internet handling
- `OrderController` with states:
  - initial
  - loading
  - success
  - error
- UI screen with:
  - "Создать заказ" button
  - loading indicator
  - error message
  - retry option

## API

POST `/api/orders`

Request:
- userId (int)
- serviceId (int)

Response:
- order_id
- status
- payment_url

Placeholder URL: https://example.com

## Tech

Flutter • Dart • http
