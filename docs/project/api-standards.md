# API Standards

## Purpose

These standards define the expected API style for recommendation delivery and related platform services. The goal is to keep contracts consistent across channels while allowing the platform to evolve by version rather than ad hoc surface-specific logic.

## API style

- Prefer resource-oriented HTTP APIs for channel consumption.
- Use explicit, structured request and response schemas rather than loosely typed payloads.
- Separate delivery concerns from back-office operator workflows when they have materially different contract needs.
- Design responses to support multiple recommendation types in one call when the surface benefits from it.

## Core contract expectations

- Requests should support known inputs such as `customerId`, `productId`, channel or surface context, location, weather context, and session metadata when available.
- Responses should clearly identify recommendation groups such as outfits, cross-sell, upsell, and style bundles.
- Every recommendation set should include a stable recommendation set identifier and trace identifier for telemetry correlation.
- Response metadata should preserve enough source context to support analytics, experiments, and operator debugging.

## Reference endpoint direction

- A shared endpoint such as `GET /recommendations` is a valid baseline direction for synchronous channel requests.
- The contract should support optional inputs rather than assuming every request has a fully known customer and full context.
- A single response may contain multiple recommendation groups so one request can populate a surface efficiently when appropriate.

## Versioning

- Use explicit API versioning for externally consumed contracts.
- Avoid breaking response shape changes without a version bump or compatible migration path.
- Track deprecated fields and contract transitions intentionally rather than leaving them implicit.

## Authentication and authorization

- Use authenticated service-to-service access for channel and internal system integrations.
- Scope access according to channel or operator role where platform capabilities differ.
- Do not rely on customer identifiers alone as proof of authorization.

## Error model

- Return consistent machine-readable error codes and human-readable summaries.
- Distinguish clearly between client input errors, authentication errors, dependency failures, and temporary recommendation unavailability.
- Support safe fallback behavior when recommendation generation cannot complete.
- Avoid returning partial data without explicit response metadata describing the degraded mode.

## Contract consistency rules

- Use canonical product, customer, look, campaign, experiment, and recommendation set identifiers.
- Represent recommendation types and source types consistently across every endpoint.
- Include inventory or eligibility status only when the contract can do so reliably for the consuming surface.
- Keep RTW and CM differences explicit in the contract where their inputs or outputs differ materially.

## Performance expectations

- Recommendation APIs for customer-facing synchronous surfaces should be designed for low-latency responses with defined fallbacks.
- Surfaces with less strict latency tolerance, such as campaign generation, may use asynchronous or batch workflows where appropriate.
- Timeout, retry, and fallback behavior must be documented per integration.

## Observability expectations

- Log request context, response identifiers, latency, dependency health, and degraded-mode outcomes.
- Ensure API events can be joined to downstream impression, click, add-to-cart, and purchase telemetry.
