# RTW and CM Mode Orchestration

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

- `docs/project/br/br-001-complete-look-recommendation-capability.md` (Phase 1 RTW focus; CM expansion hooks)
- `docs/project/br/br-002-multi-type-recommendation-support.md` (mode labeling in contracts; CM upsell/outfit labeling questions)
- `docs/project/br/br-004-rtw-and-cm-support.md` (primary source for mode differences, premium guardrails, phased rollout)
- `docs/project/br/br-005-curated-plus-ai-recommendation-model.md` (ranking boundaries stricter in premium/CM contexts)
- `docs/project/br/br-011-explainability-and-auditability.md` (stronger internal explainability for CM; mode in traces)

**Scope note:** This specification owns **recommendation mode** semantics (RTW vs CM vs mixed-eligibility), **configuration-sensitive behavior**, **phase boundaries** for CM depth, **premium styling guardrails**, and **shared vs distinct logic** across modes. It consumes compatibility graph and orchestration behaviors defined in sibling feature docs without duplicating their full rule catalogs.

---

## 1. Purpose

Ensure the platform treats **RTW** and **CM** as related but non-identical recommendation modes so journeys, contracts, governance, and success metrics stay correct while sharing infrastructure (`br-004`).

## 2. Core Concept

**Mode** is a first-class input and output attribute affecting anchor validity, candidate retrieval, explanation depth, fallback posture, and governance rigor. **CM configuration state** (fabric, color family, details, premium options) constrains compatibility dynamically as customers iterate. **RTW** anchors are finished, directly purchasable products with ecommerce-centric success patterns.

## 3. Why This Feature Exists

Collapsing CM into RTW produces incompatible or insufficiently premium suggestions; separating systems entirely loses shared telemetry, governance, and API economies. Mode orchestration preserves both.

## 4. User / Business Problems Solved

- CM customers receive guidance that respects in-progress tailoring choices (`personas.md` CM persona).
- RTW shoppers get fast, purchasable complete looks on PDP/cart.
- Stylists receive trustworthy, explainable outputs in assisted contexts.
- Analytics compares RTW vs CM without assuming identical conversion shapes (BR-004 §13).

## 5. Scope

**In:** Mode detection from request context, configuration snapshot handling contracts, phase-gated CM capabilities, premium guardrails, shared-component boundaries, fallback when configuration incomplete, trace flags for mode-sensitive paths.  
**Out:** Detailed CM configurator UI, appointment scheduling systems, low-level tailoring CAD data.

## 6. In Scope

- Explicit `mode` values on requests/responses: `RTW`, `CM`, `MIXED_ELIGIBILITY` when labeling must surface downstream (BR-004 §6.4, §8.2).
- Phase 1 **RTW-first** validation on PDP/cart with CM readiness in contracts (BR-004 §12.1).
- Premium styling rules that restrict upsell aggressiveness and incompatible premium pairings (BR-004 §9.3).

## 7. Out of Scope

- Full Phase 4 stylist appointment workflow implementation details (captured as dependencies).
- Legal/consent policy authoring.

## 8. Main User Personas

- **RTW anchor shopper:** speed and purchasability.
- **CM customer / premium buyer:** coherence, trust, iterative refinement.
- **Stylist / associate:** explanation-rich outputs, ability to override gracefully.
- **Merchandiser:** mode-specific rule authoring and approvals.

## 9. Main User Journeys

1. **RTW PDP:** mode=RTW → orchestration uses finished-product assumptions → attach cross-sell/upsell per surface policy.
2. **CM digital configuration:** mode=CM + `configurationSnapshotId` → candidate providers filter by palette/fabric/detail constraints → update on each meaningful config change event.
3. **Assisted selling:** clienteling surface requests CM mode with higher explanation verbosity internally (customer sees curated messaging only).
4. **Mixed browsing history:** customer transitions RTW↔CM; requests carry current mode while profile signals remain consent-governed.

## 10. Triggering Events / Inputs

- Commerce signals: product type RTW vs CM SKU, configuration service events, appointment context flags (later phases).
- User actions: configuration field changes, switching between RTW reference products and CM flows.
- Explicit client parameters: `mode`, optional `configurationSnapshot` payload or reference, `assistedSelling=true`.

## 11. States / Lifecycle

- CM **configuration** states: `INITIAL`, `IN_PROGRESS`, `REVIEW_PENDING`, `LOCKED` (illustrative—exact enum downstream).
- Recommendation validity: **CURRENT**, **STALE_RELATIVE_TO_CONFIG**, **BLOCKED_MISSING_ATTRIBUTES** with trace annotations (BR-011 degraded trace expectation).
- Phase gates: feature flags per roadmap phase for CM depth (Phase 4 primary expansion).

## 12. Business Rules

- CM must not be reduced to RTW cross-sell logic (BR-004 §6.3).
- Premium upsell must not break styling coherence or trust (BR-004 §9.3).
- Human-in-the-loop review expectations for new CM rule sets and sensitive premium logic (BR-004 §11.2).
- Mixed-eligibility sets must be labeled when mode-specific constraints differ within one response (BR-004 §6.4).

## 13. Configuration Model

