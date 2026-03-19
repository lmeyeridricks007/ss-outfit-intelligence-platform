# Review Rubrics

## Artifact metadata
- **Upstream source:** Repository review rules and GitHub issue #37 bootstrap context.
- **Bootstrap stage:** Bootstrap support documentation.
- **Next downstream use:** Structured review passes for project docs, BRs, architecture, plans, build artifacts, and QA outputs.
- **Key assumption:** Every later stage will use the same six-dimension scoring model unless the repository standards change explicitly.
- **Missing decisions:** Stage-specific board policies may add detail later, but not new scoring dimensions or thresholds.

## Purpose
Define the common review model for artifacts created in this repository so every stage uses the same scoring dimensions, thresholds, confidence rules, and promotion logic.

## Review dimensions
Score every reviewed artifact from 1 to 5 in each dimension.

| Dimension | What good looks like | Common failure mode |
| --- | --- | --- |
| Clarity | The artifact is easy to follow, uses repository terminology consistently, and makes scope and intent explicit. | Ambiguous scope, unclear terminology, or confusing structure. |
| Completeness | All required sections, dependencies, constraints, and missing decisions for the stage are present. | Required sections or downstream-critical details are missing. |
| Implementation Readiness | The next stage can start without guessing core behavior, interfaces, or acceptance criteria. | The next stage would need to infer major requirements or contracts. |
| Consistency With Standards | The artifact follows repository standards for terminology, lifecycle states, traceability, and structure. | It conflicts with project standards or uses ad hoc naming or states. |
| Correctness Of Dependencies | Upstream sources, downstream impacts, interfaces, and sequencing assumptions are accurate and explicit. | Missing or incorrect dependencies, unsupported assumptions, or broken traceability. |
| Automation Safety | The artifact respects approval boundaries, trigger context, and deterministic validation needs. | It overclaims approval, completion, or certainty that the evidence does not support. |

## Score anchors

### 1 - Unusable
- Major sections are missing or wrong.
- The artifact cannot safely support downstream work.
- Terminology, dependencies, or status handling is materially incorrect.

### 2 - Weak
- The artifact has some useful content but still contains blocking ambiguity, missing sections, or incorrect assumptions.
- Downstream work would likely be delayed or mis-scoped.

### 3 - Adequate
- The artifact is understandable and mostly complete.
- There are still meaningful gaps, but they are not all blocking.
- Downstream work can begin only with caution and explicit follow-up.

### 4 - Strong
- The artifact is clear, materially complete for the stage, and aligned with repository standards.
- Remaining gaps are minor, explicitly called out, and do not undermine the handoff.

### 5 - Exemplary
- The artifact is immediately actionable, internally consistent, thoroughly traceable, and clear about known unknowns.
- It materially reduces downstream ambiguity and rework risk.

## Thresholds and disposition
Use the full score set, not only the average.

| Condition | Disposition |
| --- | --- |
| Any dimension is 1 or 2 | `CHANGES_REQUESTED` |
| Average is below 3.5 | `CHANGES_REQUESTED` |
| Average is 3.5 or higher, but at least one dimension is 3 | Passing quality is possible, but only recommend promotion when the stage's approval mode allows it and no blocking issues remain. |
| Average is above 4.1 and no dimension is below 4 | Eligible for promotion according to approval mode. |

## Approval-mode handling
Apply the stage or board item's recorded approval mode.

| Approval mode | Promotion rule |
| --- | --- |
| `HUMAN_REQUIRED` | A passing review recommends `READY_FOR_HUMAN_APPROVAL`. A reviewer or human decision is still needed before `APPROVED`. |
| `AUTO_APPROVE_ALLOWED` | A passing review may recommend `APPROVED` when thresholds are met and no milestone gate is bypassed. |

## Confidence levels
- `HIGH`: The reviewer has enough direct evidence from the artifact and linked standards to support the disposition.
- `MEDIUM`: The artifact is mostly assessable, but some assumptions or gaps remain.
- `LOW`: Critical context is missing, conflicting, or too ambiguous to assess responsibly.

Low confidence should lead to `CHANGES_REQUESTED` or escalation when the main problem is unresolved product or governance decisions rather than document quality alone.

## Blocking issues versus required edits
- **Blocking issue:** Must be fixed before promotion because it changes scope, dependencies, readiness, or governance interpretation.
- **Required edit:** Needed for a high-quality handoff but not necessarily a full blocker in isolation.
- **Recommended edit:** Optional improvement that does not affect the disposition.

## Stage-specific review focus

### Bootstrap and project docs
Stress product clarity, scope boundaries, terminology, roadmap logic, and whether later feature or architecture generation could proceed without guessing.

### Business requirements and feature breakdowns
Stress problem definition, user coverage, business value, scope boundaries, and measurable success criteria without drifting into technical design.

### Architecture
Stress system boundaries, contracts, dependency correctness, operational assumptions, and whether the implementation plan can be derived safely.

### Implementation plans
Stress workstream decomposition, sequencing, readiness gates, explicit interfaces, and acceptance criteria for downstream UI, backend, integration, and QA work.

### Build artifacts
Stress contract coverage, testability, observability, dependency correctness, and alignment with plan and architecture.

### QA artifacts
Stress scenario coverage, traceability to requirements, environment assumptions, and whether release or rollout decisions still require human or deterministic validation.

## Escalation triggers
Escalate instead of guessing when:
- legal, privacy, or consent requirements are undefined for a data use case;
- organization-owned dependencies or systems of record are unclear;
- architecture trade-offs cannot be decided from existing project docs;
- scope conflicts exist between upstream artifacts;
- a human rejection implies upstream artifacts must be reworked.

## Required review output shape
Every structured review should include:
1. artifact name and identifier if available;
2. trigger source;
3. disposition;
4. scores for all six dimensions plus average;
5. confidence and rationale;
6. blocking issues;
7. required edits;
8. approval-mode interpretation;
9. upstream artifacts to update if relevant;
10. board update recommendation if a board exists;
11. remaining human, CI, or merge requirements.

## Notes for autonomous runs
Autonomous runs may complete commit, push, and PR creation when the repository configuration allows it, but the artifact itself must still be explicit about any remaining human approval, CI, rollout, or merge dependencies.
