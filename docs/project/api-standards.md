# API Standards

## Artifact metadata
- **Upstream source:** GitHub issue #37 master product description plus bootstrap architecture and standards docs.
- **Bootstrap stage:** Bootstrap project documentation.
- **Next downstream use:** Recommendation API architecture, integration planning, and channel contract design.
- **Key assumption:** Shared recommendation APIs will be the primary delivery contract across multiple channels.
- **Missing decisions:** Final API versioning and auth patterns should be set during capability architecture and integration planning.

## Purpose
Define API expectations for services that deliver recommendations, operator controls, and related platform data.

## API style
- Prefer resource-oriented HTTP APIs with JSON payloads for synchronous recommendation delivery.
- Use explicit endpoint naming that reflects the product domain, for example `/recommendations` for delivery and separate operator-facing endpoints for rules, looks, or experiments.
- Keep request contracts explicit about context inputs such as `customerId`, `productId`, `surface`, `locale`, `weather`, and session metadata when applicable.

## Response structure expectations
- Allow multiple recommendation groups in a single response, such as `outfits`, `crossSell`, `upsell`, and `styleBundles`.
- Include stable identifiers for the recommendation set, trace context, and experiment assignment when relevant.
- Return both item references and enough metadata for consumers to render or fetch display details safely.
- Represent empty results explicitly rather than overloading error responses.

## Versioning
- Use explicit versioning for externally consumed contracts, ideally URI or header based, and document the chosen pattern consistently.
- Treat contract-breaking changes as versioned changes, not silent drift.
- Maintain backward compatibility during channel migrations where feasible.

## Error model
- Use a predictable error envelope with machine-readable codes, human-readable messages, and trace identifiers.
- Distinguish between invalid request, unauthorized access, upstream dependency failure, timeout, and empty eligible-result cases.
- Do not treat "no recommendation available" as a server error when fallback behavior is expected.

## Authentication and authorization
- Customer-facing recommendation requests should use channel-appropriate service authentication rather than exposing privileged internal credentials.
- Operator-facing APIs must enforce role-based access controls for rules, curation, experiments, and governance-sensitive actions.
- Audit operator mutations that change live recommendation behavior.

## Contract consistency rules
- Field names should be stable, descriptive, and consistent across channels.
- All IDs in API contracts should map to canonical identifiers defined in `data-standards.md`.
- Recommendation responses should preserve enough context to join downstream telemetry with the original decision.
- Avoid embedding channel-specific business logic in shared API contracts.

## Resilience expectations
- Define request timeouts appropriate for synchronous customer-facing use.
- Support idempotency for write operations that mutate rules or curated look state.
- Publish clear fallback expectations when the platform cannot produce a recommendation set in time.
