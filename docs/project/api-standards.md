# API Standards

## Purpose

Define the API and contract expectations for recommendation delivery and adjacent platform services.

## API style guidance

- Prefer HTTPS JSON APIs for recommendation delivery.
- Use resource-oriented naming with clear versioning.
- Keep request shapes stable across channels where possible.
- Use explicit fields for recommendation context rather than overloaded query strings when payload complexity grows.
- Support both synchronous serving for online surfaces and integration-friendly delivery patterns for downstream systems.

## Recommendation delivery contract expectations

The primary serving contract should support inputs such as:

- customer ID
- product ID
- surface or channel
- country / location
- weather / season context
- session or intent context

The response should support:

- recommendation type
- outfit or bundle grouping
- item-level product references
- rationale or source metadata for internal use when needed
- recommendation set ID and trace metadata
- experiment and variant metadata where applicable

## Versioning approach

- Use explicit API versioning from the start.
- Prefer additive schema evolution for backward-compatible changes.
- Breaking changes should require a new version or an explicit migration plan.
- Recommendation payload semantics must not silently change without version tracking.

## Error model

- Use a consistent machine-readable error shape across endpoints.
- Error responses should distinguish between:
  - client input problems
  - authentication / authorization failures
  - dependency failures
  - rate limiting or temporary unavailability
  - partial degradation with fallback behavior
- Customer-facing consumers should be able to distinguish between "no recommendations available" and "request failed."

## Authentication and authorization expectations

- Machine-to-machine consumers should use secure service authentication.
- Internal operator and admin APIs should enforce role-appropriate authorization.
- APIs that use customer identifiers must follow consent and privacy constraints for the relevant use case and geography.

## Contract consistency rules

- Use stable canonical IDs in request and response payloads.
- Preserve source-system mapping only where required for downstream integration; do not leak unnecessary internal identifiers.
- Keep recommendation type names consistent with project terminology.
- Include enough metadata in responses for analytics correlation and support debugging.
- If different channels require different presentation fields, channel-specific adapters should be explicit rather than changing core semantics.

## Performance and resiliency guidance

- Define target latency budgets per surface before production launch.
- Allow graceful degradation and fallback recommendation behavior if upstream context is missing.
- Avoid request-time dependency chains that make customer-facing surfaces fragile.
- Prefer idempotent semantics for non-mutating delivery endpoints.

## Example direction

The product may expose an endpoint such as:

- `GET /v1/recommendations`

For richer context or larger request shapes, a POST-based serving contract may be preferable. The specific shape can be decided later, but versioning, metadata, and stable semantics are required from the first implementation.
