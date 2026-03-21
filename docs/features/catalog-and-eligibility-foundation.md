# Catalog and eligibility foundation

## Traceability / sources used

- **Canonical:** `docs/project/vision.md`, `docs/project/goals.md`, `docs/project/problem-statement.md`, `docs/project/personas.md`, `docs/project/product-overview.md`, `docs/project/business-requirements.md`, `docs/project/roadmap.md`, `docs/project/architecture-overview.md`, `docs/project/standards.md`, `docs/project/data-standards.md`, `docs/project/agent-operating-model.md`
- **BR inputs:** **BR-8** (*Product and inventory awareness*) and catalog workflow language in `business-requirements.md`. *Note: there is no dedicated `docs/project/br/` file for BR-8; this spec cites canonical docs plus `business-requirements.md` as agreed.*
- **Related BR context (downstream consumers):** BR-1–BR-7, BR-9–BR-11 (eligibility and attributes consumed by recommendation, governance, telemetry).

---

## 1. Purpose

Establish a **normalized product catalog and inventory-aware eligibility layer** so the platform can assemble **outfit** recommendations from **looks** and products that are stylistically valid, commercially relevant, and **operationally purchasable** (assortment, region, stock constraints). This foundation feeds curated/rule-based/AI-ranked paths without embedding channel-specific UI assumptions.

## 2. Core Concept

A **canonical product record** (with stable ID and source mappings) plus governed attributes (including **RTW** vs **CM**) and **inventory or availability signals** used to filter and rank candidates. A **look** is a merchandising grouping; customer-facing outputs are **outfits** assembled from eligible products.

## 3. Why This Feature Exists

Recommendations that ignore attributes, region, or availability erode trust and conversion. The vision and problem statement require complete-look usefulness, not similarity-only suggestions; BR-8 requires product and inventory awareness for coherent, relevant sets.

## 4. User / Business Problems Solved

- Customers see complements that **fit the anchor** and **can be bought** in context.
- Merchandisers and stylists trust that suggestions respect assortment and brand rules.
- Analytics can attribute outcomes to sets that were **eligible by construction**, not broken by stale catalog data.

## 5. Scope

**In:** ingestion, normalization, canonical IDs, attribute model for compatibility and ranking, inventory/eligibility integration at recommendation time, data quality guardrails, read models for recommendation services.

**Adjacent:** look graph and merchandising governance (separate specs) consume this layer; they do not replace catalog ownership.

## 6. In Scope

- Canonical product ID and source-system identifier maps.
- Attribute coverage aligned to `data-standards.md` (category, fabric, color, pattern, fit, season, occasion, style tags, price tier, imagery references, **RTW** and **CM** fields).
- Inventory or availability fields required for **eligibility** (exact field set to be finalized per source system).
- Freshness and provenance metadata for catalog vs inventory.
- Validation, quarantine, and monitoring hooks for recommendation-critical fields.

## 7. Out of Scope

- Replacing core commerce, PIM, or OMS.
- Full assortment planning, demand forecasting, or warehouse optimization (per `goals.md` non-goals).
- Final channel **surface** UI implementations (those specs consume APIs).

## 8. Main User Personas

- **Occasion-led online shopper** — needs coherent, purchasable complements.
- **Style-aware returning customer** — needs regionally correct assortment and attributes for personalization.
- **Custom Made customer** — needs **CM** attributes and configuration-aware compatibility inputs (consumed later by CM orchestration).
- **Merchandiser / stylist** — needs trustworthy representation of what can be recommended.
- **Analytics lead** — needs consistent IDs and attribute integrity for measurement.

## 9. Main User Journeys

1. **Product-led complete-look (RTW):** anchor product on PDP → platform loads canonical product + attributes + eligibility → downstream graph/rules/ranking propose **outfit** items that remain eligible.
2. **Regional shopper:** locale/market determines assortment eligibility before presentation on any **surface**.
3. **Operational correction:** bad feed fixed → eligibility and attributes update → recommendation outputs shift traceably (with versioning/freshness visible internally).

## 10. Triggering Events / Inputs

- Catalog delta feeds (batch or near-real-time, per integration reality in `architecture-overview.md`).
- Inventory or availability updates.
- Manual or tool-driven corrections in source systems (propagate via ingestion).
- Recommendation request time: **surface** and **channel** context may supply market, locale, or store context that affects eligibility.

## 11. States / Lifecycle

- **Raw ingested** → **normalized** → **validated** → **recommendation-ready** (or **quarantined** / **degraded** when critical fields missing).
- Product **active / discontinued**, **seasonal window**, regional **assortment** flags as provided by source data.
- Inventory states (e.g. in stock, low stock, backorder, not sold in market) mapped to eligibility outcomes per business rules (to be detailed when source schema is fixed).

## 12. Business Rules

- Hard **compatibility** and **governance** rules (from other modules) apply **after** eligibility; this feature must supply accurate inputs so rules do not operate on wrong SKUs.
- **Inventory and assortment constraints** materially affect recommendation eligibility (per `business-requirements.md` assumptions).
- **RTW** and **CM** attribute requirements differ; missing **CM**-critical attributes must not silently pass as RTW-equivalent.

## 13. Configuration Model

- Per-market or per-region assortment mappings.
- Thresholds for “exclude vs downrank” when inventory signals are weak or stale (open decision in §32).
- Data quality rules: required fields for recommendation participation by **surface** or recommendation type.

## 14. Data Model

