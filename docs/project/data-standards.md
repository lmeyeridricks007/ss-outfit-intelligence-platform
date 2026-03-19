# Data Standards

## Purpose

Define key data principles, identifier rules, event standards, privacy expectations, and auditability requirements for the AI Outfit Intelligence Platform.

## Practical usage

Use this document when designing catalog feeds, customer profiles, recommendation telemetry, experimentation data, analytics models, and integration mappings.

## Key data principles

1. Use stable canonical identifiers inside the platform.
2. Preserve source-system mappings explicitly.
3. Treat identity resolution confidence as data, not hidden logic.
4. Capture enough recommendation metadata to support attribution and auditability.
5. Respect consent and regional privacy requirements in data collection and recommendation usage.
6. Prefer schema consistency across channels over channel-specific event fragmentation.

## Canonical identifiers

| Identifier | Purpose |
| --- | --- |
| `productId` | Canonical product identifier used by recommendation logic. |
| `variantId` | Variant-level identifier when size, color, or other sellable distinctions matter. |
| `lookId` | Canonical identifier for a curated or generated look definition. |
| `customerId` | Canonical known-customer identifier after source mapping or identity resolution. |
| `profileId` | Identifier for the recommendation-facing style profile record. |
| `sessionId` | Identifier for anonymous or mixed-state browsing sessions. |
| `recommendationSetId` | Identifier for a specific recommendation response delivered to a consumer. |
| `ruleId` | Identifier for a merchandising rule or override. |
| `campaignId` | Identifier for campaign influence or source context. |
| `experimentId` | Identifier for an experiment definition. |
| `variantKey` | Identifier for the experiment variant or strategy assignment. |
| `traceId` | End-to-end diagnostic identifier for request, response, and outcome linkage. |

## Data ownership expectations

| Data domain | Expected source of truth | Platform responsibility |
| --- | --- | --- |
| Product and inventory | Commerce or OMS systems | Normalize and cache the fields needed for recommendation decisions. |
| Orders and transactions | Commerce, OMS, or POS systems | Consume and join as customer and affinity signals. |
| Behavioral events | Web, app, email, or store interaction sources | Normalize into a common event model. |
| Customer profile | Identity or CRM sources plus platform-derived features | Maintain recommendation-facing profile features and confidence metadata. |
| Curated looks and rules | Merchandising or admin workflows | Store and version recommendation-relevant look and rule entities. |
| Experiment metadata | Experimentation tooling or platform controls | Preserve assignment and variant context for analysis. |

## Event and telemetry standards

Recommendation-related telemetry should support at least the following events:

| Event | Required use |
| --- | --- |
| `recommendation_impression` | Recorded when a recommendation set is shown on a surface. |
| `recommendation_click` | Recorded when a user selects a recommendation. |
| `recommendation_save` | Recorded when a user saves or favorites a recommendation where supported. |
| `recommendation_add_to_cart` | Recorded when a recommended item is added to cart. |
| `recommendation_purchase` | Recorded when a recommended item or look contributes to purchase. |
| `recommendation_dismiss` | Recorded when a recommendation is actively dismissed where the surface supports it. |
| `recommendation_override` | Recorded when a stylist or merchandiser override changes the recommendation outcome. |

### Required fields on recommendation telemetry

- `eventTime`
- `surface`
- `recommendationType`
- `recommendationSetId`
- `traceId`
- `productId` or `lookId` as applicable
- `customerId` and/or `sessionId` as available
- `experimentId` and `variantKey` when applicable
- `ruleId` when a merchandising rule materially influenced the result

## Identity resolution expectations

- Preserve source identifiers separately from canonical IDs.
- Record identity resolution confidence when profiles are merged across channels or systems.
- Do not assume every anonymous event can be safely or deterministically joined to a known customer.
- Profile usage in recommendation decisions should respect both confidence level and consent state.

## Privacy and governance expectations

- Only use customer data that is permitted for the relevant use case and region.
- Respect opt-out and consent signals for personalization features.
- Avoid exposing sensitive profile reasoning directly in customer-facing experiences.
- Ensure role-based access to internal data views that include customer or stylist context.

## Data freshness and quality expectations

- Inventory-sensitive data must be fresh enough to avoid recommending unavailable products on sellable surfaces.
- Behavioral signals used for recent-intent features should have a freshness target defined by later implementation planning.
- Missing or delayed context data should trigger fallback logic rather than silent corruption of recommendation quality.
- Data contracts should define required versus optional fields explicitly.

## Auditability expectations

- Recommendation decisions should be reconstructable at a practical level using recommendation set metadata, trace identifiers, rule context, and experiment context.
- Curated look and merchandising-rule changes should be versioned or otherwise auditable.
- Downstream analytics should be able to distinguish curated influence, rule influence, and model-driven influence when feasible.

## Missing decisions

- Missing decision: retention windows for raw events, derived profile features, and recommendation trace records.
- Missing decision: whether stylist notes and appointment details require additional access controls beyond general customer-profile access.
- Missing decision: which warehouse or analytical store will act as the durable measurement source of truth.
