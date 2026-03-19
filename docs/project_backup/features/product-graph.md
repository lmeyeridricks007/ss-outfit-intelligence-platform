# Feature Deep-Dive: Product Graph (F5)

**Feature ID:** F5  
**BR(s):** BR-4 (Product and outfit graph)  
**Capability:** Model product relationships and compatibility  
**Source:** `docs/project/feature-list.md`, `docs/project/domain-model.md`, `docs/project/architecture-overview.md`

---

## 1. Purpose

Model **product relationships** (e.g. suit → shirt → tie → shoes) and **compatibility/substitution** by style, fabric, and occasion so the recommendation engine can suggest **coherent looks** and next-best items. The product graph is the structural backbone for “complete the look” and outfit-level recommendations (BR-4).

## 2. Core Concept

A **product graph** that:
- Stores **nodes**: products (from catalog ingestion F1) with canonical product_id and attributes (category, fabric, color, pattern, fit, season, occasion, price tier, RTW/CM).
- Stores **edges/relationships**: compatibility (A goes with B), substitution (A can replace B), category hierarchy (suit → shirt → tie → shoes), and optionally similarity (same style family).
- Exposes **queries** to the recommendation engine: e.g. “products compatible with product_id X for occasion Y,” “substitutes for product_id Z,” “products in same style family.”
- Supports **configurable** rules (style, fabric, occasion) that merchandising can influence via **outfit graph / look store** (F6) and **merchandising rules** (F10).

## 3. Why This Feature Exists

- **BR-4:** A product graph must model relationships and compatibility; rules must be configurable by merchandising.
- **BR-1, BR-5:** Outfit and complete-the-look recommendations require knowing which products go together; the engine uses the graph for candidate generation and ranking.
- **Differentiation:** Competitors often use “frequently bought together”; SuitSupply needs **style and occasion-aware** compatibility (fabric, formality, color) for fashion coherence.

## 4. User / Business Problems Solved

- **Customers:** See matches that make sense (e.g. shirt and tie that go with a suit), not random co-occurrence.
- **Merchandising:** Control compatibility and substitution via rules and curated looks (F6).
- **Engine:** Single source of relationship and compatibility data for all strategies (curated, rule-based, AI).

## 5. Scope

### 6. In Scope

- **Relationship types:** Compatible_with (A goes with B), Substitution (A can replace B), Part_of_category_flow (e.g. suit → shirt → tie → shoes for “complete the look” ordering). Optional: Similar_to (same style family or attribute-based).
- **Attributes for compatibility:** Style, fabric, color, pattern, occasion, price tier, season. Rules: e.g. “formal shirt with formal suit,” “no pattern clash,” “season match.”
- **Graph storage:** Nodes = products (id, attributes); edges = relationship type, optional weight/priority, source (curated vs derived). Support **bulk load** from F1 catalog and **incremental** updates when catalog changes.
- **Query API:** Get compatible products for product_id (and optional occasion, channel); get substitutes; get products by category path. Used by **recommendation engine** (F9).
- **Coverage:** Target percentage of key categories (suits, shirts, ties, shoes) in at least one relationship (target TBD—missing decision). **Rule execution** auditable (BR-4 success metric).
- **RTW vs CM:** Products may be tagged RTW, CM, or both; graph and compatibility apply to both; CM may add fabric/appointment context (from F8/F11) but graph itself is product-centric.

### 7. Out of Scope

- **Curated look definitions** (product sets) — owned by **outfit graph / look store** (F6). This feature is **relationship and compatibility** only; F6 stores which products form a “look.”
- **Merchandising pin/exclude rules** — owned by **merchandising rules engine** (F10). Graph provides candidates; F10 filters and orders.
- **Inventory filtering** — inventory is applied by F9 or F10; graph does not filter by stock (but may receive “in stock” filter from engine).
- **Authoring UI** — graph can be built from rules and catalog; authoring of rules may be in Admin (F19/F20) or config; graph itself is a data/query layer.

## 8. Main User Personas

- **Merchandising Manager** — Indirect; compatibility rules and coverage affect recommendation quality.
- **Style-Seeking / Returning Customer** — Indirect; benefit from coherent recommendations.
- **Backend/Data engineers** — Build and maintain graph model and query API.

## 9. Main User Journeys