- **Product:** canonical `productId`, source IDs, attributes, imagery references, **RTW**/**CM** flags, category taxonomy links.
- **Inventory snapshot or view:** availability, stock indicators, ship/store constraints as available from OMS/commerce.
- **Provenance:** `sourceSystem`, `lastUpdated`, optional `version` or batch ID.
- **Mappings:** explicit tables or documents for source SKU → canonical ID.

## 15. Read Model / Projection Needs

- Low-latency **product attribute** read for recommendation path.
- **Eligibility projection** combining assortment + inventory suitable for filter pushdown in the recommendation engine.
- Search or graph-friendly views for “compatible candidates,” fed by attributes (graph spec consumes this).

## 16. APIs / Contracts

- Internal service contracts (illustrative): `GET /products/{canonicalProductId}`, `POST /products/batch-resolve`, `GET /products/{id}/eligibility?market=…`.
- Recommendation **delivery API** requests carry `productId`, market, and context; catalog services answer normalization and eligibility queries—not necessarily exposed to all external clients.
- Responses should avoid leaking internal quarantine detail to customer-facing payloads.

## 17. Events / Async Flows

- `CatalogProductUpserted`, `CatalogProductInvalidated`, `InventoryUpdated` (names illustrative)—consumers: recommendation cache invalidation, graph maintenance jobs, analytics freshness metrics.

## 18. UI / UX Design

- Primarily **internal** visibility: data health dashboards, quarantine review, attribute completeness by category (**surface** UIs consume recommendations, not this module’s admin UX in full detail here).

## 19. Main Screens / Components

- Internal catalog health / completeness dashboards (deferred to implementation plan).
- Optional merchandising tooling hooks to flag “not recommendation-ready” products.

## 20. Permissions / Security Rules

- Restricted access to unpublished or embargoed assortment where applicable.
- No customer-facing exposure of internal eligibility reasons that imply sensitive inventory strategy beyond what commerce already shows.

## 21. Notifications / Alerts / Side Effects

- Alerts on feed lag beyond SLO, spike in quarantined records, or broken identifier mappings.
- Downstream **degraded mode**: fewer recommendations or rule-based fallbacks when eligibility data is unreliable (`architecture-overview.md` operational assumptions).

## 22. Integrations / Dependencies

- Commerce, PIM, catalog, and inventory sources (`architecture-overview.md`).
- **Downstream:** look graph, rule engine, recommendation orchestration, **delivery API**, analytics.

## 23. Edge Cases / Failure Cases

- Partial updates: attribute changed without inventory refresh and vice versa.
- Multi-source conflicts: two sources disagree on canonical mapping—require resolution rules.
- **CM** partial configuration: catalog must represent configurable options without pretending they are finished SKUs (handoff to CM orchestration spec).
- Zero eligible complements: downstream must empty-set gracefully with telemetry.

## 24. Non-Functional Requirements

- Latency compatible with recommendation **surface** SLAs (exact numbers in architecture phase).
- Availability: highly available read path with caching; tolerate stale inventory with explicit freshness metadata.
- Scalability for full catalog and high read QPS during peak commerce traffic.

## 25. Analytics / Auditability Requirements

- Track catalog/inventory freshness metrics; correlate with recommendation coverage and dismissal rates.
- Record which eligibility version or snapshot contributed to a **recommendation set** (via trace context in explainability spec).

## 26. Testing Requirements

- Contract tests per source adapter; golden files for normalization.
- Property-based or table tests for eligibility matrix (market × product state).
- Chaos or lag simulation for inventory staleness behavior.

## 27. Recommended Architecture

- Ingestion layer normalizes to canonical store; **catalog and product model** service exposes read APIs and projections (`architecture-overview.md` subsystem list).
- Clear separation: **descriptive** catalog vs **operational** eligibility.

## 28. Recommended Technical Design

- Event-driven updates with idempotent upserts; CDC or batch reconciliation as supported by each source.
- Cache with TTL tied to freshness policy; bust on events.
- Feature flags for strict vs soft eligibility in early phases (documented per `roadmap.md` Phase 1 emphasis on high-confidence sets).

## 29. Suggested Implementation Phasing

- **Phase 1:** RTW-focused attributes and inventory gating for PDP/cart paths; minimal viable markets.
- **Phase 2:** broaden markets; tighten freshness SLOs; enrich attributes for personalization and context.
- **Phase 4:** deepen **CM** representation and configuration linkage.

## 30. Summary

The catalog and eligibility foundation is the **prerequisite** for trustworthy **outfit** recommendations: canonical IDs, governed attributes, and inventory-aware filtering ensure curated, rule-based, and AI-ranked outputs stay **operationally valid** across **channels** and **surfaces**.

## 31. Assumptions

- Initial source systems for catalog and inventory will be identified before build (`business-requirements.md` open questions); this spec assumes at least one commerce-backed source can provide SKU, attributes, and basic availability.
- Merchandising can supply enough curated compatibility inputs once attributes are reliable (`goals.md`).
- API-first delivery remains the primary consumption pattern (`standards.md`).

## 32. Open Questions / Missing Decisions

- Which systems are **system of record** for catalog, inventory, and regional assortment at first launch (`business-requirements.md`)?
- Exact inventory granularity (store-level vs regional vs online-only) required per **surface** and **channel**?
- Hard **exclude** vs **downrank** when inventory is uncertain or stale?
- How **CM** configuration options are represented in the canonical product model until CM orchestration spec is implemented?
- Required real-time freshness thresholds per **surface** (`business-requirements.md` open questions)?
