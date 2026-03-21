# Feature review: RTW and CM mode support

**Artifact:** `docs/features/rtw-and-cm-mode-support.md`  
**Trigger source:** Issue-created automation (GitHub issue #182)  
**Reviewer:** Autonomous documentation pass following `bootstrap-feature-review-loop.md`  
**References:** `docs/project/review-rubrics.md`, `docs/project/agent-operating-model.md`, `docs/.cursor/prompts/bootstrap-feature-deep-dives.md`

---

## Disposition

**`READY_FOR_HUMAN_APPROVAL`**

Rationale: The feature doc now clears the feature-stage rubric threshold and is concrete enough for downstream architecture and implementation-planning work. It defines explicit RTW-versus-CM boundaries across contracts, validation, compatibility, governance, telemetry, explanation depth, and phased rollout. Remaining uncertainty is isolated to portfolio-level open decisions already tracked in `docs/features/open-decisions.md` (`DEC-012`, `DEC-015`, `DEC-016`, `DEC-017`, `DEC-025`, `DEC-027`, `DEC-036`) rather than being left as hidden ambiguity inside the feature itself.

---

## Scores (1-5 per `review-rubrics.md`)

| Dimension | Score | Notes |
| --- | ---: | --- |
| Clarity | 5 | The document now uses the full 30-section structure and clearly separates RTW ecommerce behavior from CM assisted and bounded self-serve behavior. |
| Completeness | 5 | Covers purpose, scope, personas, journeys, lifecycle states, policy model, data model, APIs, events, UI implications, permissions, analytics, testing, and phased rollout. |
| Implementation Readiness | 5 | Downstream architecture and planning can proceed without guessing where mode resolution, CM validation, assisted-only gating, or telemetry separation belong. |
| Consistency With Standards | 5 | Aligns with glossary terms, roadmap phasing, telemetry requirements, and the repository's feature-spec structure and open-decision handling. |
| Correctness Of Dependencies | 5 | Correctly links the feature to catalog readiness, governance, explainability, delivery contracts, ecommerce surfaces, clienteling, and CM configuration inputs. |
| Automation Safety | 5 | Does not overclaim rollout readiness, does not invent policy decisions, and keeps unresolved exposure, explanation, and ordering choices explicitly tracked. |

**Average:** **5.0**

---

## Confidence

**HIGH** - The canonical BR docs, roadmap, product overview, personas, data standards, open-decision register, and adjacent feature specs provide enough context to define an implementation-grade RTW/CM deep-dive without guessing at final self-serve CM rollout scope or architecture-stage technical choices.

---

## Blocking issues

None for the feature-spec stage.

---

## Required edits

None required before architecture work begins. Downstream work should explicitly resolve or carry forward:

1. `DEC-012` - CM digital self-service scope vs stylist-assisted scope in early phases
2. `DEC-015` - category- and surface-specific readiness thresholds
3. `DEC-016` - inventory freshness windows and fallback behavior by surface
4. `DEC-017` - minimum CM field groups and compatibility evidence for customer-facing CM
5. `DEC-025` - customer-facing explanation scope and copy boundaries
6. `DEC-027` - role matrix for explanation and audit-detail access
7. `DEC-036` - curated ordering freedom by surface and mode

---

## Approval-mode interpretation

Approval mode is **not explicit on a feature-stage board artifact available in this repository snapshot**, so this review follows the safe interpretation from `review-rubrics.md`: recommend **`READY_FOR_HUMAN_APPROVAL`** rather than `APPROVED`.

---

## Upstream artifacts to update

- No immediate upstream corrections are required.
- If `DEC-012`, `DEC-017`, or `DEC-025` resolve into canonical product truth rather than architecture-only choices, update the relevant `docs/project/` or BR artifacts first, then reconcile this feature spec and any affected peer specs.

---

## Recommended board update note

> FEAT-015 RTW and CM mode support deep-dive expanded to implementation-grade detail with explicit mode semantics, RTW-versus-CM lifecycle differences, configuration-aware CM validation, governed fallback behavior, mode-sliced telemetry, and rollout boundaries for assisted versus customer-facing CM. Automated review passes the rubric threshold and is **READY_FOR_HUMAN_APPROVAL** pending explicit feature-stage approval-mode confirmation.

---

## Remaining human, milestone-gate, merge, or CI requirements

- Human or explicit board-level confirmation is still required before any final approval claim because feature-stage approval mode is not explicit in the available repository state.
- Merge and CI evidence remain separate from this documentation review.
- Downstream architecture artifacts still need to formalize contract shape, mode-resolution boundaries for mixed contexts, CM validation interfaces, and rollout controls for bounded self-serve CM.
