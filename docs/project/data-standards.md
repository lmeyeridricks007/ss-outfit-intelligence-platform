# Data Standards

## Purpose

Define data, identity, event, and telemetry expectations for AI Outfit Intelligence Platform.

## 1. Core data principles

- Use stable canonical identifiers across products, customers, looks, rules, campaigns, experiments, and recommendation sets.
- Preserve source-system identifier mappings explicitly.
- Separate raw source ingestion from normalized recommendation-ready models.
- Record data freshness and provenance for operationally important entities.
- Treat privacy, consent, and regional restrictions as first-class data constraints.

## 2. Identifier standards

- Every product must have a canonical product ID plus source mappings.
- Every customer profile must support canonical identity plus source identifiers and identity confidence where merged.
- Curated looks, rules, campaigns, and experiments must have durable IDs so recommendation decisions can be audited.
- Every recommendation response should emit a recommendation set ID and trace ID.

## 3. Product data standards

The normalized product model should support at minimum:
- category
- fabric
- color
- pattern
- fit
- season
- occasion
- style tags
- price tier
- inventory status
- imagery references
- RTW and CM attributes

Product attributes used for compatibility or ranking should be governed, documented, and quality-checked.

## 4. Customer and profile data standards

Customer profiles may include, where permitted:
- order history
- browsing behavior
- page and product views
- add-to-cart events
- search behavior
- email engagement
- loyalty or account behavior
- store visits
- appointments
- stylist notes
- saved looks, favorites, or wishlists

Profiles must identify:
- source and recency of each signal class
- identity resolution confidence where applicable
- consent or suppression constraints relevant to activation

## 5. Context data standards

Normalize context features for:
- country
- location or region
- season
- weather
- holiday or event calendar
- device or session context where useful

Context values should include timestamp and source provenance when derived from external providers.

## 6. Event and telemetry standards

Recommendation telemetry should use a shared event model for:
- impression
- click
- save
- add-to-cart
- purchase
- dismiss
- override

Every recommendation-related event should include where applicable:
- recommendation set ID
- trace ID
- recommendation type
- surface
- channel
- customer ID or anonymous session ID
- product or look IDs involved
- experiment ID and variant
- campaign or rule context
- timestamp

## 7. Data quality standards

- Define required versus optional fields for recommendation-critical entities.
- Reject or quarantine malformed records that would silently corrupt compatibility or identity logic.
- Monitor null rates, freshness lag, identifier conflicts, and attribute inconsistencies.
- Inventory and availability data used for recommendation eligibility must be monitored separately from descriptive product data.

## 8. Privacy and governance standards

- Only use customer data for recommendation use cases that are permitted by region, consent state, and company policy.
- Do not expose sensitive profile reasoning in customer-facing outputs.
- Sensitive internal signals such as stylist notes require explicit policy validation before use.
- Audit data access and recommendation activation paths where policy requires it.

## 9. Auditability standards

- Recommendation decisions must be reconstructable from the recorded trace context and referenced rule, look, and experiment IDs.
- Changes to governed data artifacts such as rules and curated looks should preserve author, timestamp, and reason metadata.
- Downstream analytics must be able to attribute commercial outcomes to recommendation sets and variants.
