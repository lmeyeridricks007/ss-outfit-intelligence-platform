# Agent Operating Model

## Purpose

This document defines how work should move through this repository from project bootstrap through delivery. It is the canonical operating reference for agents, automations, and reviewers working from `docs/project/` and `boards/`.

## Operating principles

- `docs/project/` is the canonical source of truth for product intent, standards, and delivery guidance.
- `boards/` tracks stage progression and item-level status.
- GitHub issues and pull requests are the execution triggers and audit trail for stage work.
- Agents may draft, review, and refine artifacts, but they must not invent approvals, merge evidence, or production completion.
- Traceability from one stage to the next is required so downstream work does not guess at source intent.

## Repository delivery model

The repository is structured as a staged artifact pipeline:

1. Bootstrap canonical project docs.
2. Derive business requirements from the canonical docs.
3. Break business requirements into features.
4. Produce technical architecture for features.
5. Produce implementation plans and downstream delivery tracks.
6. Execute UI, backend, and integration work by phase.
7. Review, validate, and promote work using the board lifecycle and approval model.

## Canonical stages

### 1. Bootstrap project docs

**Primary outputs**
- `docs/project/vision.md`
- `docs/project/goals.md`
- `docs/project/problem-statement.md`
- `docs/project/personas.md`
- `docs/project/product-overview.md`
- `docs/project/business-requirements.md`
- `docs/project/roadmap.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`
- optional standards docs as needed

**Purpose**
- Establish the product definition and cross-cutting standards.
- Create the source material for all later stages.

**Typical trigger**
- `workflow:bootstrap`

### 2. Business requirements stage

**Primary board**
- `boards/business-requirements.md`

**Primary outputs**
- `docs/project/br/*.md`

**Purpose**
- Turn the project-level product docs into concrete BR artifacts with scope, users, value, constraints, and measurable outcomes.

**Typical trigger**
- `workflow:br`

### 3. Feature breakdown stage

**Primary board**
- `boards/features.md`

**Primary outputs**
- feature-level artifacts derived from BRs

**Purpose**
- Break approved business requirements into implementable feature sets and execution scope.

**Typical trigger**
- `workflow:feature-spec`

### 4. Architecture stage

**Primary board**
- `boards/technical-architecture.md`

**Primary outputs**
- feature-level technical architecture artifacts

**Purpose**
- Define boundaries, dependencies, interfaces, and technical decisions needed before implementation planning.

**Typical trigger**
- `workflow:architecture`

### 5. Implementation planning stage

**Primary board**
- `boards/implementation-plan.md`

**Primary outputs**
- implementation plans with phases, workstreams, downstream board items, approval-mode mapping, and milestone gates

**Purpose**
- Convert approved architecture into trackable execution work across UI, backend, and integration streams.

**Typical triggers**
- architecture-driven planning prompts

### 6. UI delivery stage

**Primary board**
- `boards/ui-build.md`

**Purpose**
- Execute phase-scoped user interface work from the implementation plan.

**Typical trigger**
- `workflow:ui`

### 7. Backend delivery stage

**Primary board**
- `boards/backend-build.md`

**Purpose**
- Execute phase-scoped backend and service work from the implementation plan.

**Typical trigger**
- `workflow:backend`

### 8. Integration delivery stage

**Primary board**
- `boards/integration-build.md`

**Purpose**
- Execute phase-scoped integration and contract work after upstream dependencies are ready.

**Typical trigger**
- `workflow:integration`

### 9. Phase hookup and control stage

**Purpose**
- Coordinate readiness and handoff between implementation-plan, UI, backend, and integration boards.

**Typical triggers**
- `workflow:hookup`
- `delivery-control`

## Lifecycle states

Use these exact lifecycle states across boards and stage artifacts:

- `TODO`
- `IN_PROGRESS`
- `NEEDS_REVIEW`
- `IN_REVIEW`
- `CHANGES_REQUESTED`
- `READY_FOR_HUMAN_APPROVAL`
- `APPROVED`
- `DONE`

Do not invent aliases or substitute labels.

## What each lifecycle state means

### TODO
Work has been identified and queued, but execution has not started.

### IN_PROGRESS
The artifact or work item is actively being created or revised.

### NEEDS_REVIEW
The artifact is ready for a review pass but review has not started.

### IN_REVIEW
The artifact is currently under structured review.

### CHANGES_REQUESTED
Review found blocking issues or required rework that must be completed before promotion.

### READY_FOR_HUMAN_APPROVAL
The artifact passed review but still requires explicit human approval because the board item is `HUMAN_REQUIRED`.

### APPROVED
The artifact has met the review bar and the approval path for the stage or item.

### DONE
The work is complete with whatever merge, CI, validation, or rollout evidence the stage requires. Do not treat `APPROVED` and `DONE` as interchangeable.

## Approval modes

Every board item should carry one explicit approval mode:

- `HUMAN_REQUIRED`
- `AUTO_APPROVE_ALLOWED`

### HUMAN_REQUIRED

