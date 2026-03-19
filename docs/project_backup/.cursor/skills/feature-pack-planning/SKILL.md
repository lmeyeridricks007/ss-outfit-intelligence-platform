---
name: feature-pack-planning
description: Converts approved business requirements, feature breakdowns, or architecture artifacts into execution-ready feature packs and implementation plans. Use when preparing detailed delivery assets for a specific feature: workstreams, dependency map, critical path, approval-mode and milestone-gate map, and downstream board items. Follows .cursor/prompts/architecture-to-implementation-plan.md and docs/project/agent-operating-model.md.
---

# Feature Pack Planning

## When to use
- Approved business requirements, feature breakdown, or architecture artifact exists and must be turned into an implementation plan.
- You need work packages for UI, backend, integration, and QA with clear handoffs, readiness gates, and milestone human gates.
- Downstream board items (e.g. ui-build, backend-build, integration-build, e2e-qa) must be created or updated with correct approval mode and gate dependencies.

## Required inputs
- **Approved upstream artifact:** BR, feature breakdown, or architecture (full content or path) and linked board item.
- **Standards and context:** `docs/project/standards.md`, `docs/project/review-rubrics.md`, roadmap or capability map if available.
- **Approval mode and milestone-gate constraints** from the upstream item or project (e.g. "UI gate before backend").
- **Existing implementation plan or board** (if updating) so you do not duplicate or contradict.

## Workflow
1. **Read** the approved upstream artifact and linked board item. Identify feature goal, complete set of sub-features or components, dependencies, and any stated approval or gate constraints.
2. **Identify** the complete set of work needed: no artificial cap on work packages. Include every deliverable required to move from this stage to build and QA. Trace each work package back to a feature need or architecture decision.
3. **Identify** where Cursor Automations can help (intake, review, next-task pickup) without replacing approvals. Note automation opportunities and constraints in output.
4. **Identify** milestone human gates. If the project uses "UI readiness reviewed before backend," or similar, encode it explicitly. Backend (and any other downstream track blocked by the gate) must show "Blocked until [gate item] APPROVED."
5. **Split work** into UI, backend, integration, and QA tracks as relevant. Define deliverables per track, handoff points (what artifact or acceptance triggers the next package), and merge-aware or CI completion points where applicable.
6. **Build** dependency map and critical path. Order work so dependencies are respected; call out parallel work. Surface shared dependencies (API, profile, graph, analytics, admin approvals) early.
7. **Define** readiness criteria and acceptance gates per milestone. Ensure QA planning is present before or in parallel with build work, not only at the end.
8. **Produce** approval-mode and milestone-gate map: for each track, Approval Mode and any milestone gate or blocker. Downstream boards must reflect this so agents and humans do not bypass gates.
9. **Recommend** board updates: create or update rows in `boards/implementation-plan.md` and, where gates allow, downstream boards (ui-build, backend-build, etc.). Carry approval mode and milestone-gate notes into downstream items.

## Required output (complete)
- **Feature summary:** What this plan delivers; link to upstream BR/feature/architecture.
- **Workstream split:** UI, backend, integration, QA (as applicable) with deliverables and ownership hint per work package.
- **Dependency map:** Which work packages depend on which; shared dependencies (profile, graph, API, analytics) called out.
- **Critical path:** Ordered list of dependencies that determine shortest timeline.
- **Parallel work:** What can run in parallel; constraints (e.g. backend not before UI gate approved).
- **Readiness gates:** Explicit gates (e.g. "UI checklist complete and approved before backend build starts"). Tie to approval mode and milestone human gates.
- **Acceptance gates:** What "done" means per milestone or package (deliverables, handoff criteria).
- **Approval-mode and milestone-gate map:** Table: Track | Approval Mode | Milestone gate / blocker. Example below.
- **Recommended downstream board items:** Which boards and items to create/update; status (e.g. TODO); link to parent; Approval Mode and Notes (gate dependencies).
- **Automation opportunities and constraints:** Where automation can trigger intake, review, or pickup; what it must not do (e.g. approve when HUMAN_REQUIRED).

## Validation
- Every work package traces back to a feature need or architecture decision. No orphan or vague packages.
- Shared dependencies (API, profile, graph, analytics, admin) are surfaced so implementation can sequence and avoid duplicate work.
- Milestone human gates are explicit. Backend (or other gated track) is not marked unblocked until the gate item is APPROVED.
- QA is not a single late phase; planning and coverage criteria are present before or alongside build work.
- Downstream board items are created only when approval conditions and gates allow; otherwise list "Blocked until [gate]."

## References
- Prompt (milestones, work packages, gate map): `.cursor/prompts/architecture-to-implementation-plan.md`.
- Stage table and approval pattern: `docs/project/agent-operating-model.md`.
- Boards: `boards/implementation-plan.md`, `boards/ui-build.md`, `boards/backend-build.md`, etc.
- Rules: `.cursor/rules/project-operating-model.mdc`, `.cursor/rules/approval-and-rework.mdc`.

## Example: approval-mode and milestone-gate map
| Track       | Approval Mode        | Milestone gate / blocker                    |
|------------|----------------------|---------------------------------------------|
| UI         | AUTO_APPROVE_ALLOWED | None until UI checklist complete            |
| UI sign-off| HUMAN_REQUIRED       | UI readiness reviewed before backend starts |
| Backend    | HUMAN_REQUIRED       | Blocked until UI readiness approved         |
| Integration| HUMAN_REQUIRED       | Per plan; may depend on UI/backend gates    |
| QA         | HUMAN_REQUIRED       | Release go/no-go                            |
