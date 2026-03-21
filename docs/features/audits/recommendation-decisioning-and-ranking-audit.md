# Recommendation decisioning and ranking feature audit

**Scope:** `docs/features/recommendation-decisioning-and-ranking.md`  
**Method:** Check whether the feature deep-dive is concrete enough for architecture and implementation planning, with sufficient detail on workflows, data, APIs, events, UI implications, integrations, and failure modes.  
**Trigger source:** Issue-created automation for GitHub issue #181

---

## Depth

**Sufficient.** The document goes well beyond an outline and now defines the ranking pipeline, source-blend rules, request lifecycles, candidate and policy entities, internal contract semantics, deterministic fallback behavior, and implementation phasing. It is detailed enough for downstream architecture to separate ranking, governance, and orchestration responsibilities without guessing.

## Feature abstraction check

**Not too abstract.** The deep-dive names concrete pipeline stages, precedence order, configuration domains, trace expectations, edge cases, and operator-facing components. It avoids freezing model-training or infrastructure choices that still belong to architecture, while keeping those uncertainties explicit.

## Interaction clarity

**Clear.** Interactions with catalog readiness, governance snapshots, complete-look orchestration, delivery contracts, analytics, explainability, identity, context, and RTW/CM mode support are directly named. The doc makes clear that decisioning ranks inside governed boundaries and that final grouped outfit assembly remains a separate responsibility.

## API / events / data sufficiency

**Strong.** The spec includes:

- normalized request and candidate concepts
- policy snapshot and trace entities
- a sample internal candidate payload
- internal decisioning contract semantics
- serving-time and async event families
- telemetry and trace expectations for set IDs, source mix, degraded state, and policy versions

This is enough for architecture and implementation-planning work to proceed without inventing the business meaning of the ranking contract.

## UI and backend implications

**Covered.** The document explains both backend pipeline responsibilities and operator-facing implications such as ranking policy views, trace viewers, fallback monitoring, and source-mix simulation. It also identifies customer-facing consequences, especially around recommendation-type honesty and degraded-state presentation.

## Implementability assessment

**Pass.** Architecture and implementation-planning stages can now use this feature doc as a reliable source for:

- precedence enforcement
- internal ranking-pipeline decomposition
- policy and snapshot modeling
- trace and telemetry propagation
- degraded-state and fallback design
- integration boundaries with orchestration and governance

The remaining unresolved items are appropriately constrained to explicit open decisions and architecture-stage choices rather than missing feature-stage depth.

---

## Verdict

**Pass**

The feature deep-dive is specific enough for safe downstream architecture and planning work, while keeping unresolved precedence and policy-threshold questions visible.

---

## Minor improvements to consider later

1. When architecture formalizes the internal scoring-service boundary, add normative references from this feature doc to that architecture artifact.
2. Once `DEC-008` and `DEC-036` are resolved, tighten the policy examples so cross-surface campaign and curated-order behavior can be illustrated more concretely.
