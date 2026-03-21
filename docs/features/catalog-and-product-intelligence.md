# Feature: Catalog and product intelligence

**Upstream traceability:** `docs/project/business-requirements.md` (BR-008, BR-004); `docs/project/br/br-008-product-and-inventory-awareness.md`, `br-004-rtw-and-cm-support.md`, `br-003-multi-surface-delivery.md`, `br-011-explainability-and-auditability.md`; `docs/project/architecture-overview.md`; `docs/project/data-standards.md`; `docs/project/glossary.md`; `docs/project/roadmap.md`; `docs/features/open-decisions.md` (`DEC-014` through `DEC-017`).

---

## 1. Purpose

Define the shared catalog-readiness layer that determines whether a product, variant, curated **look**, or compatibility edge is trustworthy enough to participate in recommendation delivery.

For this platform, catalog and product intelligence is the gate that turns raw product, assortment, imagery, compatibility, and inventory feeds into recommendation-safe product truth. It exists so downstream **outfit**, cross-sell, upsell, contextual, and personal recommendation flows operate on products that are:

- canonically identified
- attribute-complete enough for styling and filtering
- eligible for the current market, channel, and mode
- inventory-valid where immediate sellability matters
- imagery-ready enough for customer-facing presentation
- compatibility-covered enough to support complete-look confidence
- fresh and attributable enough that operators can trust the decision path

## 2. Core Concept

This feature is not just "catalog ingestion." It is a **policy-driven readiness plane**:

`source feeds -> canonical product truth -> readiness evaluation -> eligibility projections -> recommendation candidate pools -> traceable suppression / degradation`

The core idea is that product readiness is multi-dimensional, not globally binary. A product may be:

- fully eligible for RTW PDP/cart use
- eligible only for some recommendation types
- usable in operator-assisted contexts but not customer-facing surfaces
- temporarily degraded because freshness, imagery, or inventory confidence fell below policy
- fully suppressed because a hard business rule failed

## 3. Why This Feature Exists

The product vision depends on style credibility and operational trust. Ranking, personalization, and governance cannot rescue weak product truth after the fact.

Without a strong catalog and product intelligence layer:

- complete-look recommendations become visually or stylistically incoherent
- RTW ecommerce surfaces show unavailable or off-assortment items
- CM recommendations imply compatibility that cannot actually be validated
- channel teams fork local eligibility logic because there is no shared readiness source
- analytics confuse ranking problems with catalog-quality problems
- operators lose trust because recommendation traces cannot explain why an item was allowed or suppressed

This feature therefore exists as a Phase 1 foundation in `docs/project/roadmap.md`, not as a later optimization.

## 4. User / Business Problems Solved

| User / stakeholder | Problem to solve | What this feature enables |
| --- | --- | --- |
| P1 anchor-product shopper | Recommended items may be unavailable, visually weak, or incompatible with the browsed product | Immediate-shopping surfaces receive only recommendation-safe RTW candidates |
| P2 returning customer | Personalization can amplify bad catalog truth instead of good taste signals | Personalization operates within catalog-readiness boundaries instead of overriding them |
| P3 occasion-led shopper | Occasion or complete-look suggestions can feel generic or broken when category / compatibility data is incomplete | Occasion and outfit experiences depend on validated category, compatibility, and imagery coverage |
| S1 stylist / clienteling operator | Assisted-selling flows lose credibility when CM or premium recommendations are under-specified | Operator-facing experiences show readiness state and degraded confidence rather than pretending certainty |
| S2 merchandiser | Hard business intent around assortment, exclusions, or imagery standards is applied inconsistently | Eligibility and suppression rules become centrally managed and auditable |
| S4 product / analytics / optimization | Teams cannot tell whether low performance came from ranking, stale data, or invalid assortment | Readiness KPIs, suppression reasons, and degraded-state telemetry separate data issues from ranking issues |
| Architecture / engineering | Every downstream service reinterprets product truth differently | Shared canonical IDs, policy versions, and projections prevent contract drift |

## 5. Scope

This feature covers the implementation-oriented requirements for:

- source ingestion and canonical product identity
- attribute normalization and recommendation-facing completeness evaluation
- market, channel, lifecycle, and mode-specific eligibility
- inventory-validity handling for interactive ecommerce use
- imagery readiness for customer-facing recommendation use
- compatibility coverage inputs for complete-look assembly
- freshness, provenance, and conflict handling across source systems
- operator visibility into readiness, suppression, and degradation

