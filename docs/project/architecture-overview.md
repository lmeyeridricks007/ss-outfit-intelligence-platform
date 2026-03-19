# Architecture Overview

## Purpose

Provide a product-level technical view of the AI Outfit Intelligence Platform: the major subsystems, how data moves through them, where integrations sit, and which boundaries matter for later design work.

## Practical usage

Use this document to:
- orient later architecture and implementation planning
- show how shopper-facing recommendations depend on shared platform services
- make subsystem boundaries and assumptions explicit before detailed design begins

## High-level system view

The platform should be designed as a shared recommendation intelligence layer between upstream source systems and downstream consumer channels.

```text
Upstream systems
  -> product and inventory feeds
  -> orders and customer records
  -> browsing, search, and engagement events
  -> POS, appointments, stylist notes
  -> weather, season, holiday, and event sources

Ingestion and foundation layer
  -> product normalization
  -> event pipeline and session tracking
  -> identity resolution
  -> customer profile service
  -> curated look and rule ingestion

Decisioning layer
  -> product relationship graph
  -> look compatibility and outfit assembly model
  -> context engine
  -> candidate generation
  -> ranking and rule application

Delivery and control layer
  -> recommendation delivery API
  -> merchandising and admin controls
  -> experiment allocation
  -> traceability and diagnostics

Consumer channels
  -> ecommerce surfaces
  -> email and CRM
  -> in-store clienteling
  -> future mobile or partner consumers

Feedback loop
  -> recommendation telemetry
  -> analytics and insights
  -> model or rule optimization
```

## Major subsystems

| Subsystem | Responsibility |
| --- | --- |
| Product catalog ingestion | Normalize product attributes, images, inventory, seasonality, and RTW or CM metadata from source systems. |
| Customer signal ingestion | Capture orders, views, add-to-cart actions, search, email engagement, store visits, and other behavioral signals. |
| Event pipeline and session tracking | Create a consistent event stream that supports anonymous and known journeys. |
| Identity resolution and profile service | Link channel identifiers, build a usable style profile, and expose profile features to recommendation logic. |
| Look and merchandising model | Store curated looks, merchandising rules, campaign controls, exclusions, and override logic. |
| Product relationship and look graph | Represent compatibility between products, categories, styles, and look structures. |
| Context engine | Convert location, weather, season, holiday, and occasion inputs into recommendation features. |
| Recommendation engine | Generate candidates, apply business rules, rank outputs, and assemble recommendation sets. |
| Recommendation delivery API | Serve recommendations to channels with a stable contract and metadata for rendering, telemetry, and experiments. |
| Analytics and experimentation layer | Measure outcome events, support testing, and provide insight into recommendation performance. |
| Governance and admin interfaces | Support rule ownership, approvals, observability, auditability, and operational controls. |

## Data flow overview

1. Upstream systems provide product, inventory, customer, and event data.
2. Ingestion services normalize source-system differences into canonical platform entities.
3. Identity services connect anonymous sessions, known customers, and channel-specific identifiers where possible.
4. Profile and context services produce recommendation features from behavioral and environmental signals.
5. Look, graph, and rule services provide candidate relationships and business constraints.
6. Recommendation engine assembles and ranks recommendation candidates for the request context.
7. Delivery API returns recommendation sets, metadata, and trace identifiers to consuming channels.
8. Channels emit outcome events that feed analytics, experimentation, and later optimization.

## External integrations at a high level

| Integration category | Purpose |
| --- | --- |
| Commerce and OMS systems | Product catalog, inventory, order history, and sellable item status. |
| Web and app analytics sources | Browsing, search, product view, and add-to-cart signals. |
| POS and clienteling systems | Store visits, appointments, stylist-assisted interactions, and client context. |
| Email or marketing systems | Campaign activation and engagement data. |
| Weather and calendar sources | Context signals for climate, season, holiday, and event-aware recommendations. |
| Analytics or warehouse systems | Downstream analysis, model evaluation, and reporting. |

## Key technical boundaries

### Boundary 1: Source-of-record versus recommendation copy

Upstream commerce and customer systems remain the source of truth for core product, inventory, and transaction records. The recommendation platform should maintain only the normalized data needed for decisioning, traceability, and analytics.

### Boundary 2: Curated intent versus model-driven ranking

Curated looks and merchandising rules define the allowable and preferred recommendation space. AI ranking should optimize within those constraints, not bypass them without explicit governance.

### Boundary 3: Shared platform versus channel presentation

The platform owns recommendation generation and metadata. Each consumer surface owns final rendering, copy treatment, and surface-specific interaction design, subject to UI standards.

### Boundary 4: RTW versus CM logic

RTW and CM should share ingestion, identity, context, telemetry, and delivery foundations. Compatibility logic and request inputs may differ where configured garments require more detailed state.

### Boundary 5: Real-time serving versus offline computation

Heavy data preparation, graph construction, and profile updates can run asynchronously. Shopper-facing recommendation requests must be served within a real-time API path using prepared data and bounded per-request computation.

## Operational assumptions

- Product and inventory data can be refreshed frequently enough to avoid surfacing unavailable items.
- Customer behavior events are available with sufficient freshness to support recent-intent use cases.
- Weather and event context should be cached or otherwise handled so external dependency latency does not dominate real-time serving.
- Recommendation requests must degrade gracefully when identity, weather, or event data is missing.
- Trace identifiers and recommendation set identifiers are required for support, analytics, and experimentation.

## Implementation-oriented constraints

- The architecture must support multiple recommendation types without separate endpoint contracts for every variant.
- Recommendation outputs must contain structured item, look, and rationale metadata suitable for several channels.
- The platform should not hard-code one source system or one channel as the only supported integration path.
- Identity confidence and consent state must be available to decisioning or filtering logic where relevant.
- Admin and governance capabilities are part of the product architecture, not an afterthought.

## Architecture implications for later stages

- Feature architecture will need explicit contracts for look storage, graph modeling, recommendation assembly, and telemetry.
- Implementation planning will need clear separation between online serving components and offline data preparation jobs.
- Integration work will need stable mappings between source-system IDs and canonical platform IDs.

## Missing decisions

- Missing decision: the primary storage pattern for look, graph, and profile data.
- Missing decision: the boundary between in-request ranking and precomputed recommendation candidate generation.
- Missing decision: whether experiment allocation occurs inside the recommendation service or in a shared experimentation layer.
