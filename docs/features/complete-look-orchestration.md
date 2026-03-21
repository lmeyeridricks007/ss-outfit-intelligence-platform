# Feature: Complete-look orchestration

**Upstream traceability:** `docs/project/business-requirements.md` (BR-001); `docs/project/br/br-001-complete-look-recommendation-capability.md`, `br-002-multi-type-recommendation-support.md`, `br-008-product-and-inventory-awareness.md`, `br-005-curated-plus-ai-recommendation-model.md`; `docs/project/glossary.md` (**look** vs **outfit**); `docs/project/roadmap.md` (Phase 1 PDP/cart).

---

## 1. Purpose

Orchestrate **complete-look** outcomes: from anchor product or occasion intent, produce grouped, coherent **looks** and present them as customer-facing **outfits** with correct category spread, anchor preservation, and governed fallbacks (BR-001).

## 2. Core Concept

A **look** is internal grouping; an **outfit** is the shopper-facing bundle. Orchestration selects candidate looks, completes missing categories from rule-eligible catalog, applies governance, and assembles typed **recommendation sets** of type `outfit` (BR-002).

## 3. Why This Feature Exists

Solves “what goes with this?” beyond similar-item widgets (`problem-statement.md`, `vision.md`).

## 4. User / Business Problems Solved

- P1/P3: Confident multi-category completion.
- S2: Curated stories reflected in live assembly.
- Business: AOV and attach (`goals.md`).

## 5. Scope

Journey logic for anchor PDP, cart extension, occasion-led (specified for product, Phase 2+ broader activation per roadmap). **Missing decisions:** mandatory vs optional categories per surface; number of alternative outfits to show; minimum quality bar for launch.

## 6. In Scope

- Anchor preservation on PDP; duplicate avoidance vs cart.
- Category templates by anchor class (suit vs shoe) — templates themselves **missing decision** pending merchandising.
- Coherence rules (formality, color/pattern) delegated to compatibility/rules but enforced here as assembly constraints.

## 7. Out of Scope

Full stylist booking workflow; AR try-on; custom tailoring operations outside recommendation.

## 8. Main User Personas

P1, P3, P2 (when profile available), S1 stylist (later).

## 9. Main User Journeys

BR-001 journeys 1–5: PDP, cart, occasion-led, known customer, assisted selling—phased per roadmap.

## 10. Triggering Events / Inputs

PDP view, cart change, occasion page entry, profile/context signals, merchandising campaign context.

## 11. States / Lifecycle

`intent resolved → candidates gathered → filtered → ranked → assembled → delivered`; fallback to smaller coherent set or “curated safe” look when pool thin.

## 12. Business Rules

- **Outfit** type must not collapse into cross-sell-only lists when surface promises complete look (BR-002).
- Curated **looks** violating hard rules are repaired or blocked (BR-005).
- Inventory and eligibility gates (BR-008) before final assembly.

## 13. Configuration Model

Per-market category templates; max items; allowed optional accessories; merchandising pins for seasonal campaigns.

## 14. Data Model

`LookCandidate` (id, members, source: curated|generated), `OutfitAssembly` (anchorLineage, slots: shirt, tie, shoes…), linkage to **recommendation set ID**.

**Example:** `{ lookId: "L-100", slots: { anchor: P1, shirt: P2, shoes: P3 }, sources: { shirt: "rule_fill" } }`.

## 15. Read Model / Projection Needs

Precomputed “looks per anchor” optional; hot anchors may use online expansion from graph.

## 16. APIs / Contracts

Uses shared delivery API; orchestration service exposes internal `assembleOutfit(requestContext)`; response includes grouped members with slot labels for UI.

## 17. Events / Async Flows

Optional pre-warm cache for top anchors; async quality review sampling for merchandising (operator tooling Phase 3).

## 18. UI / UX Design

Distinct visual grouping for **outfit** modules vs carousels; clear anchor item; loading/skeleton; empty state when no valid look.

## 19. Main Screens / Components

PDP Complete Look module; Cart “Complete the look”; inspiration grids (Phase 2+).

## 20. Permissions / Security Rules

No PII in assembly logs beyond IDs; stylist tools Phase 3 with role gates.

## 21. Notifications / Alerts / Side Effects

Alert if fallback rate high for key categories; merchandising digest of failed assemblies.

## 22. Integrations / Dependencies

Catalog/graph, governance, ranking, context/profile (Phase 2+), telemetry.

## 23. Edge Cases / Failure Cases

Single-category inventory hole → drop slot vs show “similar tone” substitute **missing decision**; conflicting anchor (multi-item cart) → primary anchor selection rules needed.

## 24. Non-Functional Requirements

Interactive latency aligned with PDP; deterministic assembly given same inputs/version (for debugging).

## 25. Analytics / Auditability Requirements

Look-level impression and outcomes; preserve **recommendation set ID** + **trace ID**; slot fill attribution optional (BR-010).

## 26. Testing Requirements

Curated golden outfits per market; regression on anchor preservation; snapshot tests for fallback.

## 27. Recommended Architecture

Orchestration service between candidate providers and delivery façade; compatibility as filter stage; ranking last inside governed pool (BR-005).

## 28. Recommended Technical Design

Slot-filling algorithm pluggable; explicit `assemblyTrace` object for BR-011 (internal).

## 29. Suggested Implementation Phasing

- **Phase 1:** RTW PDP + cart; outfit + companion types in same page via multiple sets if needed.
- **Phase 2:** Occasion-led ecommerce paths; stronger context.
- **Phase 3+:** Clienteling shared looks; CM-aware assembly (see `rtw-and-cm-mode-support.md`).

## 30. Summary

Complete-look orchestration is the product differentiator (BR-001). It must preserve grouped semantics, anchor fidelity, and honest fallbacks. Category templates and substitute policies are the main **missing decisions** for implementation.