This feature does **not** choose the final PIM or OMS vendor, define creative-asset production workflows, or freeze low-level serving architecture. Those remain architecture-stage choices as long as they preserve the business semantics defined here.

**Primary missing decisions:** `docs/features/open-decisions.md` (`DEC-014` through `DEC-017`) covering source-of-truth precedence, readiness policy thresholds, inventory freshness and fallback policy, and minimum CM field groups for customer-facing compatibility claims.

## 6. In Scope

- Canonical product and variant IDs with source-system mappings
- Recommendation-facing attributes such as category, fabric, color, pattern, fit, season, occasion, style tags, price tier, and mode context
- Assortment and lifecycle eligibility by market and channel
- RTW sellability and inventory-sensitive gating for ecommerce recommendation surfaces
- CM field-group readiness needed for configuration-aware recommendation behavior
- Imagery readiness, including enough visual coverage for customer-facing recommendation use
- Compatibility edges, curated **look** membership, and their provenance
- Product-readiness snapshots and reason codes
- Read models and dashboards for catalog health, suppression reasons, and degraded-state visibility

## 7. Out of Scope

- Final organization process for taxonomy governance committees
- Creative photo-shoot or DAM production operations
- ML feature-store design beyond what is required for readiness-state outputs
- Final UI pixel design for internal catalog-health dashboards
- Full implementation ticket breakdown for ingestion pipelines or operator tools
- Search, browse, or non-recommendation merchandising logic unrelated to recommendation readiness

## 8. Main User Personas

- **P1: Anchor-product shopper** - expects complete-look and adjacent-item recommendations to be immediately relevant and purchasable
- **P2: Returning customer** - expects personal or contextual recommendations to remain valid, not just personalized
- **P3: Occasion-led shopper** - expects recommendations to be coherent for occasion, season, and visual presentation
- **S1: Stylist / clienteling operator** - needs readiness visibility for assisted selling, especially as CM depth grows
- **S2: Merchandiser** - needs control and diagnostics for assortment eligibility, manual suppressions, and imagery-quality policy
- **S4: Product / analytics / optimization stakeholder** - needs measurable catalog quality and degraded-state signals
- **Engineering / architecture teams** - need a shared product-readiness contract rather than per-service interpretation

## 9. Main User Journeys

### Journey A: New RTW SKU becomes recommendation-eligible
1. PIM and commerce systems publish a new product and sellable variants.
2. Catalog ingestion normalizes IDs, attributes, lifecycle state, and market eligibility.
3. Imagery and compatibility inputs arrive from DAM and look / rule sources.
4. Readiness evaluator computes dimension-level status.
5. Once hard requirements pass for the target market and channel, the SKU appears in recommendation candidate pools.

### Journey B: Inventory drops on an active PDP
1. OMS or inventory service publishes a sellability change for a recommended RTW variant.
2. Inventory-sensitive readiness projections for PDP and cart are recomputed.
3. Candidate pools invalidate stale entries and publish replacement-eligible products where policy allows.
4. Delivery and trace paths record that the prior candidate was suppressed or degraded because of inventory validity.

### Journey C: CM compatibility data is incomplete
1. A CM garment or fabric combination exists in catalog feeds.
2. Required CM field groups or compatibility mappings are missing.
3. Product remains available for operator review or limited contexts if policy allows, but customer-facing configuration-aware CM recommendation usage is blocked.
4. Operator tools show why the item is not eligible rather than letting ranking fail silently.

### Journey D: Source conflict or feed lag incident
1. PIM, commerce, or DAM publishes conflicting values or stops updating within freshness expectations.
2. Feed-health logic marks affected product truth as lower confidence or degraded.
3. Readiness policies narrow recommendation use, favoring safer candidate pools.
4. Alerts and dashboards show the incident, affected products, and resulting recommendation impact.

## 10. Triggering Events / Inputs

This feature reacts to:

- product create / update / withdraw events from PIM or commerce systems
- variant or SKU sellability and inventory events from OMS / inventory services
- market and channel assortment changes
- DAM / imagery publication or invalidation events
- curated **look** changes and compatibility-graph updates
- manual merchandising suppressions or exception approvals
- freshness and feed-health timers
- category-policy or readiness-policy version changes
- CM field-group updates or service-availability changes

