# Recommendation Orchestration and Types

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

- `docs/project/br/br-001-complete-look-recommendation-capability.md` (complete-look outcomes and Phase 1 loop)
- `docs/project/br/br-002-multi-type-recommendation-support.md` (taxonomy, surface boundaries, contract expectations)
- `docs/project/br/br-004-rtw-and-cm-support.md` (mode labeling in responses and mixed-eligibility)
- `docs/project/br/br-005-curated-plus-ai-recommendation-model.md` (blend order: candidates → eligibility → governance → ranking → assembly → fallback)
- `docs/project/br/br-011-explainability-and-auditability.md` (recommendation set ID, trace ID, source provenance, experiment visibility)

**Scope note:** This specification owns **recommendation type taxonomy**, **candidate generation orchestration**, the **governance → eligibility → ranking → assembly** pipeline, **fallback** behavior, and **cross-type orchestration** within a single delivery response. It references—but does not redefine—the **look graph, compatibility rules, and exclusions** (see `look-graph-and-compatibility.md`) or **RTW/CM mode phasing and premium guardrails** (see `rtw-and-cm-mode-orchestration.md`).

---

## 1. Purpose

Specify how the platform selects, governs, ranks, and assembles **typed** recommendation sets (outfit, cross-sell, upsell, style bundle, occasion-based, contextual, personal) so every surface receives coherent, measurable, traceable outputs aligned with BR-002 and BR-005.

## 2. Core Concept

A **recommendation request** identifies **surface**, **channel**, optional **anchor** context, **customer/session** context, and requested **recommendation type(s)**. The **orchestrator** pulls candidates from curated, graph/rule, behavioral, and contextual sources; applies **eligibility** and **governance**; runs **AI-ranked** ordering only inside allowed boundaries; **assembles** slots per type; and attaches **decision trace** metadata for BR-011.

## 3. Why This Feature Exists

Without explicit orchestration, channels collapse types, double-count intents, or optimize past compatibility. A shared pipeline keeps business intent legible in APIs, analytics, and internal tooling.

## 4. User / Business Problems Solved

- Customers see the right **kind** of suggestion (complete **outfit** vs attachment **cross-sell** vs premium **upsell**).
- Merchandisers can pin, suppress, and campaign-prioritize without per-channel forks.
- Analytics segments performance by **type**, **surface**, and **variant** as required by `goals.md`.

## 5. Scope

**In:** Type system enforcement, multi-type responses per request policies, candidate retrieval coordination, governance application order, ranking hooks, assembly and slotting, fallback modes, trace payload contracts.  
**Out:** Detailed compatibility graph schema, CM configuration storage, channel UI widgets.

## 6. In Scope

- Primary **recommendation type** per set plus optional **overlay** metadata (contextual/personal refinement) per BR-002 §6.3.
- Phase-aware rollout: Phase 1 focuses outfit + cross-sell + upsell on PDP/cart RTW-first while preserving type labels for later expansion (`roadmap.md`).
- Inventory and assortment filtering at assembly stage (`architecture-overview.md`).

## 7. Out of Scope

- Defining merchandising admin UX workflows beyond orchestration touchpoints.
- Replacing ESP, POS, or commerce checkout.

## 8. Main User Personas

- **Shopper:** experiences clear, actionable modules per type.
- **Merchandiser:** expects overrides and campaign precedence to win inside governed bounds.
- **Marketer / stylist consumer:** receives API payloads with stable type semantics for email/clienteling.
- **Analyst:** relies on recommendation set ID + type + surface for attribution.

## 9. Main User Journeys

1. **PDP anchor flow:** request {outfit, crossSell, upsell} → orchestrator builds three assemblies from shared candidate pools where allowed.
2. **Homepage discovery (later phase):** occasion-based or personal primary type with contextual overlay.
3. **Degraded personalization:** identity/consent low → drop personal overlay; preserve primary type with curated/rule fallback (BR-002 §7.7).
4. **Experiment live:** variant influences ranking or source blend; trace captures experiment IDs (BR-011).

## 10. Triggering Events / Inputs

- API/Gateway request with `customerId` or session, `productId`/cart state, `surface`, `channel`, `market`, `mode` (RTW/CM/mixed-eligibility flag), context bundle (season, weather, device), explicit `requestedTypes[]`, optional campaign hints.

## 11. States / Lifecycle

- Request **Accepted** → **CandidatesResolved** → **Filtered** → **Governed** → **Ranked** → **Assembled** → **Returned** / **Failed** (with degraded fallback path).
- Per-type **empty** states with explicit reason codes (inventory, rules, missing anchor, consent gating).

## 12. Business Rules

- Every emitted set declares a **primary recommendation type** (BR-002 §9).
- Hard compatibility and governance constraints cannot be overridden by ranking (BR-005 §8.3).
- Cross-sell must not replace outfit assembly when the surface expects a complete look (BR-002 §7.2).
- Upsell must remain compatibility- and trust-bounded (BR-002 §7.3).
- Presentation grouping ≠ type: UI carousels must not collapse analytics labels.

## 13. Configuration Model

- Surface-to-type allow matrix (from BR-002 §8.2, parameterized per market).
- Ranking profile per surface (bounded objectives PDP vs cart trade-offs flagged in BR-005 open questions).
- Fallback ladder: AI-ranked → curated static order → rule-only complements → safe empty state with telemetry reason.

## 14. Data Model