- **Graph build:** After catalog sync (F1), job or service builds/updates graph: load products, compute or load relationships (from rules, curated data, or algorithm), write edges. Optional: incremental update on product add/update/retire.
- **Recommendation request:** Engine (F9) calls graph: “compatible with product X, occasion Y, limit N” → graph returns product_ids (and optional weights). Engine merges with other strategies and applies F10 rules.
- **Coverage report:** Admin or batch job reports “% of suits with ≥1 compatible shirt”; used for BR-4 success metric and tuning.

## 10. Triggering Events / Inputs

- **Catalog update (F1):** Product created/updated/retired → trigger graph update (full or incremental).
- **Request-time:** Query from F9: product_id, occasion, channel, limit, optional filters (category, price tier).
- **Batch:** Nightly or on-demand full rebuild of derived relationships (e.g. similarity from attributes).
- **Inputs:** Product catalog (from F1); compatibility rules (from config or F6); optional curated edges from merchandising.

## 11. States / Lifecycle

- **Product node:** Active (in catalog) / Retired (excluded from new recommendations; may keep edges for history).
- **Edge:** Active / Deprecated (e.g. product retired).
- **Graph build:** Idle → Building → Ready / Failed. Query service serves last good state during build.

## 12. Business Rules

- **Compatibility:** Defined by rules (e.g. category pairing: suit–shirt–tie) and optionally attribute rules (color harmony, pattern, occasion). Conflicting rules: precedence (e.g. curated > derived).
- **Substitution:** Same category or defined “substitution group”; optional attribute similarity (size, color). Used when primary product out of stock or excluded.
- **Coverage:** Key categories must participate in at least one relationship (target % TBD); monitoring and alerting if coverage drops.
- **Freshness:** Graph must reflect current catalog; retired products removed or marked so engine does not recommend them.

## 13. Configuration Model

- **Relationship rules:** Category-to-category compatibility (e.g. suit → shirt), attribute rules (occasion, fabric), weights/priority. Stored in config or Admin (F19/F20).
- **Source priority:** Curated edges > rule-derived > algorithm-derived. Optional: disable algorithm-derived for certain categories.
- **Feature flags:** Use graph for candidate generation (on/off per placement or strategy).

## 14. Data Model

- **Node:** product_id, category, fabric, color, pattern, fit, season, occasion, price_tier, style_family, rtw, cm, status, updated_at (from F1; graph may cache or reference).
- **Edge:** source_product_id, target_product_id, relationship_type (compatible_with | substitution | similar_to), weight/priority, source (curated | rule | algorithm), valid_from, valid_to.
- **Compatibility rule (config):** category_pair, attribute_constraints (occasion, fabric, etc.), priority. Used to generate or validate edges.
- **Graph snapshot/metadata:** version, built_at, product_count, edge_count, coverage_metrics.

## 15. Read Model / Projection Needs

- **Recommendation engine (F9):** Primary consumer. Queries: compatible products, substitutes, similar products. Reads from graph API or embedded index; no direct DB access from engine if graph is a service.
- **Outfit graph (F6):** May use graph to validate look composition (all products in a look compatible); or F6 stores look members and graph is used only for dynamic recommendations.
- **Analytics:** Optional: which edges drove recommendations; coverage reports. Export or query for reporting.

## 16. APIs / Contracts

- **Internal (to F9):**  
  - `GET /graph/compatible?product_id=...&occasion=...&limit=20` → list of product_ids (and optional scores).  
  - `GET /graph/substitutes?product_id=...&limit=10` → list of product_ids.  
  - `GET /graph/similar?product_id=...&limit=10` → list of product_ids (if supported).
- **Bulk/Admin:** `POST /graph/rebuild` (internal) or job; optional `POST /graph/edges` to add/remove curated edges.
- **Example:**

```json
GET /graph/compatible?product_id=prod-suit-1&occasion=formal&limit=10
→ 200 OK
{ "product_ids": ["prod-shirt-1", "prod-tie-1", ...], "source": "graph" }
```

## 17. Events / Async Flows

- **Consumed:** Catalog product events (from F1) or sync completion to trigger graph update.
- **Emitted (optional):** `GraphBuilt` (version, coverage) for monitoring and optional cache invalidation.
- **Flow:** Catalog update → (async) graph job runs → update edges/nodes → query API serves new version. Or request-time query only (no event).

## 18. UI / UX Design

