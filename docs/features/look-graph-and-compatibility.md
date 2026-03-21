# Look Graph and Compatibility

## Traceability / Sources

Canonical project docs (exact paths):

- `docs/project/vision.md`
- `docs/project/goals.md`
- `docs/project/personas.md`
- `docs/project/product-overview.md`
- `docs/project/business-requirements.md`
- `docs/project/roadmap.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`
- `docs/project/review-rubrics.md`

Business requirements (BR) artifacts:

- `docs/project/br/br-001-complete-look-recommendation-capability.md` (complete-look coherence; anchor and occasion readiness)
- `docs/project/br/br-002-multi-type-recommendation-support.md` (outfit vs cross-sell vs upsell boundaries; graph feeds outfit assembly)
- `docs/project/br/br-004-rtw-and-cm-support.md` (mode-specific compatibility and premium guardrails on the graph)
- `docs/project/br/br-005-curated-plus-ai-recommendation-model.md` (curated vs rule-based roles before ranking)
- `docs/project/br/br-011-explainability-and-auditability.md` (provenance for looks, rules, exclusions, and graph-derived candidates)

**Scope note:** This specification owns the **look** composition model, **product relationship / outfit graph**, **compatibility and exclusion rules**, and **look composition assets**. It intentionally does **not** own end-to-end recommendation-type orchestration, ranking model selection, or full CM configuration schema—that logic is specified in sibling feature docs and downstream BRs.

---

## 1. Purpose

Define how SuitSupply encodes styling knowledge as **curated looks**, **structured product relationships**, and **compatibility and exclusion rules** so complete-look (**outfit**) recommendations remain coherent, purchasable, and governable across channels.

## 2. Core Concept

A **look** is a merchandising artifact: an authored or derived grouping of products (slots, roles, optional alternates) with metadata (campaign, season, occasion, mode applicability). The **look graph** (outfit graph / product relationship graph) connects products, looks, categories, and rule outcomes. **Compatibility rules** and **exclusions** constrain which combinations are valid; they are **hard** (must never surface) or **soft** (may influence ranking or de-prioritization per governance policy).

## 3. Why This Feature Exists

Isolated similarity or popularity does not answer “what completes this suit for this occasion.” The graph and rule layer productizes SuitSupply styling expertise into data the platform can query, govern, and measure—before personalization or ranking reorder candidates.

## 4. User / Business Problems Solved

- Customers avoid incompatible combinations and reduce outfit-building guesswork.
- Merchandisers scale curated styling patterns beyond one-off spreadsheets or tribal knowledge.
- Stylists and clienteling receive credible, explainable composition foundations.
- Analytics can attribute outcomes to specific looks and rule families (see BR-011 alignment).

## 5. Scope

**In:** Authoring and versioning of looks; graph edges and node types needed for outfit assembly; compatibility and exclusion evaluation; composition assets (imagery references, copy hooks where owned by look artifacts); mode-aware rule applicability (RTW vs CM at the rule/graph level).  
**Out:** Full ranking stack, multi-type slotting on surfaces, delivery payload shaping, and CM configuration persistence (specified elsewhere).

## 6. In Scope

- Curated look definitions with stable **look IDs** and source mappings.
- Relationship graph: product-to-product compatibility, look membership, category/attribute-driven edges where required.
- Rule engine inputs: attributes (fabric, color family, pattern, fit, formality, season, occasion tags, price tier, RTW/CM flags), inventory/assortment eligibility hooks, regional scope.
- Exclusions, suppressions, and mandatory pairings with audit trail linkage.
- Read models for “expand look to purchasable SKUs” and “explain why candidate X was excluded.”

## 7. Out of Scope

- Channel-specific UI layouts and carousel mechanics.
- Model training, feature stores, and scoring formulas for AI ranking.
- Identity resolution and consent enforcement (consumes signals only via contracts).
- Replacing commerce catalog or OMS.

## 8. Main User Personas

