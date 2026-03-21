# Architecture Overview

## Purpose
Provide the product-level system view for the AI Outfit Intelligence Platform, including major subsystems, data flow, external integrations, and technical boundaries.

## Practical usage
Use this document to guide feature architecture, implementation planning, API contracts, and integration design.

## High-level system view
The platform should be built as a shared recommendation stack that sits between upstream data sources and downstream delivery surfaces.

Core flow:
1. Ingest product, customer, event, and context data.
2. Normalize identifiers and construct usable product and profile representations.
3. Maintain compatibility, look, and rule knowledge.
4. Generate and rank recommendation candidates.
5. Deliver recommendation sets through a shared API.
6. Capture telemetry, attribution, and operational traces for optimization and governance.

## Major subsystems

### 1. Catalog ingestion and normalization
Responsibilities:
- ingest product catalog and inventory data
- normalize category, fabric, color, pattern, fit, season, occasion, style tags, price tier, imagery, and RTW or CM attributes
- maintain product eligibility for recommendation usage

### 2. Customer signal ingestion
Responsibilities:
- ingest orders, browsing events, add-to-cart, search, email engagement, loyalty, store visit, appointment, and stylist-note signals where available
- preserve source-system provenance and event timestamps
- feed profile building and analytics

### 3. Identity and profile service
Responsibilities:
- map source identifiers to a canonical customer identity
- expose confidence-aware profile summaries for recommendation decisions
- maintain profile features useful for personalization and suppression

### 4. Context engine
Responsibilities:
- interpret weather, location, country, season, holiday, and session-level inputs
- expose normalized context features with fallback behavior
- support occasion and market-aware recommendation logic

### 5. Outfit and compatibility knowledge layer
Responsibilities:
- store curated looks
- manage compatibility graph data and business constraints
- support rule-based filtering and candidate generation

### 6. Recommendation engine
Responsibilities:
- select eligible candidates from curated, rule-based, and learned sources
- rank and assemble recommendation sets by recommendation type
- apply rule precedence, suppression, inventory constraints, and context

### 7. Merchandising governance layer
Responsibilities:
- manage merchandising rules, exclusions, boosts, pinning, overrides, and campaigns
- expose auditable configuration changes
- enforce governance boundaries over automated ranking

### 8. Recommendation delivery API
Responsibilities:
- accept surface requests such as `GET /recommendations`
- return recommendation sets with typed outputs, look context, and trace metadata
- support multiple consuming surfaces without channel-specific core logic forks

### 9. Analytics, experimentation, and audit subsystem
Responsibilities:
- collect recommendation impressions and downstream outcome events
- support experiments, reporting, and attribution
- preserve traceability for why a recommendation set was produced

## Data flow overview

### Upstream sources
- commerce systems such as Shopify and OMS
- product information and inventory systems
- marketing and engagement systems
- POS or store systems
- external or internal context providers for weather and event signals

### Internal processing flow
1. Source data lands in ingestion pipelines.
2. Canonical IDs and normalized schemas are assigned.
3. Product, profile, context, and governance state become available to decision services.
4. Recommendation requests invoke candidate generation, filtering, ranking, and assembly.
5. Recommendation sets are returned with recommendation set ID, trace ID, and supporting metadata.
6. Exposure and outcome telemetry flows back into analytics and optimization processes.

### Downstream consumers
- ecommerce web surfaces
- email systems
- clienteling tools
- future mobile or partner APIs
- operator dashboards and governance interfaces

## External integrations at a high level
- commerce and OMS systems for orders and cart context
- catalog and inventory systems
- CRM, loyalty, and marketing platforms
- POS, appointment, or stylist-note sources
- weather and calendar providers where needed
- analytics and experimentation platforms where not built in-house

## Key technical boundaries
- Delivery surfaces should consume recommendation contracts, not embed channel-specific business logic.
- Merchandising governance must remain decoupled from UI rendering concerns.
- Identity resolution must expose confidence and provenance rather than hiding uncertainty.
- Recommendation ranking must operate within compatibility, policy, and inventory constraints.
- Audit and telemetry storage must be sufficient to reconstruct recommendation decisions after the fact.

## Operational assumptions
- Near-real-time freshness is likely required for inventory and high-value behavioral signals.
- Batch processing is acceptable for some profile enrichments and curated look ingestion.
- Recommendations should fail gracefully with fallback logic if some context or profile inputs are unavailable.
- Not every surface needs the same latency target, but ecommerce requests require interactive response times.

## Implementation-oriented constraints
- Stable canonical IDs are required for products, customers, looks, rules, campaigns, recommendation sets, and experiments.
- Trace metadata must be present in delivery and telemetry paths.
- Data quality controls are not optional because product and attribute inconsistencies directly damage recommendation quality.
- Rule precedence and override semantics must be deterministic and documented.
- RTW and CM data models should share a core contract while preserving mode-specific differences.

## Missing decisions
- Missing decision: exact serving architecture for online inference and candidate retrieval.
- Missing decision: source of truth for curated looks and rule authoring UI.
- Missing decision: whether experimentation is native to the platform or integrated through an existing experimentation stack.
- Missing decision: which components require strict real-time processing versus scheduled refresh.