## 11. States / Lifecycle

### Product-readiness lifecycle
`discovered -> normalized -> evaluated -> eligible | degraded | suppressed -> withdrawn`

### Dimension-level readiness states
Each product or variant should preserve independent status for:

- `attributes`
- `assortment`
- `inventory`
- `imagery`
- `compatibility`
- `freshness`
- `modeSpecificReadiness`

Suggested normalized values:

- `PASS`
- `PARTIAL`
- `FAIL`
- `UNKNOWN`
- `STALE`

### Lifecycle interpretation

- **eligible:** all hard requirements for the target market, channel, recommendation type, and mode passed
- **degraded:** one or more non-fatal dimensions weakened, so recommendation breadth or surface eligibility narrows
- **suppressed:** a hard rule failed, so customer-facing recommendation use is blocked
- **withdrawn:** lifecycle or assortment state intentionally removes the product from recommendation use

Every state must be traceable to a policy version and source timestamps so recommendation traces can reconstruct why the state applied.

## 12. Business Rules

- Hard readiness failures must be resolved **before** ranking. Ranking cannot "rescue" an ineligible product.
- Curated content does not bypass hard assortment, lifecycle, inventory, or policy validity rules.
- RTW ecommerce recommendation surfaces must not treat unknown or stale sellability as normal inventory-valid state.
- CM recommendation behavior must not claim configuration-aware compatibility when mandatory CM fields or compatibility evidence are incomplete.
- A product missing recommendation-critical attributes for a requested recommendation type must be suppressed or narrowed to safer use cases.
- Customer-facing recommendation use requires imagery readiness; operator-only contexts may allow lower visual thresholds if explicitly configured.
- Unknown freshness must not be interpreted as fresh truth.
- Recommendation contracts must preserve readiness reason codes so downstream surfaces and traces do not invent local explanations.
- Market and channel eligibility must be explicit; product existence in a source catalog is not enough to imply recommendation eligibility.
- Manual exceptions and suppressions must be audited, versioned, and time-bounded where appropriate.

## 13. Configuration Model

This feature needs a policy layer that supports:

- required attribute groups by category and recommendation type
- per-surface eligibility expectations such as PDP, cart, homepage, email, and clienteling
- market and channel eligibility overrides
- inventory freshness windows by surface and mode
- imagery readiness thresholds by category and surface
- compatibility depth expectations for `outfit` vs adjacent cross-sell / upsell use
- CM field-group requirements before configuration-aware recommendation use
- manual suppression lists, exception approvals, and expiry windows
- alert thresholds for feed lag, readiness drop, and suppression spikes
- policy versioning so traces can explain which rules were applied

Configuration changes must be versioned and auditable because they materially affect what products may enter recommendation candidate pools.

## 14. Data Model

### Core entities

| Entity | Purpose | Required core fields |
| --- | --- | --- |
| `Product` | Canonical product identity and shared attributes | `productId`, `sourceIds`, `mode`, `category`, canonical attributes, lifecycle state |
| `Variant` | Sellable or configurable child entity | `variantId`, `productId`, size / option context, sellability linkage |
| `AssortmentEligibility` | Market and channel eligibility state | `productIdOrVariantId`, `market`, `channel`, `eligibilityState`, `effectiveFrom`, `effectiveTo` |
| `InventorySnapshot` | Inventory-validity view for recommendation use | `variantId`, `sellableState`, `inventoryQtyOrBucket`, `capturedAt`, `inventorySource` |
| `ImageryAsset` | Recommendation-facing visual-readiness metadata | `assetId`, `productIdOrVariantId`, `assetRole`, `qualityState`, `publishedAt` |
| `CompatibilityEdge` | Governed compatibility or curated relationship | `edgeId`, `sourceType`, `leftEntityId`, `rightEntityId`, `conditions`, `confidenceOrPolicyState` |
| `ProductReadinessSnapshot` | Evaluated readiness output | `snapshotId`, `entityId`, dimension statuses, `reasonCodes`, `policyVersionId`, `catalogVersionId`, `evaluatedAt` |
| `CatalogVersion` | Snapshot lineage for traceability | `catalogVersionId`, source versions, `createdAt`, `freshnessSummary` |
| `FeedHealthIncident` | Operational visibility for degraded inputs | `incidentId`, `sourceSystem`, `startedAt`, `affectedScope`, `status` |

