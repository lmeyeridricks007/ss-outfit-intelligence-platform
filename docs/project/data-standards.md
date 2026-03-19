# Data Standards

## Purpose

These standards define how the Outfit Intelligence Platform should model identifiers, customer and product data, event telemetry, privacy handling, and auditability.

## 1. Canonical identifiers

The platform should maintain stable canonical IDs for:

- products
- variants or sellable units where needed
- customers
- anonymous sessions
- looks or outfit definitions
- recommendation sets
- rules
- campaigns
- experiments

Source-system IDs from Shopify, OMS, POS, email, or other systems must be preserved as mappings, not treated as interchangeable canonical identifiers.

## 2. Product data standards

- Product attributes used for recommendation logic must be normalized into a consistent schema.
- Required recommendation attributes should include category, fabric, color, pattern, fit, season, occasion, style tags, price tier, imagery, inventory status, and RTW or CM classification.
- Missing attributes must be explicit so recommendation logic can fall back safely instead of assuming defaults.
- Inventory freshness and assortment availability should be tracked separately from long-lived descriptive attributes.

## 3. Customer and identity standards

- Customer profiles must record source-system mappings and identity resolution confidence.
- Anonymous and known-customer journeys should be supported without forcing unreliable identity merges.
- Preference, purchase, browsing, and engagement signals should be timestamped and attributable to a source.
- Sensitive data beyond recommendation need should not be ingested simply because it is available.

## 4. Event standards

Recommendation telemetry should capture at minimum:

- impression
- click
- save
- add-to-cart
- purchase
- dismiss
- override

Each outcome event should carry:

- recommendationSetId
- traceId
- strategy or variant identifier
- channel or surface
- product or look references involved
- timestamp
- customer or session reference as permitted

## 5. Data quality and consistency rules

- Event timestamps must use a consistent timezone standard.
- Important enumerations such as recommendation type, surface, and occasion should use controlled vocabularies.
- Schema evolution must be versioned and documented.
- Upstream nulls, stale attributes, or conflicting IDs must be handled explicitly, not silently overwritten.

## 6. Privacy and governance

- Personalization data use must respect consent, opt-out, and region-specific rules.
- Customer-facing experiences should not reveal sensitive inferred attributes or private reasoning.
- Access to raw customer-level data should follow least-privilege principles.
- Governance decisions that affect ranking behavior or data use should be auditable.

## 7. Auditability and lineage

- Recommendation outputs must be traceable to the data and configuration used to generate them.
- Curated looks, rules, and model versions should be versioned or otherwise attributable.
- Operators should be able to understand whether a recommendation was primarily curated, rule-based, or AI-ranked.

## 8. Freshness expectations

- Inventory and critical assortment signals should refresh frequently enough to avoid recommending unavailable items on customer-facing surfaces.
- Product taxonomy and descriptive attributes may refresh on a slower cadence, but changes that affect compatibility should be propagated predictably.
- Customer behavior and session events should be available soon enough to support session-aware and recent-behavior strategies where promised.
