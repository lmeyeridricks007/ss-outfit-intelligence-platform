# Data Standards

## Purpose

Define cross-cutting expectations for identifiers, event data, profile data, recommendation telemetry, and governance.

## Data principles

- data should be usable across web, email, clienteling, and admin contexts
- data contracts should favor stable semantics over source-specific shortcuts
- recommendation analytics must be traceable to the exact recommendation set that was served
- identity and consent must be explicit, not inferred
- missing or low-confidence data should be represented clearly rather than hidden

## Canonical identifiers

The platform should maintain stable canonical IDs for:

- products
- customers
- looks
- recommendation sets
- rules
- campaigns
- experiments

Source-system mappings must be retained explicitly, including identifier type and source of origin.

## Ownership expectations

- source systems remain authoritative for their native records such as commerce orders or ESP campaign state
- the recommendation platform is authoritative for look IDs, recommendation set IDs, rule IDs, and recommendation telemetry schemas
- canonical mapping ownership must be defined for each shared entity before production rollout

## Identity resolution expectations

- customer identity resolution should preserve confidence level or confidence score
- anonymous session context and known-customer context must be distinguishable
- merged profiles must retain lineage to source identifiers
- data usage for personalization must respect consent and regional policy constraints

## Product data expectations

Product data used for recommendation decisions should include, where applicable:

- category
- fabric
- color
- pattern
- fit
- season
- occasion
- style tags
- price tier
- imagery
- inventory or sellability indicators
- RTW / CM distinguishing attributes

If critical compatibility fields are missing, the data quality gap should be visible to operators.

## Recommendation telemetry standards

At minimum, recommendation telemetry should capture:

- request received
- recommendation served / impression
- click
- save or favorite
- add-to-cart
- dismiss where applicable
- purchase
- operator override where applicable

Each event should include enough context to join it back to:

- recommendation set ID
- customer or session context when allowed
- surface / channel
- recommendation type
- experiment / variant
- rule or curated source indicators where relevant
- timestamp and source system

## Event consistency rules

- event names should be consistent across channels for equivalent actions
- timestamps should include clear timezone handling or normalized UTC storage
- payloads should distinguish missing values from empty values
- schemas should be versioned when materially changed
- channel adapters should not change the semantic meaning of core telemetry events

## Freshness and quality expectations

- freshness requirements should be documented per data domain rather than assumed globally
- product availability and assortment-related data should reflect channel needs closely enough to avoid obviously unsellable recommendations
- delayed or partial data ingestion should surface monitoring signals and fallback behavior

## Privacy and governance expectations

- use only customer data allowed for the specific region and use case
- persist and honor consent and opt-out states
- do not expose sensitive profile reasoning on customer-facing surfaces unless explicitly designed and approved
- treat stylist notes and store-visit data as governed inputs with explicit policy review before use

## Auditability expectations

- recommendation decisions should be reconstructable from logged request, output, rule, and experiment context
- key curation and rule changes should be attributable to an operator or system action
- schema and pipeline changes should be traceable to a versioned change record