### Example readiness payload

```json
{
  "snapshotId": "prdready_01JPDQM8WJVC6GG2FWZB2M4V3B",
  "entityId": "variant_12345_blue_48",
  "mode": "RTW",
  "market": "NL",
  "channel": "web-pdp",
  "statuses": {
    "attributes": "PASS",
    "assortment": "PASS",
    "inventory": "PASS",
    "imagery": "PASS",
    "compatibility": "PARTIAL",
    "freshness": "PASS",
    "modeSpecificReadiness": "PASS"
  },
  "reasonCodes": [
    "compatibility_missing_outerwear_edge"
  ],
  "policyVersionId": "readiness_policy_v12",
  "catalogVersionId": "catalog_v2026_03_21_1400",
  "evaluatedAt": "2026-03-21T14:05:11Z"
}
```

### Data-model notes

- Source-system mappings must be preserved rather than flattened away.
- Readiness snapshots must distinguish `UNKNOWN` from `FAIL` and `STALE`.
- Compatibility provenance should distinguish curated, rule-based, and derived relationships.
- Inventory-sensitive uses should evaluate at variant or sellable-SKU resolution when required by the surface.

## 15. Read Model / Projection Needs

This feature requires materialized projections for:

- recommendation-eligible products by market, channel, mode, and recommendation type
- variant-level sellability views for interactive ecommerce use
- top-anchor compatibility neighborhoods for fast candidate expansion
- imagery-readiness views for customer-facing surfaces
- catalog-health dashboards by category, market, and source system
- suppression-reason and degraded-state summaries
- feed-health and freshness incident views

The projection strategy must support both:

- low-latency reads for recommendation candidate retrieval
- operator analytics for understanding why coverage or eligibility changed

## 16. APIs / Contracts

Architecture may choose transport later, but the semantic contracts below are required.

### Required contract surfaces

- `GET /catalog/products/{id}/readiness`
- `GET /catalog/variants/{id}/eligibility?market=...&channel=...`
- `POST /catalog/readiness/evaluate`
- `POST /catalog/compatibility/validate`
- `GET /catalog/health/summary`

### Required response concepts

- canonical entity ID and source mappings
- policy version and catalog version
- dimension-level readiness statuses
- reason codes for suppression or degradation
- market / channel / mode context
- freshness timestamps or freshness state

### Contract expectations for downstream consumers

- Recommendation decisioning must consume readiness projections rather than reconstructing catalog validity from raw feeds.
- Delivery and explainability paths must preserve `catalogVersionId`, readiness reason codes, and policy version where relevant.
- APIs should remain stable enough that ecommerce, analytics, and operator tools do not fork readiness semantics.

## 17. Events / Async Flows

### Primary event families

- `catalog.product.discovered`
- `catalog.product.normalized`
- `catalog.product.withdrawn`
- `catalog.assortment.updated`
- `catalog.inventory.changed`
- `catalog.imagery.published`
- `catalog.compatibility.updated`
- `catalog.readiness.evaluated`
- `catalog.readiness.degraded`
- `catalog.feed.incident.opened`
- `catalog.feed.incident.resolved`

### Flow A: Product update to eligibility projection
1. Source update lands from PIM or commerce.
2. Normalization service resolves canonical ID and attribute mapping.
3. Readiness evaluator runs policy checks for relevant markets, channels, and modes.
4. Projection service updates eligible-candidate pools.
5. Downstream recommendation caches invalidate affected entries.

### Flow B: Inventory-sensitive suppression
1. Inventory event changes a sellable RTW variant from valid to invalid.
2. Inventory projection updates immediately for interactive ecommerce scopes.
3. Readiness snapshots for PDP and cart uses flip to `FAIL` or `STALE`.
4. Recommendation candidate pools publish replacement-safe state.
5. Trace and analytics systems receive suppression reason context.

### Flow C: Feed degradation
1. Freshness monitor detects a source feed lag or conflicting data state.
2. Incident is recorded and linked to affected entities or scopes.
3. Product-readiness states degrade according to configured policy.
4. Alerts notify operators and dashboards show recommendation impact.

