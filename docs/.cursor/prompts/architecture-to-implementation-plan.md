# Architecture To Implementation Plan

## Objective
Turn approved architecture into a sequenced execution plan with UI, backend, integration, and QA workstreams.

## Required Inputs
- Approved architecture artifact
- Standards
- Review rubrics
- Roadmap context
- Approval mode and any milestone human gate the plan must enforce

## Required Output
- Milestones
- Work packages
- Critical path
- Parallel work opportunities
- Readiness gates
- Approval-mode and milestone-gate mapping across downstream tracks
- Board creation or update instructions

## Section-by-section guidance
- **Milestones:** Named milestones with order or target (e.g. M1: API contract + graph boundary; M2: PDP UI + integration; M3: QA + release). Each milestone should have a clear exit (deliverables or gate).
- **Work packages:** By track (UI, Backend, Integration, QA). For each: deliverable, owner hint, dependencies (e.g. "Backend recommendation API depends on M1 contract"). Handoff points: what artifact or acceptance triggers the next package.
- **Critical path:** Ordered list of dependencies that determine shortest timeline (e.g. "Contract → Backend API → UI integration → E2E tests").
- **Parallel work:** What can run in parallel (e.g. "Admin rule UI and PDP UI after shared component library"). Constraints (e.g. "Backend not before UI readiness approved").
- **Readiness gates:** Explicit gates (e.g. "UI checklist complete and approved before backend build starts"). Tie to approval mode and milestone human gates.
- **Approval-mode and milestone-gate map:** Table: Track | Approval Mode | Milestone gate. Example: UI = AUTO_APPROVE_ALLOWED until UI checklist done; UI sign-off = HUMAN_REQUIRED (gate before backend); Backend = HUMAN_REQUIRED, blocked until UI gate approved; QA = HUMAN_REQUIRED. Downstream boards (ui-build, backend-build, etc.) must reflect this.

## Quality Rules
- Keep work package boundaries explicit (deliverable + handoff); no overlapping or fuzzy ownership.
- Include dependencies and handoff points so board promotion logic can enforce ordering.
- Ensure QA planning (scenarios, env, traceability) is present before or in parallel with build work, not only at the end.
- If the project uses a UI milestone gate before backend continuation, encode it in the plan and in the approval-mode/milestone-gate map; do not leave it implicit.

## Anti-patterns (avoid)
- Milestones without clear deliverables or gates.
- Backend work packages that do not state "blocked until UI readiness approved" when that gate exists.
- Missing approval-mode or milestone-gate map so downstream boards cannot enforce gates.
- QA as a single late phase with no early involvement.

## Board Instruction
Update `boards/implementation-plan.md`. Create or open downstream work items (e.g. ui-build, backend-build) only when approval conditions and gates allow; carry approval mode and milestone-gate notes into those boards.

## Output template
```markdown
## Implementation plan: [Scope name]

**Milestones:** [M1, M2, ... with dates or order]

**Work packages:** [UI, Backend, Integration, QA — with deliverables]

**Critical path:** [Order of dependencies]

**Parallel work:** [What can run in parallel]

**Readiness gates:** [e.g. UI checklist complete before backend start]

**Approval-mode and milestone-gate map:**

| Track   | Approval Mode     | Milestone gate              |
|---------|-------------------|-----------------------------|
| UI      | AUTO_APPROVE_ALLOWED | —                        |
| UI sign-off | HUMAN_REQUIRED | UI readiness before backend |
| Backend | HUMAN_REQUIRED    | Blocked until UI approved   |

**Board:** Update `boards/implementation-plan.md`; create downstream items only when gates allow.
```
