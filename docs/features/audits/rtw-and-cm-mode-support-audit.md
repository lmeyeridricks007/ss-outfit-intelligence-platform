# RTW and CM mode support feature audit

**Scope:** `docs/features/rtw-and-cm-mode-support.md`  
**Method:** Check whether the feature deep-dive is concrete enough for architecture and implementation planning, with sufficient detail on workflows, data, APIs, events, UI implications, integrations, and failure modes.  
**Trigger source:** Issue-created automation for GitHub issue #182

---

## Depth

**Sufficient.** The document now goes well beyond an outline and defines explicit RTW-versus-CM behavior across request handling, validation states, recommendation lifecycles, configuration, data structures, contract semantics, event flows, UI posture, permissions, analytics, testing, and roadmap phasing.

## Feature abstraction check

**Not too abstract.** The deep-dive names concrete constructs such as `ModeContext`, `CMConfigurationSnapshot`, `ModeEligibilitySummary`, `ModePolicySnapshot`, explicit state transitions, assisted-use versus customer-facing-use validation, and mode-specific fallback behavior. It avoids freezing architecture-stage implementation choices while still giving downstream teams enough specificity to work safely.

## Interaction clarity

**Clear.** The document makes mode interactions explicit across:

- shared delivery contracts
- catalog and product intelligence
- recommendation decisioning and ranking
- merchandising governance and curated-order policy
- explainability and auditability
- ecommerce and clienteling consumers
- identity and profile usage boundaries
- CM configurator and appointment context sources

It is clear which parts stay shared and which must vary by mode.

## API / events / data sufficiency

**Strong.** The spec includes:

- mode-aware request and response semantics
- conceptual entities for mode context, CM configuration snapshots, eligibility summaries, and explanation payloads
- an illustrative CM payload example
- event families for mode resolution, CM validation, invalidation, degradation, and assisted review
- telemetry and audit expectations linking `mode`, recommendation IDs, trace IDs, snapshot IDs, and override context

This is enough for architecture and implementation-planning work to proceed without inventing the business meaning of RTW-versus-CM support.

## UI and backend implications

**Covered.** The feature defines both:

- backend responsibilities such as explicit mode resolution, validator components, stricter CM gating, invalidation flows, and policy snapshots
- UI and operator implications such as RTW purchase-forward presentation, CM limitation messaging, operator-safe explanation tiers, and clienteling-oriented review behavior

The document stops appropriately short of freezing final screen design or serving topology.

## Implementability assessment

**Pass.** Architecture and implementation-planning teams can safely use this feature doc as a baseline for:

- mode-aware contract and trace design
- RTW-first ecommerce behavior
- CM assisted-use validation and later customer-facing gating
- stricter governance and explanation boundaries for premium contexts
- mode-specific analytics and rollout guardrails

The remaining open items are legitimate portfolio decisions already tracked in `open-decisions.md`, not defects in the feature-stage specification.

---

## Verdict

**Pass**

The feature deep-dive is now specific enough for safe downstream architecture and planning work and materially stronger than the original outline-level version.

---

## Minor improvements to consider later

1. Once architecture formalizes the shared delivery and validator interfaces, add direct links from this feature doc to the normative architecture artifacts.
2. After `DEC-012`, `DEC-017`, and `DEC-036` resolve, tighten the examples for assisted-only versus customer-facing CM behavior and curated-order freedom by surface.
