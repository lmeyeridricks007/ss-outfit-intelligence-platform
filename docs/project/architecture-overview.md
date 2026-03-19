# Architecture Overview

## Artifact metadata
- **Upstream source:** GitHub issue #37 master product description plus bootstrap product docs.
- **Bootstrap stage:** Bootstrap project documentation.
- **Next downstream use:** Capability-level architecture artifacts, implementation planning, and integration scoping.
- **Key assumption:** The first architecture slice should support a PDP RTW rollout while keeping the domain model extensible for later personalization, operator tooling, and CM growth.
- **Approval note:** Later architecture artifacts should default to `HUMAN_REQUIRED`, especially where identity, privacy, or external integration trade-offs are still open.

## Purpose
Describe the high-level system shape for the AI Outfit Intelligence Platform so later architecture artifacts can decompose the platform into feature- and service-level designs without redefining the core boundaries.

## High-level system view
The platform should sit between source systems and recommendation-consuming channels.

1. **Source systems** provide product, inventory, order, customer, marketing, and store-interaction data.
2. **Ingestion and normalization** turns source data into canonical catalog, customer, context, and event records.
3. **Intelligence services** build relationship graphs, customer profiles, context signals, and recommendation candidates.
4. **Decision and delivery services** apply rules, rank candidates, and serve recommendation sets through APIs.
5. **Channel surfaces and operator tools** consume recommendation output and feed back performance and override signals.

## Major subsystem areas

### 1. Catalog and inventory ingestion
Responsible for:
- product attributes across RTW and CM;
- imagery and style tags;
- inventory and availability status;
- source-to-canonical product ID mapping.

### 2. Event and customer signal pipeline
Responsible for:
- browsing, search, product-view, cart, order, email-engagement, appointment, and clienteling signals;
- event normalization and schema enforcement;
- session stitching and channel-source attribution.

### 3. Identity resolution and profile service
Responsible for:
- linking anonymous and known customer identifiers;
- storing profile attributes, purchase affinities, and segmentation outputs;
- exposing confidence-scored identity resolution results to downstream consumers.

**Bootstrap direction:** Treat the recommendation profile service as the canonical serving layer for recommendation decisions, with mapped source identities from commerce, CRM, POS, and clienteling systems feeding it.

### 4. Product relationship and outfit graph
Responsible for:
- compatibility relationships across categories;
- curated looks and look-to-product membership;
- business-rule metadata such as exclusions, priorities, and campaign overlays;
- RTW and CM compatibility differences.

### 5. Context engine
Responsible for:
- season, weather, location, market, and occasion enrichment;
- session-level context signals usable in recommendation requests;
- graceful fallback when context data is incomplete.

### 6. Recommendation engine
Responsible for:
- candidate retrieval from curated, rule-based, and learned sources;
- scoring and ranking of outfits, cross-sell, upsell, and style bundles;
- balancing relevance, availability, and merchandising controls;
- producing explanation metadata for internal debugging and analytics.

### 7. Recommendation delivery API
Responsible for:
- receiving request context such as customer ID, product ID, locale, weather, and surface type;
- returning recommendation groups in a channel-consumable contract;
- passing recommendation-set IDs, trace IDs, and experiment metadata for telemetry;
- meeting latency and reliability needs for customer-facing surfaces.

### 8. Merchandising and governance tools
Responsible for:
- curated look authoring or import workflows;
- rule management for inclusion, exclusion, and override logic;
- experiment and campaign configuration;
- auditability and access control for sensitive operations.

### 9. Analytics and observability
Responsible for:
- recommendation event telemetry;
- performance dashboards and experiment readouts;
- operational monitoring for API health, data freshness, and model or rule outcomes.

## Data flow overview
1. Source data arrives from commerce, OMS, POS, CRM, email, clienteling, and context providers.
2. Normalization pipelines create canonical records for products, customers, events, and context dimensions.
3. Relationship modeling and profiling services update look structures, affinities, and segmentation outputs.
4. A consuming surface calls the recommendation API with user, product, and context inputs.
5. The recommendation engine retrieves eligible candidates, applies rules, scores results, and returns structured recommendation sets.
6. The surface renders those sets and emits telemetry events tied to recommendation-set and trace identifiers.
7. Analytics and experimentation systems evaluate outcomes and feed future optimization.

## External integrations
Likely integrations include:
- Shopify or other commerce catalog and order systems;
- OMS or inventory sources;
- POS or clienteling systems for store interactions;
- CRM, loyalty, or account systems;
- email marketing or campaign tools;
- weather or locale-context providers;
- analytics and experimentation platforms.

## Technical boundaries
- Recommendation logic should depend on canonical product, context, and profile inputs rather than channel-specific schemas.
- Channel surfaces should not embed their own incompatible ranking logic when a shared platform contract exists.
- Merchandising overrides should constrain recommendation eligibility and ranking without bypassing traceability.
- Identity confidence, consent state, and inventory availability should be treated as first-class inputs, not optional afterthoughts.

## Operational assumptions
- Some recommendation requests will run for anonymous users and must rely on session and context signals only.
- Some source data will arrive with latency or incompleteness, so freshness tracking and fallback behavior are required.
- The platform will likely need hybrid batch and near-real-time processing: batch for relationship modeling and profile aggregation, near real time for session context and delivery.

## Implementation-oriented constraints
- The API contract must support multiple recommendation groups in one response.
- Telemetry must preserve recommendation-set IDs, trace IDs, rule context, and experiment context so results are auditable.
- Data models must represent both product-level items and multi-item looks.
- CM support must not be bolted on later in a way that breaks the product model; the domain model should account for configurable garments from the start.
- Observability must cover freshness, latency, empty-result rate, and override frequency.

## Missing decisions

| Missing decision | Why it matters | Temporary bootstrap direction | Proposed resolution stage | Recommended owner |
| --- | --- | --- | --- | --- |
| Repository or deployment topology for the eventual platform services | Shapes service ownership, scaling, and release boundaries. | Keep this overview deployment-agnostic until feature-level architecture exists. | Capability architecture artifacts and implementation planning. | Architecture owners. |
| Whether the relationship graph is implemented as graph-native storage, relational structures, or a hybrid model | Impacts performance, maintainability, and operator workflows. | Model relationships abstractly now and choose storage during architecture decomposition. | Product-relationship and recommendation-architecture work. | Architecture and data-platform owners. |
| Where experimentation assignment lives if existing company tooling already handles it | Affects API design and telemetry joins. | Keep experiment context as an input and output contract requirement regardless of assignment location. | Recommendation API and experimentation architecture. | Product analytics and architecture owners. |
