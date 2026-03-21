# Feature review: Customer signal ingestion

**Artifact:** `docs/features/customer-signal-ingestion.md`  
**Trigger source:** Issue-created automation (GitHub issue #174)  
**Reviewer:** Autonomous documentation pass following `bootstrap-feature-review-loop.md`  
**References:** `docs/project/review-rubrics.md`, `docs/project/agent-operating-model.md`, `docs/.cursor/prompts/bootstrap-feature-deep-dives.md`

---

## Disposition

**`READY_FOR_HUMAN_APPROVAL`**

Rationale: The FEAT-007 doc now clears the feature-stage rubric threshold and is detailed enough for architecture and implementation-planning work without forcing downstream teams to guess about canonical signal envelopes, policy evaluation boundaries, freshness handling, consent-safe activation, operator-signal governance, or deletion / replay semantics. Remaining uncertainty is concentrated in explicit portfolio decisions in `docs/features/open-decisions.md` (`DEC-021`, `DEC-022`, `DEC-023`, `DEC-024`) rather than in missing structural coverage inside the feature itself.

---

## Scores (1-5 per `review-rubrics.md`)

| Dimension | Score | Notes |
| --- | ---: | --- |
| Clarity | 5 | The rewritten doc clearly separates raw capture, normalization, eligibility evaluation, downstream projections, and degraded-state behavior while using repository vocabulary consistently. |
| Completeness | 5 | It now covers personas, journeys, lifecycle states, business rules, data entities, projections, contracts, async flows, permissions, failure modes, and phased rollout in implementation-grade detail. |
| Implementation Readiness | 5 | Architecture and planning teams can act directly on the artifact because it specifies canonical envelopes, policy and eligibility semantics, projection types, revocation handling, and cross-feature dependencies. |
| Consistency With Standards | 5 | Aligns with BR-006, BR-010, BR-012, roadmap Phase 2/3 sequencing, `data-standards.md`, and the repository's required feature-spec structure. |
| Correctness Of Dependencies | 5 | Dependencies on identity/profile, analytics, explainability, clienteling, email, and governance are accurate and materially useful for downstream work. |
| Automation Safety | 5 | The document preserves explicit unresolved questions via tracked decision-register items, avoids claiming final policy or infrastructure decisions, and does not imply unsupported approval states. |

**Average:** **5.0**

---

## Confidence

**HIGH** - The canonical BR artifacts, architecture overview, roadmap, data standards, and adjacent feature specs provide enough context to define an implementation-grade customer-signal-ingestion feature specification without inventing the final regional policy matrix, exact freshness thresholds, note-governance depth, or storage architecture.

---

## Blocking issues

None for the feature-spec stage.

---

## Required edits

None required before architecture work begins. Downstream stages should resolve or explicitly defer:

1. `DEC-021` - signal-family consent matrix and permitted-use policy by region and surface
2. `DEC-022` - numeric freshness windows and decay policy by signal family and consuming surface
3. `DEC-023` - store / stylist signal governance depth, structured taxonomy, and reviewed free-text policy
4. `DEC-024` - raw signal retention, PII minimization, replay strategy, and regional residency model

---

## Approval-mode interpretation

Approval mode is **not explicit on a feature-stage board artifact available in this repository snapshot**, so this review uses the safe interpretation from `review-rubrics.md`: recommend **`READY_FOR_HUMAN_APPROVAL`** rather than `APPROVED`.

---

## Upstream artifacts to update

- No immediate upstream correction is required.
- If `DEC-021` through `DEC-024` resolve as canonical product or governance policy rather than architecture-only decisions, update the relevant `docs/project/` docs and affected BR artifacts before revising this feature spec.

---

## Recommended board update note

> FEAT-007 customer signal ingestion deep-dive expanded to implementation-grade detail with canonical signal envelopes, freshness and eligibility semantics, downstream projections, consent / identity gating, revocation handling, and operator-signal governance boundaries. Automated review passes the rubric threshold and is **READY_FOR_HUMAN_APPROVAL** pending explicit feature-stage approval-mode confirmation.

---

## Remaining human, milestone-gate, merge, or CI requirements

- Human or explicit board-level confirmation is still required before any final approval claim because feature-stage approval mode is not explicit in the available repository state.
- Merge and CI evidence remain separate from this documentation review.
- Downstream architecture and planning work still need to formalize the decision-register items referenced above.
