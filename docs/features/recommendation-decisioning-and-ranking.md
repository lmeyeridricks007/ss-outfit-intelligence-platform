# Feature: Recommendation decisioning and ranking

**Upstream traceability:** `docs/project/business-requirements.md` (BR-005, BR-002); `docs/project/br/br-005-curated-plus-ai-recommendation-model.md`, `br-002-multi-type-recommendation-support.md`, `br-001-complete-look-recommendation-capability.md`, `br-008-product-and-inventory-awareness.md`; `docs/project/glossary.md` (curated, rule-based, AI-ranked); `docs/project/roadmap.md`.

---

## 1. Purpose

Implement the governed **three-source blend**: curated **looks**, **rule-based** compatibility and policy, and **AI-ranked** ordering—with deterministic precedence so optimization cannot violate brand or operational boundaries (BR-005).

## 2. Core Concept

**Eligibility gate → hard rules → operator/campaign controls → AI ranking in allowed pool → deterministic fallback** (explicit order in BR-005).

## 3. Why This Feature Exists

Pure ML drifts from taste; pure curation does not scale; rules without ranking underuse signals (`vision.md`, BR-005).

## 4. User / Business Problems Solved

- Customers get coherent **outfits** and relevant cross/upsell **recommendation types** (BR-002).
- Merchandisers retain control; analytics can separate source effects (BR-010).

## 5. Scope

Candidate generation, filtering, scoring, assembly into **recommendation sets**, per-type objectives, fallback when model unavailable. **Missing decisions:** model hosting vendor; feature set; exploration/exploitation policy; tie-breakers when scores equal.

## 6. In Scope

- Candidate sources: curated full/partial looks, rule-expanded catalog, campaign boosts.
- Type-specific objectives: outfit coherence vs attach vs premium step-up (BR-002 table).
- Source lineage for explainability (BR-011).

## 7. Out of Scope

Training pipeline details; real-time bidding; non-recommendation search ranking.

## 8. Main User Personas

P1–P3; S2 merchandiser; S4 optimizer.

## 9. Main User Journeys

PDP request produces multiple **recommendation sets** (e.g. outfit + cross-sell); cart emphasizes completion; later personalized reordering within pool.

## 10. Triggering Events / Inputs

Delivery API invocation with context bundle: catalog snapshot ids, profile summary (Phase 2+), context features, governance snapshot version, experiment variant.

## 11. States / Lifecycle

`inputs resolved → candidates enumerated → filtered → scored → ordered → post-processed (pins) → validated → returned`; `model_degraded` path uses rule-only ordering.

## 12. Business Rules

- Hard rules cannot be bypassed by AI or curation (BR-005).
- AI must not optimize click-only at expense of outfit coherence when type is `outfit` (**quantify in policy**—missing decision).
- Campaign vs personalization conflict resolution **missing decision** (`business-requirements.md`).

## 13. Configuration Model

Ranking policy per recommendation type and surface; weights bounds; allowed reorder of curated sets (merchandising declares).

## 14. Data Model

`CandidateItem` (productId, lookId?, sourceTags, featureVectorRef), `ScoreBreakdown` (internal), `RankingPolicyVersion`, `GovernanceSnapshotId`.

## 15. Read Model / Projection Needs

Precomputed candidate neighborhoods; model feature lookups; experiment bucket assignment.

## 16. APIs / Contracts

Internal: `rank(candidates, policyId, context) → ordered list`; external exposure via shared delivery API only.

## 17. Events / Async Flows

Optional offline scoring jobs for batch email; model refresh events; shadow mode evaluation streams.

## 18. UI / UX Design

Customer UI unaffected directly; internal debug UI may show high-level “why ranked” (Phase 3+).

## 19. Main Screens / Components

Operator policy console (ties to governance feature); model monitoring dashboards.

## 20. Permissions / Security Rules

Model artifacts access controlled; no customer PII in logs beyond permitted IDs.

## 21. Notifications / Alerts / Side Effects

Alerts on model latency, score distribution shift, sudden boost in exclusions.

## 22. Integrations / Dependencies

Feature platform, governance service, catalog readiness, profile/context services, experimentation.

## 23. Edge Cases / Failure Cases

Empty candidate pool after rules → fallback curated safe set or empty with explicit degradation; inconsistent experiment assignment → default bucket.

## 24. Non-Functional Requirements

Scoring latency budget inside PDP SLO; horizontal scale for peak traffic; reproducibility for given policy version + inputs.

## 25. Analytics / Auditability Requirements

Record policy version, model version, source mix tags, experiment variant on **trace ID** path (BR-010, BR-011).

## 26. Testing Requirements

Offline evaluation sets; counterfactual tests when rules change; fairness/guardrail tests per market (**method TBD**).

## 27. Recommended Architecture

Separate **Ranking** service with pluggable scorers; rules engine upstream; feature store integration later.

## 28. Recommended Technical Design

Declarative rule DSL or config tables; scoring pipeline as DAG; shadow traffic for new models.

## 29. Suggested Implementation Phasing

- **Phase 1:** Rules + curated + simple AI reorder within outfit/cross-sell/upsell for RTW PDP/cart.
- **Phase 2:** Profile/context-aware features inside allowed pool.
- **Phase 4:** CM-specific scorers and premium constraints.

## 30. Summary

Decisioning encodes brand-safe optimization (BR-005). Precedence is non-negotiable; many ML and policy details remain **missing decisions** for architecture and data science.