- **Admin (optional):** Graph coverage dashboard; list of relationship rules; trigger rebuild; view sample compatible sets. Not required for Phase 1; can be config-driven.
- **Monitoring:** Graph build duration, coverage %, query latency, error rate.

## 19. Main Screens / Components

- Coverage report; rule list; rebuild trigger; sample queries. Operational.

## 20. Permissions / Security Rules

- **Graph API:** Internal only (F9). No customer-facing exposure. Admin role to trigger rebuild or edit curated edges.
- **Data:** Product data only; no PII. Read-only for engine; write for graph build job and admin.

## 21. Notifications / Alerts / Side Effects

- **Alerts:** Graph build failure, coverage below threshold, query latency spike.
- **Side effects:** F9 recommendations change when graph is updated; ensure no thundering herd (e.g. gradual rollout or cache invalidation).

## 22. Integrations / Dependencies

- **Upstream:** Catalog and inventory ingestion (F1) for product nodes and attributes.
- **Downstream:** Recommendation engine (F9) for candidate generation. Outfit graph (F6) may consume compatibility for look validation.
- **Shared:** Domain model (Product, relationships); glossary (compatibility, substitution); BR-4 (graph coverage, rule execution).

## 23. Edge Cases / Failure Cases

- **Product not in graph:** New product not yet in graph → return empty or fallback to category-based; trigger incremental update.
- **No compatible products:** E.g. very niche product → return empty; F9 fallback strategy (e.g. popular in category) handles empty candidate set.
- **Graph build timeout:** Serve previous version; retry build; alert.
- **Conflicting rules:** Define precedence (curated > rule > algorithm); document and test.
- **Large catalog:** Graph size and query performance; use index (e.g. graph DB, or precomputed adjacency); pagination or limit on query size.

## 24. Non-Functional Requirements

- **Query latency:** p95 &lt; 50–100 ms for compatible/substitute queries so F9 is not bottlenecked.
- **Build time:** Full rebuild within maintenance window (catalog size TBD); incremental &lt; N minutes.
- **Availability:** Query API highly available; build runs async and does not block queries.

## 25. Analytics / Auditability Requirements

- **Audit:** Log graph build runs (version, duration, coverage); optional log of rule sources for edges (for “rule execution” BR-4 metric).
- **Metrics:** Coverage %, query volume, latency; export for BR-4 success metrics.

## 26. Testing Requirements

- **Unit:** Compatibility rule evaluation; edge creation from rules; query logic.
- **Integration:** Load sample catalog and rules; run build; query compatible/substitute; verify F9 receives expected candidates. Test retired product excluded.
- **Contract:** Graph API response schema for F9. Coverage calculation correctness.

## 27. Recommended Architecture

- **Component:** Part of “Product & outfit graph” layer (architecture). Can be a dedicated service (graph API + build job) or embedded index (e.g. in recommendation service) with periodic rebuild.
- **Pattern:** Build: batch or incremental from catalog + rules → write to graph store or index. Query: read-only API. Use graph DB or key-value/index (e.g. Neo4j, or relational + materialized edges) depending on stack.

## 28. Recommended Technical Design

- **Graph store:** Nodes = products (or reference F1 store); edges = table or graph DB. **Build job:** Load products, compute edges from rules and optional ML, write edges. **Query API:** Lookup compatible/substitute by product_id with filters; use index (e.g. BFS, or precomputed lists per product). **Cache:** Optional cache for hot products to reduce load.

## 29. Suggested Implementation Phasing

- **Phase 1:** Core relationship types (compatible_with, substitution); rule-based edges from config; query API for compatible and substitute; feed F9. One category path (e.g. suit → shirt → tie). Coverage metric.
- **Phase 2:** Similar_to; attribute-based rules (occasion, fabric); curated edges from Admin; incremental update on catalog change; coverage dashboard.
- **Later:** ML-derived similarity; full category coverage; performance tuning for large catalog.

## 30. Summary

The **product graph** (F5) models **product relationships** and **compatibility/substitution** for the AI Outfit Intelligence Platform. It consumes catalog data from **F1**, exposes **compatible** and **substitute** (and optional **similar**) queries to the **recommendation engine** (F9), and supports **configurable rules** and optional curated edges. It does not store curated looks (that is F6) or apply merchandising pin/exclude (that is F10). Graph coverage and rule execution are BR-4 success metrics; query latency and build reliability are key non-functional requirements.