- Passing review promotes to `READY_FOR_HUMAN_APPROVAL`.
- A human approval record is required before the item becomes `APPROVED`.
- Agents and automations must not skip this path unless autonomous mode is explicitly configured for run completion and the repository rules allow it.

### AUTO_APPROVE_ALLOWED

- Passing review may promote directly to `APPROVED`.
- This mode must be recorded on the board or in the artifact notes.
- It does not remove milestone gates or deterministic validation requirements.

## Milestone human gates

Some workflows include milestone gates that affect downstream readiness, for example:

- UI readiness reviewed before backend work continues
- legal or privacy review before sensitive signals are used
- release or production cutover approval before a stage is marked done

Milestone gates must be recorded in:
- board notes, or
- the implementation plan, or
- both

If a milestone gate is unresolved, downstream pickup must say so explicitly.

## Board responsibilities

Boards are the operational index of stage progress. Each board row should be able to answer:

- what item is being worked on
- what stage it belongs to
- what source artifact triggered it
- what output file or deliverable is expected
- what approval mode applies
- what notes, blockers, or milestone gates apply
- what downstream stage it promotes to

At minimum, boards should preserve:
- item ID
- title or feature name
- status
- approval mode
- source references
- output path
- exit criteria
- notes or blockers

## Traceability requirements

Every artifact should be traceable:

- upstream to the source artifact or board row that required it
- downstream to the next board or stage it enables

Examples:
- bootstrap docs -> BR board rows
- BR artifact -> feature rows
- feature artifact -> architecture row
- architecture artifact -> implementation plan
- implementation plan -> UI/backend/integration rows

When rework invalidates an upstream assumption, the affected upstream artifact must be updated rather than patched only in a downstream file.

## Agent responsibilities by role

### Cursor Cloud agents

- read the relevant prompts, rules, and source docs
- create or update the target artifact
- preserve traceability and terminology consistency
- run the appropriate review loop
- commit and push when the workflow expects autonomous completion

### Cursor automations

- trigger narrow, auditable actions
- summarize or suggest board impact within authority boundaries
- avoid claiming approvals, completion, or merge-coupled status changes without evidence

### GitHub Actions and deterministic systems

- perform reproducible checks
- enforce CI and merge conditions
- provide merge-aware evidence when `DONE` depends on repository state

### Humans

- approve items that are `HUMAN_REQUIRED`
- resolve scope, legal, policy, or architectural escalations
- review milestone gates where human judgment is explicitly required

## Autonomous mode behavior

When autonomous mode is enabled for a run:

- agents should complete the assigned artifact work without stopping for a manual "mark ready" step
- agents may commit and push so the run can finish end-to-end
- review outcomes may support `APPROVED` for run completion when repository rules allow it
- milestone gates still need to be recorded as notes; they do not disappear
- `DONE` still requires the evidence appropriate to the stage, such as merge or deterministic validation where applicable

When autonomous mode is not enabled:

- agents should respect standard approval and review boundaries
- `HUMAN_REQUIRED` items must stop at `READY_FOR_HUMAN_APPROVAL`

## Promotion rules by stage

### Bootstrap docs -> business requirements
- Promote only when the canonical project docs are coherent, complete, and useful for BR fan-out.

### Business requirements -> features
- Promote only when the BR has explicit scope, users, value, metrics, constraints, and phase context.

### Features -> architecture
- Promote only when feature behavior and acceptance boundaries are clear enough for technical design.

### Architecture -> implementation plan
- Promote only when boundaries, dependencies, and critical interfaces are concrete enough to sequence execution.

### Implementation plan -> UI/backend/integration
- Promote only when tracks, dependencies, milestone gates, and approval modes are explicit on the plan and downstream boards.

### UI/backend/integration -> completion
- Promote only when acceptance criteria, review results, and any required deterministic validation are present.

## Review expectations

- Use `docs/project/review-rubrics.md` for scoring dimensions and promotion thresholds.
- Reviews should lead with blockers and required edits before strengths.
- Confidence must be recorded as `HIGH`, `MEDIUM`, or `LOW`.
- Human rejection comments become required rework inputs, not optional suggestions.

## Repository-specific current state

At the time of this bootstrap layer:

- `boards/business-requirements.md` exists and reflects BR-stage workflow expectations.
- Later boards such as `boards/features.md`, `boards/technical-architecture.md`, `boards/implementation-plan.md`, `boards/ui-build.md`, `boards/backend-build.md`, and `boards/integration-build.md` are expected by prompts but may not exist yet.
- Agents creating later-stage artifacts should create or update those boards when the relevant stage is reached rather than assuming they already exist.

## Guardrails

- Do not skip stages because a later-stage prompt appears available.
- Do not mark `APPROVED` or `DONE` without the required review and approval evidence.
- Do not treat a board update as a substitute for a real artifact.
- Do not hide assumptions or unresolved decisions inside downstream implementation notes.
- Do not contradict GitHub state, recorded approvals, or merge evidence.

## References

- `docs/project/standards.md`
- `docs/project/review-rubrics.md`
- `docs/project/roadmap.md`
- `boards/`
