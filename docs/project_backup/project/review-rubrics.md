# Review Rubrics

## Review Loop Standard
Every stage follows the same baseline loop:

Create -> Review -> Edit -> Review -> Ready for human approval -> Approved -> Done

No artifact should bypass the loop.

Automation-triggered reviews may accelerate the loop, but they do not remove the need for human approval or merge-aware completion where the stage requires it.

## Approval Modes
Every board item or stage should declare an approval mode:
- `HUMAN_REQUIRED`: a passing review moves the item to `READY_FOR_HUMAN_APPROVAL`, and a named human decision is required before `APPROVED`.
- `AUTO_APPROVE_ALLOWED`: a passing review may move the item directly to `APPROVED` when the configured window explicitly allows it.

Auto-approval is a governance setting, not a shortcut around review quality. It should be used only for clearly defined phases or checkpoints, such as allowing agent-driven iteration up to UI readiness and then restoring a human gate before backend continuation.

If a human reviewer rejects an item and leaves comments, those comments become required rework inputs. The next agent pass must fold them back into the current artifact and any upstream requirements, plans, or dependency notes that were invalidated by the feedback.

## Scoring Dimensions
Score each dimension from 1 to 5.

| Dimension | What Good Looks Like |
|---|---|
| Clarity | Scope, intent, and artifact structure are easy to understand without restating the prompt. |
| Completeness | Required sections, dependencies, and edge cases are covered for the stage. |
| Implementation Readiness | The next stage could begin with limited ambiguity or rework. |
| Consistency With Standards | Artifact aligns with project terminology, structure, and lifecycle rules. |
| Correctness Of Dependencies | Upstream artifacts, contracts, assumptions, and constraints are referenced accurately. |
| Automation Safety | If the artifact or review was automation-triggered, it respects guardrails around approvals, promotion, and repo mutation. |

## Threshold Rules
- Average score below 3.5: automatic `CHANGES_REQUESTED`.
- Any single dimension at 2 or below: automatic `CHANGES_REQUESTED`.
- Average score 3.5 to 4.1 with no dimension below 3: may remain in review with targeted edits.
- Average score above 4.1 with no dimension below 4: eligible for promotion after review. Move to `READY_FOR_HUMAN_APPROVAL` if the item is `HUMAN_REQUIRED`; move directly to `APPROVED` if the item is explicitly `AUTO_APPROVE_ALLOWED`.
- Human approval is still required whenever the active approval mode says it is required.
- Any automation-triggered review that suggests promotion must still show the evidence path for human or merge-aware validation.

## Confidence Rating
Reviewers must provide a confidence rating:
- `HIGH`: inputs are stable, dependencies are clear, and outputs are ready for promotion.
- `MEDIUM`: likely correct, but one or more assumptions need explicit validation.
- `LOW`: uncertainty is high enough that promotion would risk rework or incorrect implementation.

Low confidence forces either:
- `CHANGES_REQUESTED`, or
- escalation to a human if the blocker is a missing decision rather than artifact quality.

## When Changes Are Requested
Move to `CHANGES_REQUESTED` when:
- required sections are missing,
- upstream dependencies are ambiguous,
- the artifact cannot support the next stage,
- standards are violated materially,
- unresolved assumptions could create costly downstream errors,
- a human approver rejected the item and provided comments that require requirements, design, or plan updates,
- or an automation-triggered run attempted to imply approval or completion without the required human or merge evidence.

## Escalation Rules
Escalate to a human decision when:
- scope conflicts with product strategy,
- architecture trade-offs cannot be resolved from existing context,
- dependencies require organizational decisions,
- data usage or governance questions affect legal or policy boundaries,
- repeated review cycles fail to converge,
- or automation recommendations conflict with explicit human or GitHub state.

## Stage-Specific Focus
### Requirements Stages
Prioritize clarity, completeness, and business correctness.

### Architecture Stage
Prioritize implementation readiness, correctness of dependencies, and standards consistency.

### Build Stages
Prioritize dependency correctness, interface coverage, testability, and acceptance criteria.

### QA Stage
Prioritize completeness of coverage, environment assumptions, traceability, and defect handling.

### Automation-Triggered Reviews
Prioritize:
- whether the run had the right trigger context;
- whether the correct board item or PR was targeted;
- whether the output stayed within automation-safe boundaries;
- and whether it avoided implying final approval or deterministic completion.

## Review Behavior For Hybrid Orchestration
- Cursor Automations may launch review agents on issue or PR events.
- Review agents may recommend status changes, but they must not collapse review, approval, and completion into a single step.
- If auto-approval is enabled for a stage, the approval-mode setting must be visible in the artifact or board context so reviewers can distinguish governed auto-approval from accidental approval skipping.
- If a board item depends on merge or CI completion, a review cannot mark it effectively done before the relevant GitHub state exists.
- Review output should note whether it came from direct invocation, PR-triggered automation, issue-triggered automation, or scheduled automation.

## Required Review Output Format
Every review should produce:
- overall disposition,
- scored dimensions,
- confidence rating,
- blocking issues,
- recommended edits,
- explicit statement on whether the artifact should move to `READY_FOR_HUMAN_APPROVAL`, direct `APPROVED`, or `CHANGES_REQUESTED` based on its approval mode,
- explicit note on whether human rejection comments must be propagated back into upstream requirements or plans,
- and, when relevant, explicit statement on what must still be confirmed by GitHub Actions or human approval before completion.
