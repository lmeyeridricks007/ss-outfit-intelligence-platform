# API Standards

## Purpose

These standards define expectations for recommendation-serving and operational APIs used by the AI Outfit Intelligence Platform.

## 1. API style

- Prefer HTTP APIs with JSON payloads for synchronous recommendation delivery.
- Use resource-oriented naming where practical, with recommendation requests modeled clearly by use case.
- Keep delivery APIs separate from internal admin or merchandising mutation APIs.

Example direction:

- `GET /recommendations` for simple retrieval use cases
- `POST /recommendations/query` when request payload complexity exceeds query-string practicality

## 2. Contract expectations

Recommendation responses should:

- identify the recommendation types returned, such as `outfits`, `crossSell`, `upsell`, or `styleBundles`
- include stable IDs for recommendation sets and returned entities
- include enough metadata to support analytics, debugging, and experimentation
- remain consistent across channels even when presentation differs

Recommendation requests should support inputs such as:

- `customerId`
- `productId`
- `context`
- `location`
- `weather`
- `channel`
- `sessionId`

## 3. Versioning approach

- Use explicit versioning for externally consumed contracts.
- Prefer path or header versioning that allows additive evolution without breaking current consumers.
- Deprecation windows must be communicated before removing fields or endpoints used by active channels.

## 4. Error model

APIs should return structured errors with:

- machine-readable error code
- human-readable message for internal debugging
- trace or request identifier
- retry guidance when applicable

Recommendation delivery should distinguish:

- invalid request input
- unauthorized access
- dependency timeout or upstream failure
- no eligible recommendations found
- partial-context fallback responses

## 5. Authentication and authorization

- Service-to-service authentication must be required for internal channel integrations.
- Access scopes should limit who can retrieve customer-linked recommendation data or mutate merchandising configuration.
- Admin and merchandising APIs require stronger authorization boundaries than read-only recommendation delivery.

## 6. Latency and fallback behavior

- Recommendation delivery APIs must be suitable for real-time surfaces such as PDP and cart.
- If full personalization context is unavailable, the platform should degrade gracefully to curated or rule-based recommendations rather than fail silently.
- Fallback behavior must still emit trace metadata so degraded responses can be measured.

## 7. Consistency rules

- Do not expose channel-specific field names for the same concept.
- Preserve identifier consistency across read and analytics contracts.
- Clearly distinguish anchor product, recommended item, look source, and recommendation-set metadata.
- Keep RTW and CM extensions additive where possible rather than creating entirely separate core schemas.

## 8. Observability expectations

Every API response should support downstream observability through:

- request ID
- recommendation set ID
- experiment or variant context if applicable
- timing and status metrics emitted by the service

## 9. Mutation API guidance

When the platform introduces admin APIs for looks, rules, or campaigns:

- use idempotent writes where feasible
- validate compatibility and governance constraints before publish
- preserve audit history for changes that affect live recommendation behavior