**Key constructs:**

| Construct | Description |
|-----------|-------------|
| RecommendationSet | Typed collection with slots/items, `recommendationSetId`, `traceId`, primary type |
| Candidate | Product or sub-look reference with source tags (curated / rule / graph / behavioral / contextual) |
| GovernanceDecision | Overrides, pins, suppressions applied with artifact IDs |
| RankOutput | Ordering metadata, model version pointer, confidence band |
| AssemblyPlan | Slot template per recommendation type |

## 15. Read Model / Projection Needs

- Fast lookup of active governance objects affecting a SKU/market/surface.
- Experiment assignment cache per customer/session.
- Optional precomputed candidate pools for hot anchors (Phase 1 scope decision).

## 16. APIs / Contracts

Illustrative delivery contract (aligned with `architecture-overview.md`):

`GET /recommendations` response shape includes:

- `outfits[]`, `crossSell[]`, `upsell[]`, `styleBundles[]` (as enabled)
- each array item: items[], `recommendationType`, `surface`, `channel`, `mode`, `recommendationSetId`, `traceContext` {sourceFamilies[], experimentIds[], fallbackReason?}

Cross-type orchestration flags:

- `requestedTypes`, `returnedTypes`, `degradedModes[]`

## 17. Events / Async Flows

- Async refresh of behavioral candidates; synchronous path must degrade gracefully if async data stale.
- Publish `RecommendationServed` internal event with redacted PII for ops dashboards.

## 18. UI / UX Design

- Surfaces label or visually distinguish modules consistent with **type** intent (outfit completeness vs attachment vs premium alternative).
- Customer-facing copy avoids exposing internal trace fields (BR-011 §10.3).

## 19. Main Screens / Components

- PDP/cart modules consume typed slots; homepage/inspiration layouts differ per BR-002; orchestration supplies **ordered item lists + metadata**, not layout.

## 20. Permissions / Security Rules

- Request authentication/authorization per channel consumer; respect consent for personal/contextual branches.
- Withhold personal overlays when policy flags demand.

## 21. Notifications / Alerts / Side Effects

- Alert on elevated fallback rates per surface/type.
- Optional webhook to merchandising ops on repeated empty states for priority anchors.

## 22. Integrations / Dependencies

- **Look graph & compatibility** for ruled/graph candidates.
- **Context engine** for contextual overlays.
- **Customer profile & identity** services for personal overlays.
- **Analytics pipeline** for impression/outcome events with set IDs (`goals.md`).

## 23. Edge Cases / Failure Cases

- Partial type success: return available types with explicit absence reasons for others.
- Conflicting campaign pins → deterministic precedence (tie-breaker policy needed—§32).
- Mixed RTW/CM eligibility in one response: preserve labeling per BR-004 §6.4.
- Model timeout → fall back per configuration without violating hard rules.

## 24. Non-Functional Requirements

- Latency SLOs per surface class; circuit breakers on optional signals never block hard-rule application.
- Idempotent recommendation set generation where appropriate for retries.

## 25. Analytics / Auditability Requirements

- Impression/click/add-to-cart/purchase/dismiss events carry `recommendationSetId`, `traceId`, `recommendationType`, `surface`, `channel`, variant/experiment fields (`goals.md`, BR-011).
- Measure coverage and lift **per type** as BR-002 §12 prescribes.

## 26. Testing Requirements

- Contract tests for each recommendation type’s minimum viable payload.
- Scenario tests for fallback ladder and experiment visibility.
- Load tests on hot anchors with caching enabled/disabled.

## 27. Recommended Architecture

Dedicated **Recommendation Orchestrator** service composing pluggable **candidate providers**, **governance service**, **ranking service**, and **assembler**—mirroring “Recommendation engine” responsibilities in `architecture-overview.md`.

## 28. Recommended Technical Design

- Pure pipeline stages with explicit DTOs for trace capture at each boundary.
- Strategy pattern per recommendation type for assembly templates.
- Feature flags for enabling Phase 2+ types per market without contract breaks.

## 29. Suggested Implementation Phasing

- **Phase 1:** outfit + cross-sell + upsell on PDP/cart; telemetry + type labels mandatory (`roadmap.md`).
- **Phase 2:** contextual + personal overlays; occasion-based primaries on eligible surfaces.
- **Phase 3:** style bundle activation across email/clienteling with governance workflows.
- **Phase 4+:** deeper CM-aware candidate providers coordinated via mode orchestration doc.

## 30. Summary

Orchestration turns governed candidates into **typed**, **traceable** recommendation sets. It enforces BR-002 semantics end-to-end and implements the BR-005 decision sequence without re-deriving compatibility graph details owned elsewhere.

## 31. Assumptions

- Delivery remains **API-first** with stable type labels across consumers (`standards.md`).
- Candidate providers expose uniform interfaces with provenance for tracing.
- Inventory filtering is always applied before customer-visible assembly completes.
- Analytics consumers can store `recommendationSetId` and `traceId` on outcome events.

## 32. Open Questions / Missing Decisions

- Single multi-type response vs multiple single-type calls at scale (BR-002 §14).
- Campaign vs customer ranking objective trade-offs on PDP vs cart (BR-005 §14).
- Minimum model confidence threshold triggering fallback (BR-005 §14).
- Tie-breaking when multiple governance objects target the same slot.
- Style bundle customer-facing exposure strategy across channels (BR-002 §14).