- **Merchandiser / look curator:** authors looks, rules, exclusions, campaign-scoped overrides.
- **Stylist / associate:** consumes composed looks with enough provenance to adapt live.
- **Customer:** experiences coherent **outfits** without seeing internal graph mechanics.
- **Platform operator / analyst:** investigates missing or surprising compositions using trace IDs and rule IDs.

## 9. Main User Journeys

1. **Anchor-product outfit completion (RTW):** PDP anchor → graph retrieves candidate complements and curated look expansions → rules filter → handoff to orchestration/ranking.
2. **Campaign-led look activation:** named look promoted for season/event → eligible on inspiration/email surfaces per BR-002 boundaries.
3. **Governance change:** merchandiser updates exclusion or look membership → versioned publish → downstream consumers see effective-dated behavior.
4. **Investigation:** support traces a bad pairing to a specific rule version or stale graph edge.

## 10. Triggering Events / Inputs

- Catalog or attribute updates (invalidates or refreshes edges).
- Look authoring publish, rule deploy, override activate/expire.
- Recommendation request carrying anchor `productId`, market, mode (RTW/CM), optional occasion/context keys.
- Inventory or assortment signals that affect **eligibility** at assembly time (consumed jointly with orchestration).

## 11. States / Lifecycle

- **Draft** look/rule → **Review** (if policy requires) → **Scheduled** → **Active** → **Deprecated** / **Rolled back**.
- Graph materialization jobs: **Queued**, **Processing**, **Consistent**, **Failed** (with partial serving policy defined with orchestration).
- Rule evaluation cache: **Fresh**, **Stale**, **Bypassed** (emergency governance).

## 12. Business Rules

- Hard compatibility and exclusions override any retrieval or ranking intent (BR-005, BR-002).
- A **look** must not imply purchasability without inventory/assortment checks at assembly time.
- RTW and CM may share graph infrastructure but **mode-specific** rules must not silently apply across modes (BR-004).
- Style bundle and outfit distinctions preserved: bundles are reusable packaging; outfit is complete-look assembly (BR-002).

## 13. Configuration Model

- Scoped dimensions: market/region, channel family, surface (for rule applicability hints), recommendation **type** eligibility for look activation, campaign ID, effective window.
- Feature flags for gradual graph migrations and shadow evaluation (coordinated with experimentation docs).
- Override precedence: emergency suppression > campaign pin > default rule stack (exact precedence table finalized with governance BRs).

## 14. Data Model

**Entities (illustrative):**

| Entity | Key fields | Notes |
|--------|------------|-------|
| Look | `lookId`, version, slots[], alternates[], tags, mode applicability | Stable canonical ID |
| LookSlot | role (e.g., shirt, tie), required/optional, constraints | Drives assembly |
| GraphEdge | `fromProductId`, `toProductId`, edgeType, strength, source | Provenance required |
| CompatibilityRule | `ruleId`, expression, severity (hard/soft), scope | Auditable |
| Exclusion | `exclusionId`, pair/set pattern, scope, reason code | Links to BR-011 traces |

Maintain **source-system mappings** for any imported look data per `standards.md`.

## 15. Read Model / Projection Needs

- “Eligible complements for product P in market M under mode X.”
- “Active looks covering anchor P with slot fulfillment status.”
- “Rule hits and exclusions applied to candidate set” (for internal explainability).
- Denormalized projections for low-latency PDP paths vs batch-quality graph rebuilds.

## 16. APIs / Contracts

Internal service contracts (illustrative):

- `POST /looks/validate` — validate draft look against schema and sample catalog slice.
- `GET /graph/neighbors?productId&mode&market` — retrieve typed neighbors with provenance.
- `POST /compatibility/evaluate` — batch evaluate candidates with returned **rule decision codes** (for traces).

External delivery API remains in recommendation orchestration; this module returns **structured candidate sets + decision metadata**, not final ranked responses.

## 17. Events / Async Flows

- `LookPublished`, `LookDeprecated`, `RuleActivated`, `RuleRolledBack`, `GraphRebuildCompleted`, `GraphRebuildFailed`.
- Downstream consumers update caches and invalidate read models; events carry `artifactId`, version, effective timestamp.

## 18. UI / UX Design

