# API Standards

## Purpose
Define the API design standards for recommendation delivery and internal service contracts.

## Practical usage
Use these standards when specifying public or internal recommendation APIs, admin APIs, and event-enriched service interactions.

## API style guidance
- Prefer resource-oriented HTTP APIs for delivery and operator interactions unless a streaming or event model is clearly needed.
- Keep recommendation responses typed and explicit rather than relying on consumer inference.
- Use consistent naming for customer, product, look, recommendation type, campaign, and experiment fields.

## Core contract expectations
- Recommendation requests should support identifiers such as `customerId`, `productId`, `sessionId`, `surface`, and context inputs.
- Recommendation responses should include recommendation set ID, trace ID, recommendation type, ranked items, and applicable metadata.
- Consumers should not need to guess whether a result is outfit, cross-sell, upsell, or contextual.

## Versioning approach
- Version external or shared APIs explicitly.
- Prefer additive changes where possible.
- Breaking changes require a migration plan for consuming surfaces.

## Error model
- Return structured errors with stable error codes, message, and correlation identifiers.
- Distinguish validation errors, authorization errors, upstream dependency failures, and degraded-fallback responses.
- Do not leak sensitive profile or system internals in error bodies.

## Authentication and authorization
- Require authenticated access for internal admin and clienteling APIs.
- Scope access by consumer type and least privilege.
- Keep secrets outside source control and rotate them through the platform secret-management process.

## Contract consistency rules
- Use canonical IDs from `docs/project/data-standards.md`.
- Propagate trace IDs through request, response, and telemetry paths.
- Surface fallback or partial-result conditions explicitly so consumers can render safely.