- Per-market toggles: CM candidate providers enabled, maximum allowed upsell aggressiveness in CM, explanation verbosity tiers.
- Governance: separate approval workflows for CM compatibility vs RTW (BR-004 §11.1).
- Premium guardrail profiles linking to merchandising policy objects.

## 14. Data Model

| Artifact | Purpose |
|----------|---------|
| ConfigurationSnapshot | Immutable view of CM choices at recommendation time |
| ModeDescriptor | RTW/CM/mixed + rationale codes for traces |
| PremiumGuardrailProfile | Caps and exclusions for upsell in CM |
| PhaseCapabilityMatrix | Maps roadmap phase → allowed CM behaviors |

## 15. Read Model / Projection Needs

- Fast mapping SKU/configuration → compatible styling space summaries for stylists.
- Historical comparison of recommendations across configuration revisions (internal).

## 16. APIs / Contracts

- Requests include `mode` and optional `configurationSnapshotRef`.
- Responses echo `mode` and, when needed, `eligibilityNotes[]` for internal consumers; customer payloads remain non-technical.
- Error/fallback codes specific to CM: `CM_CONFIG_INCOMPLETE`, `CM_RULE_STRICT_EMPTY_SET`.

## 17. Events / Async Flows

- `ConfigurationUpdated` triggers selective invalidation of CM candidate caches.
- `CMRecommendationServed` with snapshot hash for audit correlation (internal).

## 18. UI / UX Design

- RTW surfaces emphasize add-to-cart immediacy.
- CM surfaces emphasize coherence, premium tone, progressive disclosure; avoid aggressive monetization patterns that erode trust (BR-004 §7.2).

## 19. Main Screens / Components

- CM configuration UI (owned elsewhere) emits snapshot references consumed here.
- Clienteling panels show richer internal rationale than ecommerce (BR-011 customer boundary).

## 20. Permissions / Security Rules

- Stricter access to CM traces containing detailed customer tailoring choices.
- Respect regional restrictions on storing configuration detail.

## 21. Notifications / Alerts / Side Effects

- Alert merchandising when CM strict modes produce frequent empty sets (quality signal).
- Escalation path when premium guardrails block requested campaigns.

## 22. Integrations / Dependencies

- Configuration services for CM; catalog for RTW; shared orchestration and look/compatibility services with mode-aware plugins.

## 23. Edge Cases / Failure Cases

- Incomplete configuration: prefer safe curated defaults or stylist handoff per policy (BR-004 §9.4).
- Rapid configuration churn: throttle recomputation and show stability-friendly messaging.
- Mixed cart with RTW + CM items: clarify anchor for recommendation request or split sets.

## 24. Non-Functional Requirements

- CM paths may tolerate higher latency for richer evaluation where digital experience allows; RTW paths stay tight.
- Feature flags must prevent partial CM enablement that bypasses guardrails.

## 25. Analytics / Auditability Requirements

- Segment metrics by `mode`; track compatibility stability across configuration changes (BR-004 §13.2).
- Include mode and snapshot hash (internal) in traces for CM investigations (BR-011).

## 26. Testing Requirements

- Simulation matrix across configuration deltas ensuring no incompatible recommendations surface.
- Regression tests ensuring RTW paths unchanged when CM flags off.

## 27. Recommended Architecture

Mode-aware **strategy resolution** layer selecting provider chains per mode, sharing core eligibility and telemetry infrastructure (`architecture-overview.md` RTW/CM boundary).

## 28. Recommended Technical Design

- Plugin registry: `CandidateProviderRTW`, `CandidateProviderCM`, shared `EligibilityEngine` with mode-specific rule packs.
- Explicit DTO for `ConfigurationSnapshot` to avoid leaking unstructured blobs into ranking.

## 29. Suggested Implementation Phasing

- **Phase 1:** Contract-ready mode fields; RTW-only depth; CM strict fallbacks stubbed (`roadmap.md`, BR-004 §12.1).
- **Phase 2–3:** Harden shared telemetry/governance without forcing CM retrieval depth.
- **Phase 4:** CM-aware retrieval/ranking, premium profiles, stylist workflows (BR-004 §12.4).
- **Phase 5:** Operational maturity and broader surfaces.

## 30. Summary

Mode orchestration preserves **fast RTW ecommerce validation** while laying a **governed, explainable path** for **CM** and **premium** styling. Shared platform components stay reusable; divergent business rules remain explicit in configuration, contracts, and traces.

## 31. Assumptions

- Phase 1 commercial validation remains RTW-first on PDP/cart as `roadmap.md` describes.
- CM configuration can be snapshotted or referenced with stable IDs for trace replay.
- Merchandising will codify premium guardrails before broad CM automation.
- Mixed-eligibility labeling is required wherever downstream behavior would otherwise misinterpret sets.

## 32. Open Questions / Missing Decisions

- Minimum configuration completeness before CM recommendations are allowed (BR-004 §15).
- Which premium styling changes require mandatory human approval before automation (BR-004 §15).
- Customer-facing explanation depth for CM vs internal-only (BR-004 §15, BR-011 §10.3).
- Prioritization of first clienteling/appointment surfaces for Phase 4 CM depth (BR-004 §15).
- Labeling strategy for hybrid journeys when customers switch between RTW browsing and CM consultation (BR-004 §15).
