# API Standards

## Purpose
Define baseline API expectations for services that expose recommendation functionality or supporting controls.

## Practical usage
Use these standards when designing recommendation delivery endpoints, internal administration APIs, and event ingestion contracts.

## API style guidance
- Prefer resource-oriented HTTP APIs with JSON payloads for external and cross-team consumers.
- Version externally consumed APIs explicitly, for example `/v1/recommendations`.
- Keep recommendation responses stable even when ranking strategies change internally.
- Separate read APIs for recommendation retrieval from write APIs for feedback, overrides, or administration.

## Core contract expectations
Recommendation responses should include, where relevant:
- recommendation set ID
- trace ID
- request context summary
- recommendation type
- source provenance such as curated, rule-based, or AI-ranked
- items with canonical product identifiers
- optional explanation metadata for internal or controlled consumer use

## Versioning approach
- Use additive changes whenever possible.
- Breaking changes require a new versioned endpoint or explicit migration path.
- Channel consumers should not parse undocumented internal fields.

## Error model
Use a consistent error envelope with:
- machine-readable code
- human-readable message
- trace ID
- optional field-level details for validation errors

Suggested error categories:
- invalid_request
- unauthorized
- forbidden
- not_found
- conflict
- dependency_unavailable
- rate_limited
- internal_error

## Authentication expectations
- Customer-facing surfaces should use channel-appropriate service authentication rather than exposing privileged internal credentials.
- Internal administration APIs should require authenticated service or user identity with role-based authorization.
- Sensitive endpoints should log actor identity and change intent.

## Contract consistency rules
- Use canonical IDs for products, customers, looks, campaigns, and experiments.
- Use consistent naming for request fields such as `customerId`, `productId`, `context`, `location`, and `weather` when those concepts are represented.
- Inventory and policy filtering should be reflected in returned results rather than delegated to the consumer.
- Request schemas should support optional context fields without forcing every surface to send the same payload.

## Reliability expectations
- Timeouts and retry behavior must be documented per integration path.
- Idempotency keys are required for any write endpoint that can be safely retried.
- Latency-sensitive recommendation endpoints should expose cache-safe semantics where appropriate.
