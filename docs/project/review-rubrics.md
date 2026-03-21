# Review Rubrics

## Purpose
Define the scoring model, thresholds, approval interpretation, and required output structure for reviewing repository artifacts.

## Practical usage
Use this rubric for BR artifacts, feature specs, architecture docs, implementation plans, build artifacts, and QA artifacts.

## Review dimensions
Score every artifact from 1 to 5 in each dimension:
1. **Clarity** - Is the artifact easy for the next stage to understand without re-interpretation?
2. **Completeness** - Does it cover required scope, boundaries, assumptions, and missing decisions?
3. **Implementation Readiness** - Can the next stage act on it without major guesswork?
4. **Consistency With Standards** - Does it align with `docs/project/standards.md` and any stage-specific standards?
5. **Correctness Of Dependencies** - Are upstream inputs, constraints, and downstream implications represented correctly?
6. **Automation Safety** - Does it avoid overstating certainty, bypassing approval paths, or implying unsupported state changes?

## Score meanings
| Score | Meaning |
| --- | --- |
| 5 | Strong and immediately usable with no meaningful gaps |
| 4 | Good and promotable with only minor improvements |
| 3 | Usable but still requires notable edits before safe promotion |
| 2 | Weak and missing important detail or correctness |
| 1 | Unusable or materially misleading |

## Thresholds
- Average below 3.5 -> recommend `CHANGES_REQUESTED`
- Any dimension at 2 or below -> recommend `CHANGES_REQUESTED`
- Average above 4.1 with no dimension below 4 -> eligible for promotion

Promotion interpretation then depends on approval mode:
- `HUMAN_REQUIRED` -> recommend `READY_FOR_HUMAN_APPROVAL`
- `AUTO_APPROVE_ALLOWED` -> may recommend `APPROVED`

## Confidence levels
- **HIGH**: Context is sufficient and the artifact is clearly promotable or clearly blocked.
- **MEDIUM**: Minor uncertainty remains, but review conclusions are dependable.
- **LOW**: Missing decisions or context gaps prevent a safe promotion recommendation.

LOW confidence should result in `CHANGES_REQUESTED` or explicit escalation rather than approval.

## Stage-specific focus
### Requirements artifacts
Emphasize clarity, completeness, user reality, scope boundaries, and measurable success criteria.

### Architecture artifacts
Emphasize implementation readiness, dependency correctness, contracts, and explicit technical boundaries.

### Build artifacts
Emphasize interface coverage, acceptance criteria, testability, and alignment to architecture and plan.

### QA artifacts
Emphasize coverage, traceability to requirements, environment assumptions, and defect handling.

## Blocking issues
A finding is blocking when it:
- makes downstream implementation unsafe
- contradicts a canonical requirement or standard
- omits a critical dependency or missing decision
- implies an approval or completion state that is not supported

## Required review output
Every formal review should include:
- overall disposition: `CHANGES_REQUESTED`, `READY_FOR_HUMAN_APPROVAL`, `APPROVED`, or `Escalation`
- all six scores and the average
- confidence level with one-line justification
- blocking issues
- required edits
- approval-mode interpretation
- upstream artifacts to update, if any
- recommended board update and note
- remaining human, milestone-gate, merge, or CI requirements

## Approval modes
- `HUMAN_REQUIRED`: a passing review can only recommend `READY_FOR_HUMAN_APPROVAL`; final approval still requires a human.
- `AUTO_APPROVE_ALLOWED`: a passing review may recommend `APPROVED` when thresholds are met and no milestone gate is bypassed.

Approval mode must be explicit on the board item or artifact. Do not assume it.

## Rejection and rework expectations
If a human reviewer rejected an artifact:
- keep or set status to `CHANGES_REQUESTED`
- treat every rejection comment as required rework input
- update upstream artifacts when the comments invalidate upstream assumptions
- do not self-approve from the same rework pass

## Automation-triggered review notes
When a review is automation-triggered, state the trigger source explicitly and call out what still requires human approval, milestone approval, merge, or CI evidence.
