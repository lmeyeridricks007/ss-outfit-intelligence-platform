# API Standards

## Purpose

Define API expectations for recommendation delivery and supporting platform services.

## API style

- Prefer resource-oriented HTTP APIs for synchronous recommendation retrieval.
- Use clear, typed response structures that separate recommendation types such as outfits, cross-sell, upsell, and style bundles.
- Request contracts should allow explicit context inputs rather than hiding them in opaque parameters.
- Keep the recommendation API consumer-agnostic; surface-specific rendering logic should stay outside the core contract.

## Core contract expectations

- Requests should support identifiers and context such as:
  - customerId
  - productId
  - surface
  - location
  - weather
  - locale or country
  - session or request context where useful
- Responses should include:
  - recommendation set ID
  - recommendation type
  - ordered items or looks
  - trace or explanation metadata for internal consumers where appropriate
  - experiment or variant metadata when applicable

## Versioning

- Use explicit API versioning for externally consumed contracts.
- Avoid breaking changes without a migration path.
- When channel-specific fields are needed, add them through versioned extensions or consumer adapters rather than fragmenting the core API.

## Error model

- Use a consistent error structure with machine-readable error codes.
- Distinguish invalid input, upstream dependency failure, timeout, authorization failure, and no-recommendation cases.
- No-recommendation outcomes should return an explicit empty result contract rather than an ambiguous failure.
- Internal trace IDs should be returned or logged for operational debugging.

## Authentication and authorization

- Protect internal recommendation and governance endpoints with platform-standard authentication and authorization.
- Restrict authoring, override, and governance operations separately from read-only delivery APIs.
- Treat customer and stylist-facing consumers as separate trust domains when permissions differ.

## Contract consistency rules

- Use canonical IDs for products, looks, customers, campaigns, and experiments.
- Keep field names stable and domain-aligned with `docs/project/standards.md`.
- Represent recommendation origin consistently, distinguishing curated, rule-based, and AI-ranked contributions when needed.
- Ensure response contracts can support both RTW and CM without forcing incompatible fields into one ambiguous schema.

## Reliability expectations

- Define request timeouts and fallbacks for each consumer surface.
- Recommendation APIs should degrade gracefully when some context inputs are missing.
- Hard compatibility failures must not be hidden by fallback ranking behavior.
