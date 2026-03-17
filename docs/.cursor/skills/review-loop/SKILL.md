---
name: review-loop
description: Runs the project review loop for repository artifacts using the defined rubric and approval states. Use when reviewing requirements, architecture, implementation plans, build checklists, or QA artifacts. Follows docs/project/review-rubrics.md and .cursor/prompts/review-pass.md.
---

# Review Loop

## When to use
- Any stage artifact is ready for review (BR, feature breakdown, architecture, implementation plan, UI/backend/integration deliverable, QA artifact).
- A review has been requested (direct run, or automation-triggered via issue/PR/schedule).
- You must decide whether the artifact requires edits, can move to READY_FOR_HUMAN_APPROVAL, can move directly to APPROVED, or should be escalated.

## Required inputs
- **Artifact under review:** Full content or path; do not review without it.
- **Upstream dependencies:** Linked BR, feature, architecture, or plan items so dependency correctness can be scored.
- **Approval mode** for this board item: HUMAN_REQUIRED or AUTO_APPROVE_ALLOWED (from board or artifact).
- **Milestone human gate or downstream block** (e.g. "UI readiness before backend") if applicable.
- **Trigger source** when applicable: direct run, issue-created, PR-opened, scheduled—state it in output.
- **Rejection comments** (if any): from board Notes or prior review; treat as required rework inputs.

## Workflow
1. **Read** the artifact and its upstream dependencies. If the artifact is missing or inaccessible, stop and request it; do not review from summary only.
2. **Read** `docs/project/review-rubrics.md` and any stage-relevant standards (e.g. `docs/project/standards.md`, `docs/project/data-standards.md`).
3. **Score** all six dimensions from 1 to 5: Clarity, Completeness, Implementation Readiness, Consistency With Standards, Correctness Of Dependencies, Automation Safety. Use the scoring anchors in `.cursor/prompts/review-pass.md` to justify scores. Compute the average.
4. **Apply stage-specific focus:** Requirements → clarity, completeness, business correctness. Architecture → implementation readiness, dependency correctness, no "TBD" on critical path. Build → interface coverage, testability, acceptance criteria, links to plan/architecture. QA → coverage, traceability, defect handling, human gate for release.
5. **Classify findings:** Blocking (must fix; dimension ≤2 or blocks promotion), required edits (should fix before promotion; list with section + change), optional (recommended edits or omit).
6. **Identify** approval mode and any milestone human gate. If automation-triggered, identify what still requires human approval, milestone-gate approval, or GitHub Actions.
7. **If human rejection comments exist,** treat them as required rework inputs and list every upstream artifact that must be updated before the item re-enters review.
8. **Recommend exactly one disposition:** CHANGES_REQUESTED, READY_FOR_HUMAN_APPROVAL, APPROVED (only if AUTO_APPROVE_ALLOWED and thresholds met), or escalation. Produce blockers first, then required edits, then promotion recommendation.
9. **Set confidence:** HIGH / MEDIUM / LOW. Low confidence forces CHANGES_REQUESTED or escalation; do not guess on missing decisions.

## Required output (complete)
- **Overall disposition:** Exactly one of CHANGES_REQUESTED, READY_FOR_HUMAN_APPROVAL, APPROVED, or Escalation.
- **Scores:** All six dimensions (1–5) and average. Brief justification for any score ≤2 or ≥4 where helpful.
- **Confidence:** HIGH | MEDIUM | LOW and one-line justification.
- **Blocking issues:** List or "None." Each with section/location and what must change.
- **Required edits:** List; each with section name and specific change. Optional: "Recommended edits" for non-blocking improvements.
- **Approval-mode interpretation:** HUMAN_REQUIRED → recommend READY_FOR_HUMAN_APPROVAL (never APPROVED). AUTO_APPROVE_ALLOWED → may recommend APPROVED only if average >4.1, no dimension <4, and no milestone gate bypassed.
- **Upstream artifacts to update:** If rejection comments apply or findings invalidate upstream assumptions, list artifacts (e.g. BR-001, implementation-plan) and what must be revised; otherwise "None."
- **Board update:** Recommended status and short note (rationale).
- **Remaining human/merge requirements:** What still needs human approval, milestone-gate approval, or GitHub Actions (e.g. merge, CI).

## Validation
- Do not approve artifacts that still require major interpretation for the next stage. Implementation readiness must support handoff.
- Escalate missing decisions instead of guessing; use LOW confidence and CHANGES_REQUESTED or explicit escalation note.
- Direct APPROVED is valid only when the item is explicitly AUTO_APPROVE_ALLOWED and review thresholds are met. Never recommend APPROVED for HUMAN_REQUIRED items without human approval evidence.
- Do not collapse review, approval, and completion into one step. State trigger and remaining human/merge requirements when automation-triggered.

## References
- Rubric and thresholds: `docs/project/review-rubrics.md`.
- Prompt (scoring anchors, stage focus, blocking vs required): `.cursor/prompts/review-pass.md`.
- Rules: `.cursor/rules/review-rigor.mdc`, `.cursor/rules/approval-and-rework.mdc`.

## Example output (structure)
```markdown
## Review: [Artifact name] — [Board item ID]

**Trigger:** [Direct run | issue-created | PR-opened | scheduled]

**Disposition:** [CHANGES_REQUESTED | READY_FOR_HUMAN_APPROVAL | APPROVED | Escalation]

**Scores (1–5):** Clarity _ | Completeness _ | Implementation Readiness _ | Consistency _ | Dependencies _ | Automation Safety _ → **Average:** _

**Confidence:** [HIGH | MEDIUM | LOW] — [one-line justification]

**Blocking issues:** [List with section/location or "None"]

**Required edits:** [List: section + change]

**Approval-mode interpretation:** [HUMAN_REQUIRED → READY_FOR_HUMAN_APPROVAL | AUTO_APPROVE_ALLOWED → APPROVED if thresholds met]

**Upstream artifacts to update:** [List or "None"]

**Board update:** Set status to [status]; add note: [rationale].

**Remaining human/merge requirements:** [What still needs human approval, milestone gate, or GitHub state]
```
