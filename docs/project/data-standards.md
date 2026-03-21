# Data Standards

## Purpose
Define the core data, identity, event, privacy, and auditability standards for the platform.

## Practical usage
Use this document when designing schemas, pipelines, telemetry, identity resolution, experimentation, and recommendation trace storage.

## Core data principles
- Use stable canonical IDs for products, customers, looks, campaigns, rules, experiments, recommendation sets, and recommendation items.
- Preserve source-system mappings rather than replacing them.
- Record freshness, provenance, and transformation ownership for important entities.
- Keep RTW and CM data aligned through shared primitives while preserving mode-specific fields.

## Identifier standards
| Entity | Required identifier standard |
| --- | --- |
| Product | Stable canonical product ID plus source-system IDs |
| Customer | Stable canonical customer ID plus source identity mappings |
| Look | Stable look ID for curated or generated look objects |
| Rule | Stable merchandising rule ID |
| Campaign | Stable campaign ID |
| Experiment | Stable experiment and variant IDs |
| Recommendation set | Unique recommendation set ID and trace ID per response |

## Identity standards
- Identity resolution must record confidence where multiple source identities are merged.
- Customer profile use must respect consent and permitted-use boundaries.
- Unknown or low-confidence identity should trigger safe fallback behavior instead of aggressive personalization.

## Event and telemetry standards
Required recommendation telemetry events:
- impression
- click
- save
- add-to-cart
- purchase
- dismiss
- override

Each event should include, where applicable:
- event timestamp
- canonical customer ID or anonymous session ID
- surface and channel
- anchor product ID or look ID
- recommendation set ID
- trace ID
- recommendation type
- rule context
- experiment and variant context

## Data consistency rules
- Timestamps must be normalized and timezone-safe.
- Required fields should be versioned and documented before downstream reliance.
- Null or missing values should be distinguished from unknown or not-applicable states where it matters for ranking or governance.

## Privacy and governance expectations
- Use only data permitted for the use case and region.
- Avoid exposing sensitive profile reasoning in customer-facing experiences.
- Ensure opt-out or suppression rules can be enforced in downstream activation.
- Maintain audit logs for rule changes, curated look changes, and operator overrides.

## Auditability expectations
- Recommendation decisions must be reconstructable using trace context, rule context, and versioned inputs.
- Data transformations affecting ranking or filtering should have accountable ownership.