## 18. UI / UX Design

This feature primarily supports internal experiences, not customer-facing screens. UX goals should emphasize explanation speed and confidence boundaries.

### UX principles

- show readiness by dimension, not only a single pass / fail badge
- make market, channel, and mode context explicit
- separate "suppressed", "degraded", and "unknown" states clearly
- allow drilldown from category-level health to product-level reason codes
- preserve the origin of compatibility edges and manual overrides
- highlight freshness and feed-health incidents that changed recommendation coverage

Customer-facing surfaces should not expose raw readiness diagnostics, but shared contracts should still carry enough degraded-state metadata for safe fallbacks.

## 19. Main Screens / Components

- **Catalog health dashboard** - readiness coverage, degraded-state trends, and feed health by market / category
- **Product readiness drilldown** - dimension statuses, source lineage, reason codes, and recent evaluation history
- **Suppression queue** - products or variants blocked for customer-facing recommendation use with sortable causes
- **Compatibility explorer** - coverage of curated and rule-based edges around anchor products and key categories
- **Feed incident panel** - lag, stale-source scopes, and operational impact on recommendation eligibility
- **Manual exception panel** - merchandiser-approved suppressions, temporary overrides, and expiry tracking

## 20. Permissions / Security Rules

- Most downstream services should have read-only access to readiness projections.
- Write access to policy versions, manual suppressions, and exceptions should be restricted to authorized operator roles.
- Source-system credentials and operational feeds must remain isolated from broad operator access.
- No customer PII is required for the core catalog-readiness feature; access should stay product-data scoped wherever possible.
- All manual suppressions, overrides, and policy edits must create audit records with actor, timestamp, and scope.

## 21. Notifications / Alerts / Side Effects

This feature must support alerts for:

- feed lag beyond freshness policy
- sudden spikes in suppressed or degraded products
- top-category imagery readiness drops
- compatibility coverage regressions for high-volume anchors
- inventory-validity outages that affect interactive ecommerce surfaces
- conflicting source data for authoritative fields

Side effects include:

- candidate-pool invalidation when readiness changes
- recommendation-quality dashboards annotating catalog incidents
- explainability traces receiving updated suppression reason codes
- operator workflows for remediation and manual exception review

## 22. Integrations / Dependencies

- **PIM / commerce catalog systems** - source product and lifecycle data
- **OMS / inventory systems** - sellability and inventory state
- **DAM / imagery systems** - published asset readiness
- **Curated look and compatibility sources** - look membership, edges, and constraints
- **Merchandising governance** - manual suppressions, policy versions, and exceptions
- **Recommendation decisioning and ranking** - consumes readiness projections rather than raw product truth
- **Shared contracts and delivery API** - carries catalog version and degraded-state metadata
- **Explainability and auditability** - reconstructs why a product or variant was eligible or suppressed
- **Analytics and experimentation** - measures catalog-readiness impact separately from ranking impact

The most important dependency rule is directional: other recommendation features depend on this feature's projections, but this feature should not depend on ranking decisions to infer readiness.

## 23. Edge Cases / Failure Cases

- **Conflicting source systems:** PIM says active, commerce says withdrawn; system must preserve conflict visibility instead of silently picking one without policy
- **Parent / child mismatch:** parent product appears eligible, but all sellable variants fail inventory or assortment checks
- **Partial translations or incomplete regional attributes:** usable in some markets but not others
- **Imagery mismatch:** asset exists but shows the wrong color / variant for customer-facing use
- **Legacy curated look references withdrawn products:** curated content must quarantine invalid members rather than bypass hard gates
- **Inventory stale but not explicitly out of stock:** interactive ecommerce use should degrade conservatively
- **CM garment present without full compatibility field groups:** may remain visible in operator tools but not configuration-aware customer-facing flows
- **Category policy change reclassifies required attributes:** large-scale suppression wave must be traceable to a policy-version change, not mistaken for source failure
- **Feed outage during peak traffic:** recommendation systems should continue with highest-confidence projections rather than consuming raw unknown states

## 24. Non-Functional Requirements

