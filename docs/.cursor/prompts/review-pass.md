# Review Pass Prompt

## Objective
Perform a rubric-based review of a stage artifact and decide whether it requires edits, can move to `READY_FOR_HUMAN_APPROVAL`, can move directly to `APPROVED`, or should be escalated. Use the scoring dimensions and thresholds in `docs/project/review-rubrics.md`; do not invent new criteria.

## Required Inputs
- Artifact under review (full content or path)
- Relevant standards (e.g. `docs/project/standards.md`, stage-specific docs)
- `docs/project/review-rubrics.md` (scoring dimensions and threshold rules)
- Upstream dependencies (linked BR, feature, architecture, or plan items)
- Approval mode for this item (`HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED`)
- Any milestone human gate or downstream block (e.g. "UI readiness before backend")
- Trigger source when applicable (direct run, issue-created, PR-opened, scheduled)

## Scoring anchors (1–5 per dimension)
Use these to justify scores; cite which anchor applies when giving a 2 or a 4.
- **Clarity:** 1–2 = scope or intent unclear, structure missing or confusing. 3 = understandable but needs clarification in places. 4–5 = scope, intent, and structure clear; next reader can act without restating the prompt.
- **Completeness:** 1–2 = required sections missing or obviously incomplete. 3 = most sections present but gaps (e.g. edge cases, dependencies). 4–5 = all required sections present; dependencies and edge cases addressed for this stage.
- **Implementation Readiness:** 1–2 = next stage cannot start or would guess. 3 = next stage could start with some clarification. 4–5 = next stage can start with limited ambiguity; handoff criteria explicit.
- **Consistency With Standards:** 1–2 = terminology or lifecycle rules violated. 3 = minor inconsistencies. 4–5 = aligns with project terminology, structure, and lifecycle (e.g. approval mode, board states).
- **Correctness Of Dependencies:** 1–2 = upstream refs wrong or missing; contracts/assumptions incorrect. 3 = mostly correct but one or more refs vague. 4–5 = upstream artifacts, contracts, and constraints referenced accurately.
- **Automation Safety:** 1–2 = implies approval/completion without evidence or bypasses gates. 3 = unclear whether automation boundaries were respected. 4–5 = trigger stated; no overclaim of approval or done state; milestone gates respected.

## Stage-specific focus (what to stress when scoring)
- **Requirements (BR, feature breakdown):** Clarity and completeness of problem, scope, users, and success criteria; no hidden technical design.
- **Architecture:** Implementation readiness and correctness of dependencies; explicit boundaries and contracts; no hand-wavy "will be decided later" on critical paths.
- **Build (UI, backend, integration):** Dependency correctness, interface coverage (APIs, events, surfaces), testability, and acceptance criteria; links to plan and architecture.
- **QA:** Coverage (happy path, fallback, errors), environment assumptions, traceability to requirements, defect handling; no approval of release without human gate unless explicitly allowed.

## Blocking vs required edit vs optional
- **Blocking:** Must fix before any promotion (e.g. missing section, wrong approval-mode use, incorrect upstream ref). Score in the affected dimension 2 or below; disposition must be CHANGES_REQUESTED.
- **Required edit:** Should fix before recommending READY_FOR_HUMAN_APPROVAL or APPROVED (e.g. ambiguous scope, missing edge case). List under "Required edits"; if not fixed, confidence must not be HIGH.
- **Optional:** Improves quality but not required for this stage. Can list under "Recommended edits" or omit to keep output focused.

## Required Output
- Overall disposition (exactly one of: CHANGES_REQUESTED, READY_FOR_HUMAN_APPROVAL, APPROVED)
- Score for each of the six dimensions (1–5) and average
- Confidence (HIGH | MEDIUM | LOW) and brief justification
- Blocking issues (list or "None")
- Required edits (list; be specific: section name + what to change)
- Approval-mode interpretation (HUMAN_REQUIRED → recommend READY_FOR_HUMAN_APPROVAL; AUTO_APPROVE_ALLOWED → may recommend APPROVED only if scores and thresholds met)
- Upstream artifacts to update if rejection comments changed assumptions (list or "None")
- Board update recommendation (status + short note)
- Remaining human/merge requirements (what still needs human approval or GitHub state)

## Quality Rules
- Prioritize correctness, gaps, and readiness over summary; avoid generic praise.
- Do not approve artifacts that are well written but not actionable (e.g. "nice overview" with no handoff criteria).
- Escalate unresolved dependency decisions rather than guessing (LOW confidence + CHANGES_REQUESTED or escalation note).
- If the item is `HUMAN_REQUIRED`, a passing review recommends `READY_FOR_HUMAN_APPROVAL`, never direct `APPROVED`.
- If the item is `AUTO_APPROVE_ALLOWED`, a passing review may recommend `APPROVED` only when average > 4.1, no dimension < 4, and no milestone gate is bypassed.
- If a human reviewer previously rejected with comments, treat those comments as required rework and list upstream artifacts that must be revised.
- If the run was automation-triggered, state trigger and what still requires human approval, milestone-gate approval, or GitHub Actions.

## Output template
```markdown
## Review: [Artifact name] — [Board item ID]

**Trigger:** [Direct run | issue-created | PR-opened | scheduled]

**Disposition:** [CHANGES_REQUESTED | READY_FOR_HUMAN_APPROVAL | APPROVED]

**Scores (1–5):** Clarity _ | Completeness _ | Implementation Readiness _ | Consistency _ | Dependencies _ | Automation Safety _ → **Average:** _

**Confidence:** [HIGH | MEDIUM | LOW]

**Blocking issues:** [List or "None"]

**Required edits:** [List]

**Approval-mode interpretation:** [HUMAN_REQUIRED → recommend READY_FOR_HUMAN_APPROVAL | AUTO_APPROVE_ALLOWED → recommend APPROVED]

**Upstream artifacts to update (if rejection comments apply):** [List or "None"]

**Board update:** Set status to [status]; add note: [rationale].

**Remaining human/merge requirements:** [What still needs human approval or GitHub state]
```
