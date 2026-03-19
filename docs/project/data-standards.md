# Data Standards

## Purpose

These standards define the core data expectations for the AI Outfit Intelligence Platform, including identifiers, event consistency, privacy, and auditability.

## 1. Data principles

- Use shared canonical identifiers wherever possible.
- Preserve source-system mappings instead of overwriting original identifiers.
- Favor explicit data contracts for high-value entities and events.
- Record uncertainty where identity or attribute quality is probabilistic.
- Keep data useful for both real-time recommendation delivery and offline analysis.

## 2. Core entities

The platform should maintain clear ownership and contracts for at least:

- products
- product variants and configuration attributes
- customers and profiles
- sessions
- looks
- recommendation sets
- rules
- campaigns
- experiments
- events and outcomes

## 3. Identifier standards

- Every core entity must have a stable canonical ID within the recommendation platform.
- Source-system IDs must be retained as mapped references.
- Recommendation outputs must carry recommendation set IDs that can be joined to impression and conversion outcomes.
- Identity resolution should preserve a confidence value or source quality indicator when profiles are merged across channels.

## 4. Event standards

At minimum, the platform should support consistent event definitions for:

- recommendation impression
- click
- save or wishlist
- add-to-cart
- purchase
- dismiss or hide
- override where an internal user changes or rejects a suggested recommendation set

Each event should record, where applicable:

- timestamp
- channel and surface
- customer or session identifier
- anchor product or context
- recommendation set ID
- recommended entity IDs
- look ID or rule context if available
- experiment and variant identifiers

## 5. Product and attribute expectations

- Product attributes used for compatibility must be normalized enough to support cross-category reasoning.
- Required attributes for early releases should include category, color, pattern, fabric, fit, occasion, season, price tier, inventory state, and imagery references.
- RTW and CM attributes should share common foundations while allowing mode-specific extensions.

## 6. Profile and identity expectations

- Customer profiles must distinguish known identity, anonymous session context, and merged identity states.
- Consent and region should influence which behavior or personalization fields are eligible for use.
- Prior purchases should be modeled in a way that supports exclusion or prioritization logic, not only aggregate counts.

## 7. Data freshness expectations

- Inventory and active merchandising changes require near-real-time or operationally acceptable freshness for serving decisions.
- Product master data and look definitions must refresh often enough to avoid broken or stale outfit recommendations.
- Long-term profile and affinity features may tolerate slower refresh than inventory or live session context.

## 8. Privacy and governance expectations

- Only use customer data permitted for the relevant region and use case.
- Respect consent, opt-out, and suppression requirements.
- Do not expose sensitive profile reasoning in customer-facing payloads unless explicitly approved.
- Record data lineage for the signals that materially affect recommendation decisions.

## 9. Auditability expectations

- It must be possible to reconstruct which inputs, rules, and recommendation set outputs were involved in a served recommendation.
- Model features or ranking signals do not need full customer-facing explanation, but internal traceability is required.
- Changes to curated looks, rules, and source mappings must be auditable.

## 10. Data quality expectations

- Unknown, missing, or low-confidence fields should be represented explicitly rather than silently assumed.
- Duplicate products, conflicting attributes, and stale inventory data should be detectable.
- Downstream analytics should be able to separate missing data from true negative outcomes.
