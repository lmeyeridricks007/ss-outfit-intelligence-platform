# Data Standards

## Scope
These standards apply to product, customer, context, recommendation, and telemetry data used by the AI Outfit Intelligence Platform.

## Key data principles
- Use canonical platform identifiers for products, customers, looks, campaigns, experiments, recommendation sets, and rules.
- Preserve mappings to source-system identifiers rather than replacing them silently.
- Treat recommendation data as decision data that must remain explainable and auditable.
- Distinguish observed facts from inferred attributes and model outputs.

## Entity and ownership expectations
- Product master data remains owned by the designated commerce or catalog source of record.
- Inventory and availability remain owned by the designated operational source of record.
- Customer identity may aggregate multiple source identifiers, but the platform must record identity resolution confidence.
- Curated looks, compatibility rules, campaign metadata, and recommendation trace records are platform-owned artifacts.

## Event and telemetry rules
At minimum, recommendation telemetry should support:
- request
- impression
- click
- save or favorite
- add-to-cart
- purchase
- dismiss
- override

Each recommendation-related event should include where available:
- recommendation set ID
- trace ID
- customer ID or anonymous session ID
- product or look IDs involved
- surface and slot
- recommendation type
- campaign or experiment context
- timestamp

## Data consistency expectations
- Product attributes required for compatibility logic must be normalized to controlled vocabularies where feasible.
- Inventory, price tier, season, and availability data should have freshness expectations defined per consuming surface.
- Anonymous and known-customer events must be joinable through an approved identity model.
- Recommendation outputs should record which rule, curated look, or ranking version materially influenced the result.

## Privacy and governance expectations
- Use only customer data permitted by consent, contract, and regional policy.
- Do not expose sensitive internal profile reasoning in customer-facing responses.
- Apply retention rules appropriate to customer signals, experiment data, and audit records.
- Make data access and override actions auditable for operational review.

## Auditability expectations
- Recommendation decisions must be reproducible enough for support, analytics, and governance review.
- Rule, campaign, and model changes should be timestamped and attributable.
- Identity merges, overrides, and consent changes should be traceable.