- Interactive ecommerce projections must update quickly enough to support PDP and cart trust expectations from Phase 1.
- Freshness handling must distinguish immediate, current, durable, and reviewed data classes as described in BR-008.
- Readiness evaluation should be idempotent and replayable for backfills or incident recovery.
- System design must preserve source provenance and accountable transformation ownership.
- Projection and cache invalidation paths must scale to catalog-wide updates without leaving long-lived stale eligibility.
- Readiness reason codes and policy versions must be queryable for audits and debugging.

## 25. Analytics / Auditability Requirements

This feature must make catalog quality measurable, not just enforceable.

### Required measurement families

- coverage of products that pass minimum readiness by category / market / channel
- suppression and replacement reasons before recommendation delivery
- degraded-state rates caused by freshness, imagery, inventory, or compatibility issues
- recommendation impression share involving degraded catalog context
- top-anchor compatibility coverage and failure concentration
- manual suppression and override usage over time

### Auditability expectations

- recommendation traces should capture `catalogVersionId`, readiness policy version, and suppression / degradation reasons
- operators must be able to answer "why was this product allowed?" and "why was this product blocked?"
- analytics should separate catalog-readiness failures from ranking or experiment outcomes
- policy changes that materially affect coverage should be annotated in dashboards and traces

## 26. Testing Requirements

- schema and contract tests for canonical product, readiness snapshot, and projection payloads
- normalization tests for source-ID mapping and category / attribute harmonization
- policy tests for category-specific readiness rules and market / channel eligibility
- freshness and replay tests for delayed, duplicated, or missing source updates
- inventory-suppression tests for interactive ecommerce use cases
- compatibility-coverage tests for outfit assembly and CM field-group requirements
- operator-flow tests for manual suppressions, exception expiry, and audit logging
- load tests for catalog-wide recomputation and projection rebuilds

## 27. Recommended Architecture

Recommended logical flow:

`source connectors -> canonical catalog store -> policy / readiness evaluator -> projection builders -> recommendation-facing read models -> operator health tooling`

Supporting subsystems:

- source conflict-resolution and provenance tracking
- inventory-sensitive projection path for interactive ecommerce
- compatibility and curated-look knowledge store
- feed-health monitor
- audit / analytics sink for readiness and suppression events

Architecture should keep product truth evaluation separate from recommendation ranking so eligibility remains deterministic and testable.

## 28. Recommended Technical Design

- Use stable canonical IDs across products, variants, looks, policies, and catalog versions.
- Store raw source records plus normalized recommendation-facing entities so reconciliation remains possible.
- Version readiness policy definitions and include policy IDs in snapshots and traces.
- Evaluate readiness per relevant market / channel / mode combination instead of assuming one global status.
- Materialize read models optimized for decisioning rather than running heavy joins during recommendation requests.
- Carry explicit reason codes such as `inventory_stale`, `missing_required_imagery`, `assortment_ineligible`, or `cm_fields_incomplete`.
- Prefer event-driven invalidation for freshness-sensitive dimensions and scheduled recomputation for slower-changing completeness checks.

## 29. Suggested Implementation Phasing

- **Phase 1:** Canonical product IDs, core RTW attributes, market / channel eligibility, inventory-aware filtering for PDP and cart, imagery-readiness gating, baseline compatibility coverage, and catalog-health dashboards
- **Phase 2:** Richer season / occasion completeness checks, broader ecommerce placements, stronger degraded-state measurement, and improved projection coverage for contextual / personal recommendation types
- **Phase 3:** Operator tooling maturity, stronger suppression / exception workflows, cross-channel readiness views, and richer feed incident handling
- **Phase 4:** Deeper CM field-group validation, configuration-aware compatibility readiness, premium operator controls, and expanded assisted-selling readiness visibility

Phase order matters: Phase 1 should optimize for trustworthy RTW ecommerce eligibility before broader personalization or CM depth is attempted.

## 30. Summary

Catalog and product intelligence is the recommendation platform's product-truth control plane. It ensures that downstream recommendation features operate on products and looks that are:

- valid enough to style
- eligible enough to sell
- visual enough to trust
- current enough to serve
- traceable enough to explain

The implementation bar for this feature is not "we ingested the catalog." It is "we can prove why a product was eligible, degraded, or suppressed for a given recommendation use case." The remaining open questions are real architecture and policy decisions, but they should resolve through the shared decision register (`DEC-014` through `DEC-017`), not through ad hoc downstream interpretation.
