# Agent Operating Model

## Artifact metadata
- **Upstream source:** Repository rules, prompts, and GitHub issue #37 master product description.
- **Bootstrap stage:** Bootstrap support documentation.
- **Next downstream use:** Board design, stage promotion logic, and approval handling for later artifacts.
- **Key assumption:** The repository will add staged artifacts after bootstrap, so this operating model must work before boards exist.
- **Missing decisions:** Specific board schemas can be added later without changing the lifecycle and approval model defined here.

## Purpose
Define how this repository moves from bootstrap documentation to phased delivery so agents, humans, and automation operate against the same lifecycle, approval rules, and artifact handoffs.

## Source of truth
- `docs/project/` holds product, standards, architecture, and workflow guidance.
- `boards/` will hold stage-specific delivery tracking when boards are introduced.
- GitHub issues and pull requests hold execution history, review discussion, and merge state.
- `.cursor/prompts/`, `.cursor/rules/`, and `.cursor/skills/` define execution behavior for agents.

## Delivery stages

| Stage | Primary artifact | Purpose | Typical downstream handoff |
| --- | --- | --- | --- |
| Bootstrap | Canonical project docs in `docs/project/` | Establish shared product context, scope, roadmap, architecture direction, and standards. | Business requirements and feature breakdown generation. |
| Business requirements | BR artifact per product area or request | Capture scoped product and business intent for a work item. | Feature breakdown. |
| Feature breakdown | Feature or capability decomposition | Convert business scope into implementation-oriented feature slices. | Architecture. |
| Architecture | Technical architecture artifact | Define subsystem boundaries, interfaces, dependencies, and implementation approach. | Implementation plan. |
| Implementation plan | Workstream plan with dependency map | Split approved architecture into UI, backend, integration, and QA work. | Build stages. |
| UI / Backend / Integration build | Deliverable-specific build artifacts and code | Execute planned work in parallel where dependencies allow. | QA review. |
| QA review | Test matrix, validation notes, and go/no-go recommendation | Verify the work against the plan and requirements. | Human approval and release operations. |
| Release / optimization | Rollout, monitoring, and iteration | Move validated work into production and learn from telemetry. | Follow-on requirements. |

## Lifecycle states
Use these exact states in boards and stage notes:
- `TODO`
- `IN_PROGRESS`
- `NEEDS_REVIEW`
- `IN_REVIEW`
- `CHANGES_REQUESTED`
- `READY_FOR_HUMAN_APPROVAL`
- `APPROVED`
- `DONE`

## Approval modes
Every stage item should record one approval mode.

| Approval mode | Meaning |
| --- | --- |
| `HUMAN_REQUIRED` | A passing review is not enough to fully approve the item. Human approval is required before the item becomes `APPROVED`. |
| `AUTO_APPROVE_ALLOWED` | A passing review may recommend direct `APPROVED` when rubric thresholds are met and milestone gates are not bypassed. |

## Default approval guidance
Use these defaults unless a board item or artifact explicitly overrides them.

| Stage | Default approval mode |
| --- | --- |
| Bootstrap project docs | `AUTO_APPROVE_ALLOWED` for autonomous bootstrap runs |
| Business requirements | `HUMAN_REQUIRED` |
| Feature breakdown | `HUMAN_REQUIRED` |
| Architecture | `HUMAN_REQUIRED` |
| Implementation plan | `HUMAN_REQUIRED` |
| UI / Backend / Integration build | `AUTO_APPROVE_ALLOWED` for implementation readiness, unless a milestone gate says otherwise |
| QA review | `HUMAN_REQUIRED` before production release |

## Milestone-gate pattern
Some downstream work should wait for a recorded readiness checkpoint even when work streams are independently reviewable.

Examples:
- UI readiness reviewed before backend or integration work consumes a shared contract that the UI defines.
- Data contract approval before experimentation or marketing activation depends on new identity or telemetry logic.
- QA signoff before production rollout.

Record these gates in the artifact or board Notes rather than leaving them implicit.

## Artifact traceability expectations
Every artifact should identify:
- its upstream input artifacts;
- the next intended downstream artifact or stage;
- missing decisions that still require resolution;
- assumptions that shape the current design;
- the approval mode or governance interpretation if relevant.

## Roles

### Cursor Cloud Agents
Create and update artifacts, code, tests, and review outputs using repository prompts and rules.

### Cursor Automations
Trigger intake, review, or pickup suggestions. They must not overclaim approval or completion without the configured evidence.

### GitHub Actions
Provide deterministic validation such as linting, tests, CI checks, or merge-coupled workflows.

### Humans
Resolve strategic scope choices, approve stages that require human judgment, and make go or no-go decisions for production rollout.

## What later stages should expect from bootstrap docs
Bootstrap docs are complete enough when later agents can:
- derive business requirements for individual capabilities;
- split the platform into recommendation, data, delivery, and governance work streams;
- identify major surfaces, integrations, and telemetry requirements;
- understand where decisions are still open instead of guessing.

## Missing-decision handling
When the repository lacks a decision that affects scope, governance, or implementation direction:
1. record it explicitly as a missing decision;
2. keep the current artifact internally consistent without pretending the decision is settled;
3. point to the stage where the decision should be resolved;
4. do not silently widen or narrow scope downstream.

## Practical operating rule for this bootstrap repository state
This repository is still in the product-definition stage. Until boards and feature-level artifacts exist, `docs/project/` is the authoritative operating layer for product direction, review criteria, and future stage handoffs.
