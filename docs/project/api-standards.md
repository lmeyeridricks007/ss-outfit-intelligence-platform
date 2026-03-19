# API Standards

## Purpose

These standards define the baseline contract expectations for APIs exposed by the Outfit Intelligence Platform, especially recommendation delivery APIs consumed by web, email, clienteling, and future channels.

## 1. API style

- Prefer resource-oriented HTTP APIs with explicit, stable request and response schemas.
- Recommendation responses should identify recommendation type and intended surface context when relevant.
- APIs must support partial context gracefully; missing optional inputs should not cause schema instability.
- Separate request context from recommendation results so consumers can debug and audit responses more easily.

## 2. Baseline endpoint direction

An initial endpoint shape may be:

`GET /recommendations`

Supported request inputs may include:

- customerId
- productId
- surface
- context
- location
- weather
- occasion
- sessionId

The contract should allow multiple response groups such as:

- outfits
- crossSell
- upsell
- styleBundles

Occasion-based, contextual, and personal recommendation logic should normally appear as strategy metadata on a recommendation set or response group, not as incompatible top-level response shapes for each surface.

## 3. Contract consistency rules

- Every recommendation object must include stable IDs for the recommendation set and the underlying items or looks.
- Every recommendation group must identify its group type, such as outfit, cross-sell, upsell, or style bundle.
- Every recommendation set should expose strategy metadata that captures the active recommendation dimensions, such as occasion-based, contextual, personal, curated, rule-based, or AI-ranked.
- Every response must identify the strategy or variant metadata needed for analytics and experimentation.
- Product references should use canonical product identifiers rather than only display names.
- Optional explanation or badge fields must be clearly typed and safe for customer display.
- Responses must distinguish between unavailable fields and empty recommendation results.

## 4. Versioning

- Version APIs explicitly from the start.
- Avoid breaking changes within a published version.
- Additive fields are preferred over schema replacement.
- Consumer-facing version changes must include deprecation guidance and migration timing once multiple consumers exist.

## 5. Authentication and authorization

- Use channel-appropriate authentication for server-to-server and authenticated customer contexts.
- Do not expose internal operator-only data on customer-facing endpoints.
- Authorization must account for region, channel, and role where operator tooling is involved.
- Sensitive personalization inputs should not be accepted or returned without a documented need and approval path.

## 6. Error model

- Return structured errors with machine-readable codes and human-readable messages.
- Distinguish validation errors, authentication errors, authorization errors, upstream dependency failures, and empty-result conditions.
- Empty recommendations should generally be represented as valid responses with empty collections, not transport-level errors.
- Include trace or correlation identifiers in error responses when operationally safe.

## 7. Latency and resiliency expectations

- Customer-facing recommendation APIs should favor predictable latency over unbounded ranking depth.
- Timeouts and fallbacks must be defined for optional dependencies such as weather or profile enrichment.
- The API should degrade to simpler strategies when upstream signals are unavailable rather than failing entirely.

## 8. Observability and analytics requirements

- Each response must carry enough metadata to connect impression and outcome events back to the generating recommendation set.
- Recommendation set ID, trace ID, variant ID, and strategy source should be available for telemetry.
- Logging and tracing must avoid exposing raw sensitive customer data unless explicitly authorized and protected.

## 9. Consumer integration expectations

- Consumers own rendering and layout.
- The API owns recommendation semantics, ranking outputs, and machine-usable metadata.
- Channel-specific presentation rules should be additive rather than requiring incompatible contracts for each surface.
