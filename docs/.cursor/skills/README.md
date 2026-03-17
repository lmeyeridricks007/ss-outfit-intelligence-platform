# Project Skills

## Purpose
Reusable project-level Cursor skills for the AI Outfit Intelligence Platform workflow. Each skill is a **complete workflow**: when to use it, required inputs, step-by-step workflow, required output, validation rules, references to prompts/rules/docs, and examples. Use the correct skill for the task so behavior stays consistent with project standards.

## Skills (complete set)

### review-loop
**Use when:** Reviewing any stage artifact (BR, feature breakdown, architecture, implementation plan, UI/backend/integration deliverable, QA artifact) to decide disposition: CHANGES_REQUESTED, READY_FOR_HUMAN_APPROVAL, APPROVED, or escalation.

**Required inputs:** Artifact under review, upstream dependencies, approval mode, milestone gate (if any), trigger source, rejection comments (if any).

**Delivers:** Disposition, six dimension scores and average, confidence, blocking issues, required edits, approval-mode interpretation, upstream artifacts to update, board update recommendation, remaining human/merge requirements.

**References:** `docs/project/review-rubrics.md`, `.cursor/prompts/review-pass.md`, `.cursor/rules/review-rigor.mdc`, `.cursor/rules/approval-and-rework.mdc`.

---

### board-maintenance
**Use when:** Updating a board after artifact creation, review, approval, or promotion; recording rejection and upstream impact; creating downstream board entries when an item is approved and promotes to the next stage.

**Required inputs:** Board name, item ID, current status, requested new status, evidence for the transition, approval mode, milestone gate (if relevant), trigger source.

**Delivers:** Updated board row(s) with all required columns, change note, promotion decision (or upstream items to revise), and any new downstream row(s) when promoting.

**References:** `.cursor/prompts/board-update.md`, `docs/project/standards.md`, each `boards/*.md` Item Structure, `.cursor/rules/project-operating-model.mdc`, `.cursor/rules/approval-and-rework.mdc`.

---

### feature-pack-planning
**Use when:** Turning approved BR, feature breakdown, or architecture into an implementation plan: workstreams (UI, backend, integration, QA), dependency map, critical path, readiness gates, approval-mode and milestone-gate map, and recommended downstream board items.

**Required inputs:** Approved upstream artifact and linked board item, standards/context, approval mode and milestone-gate constraints, existing plan (if updating).

**Delivers:** Feature summary, workstream split, dependency map, critical path, parallel work, readiness and acceptance gates, approval-mode and milestone-gate map table, recommended downstream board items, automation opportunities and constraints.

**References:** `.cursor/prompts/architecture-to-implementation-plan.md`, `docs/project/agent-operating-model.md`, `boards/implementation-plan.md` and downstream boards, `.cursor/rules/project-operating-model.mdc`, `.cursor/rules/approval-and-rework.mdc`.

---

### automation-safe-triage
**Use when:** Any run was triggered by automation (issue, PR, or schedule). You must produce useful output (intake, review, suggestion) while respecting approval and completion boundaries and stop conditions.

**Required inputs:** Trigger source (must be stated in output), target (artifact/board item/PR), context (issue body, PR description, or board state). If context is insufficient or target is missing, stop and request clarification.

**Delivers:** Bounded output by type—intake summary and suggested board update; review findings and board impact; or next-task pickup suggestion—with trigger stated and no APPROVED/DONE without evidence and configured path.

**References:** `.cursor/prompts/automation-issue-intake.md`, `.cursor/prompts/automation-pr-review.md`, `.cursor/prompts/automation-next-task-pickup.md`, `.cursor/rules/automation-safety.mdc`, `docs/project/standards.md`.

---

### rejection-rework
**Use when:** A human reviewer rejected an item with comments; the item is in CHANGES_REQUESTED; and you must update the current artifact and any upstream artifacts invalidated by the comments. Do not use to approve—only to rework.

**Required inputs:** Rejection comments (full text), current artifact, board item ID, upstream artifacts (to identify what must be updated).

**Delivers:** Revised current artifact (or clear diff), upstream impact list (updated or to-be-revised artifacts with concrete changes), updated board Notes, explicit note that the item remains in CHANGES_REQUESTED until the next review.

**References:** `.cursor/rules/approval-and-rework.mdc`, `docs/project/review-rubrics.md`, `.cursor/skills/board-maintenance/SKILL.md`.

---

## Coverage summary
Together the skills cover: **review** (rubric-based disposition and scoring), **board updates** (evidence-based transitions and downstream creation), **planning** (implementation plans and approval/milestone-gate map), **automation safety** (bounded outputs and stop conditions), and **rejection rework** (comment incorporation and upstream propagation). For stage-specific artifact creation (e.g. BR from request, UI deliverable from plan), use the corresponding prompt in `.cursor/prompts/`; skills apply when the task is a multi-step workflow that combines reading standards, applying rules, and producing the full output structure described above.
