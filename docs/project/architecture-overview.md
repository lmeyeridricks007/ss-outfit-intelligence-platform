# Architecture Overview

## Purpose
Provide a product-level architecture view for the AI Outfit Intelligence Platform.

## Practical usage
Use this document to guide detailed architecture work, service decomposition, integration design, and implementation planning.

## Source
- GitHub issue #37: Master product spec: AI Outfit Intelligence Platform (SuitSupply Recommendation Engine)

## High-level system view
The platform should be structured as a shared recommendation system with clear separation between data ingestion, profile and graph intelligence, recommendation generation, delivery, and governance.

```text
Source systems and feeds
  -> catalog ingestion
  -> customer signal ingestion
  -> context ingestion
  -> identity resolution and profile service
  -> product relationship and outfit graph
  -> candidate generation and ranking
  -> recommendation delivery API
  -> channel consumers (web, email, clienteling, future APIs)
  -> telemetry, analytics, experimentation, and governance loops
```

## Major subsystems
| Subsystem | Responsibility |
| --- | --- |
| Catalog ingestion and normalization | Ingest product data, enrich attributes, and maintain RTW/CM-ready product representations. |
| Customer signal ingestion | Collect orders, browsing, add-to-cart, search, engagement, and assisted-selling signals. |
| Context ingestion | Resolve weather, season, location, holiday, and session context needed for ranking. |
| Identity resolution and profile service | Map channel identities to canonical customer profiles with confidence and consent controls. |
| Product relationship graph | Represent category relationships, compatibility, style tags, and curated look associations. |
| Outfit graph or curated look model | Store complete-look compositions, merchandising curation, and rule-based outfit structures. |
| Recommendation engine | Generate candidates from curated, rule-based, and AI-ranked strategies, then score and filter them. |
| Context engine | Translate raw context signals into recommendation-useful constraints and boosts. |
| Delivery API | Provide stable response contracts for recommendation consumers across surfaces. |
| Merchandising and campaign controls | Manage curated looks, overrides, campaign priorities, and go-live controls. |
| Telemetry and analytics | Record recommendation sets, outcome events, experiments, and operational metrics. |
| Observability and governance | Support auditability, incident analysis, privacy controls, and operational health. |

## Data flow overview
1. Product, customer, and context data arrive from internal or external source systems.
2. Ingestion pipelines normalize and validate the inputs against canonical schemas.
3. Identity resolution links channel identifiers to customer profiles where permitted and possible.
4. Product relationships, curated looks, and compatibility rules create candidate generation inputs.
5. The recommendation engine builds candidate sets using curated, rule-based, and AI-ranked sources.
6. Ranking and filtering apply context, profile, inventory, policy, and channel constraints.
7. The delivery API returns recommendation sets with metadata such as recommendation set ID, source provenance, and trace ID.
8. Consumers emit impression and outcome telemetry back into analytics and optimization loops.

## External integrations
Expected high-level integrations include:
- Commerce systems such as Shopify and OMS for product, order, and inventory data.
- POS and store systems for store visits, appointments, and assisted-selling context.
- Marketing platforms for email activation and engagement feedback.
- Analytics systems for event collection, experimentation, and reporting.
- Weather or contextual data providers where internal data is insufficient.

## Technical boundaries
- The delivery API should remain surface-agnostic while allowing channel-specific request context.
- Merchandising controls should influence recommendation behavior without requiring code deployments for normal changes.
- Identity resolution and consent enforcement should be platform-level concerns, not reimplemented per channel.
- Inventory filtering should happen before customer-facing delivery to avoid recommending unavailable items.
- RTW and CM should share foundational services but allow separate compatibility logic and request inputs.

## Operational assumptions
- Near-real-time event ingestion is desirable for behavioral relevance, but not every source requires streaming if freshness targets can still be met.
- Recommendation generation should have fallbacks that work when customer profile or weather data is unavailable.
- Recommendation telemetry must be end-to-end traceable from request through downstream outcome events.
- Internal administration interfaces may consume the same APIs plus additional governance endpoints.

## Implementation-oriented constraints
- Channel consumers need stable schemas and versioning because recommendation logic will evolve.
- Recommendation responses must be explainable enough for debugging, governance, and experimentation, even if not all reasoning is shown customer-facing.
- Source-system data quality gaps should be expected; normalization and validation cannot be deferred.
- Latency-sensitive surfaces such as PDP and clienteling likely require precomputation, caching, or hybrid candidate generation patterns.

## Missing architecture decisions
- Missing decision: online versus batch generation mix for each surface.
- Missing decision: canonical storage choices for product graph, look graph, and event telemetry.
- Missing decision: whether recommendation ranking is a single service or a pipeline of specialized services.
- Missing decision: which systems own experimentation assignment and campaign targeting.
