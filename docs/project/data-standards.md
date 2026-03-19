# Data Standards

## Artifact metadata
- **Upstream source:** GitHub issue #37 master product description plus bootstrap architecture and standards docs.
- **Bootstrap stage:** Bootstrap project documentation.
- **Next downstream use:** Data-model design, telemetry implementation, identity architecture, and analytics planning.
- **Key assumption:** Recommendation quality depends on canonical identifiers and consistent telemetry across channels.
- **Missing decisions:** Data ownership assignments and some source-system mappings should be finalized during data and identity architecture work.

## Purpose
Define cross-cutting data expectations for product, customer, event, context, and recommendation telemetry used by the AI Outfit Intelligence Platform.

## Core principles
- Use stable canonical identifiers for products, customers, looks, campaigns, rules, experiments, and recommendation sets.
- Preserve source-system mappings so the platform can reconcile commerce, POS, CRM, and marketing data safely.
- Separate raw source data from normalized canonical records.
- Record identity resolution confidence whenever signals from multiple systems are stitched together.
- Treat consent and regional privacy state as required decision inputs for personalization.

## Canonical identifiers
At minimum, the platform should define:
- `productId`
- `variantId` where applicable
- `lookId`
- `customerId`
- `sessionId`
- `recommendationSetId`
- `traceId`
- `ruleId`
- `campaignId`
- `experimentId`

Every identifier should have a documented owner and source mapping rule.

## Product and look data expectations
- Product records should cover category, fabric, color, pattern, fit, season, occasion, style tags, price tier, imagery, inventory state, and RTW or CM-specific attributes.
- Look records should represent a modeled compatible set of products, not only an ad hoc UI grouping.
- CM entities should support configurable options without breaking canonical product and look relationships.

## Event taxonomy
Recommendation telemetry should at minimum support these event types:
- impression
- click
- save
- add-to-cart
- purchase
- dismiss
- override

Each event should carry, where applicable:
- `recommendationSetId`
- `traceId`
- `surface`
- `recommendationType`
- `lookId` or product references
- experiment context
- rule context
- session and customer identifiers with confidence or consent context as needed

## Event consistency rules
- Emit recommendation events from every surface using the same base schema.
- Timestamp events in a standard timezone format and record event source.
- Distinguish user actions from operator actions.
- Preserve ordering or causality information where it matters for analysis.
- Validate schemas before ingestion into downstream analytics stores.

## Identity and privacy expectations
- Do not assume one channel identifier is globally reliable without mapping logic.
- Record identity confidence when linking anonymous and known profiles.
- Do not use personalization signals when consent or regional policy does not allow it.
- Avoid storing or exposing unnecessary sensitive inferences in customer-facing contexts.

## Data quality and auditability
- Track freshness of catalog, inventory, customer, and context feeds.
- Monitor schema drift, null-rate spikes, and source-mapping failures.
- Keep change history for curated looks, rules, and operator overrides.
- Ensure recommendation outcomes can be audited back to the decision context that produced them.

## Ownership expectations
- Define data owners for catalog, customer identity, recommendation logic, and analytics datasets before production rollout.
- Record whether each critical data element is source-of-truth, derived, or operational cache data.
