# Data Standards

## Purpose

These standards define the core data expectations for the AI Outfit Intelligence Platform. The platform depends on consistent identifiers, recommendation telemetry, customer-signal governance, and clear ownership boundaries across multiple source systems.

## Data principles

- Use canonical models for products, customers, looks, recommendation sets, rules, campaigns, and experiments.
- Preserve source-system mappings instead of overwriting original identifiers.
- Design for incomplete and uneven data quality; confidence and freshness matter.
- Treat recommendation telemetry as a first-class product input, not only as reporting output.

## Identifier standards

- Every canonical entity must have a stable primary identifier.
- Source-system identifiers must be retained as mapped references with source attribution.
- Customer identity resolution should record confidence or match strength where identities are merged.
- Recommendation sets must be uniquely identifiable so downstream behavior can be analyzed reliably.

## Product and look data

- Product data should support category, fabric, color, pattern, fit, season, occasion, style tags, price tier, inventory, imagery, and RTW or CM distinctions.
- Look and outfit data should make anchor items, complementary items, and composition logic explicit.
- Compatibility metadata should distinguish curated compatibility from inferred or learned relationships when possible.

## Event and telemetry standards

At minimum, recommendation telemetry should support:

- recommendation request
- recommendation response
- impression
- click
- save
- dismiss
- add-to-cart
- purchase
- operator override where applicable

Each event stream should preserve:

- recommendation set ID
- trace ID
- recommendation type
- source type
- experiment and variant identifiers where relevant
- channel or surface
- customer and session identifiers when permitted
- timestamp and market context

## Customer data standards

- Only use customer data that is permitted for the use case and region.
- Profile assembly must distinguish known facts from inferred preferences.
- Sensitive or regulated data should not be exposed to customer-facing recommendation explanations.
- Identity stitching rules must be explicit enough to support debugging and governance review.

## Consistency and freshness

- Inventory-sensitive recommendations require freshness expectations appropriate to the consuming channel.
- Context data such as weather and event calendars should include source and recency metadata where relevant.
- Data quality checks should exist for missing critical attributes, malformed identifiers, and broken source mappings.

## Ownership expectations

- Source systems retain ownership of their master records.
- The recommendation platform owns normalized decisioning-ready representations, recommendation telemetry, and recommendation-specific derived entities.
- Derived customer or product signals should be traceable back to source records and transformation logic.

## Privacy, governance, and auditability

- Consent and regional restrictions must be enforced before data enters personalization logic.
- Recommendation decisions should remain auditable enough to explain the source of a result internally.
- Operator-driven changes to curated looks, rules, or campaigns must be linked to identifiable users or systems.
- Data retention and deletion requirements should be handled in line with the customer data systems involved.
