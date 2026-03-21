# Feature: Catalog and product intelligence

**Upstream traceability:** `docs/project/business-requirements.md` (BR-008); `docs/project/br/br-008-product-and-inventory-awareness.md`, `br-004-rtw-and-cm-support.md`; `docs/project/architecture-overview.md` (catalog ingestion); `docs/project/data-standards.md`; `docs/project/glossary.md`; `docs/project/roadmap.md` (Phase 1 foundation).

---

## 1. Purpose

Ensure every recommendation candidate is **attribute-complete**, **assortment-eligible**, **inventory-valid** (where required), **imagery-ready**, and **compatibility-covered** enough for complete-look credibility—per BR-008—before ranking runs.

## 2. Core Concept

**Product readiness** is not binary globally: hard failures exclude customer-facing use; partial readiness may allow narrowed recommendation types or operator-only review contexts (BR-008).

## 3. Why This Feature Exists

Poor catalog truth produces incoherent **outfits**, stockouts, and mistrust; optimization cannot fix missing fabric/color/formality data (`problem-statement.md`, BR-008).

## 4. User / Business Problems Solved

- P1 shoppers see purchasable, understandable products.
- S2 merchandisers align eligibility with campaigns.
- S4 teams separate ranking issues from data readiness gaps.

## 5. Scope

Ingestion, normalization, canonical IDs, readiness evaluation, compatibility graph inputs, inventory snapshots, imagery gating, freshness/provenance. **Missing decisions:** source PIM vs commerce master; refresh SLAs; numeric thresholds for “imagery ready.”

## 6. In Scope

- Canonical product attributes: category, fabric, color, pattern, fit, season, occasion tags, price tier, RTW vs **CM** fields.
- Assortment and channel eligibility per market.
- Inventory sellability for RTW ecommerce surfaces.
- Compatibility edges and curated **look** membership references.

## 7. Out of Scope

- Final taxonomy governance committee process; creative production for assets; detailed ML feature stores.

## 8. Main User Personas

P1, P3, S2 (merchandising), S4 (data quality visibility).

## 9. Main User Journeys

1. New SKU onboarded → readiness gates computed → appears in eligible candidate pools.
2. Inventory drops → candidate removed or demoted on next sync.
3. CM configuration change → compatibility revalidated before stylist-facing display.

## 10. Triggering Events / Inputs

Catalog feed updates, OMS/inventory events, manual merchandising overrides, image pipeline completions, market config changes.

## 11. States / Lifecycle

`draft → eligible → degraded → withdrawn`; per-dimension flags (attributes, imagery, inventory, compatibility). Version pointers for “which catalog snapshot” tied to **trace ID** (BR-011).

## 12. Business Rules

- No customer-facing ecommerce recommendation of non-sellable RTW SKU unless explicit fallback policy allows substitution messaging (**missing decision**).
- CM products without configuration compatibility coverage cannot participate in configuration-aware CM ranking (BR-004, BR-008).

## 13. Configuration Model

Per-market eligibility rules; imagery thresholds; category-specific mandatory attributes; suppression lists for defective feeds.

## 14. Data Model

**Entities:** `Product` (canonical id + source ids), `Variant`, `AssortmentEligibility`, `InventoryState`, `ImageryAsset`, `CompatibilityEdge`, `ReadinessSnapshot`, `CatalogVersion`.

**Example record (illustrative):** `Product { id, mode: RTW, attributes: {...}, readiness: { inventory: OK, imagery: OK, compatibility: PARTIAL } }`.

## 15. Read Model / Projection Needs

Materialized “recommendation-eligible products” per market/channel/mode; denormalized graph neighborhood for fast candidate expansion; dashboards for readiness KPIs.

## 16. APIs / Contracts

Internal service APIs: `GET /products/{id}/readiness`, `POST /compatibility/validate`, batch inventory snapshot fetch; event payloads include `catalogVersionId`.

## 17. Events / Async Flows

`catalog.product.updated`, `inventory.changed`, `imagery.published`, `compatibility.graph.updated`—downstream decisioning invalidates caches.

## 18. UI / UX Design

Operator-facing data quality dashboards (not customer); surfacing “why suppressed” in internal tools (ties to `explainability-and-auditability.md`).

## 19. Main Screens / Components

Catalog health dashboard; SKU readiness drilldown; compatibility graph explorer (Phase 3+ depth **missing decision**).

## 20. Permissions / Security Rules

Read-only for most services; restricted write for merchandising on exclusions; audit on manual suppressions.

## 21. Notifications / Alerts / Side Effects

Alerts on feed lag, spike in ineligible SKUs, broken compatibility coverage for top anchors.

## 22. Integrations / Dependencies

Commerce (Shopify/OMS per `architecture-overview.md`), PIM, DAM, warehouse inventory.

## 23. Edge Cases / Failure Cases

Conflicting source systems → last-writer-wins vs manual merge **missing decision**; partial translations; discontinued items still referenced by old **curated looks** → governance quarantine.

## 24. Non-Functional Requirements

Near-real-time inventory for PDP; batch acceptable for some attributes; data lineage retained per `data-standards.md`.

## 25. Analytics / Auditability Requirements

Log readiness reason codes in recommendation traces; measure % impressions with degraded catalog context (BR-010, BR-011).

## 26. Testing Requirements

Golden catalog fixtures; property tests on compatibility rules; load tests on snapshot materialization.

## 27. Recommended Architecture

Ingestion pipelines → canonical store → readiness evaluator → graph service → low-latency read models for decisioning.

## 28. Recommended Technical Design

CDC or event-driven updates; feature store optional later; explicit `catalogVersionId` in every recommendation request path.

## 29. Suggested Implementation Phasing

- **Phase 1:** RTW PDP/cart readiness gates; inventory + core attributes + imagery for ecommerce.
- **Phase 2:** Richer occasion/season completeness checks for expanded surfaces.
- **Phase 4:** CM configuration-aware validation depth (BR-004).

## 30. Summary

Catalog and inventory awareness is a hard gate for trustworthy **outfits** (BR-008). The feature must expose readiness explicitly so ranking never masks data defects. Thresholds and source-system precedence remain key **missing decisions** for architecture.
