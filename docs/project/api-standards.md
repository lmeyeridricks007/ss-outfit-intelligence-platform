# API Standards

## Purpose

Define cross-cutting API standards for recommendation delivery and related service contracts in the AI Outfit Intelligence Platform.

## Practical usage

Use this document when designing recommendation-serving endpoints, telemetry ingestion APIs, admin APIs, and integration contracts consumed by channel teams.

## API style guidance

- Prefer resource-oriented HTTP APIs with JSON request and response bodies.
- Use noun-based endpoint paths and explicit action semantics only where resource modeling would be misleading.
- Keep recommendation APIs channel-agnostic; channel-specific presentation concerns belong outside the service contract.
- Use structured nested objects for context, customer identity, and recommendation metadata rather than proliferating flat ad hoc parameters.

## Recommended contract shape

### Recommendation request pattern

The recommendation delivery API should support inputs such as:
- `customerId`
- `sessionId`
- `productId`
- `context`
- `location`
- `weather`
- `surface`
- `mode` (`RTW` or `CM`)

### Recommendation response pattern

Responses should be able to return:
- one or more recommendation groups by type
- item-level metadata needed for rendering
- recommendation set identifiers
- trace identifiers
- experiment or variant metadata when applicable
- rule or reason metadata suitable for analytics and support

## Versioning approach

- Version public or broadly consumed APIs in the path, for example `/v1/recommendations`.
- Prefer additive changes within a version.
- Breaking changes require a new version and a migration plan for consumers.
- Contract examples in docs should indicate versioned paths explicitly.

## Authentication expectations

- Use service-to-service authentication for internal channel consumers and integration clients.
- Do not place secrets in client-rendered code or URL query strings.
- Auth context should support scoping by consumer application and environment.
- Customer identity in a request does not replace service authentication; both concerns should be handled distinctly.

## Error model

Use a machine-readable error envelope with consistent fields.

| Field | Purpose |
| --- | --- |
| `code` | Stable programmatic error code. |
| `message` | Human-readable summary. |
| `traceId` | Identifier for diagnostics and support. |
| `details` | Optional structured error details. |
| `retryable` | Whether the caller may retry safely. |

### Error handling rules

- Use consistent error codes across endpoints.
- Differentiate validation failures, upstream dependency failures, authorization failures, and internal service failures.
- When possible, return partial or fallback recommendation behavior rather than hard failure on optional context dependencies.
- Never expose sensitive internal reasoning or secrets in error payloads.

## Contract consistency rules

- Recommendation types should use stable enum values across request and response contracts.
- Surface names, mode names, and item identifiers must match project standards.
- Context objects should preserve canonical field names for location, weather, season, and occasion.
- Response collections should have deterministic ordering semantics when ranking is meaningful.
- Unknown optional fields should be ignored by consumers unless the contract states otherwise.

## Idempotency and retries

- `GET` endpoints must be safe to retry.
- Event or feedback ingestion endpoints that accept recommendation outcome events should support idempotency keys or equivalent duplicate protection.
- Callers should treat retryability as a contract concern, not a guess based on status code alone.

## Observability and tracing

- Every request should carry or generate a `traceId`.
- Recommendation responses should include a `recommendationSetId` that downstream events can reference.
- Logs, metrics, and events should allow joining request context, recommendation outputs, and business outcomes.

## Example endpoint direction

These are directionally appropriate examples, not final endpoint commitments:
- `GET /v1/recommendations`
- `POST /v1/recommendation-events`
- `POST /v1/merchandising-rules`

## Missing decisions

- Missing decision: whether recommendation delivery should be a synchronous read API only or also support precomputed batch export contracts.
- Missing decision: whether clienteling and email consumers need separate contract variants or a single shared response schema with surface metadata.