- Internal authoring UX: slot builder, compatibility tester, impact preview (“affected anchors”), diff across versions.
- Customer-facing surfaces show **outfits**, not raw graph terminology (`standards.md`).

## 19. Main Screens / Components

- Look editor, rule editor, exclusion manager, graph health dashboard, “explain exclusion” inspector (internal).

## 20. Permissions / Security Rules

- Role-based access for authoring vs read-only operator views.
- Segregation of production rule publish from draft experimentation.
- No sensitive customer reasoning stored in look artifacts.

## 21. Notifications / Alerts / Side Effects

- Alerts on graph rebuild failure, spike in exclusion rate, or look coverage gaps for priority anchors (BR-001 success measures).
- Notify merchandising when scheduled publishes fail validation.

## 22. Integrations / Dependencies

- **Upstream:** normalized catalog, attribute quality, inventory/assortment feeds.
- **Downstream:** recommendation orchestration (candidate generation), governance services, analytics telemetry correlation via look/rule IDs.

## 23. Edge Cases / Failure Cases

- Missing attributes → conservative fallback: exclude ambiguous candidates or route to curated-only paths (policy decision recorded in §32).
- Conflicting rules → deterministic conflict resolution order with logged conflict ID.
- Stale graph with fresh catalog → define serving policy (e.g., serve last consistent + flag trace degraded per BR-011).
- CM partial configuration → graph queries must receive explicit **mode** and **configuration snapshot** references from CM orchestration.

## 24. Non-Functional Requirements

- Latency budgets compatible with PDP paths (target set with architecture).
- Versioning and rollback for all authored artifacts.
- Regional isolation where legal/assortment requires separate graphs.

## 25. Analytics / Auditability Requirements

- Emit structured decision codes for rule hits, exclusions, and look provenance in recommendation traces (BR-011).
- Measure look coverage, rule churn, and graph freshness KPIs aligned with `goals.md` operational outcomes.

## 26. Testing Requirements

- Golden fixtures for representative anchors across categories and modes.
- Property-style tests for hard-exclusion invariants.
- Regression suite when catalog taxonomies change.

## 27. Recommended Architecture

Standalone **Look & Compatibility** service (logical boundary) with pluggable storage for graph (OLTP + analytical projection), rule repository, and event publishing—aligned with “Look graph and compatibility engine” in `architecture-overview.md`.

## 28. Recommended Technical Design

- Immutable versioned artifacts for looks and rules; graph edges materialized from rules + curated inputs.
- Evaluation engine pure-functional over inputs for testability.
- Feature flag around new edge types; shadow mode compares candidate sets without customer impact.

## 29. Suggested Implementation Phasing

- **Phase 1:** RTW high-confidence looks + hard rules + minimal graph for PDP/cart anchors (`roadmap.md`).
- **Phase 2:** Richer attributes, occasion tags, expanded projections.
- **Phase 3:** Campaign-scoped governance workflows, multi-channel activation hooks.
- **Phase 4:** CM-sensitive rules layered on shared graph with stricter review gates (BR-004).

## 30. Summary

The look graph and compatibility layer encodes SuitSupply’s styling knowledge so **outfit** assembly is safe, coherent, and traceable. It supplies governed candidates and explicit exclusion explanations to the recommendation pipeline without owning ranking or full cross-type orchestration.

## 31. Assumptions

- Canonical product IDs and attribute completeness will reach agreed thresholds for Phase 1 anchors.
- Merchandising can supply an initial curated look catalog for priority RTW anchors.
- Hard vs soft rule semantics are enforced consistently in evaluation and in traces.
- Inventory/assortment eligibility checks remain part of final assembly even when graph suggests compatibility.

## 32. Open Questions / Missing Decisions

- Authoring tool MVP depth versus API-first authoring for merchandising.
- Exact conflict-resolution order when multiple rules fire.
- Minimum attribute schema required before a product may appear in automated graph edges.
- How look imagery and marketing copy ownership splits between CMS and recommendation look artifacts.
- Partial graph degradation: hard fail vs last-known-good with explicit trace flags (cross-cutting with BR-011).
