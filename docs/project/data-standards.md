# Data Standards

## Purpose
Define the data principles and event standards needed for a governed outfit intelligence platform.

## Practical usage
Use this document when shaping schemas, identity models, telemetry, and data quality controls.

## Key data principles
- Prefer canonical domain entities over channel-specific copies.
- Preserve source-system mappings rather than overwriting them.
- Record recommendation provenance and telemetry so outcomes are auditable.
- Treat consent, privacy, and regional restrictions as data-model concerns, not only policy text.

## Canonical identifiers and ownership
The platform should maintain canonical IDs for at least:
- product
- customer
- look
- recommendation set
- merchandising rule
- campaign
- experiment
- event

Each canonical record should preserve:
- source system name
- source system identifier
- last-updated timestamp
- ownership or stewardship responsibility
- identity resolution confidence where applicable

## Event and telemetry standards
Recommendation telemetry should support these event types where applicable:
- impression
- click
- save
- add-to-cart
- purchase
- dismiss
- override

Each event should include, at minimum:
- event ID
- event timestamp
- recommendation set ID
- trace ID
- surface or channel
- recommendation type
- product or look references involved
- customer or session reference, if permitted
- experiment or variant context, if present
- source provenance such as curated, rule-based, or AI-ranked

## Identity and profile expectations
- Identity resolution must separate asserted identity from probabilistic matches.
- Profile joins should preserve confidence, consent status, and source provenance.
- Do not assume a single channel identifier is globally stable without mapping logic.
- Customer-facing experiences should avoid exposing sensitive inferred profile attributes.

## Data consistency rules
- Product attributes used for compatibility must be normalized across source systems.
- Inventory freshness expectations should be documented and monitored because stale availability undermines trust.
- Recommendation set IDs should remain stable throughout downstream telemetry for a given response instance.
- Event schemas should be validated at ingestion and reject or quarantine malformed payloads.

## Privacy and governance expectations
- Use only customer data permitted for the use case and geography.
- Respect opt-out and consent signals for personalization and outbound use cases.
- Limit access to stylist notes or other sensitive internal signals based on role and need.
- Maintain auditable records for overrides, campaign activation, and experiment exposure.

## Auditability expectations
- Recommendation outputs must be reproducible enough to debug major incidents or quality regressions.
- Rule changes, curated look changes, and identity merges should be logged with actor and timestamp metadata.
- Data quality monitoring should cover completeness, freshness, schema conformity, and joinability.
