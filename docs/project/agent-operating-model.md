# Agent Operating Model

## Purpose
This document defines how the repository should operate as a hybrid delivery system for the AI Outfit Intelligence Platform. It explains how GitHub, Cursor Cloud Agents, Cursor Automations, GitHub Actions, boards, prompts, rules, skills, and human approvals work together.

## Operating Principles
- GitHub remains the source of truth for issues, pull requests, code, docs, merge history, and approvals.
- Cursor Cloud Agents remain the primary repo-aware execution engine.
- Cursor Automations are introduced where event-driven or background triggering simplifies the workflow.
- GitHub Actions remain the deterministic automation layer for CI, merge-aware transitions, and safety-critical repo workflows.
- Approval mode must be explicit at every major stage boundary.
- Human approvals remain mandatory wherever the active approval mode is `HUMAN_REQUIRED`.
- Auto-approval may be enabled only for clearly bounded windows with a named stop point.

## Repository Structure Recommendation
Use the repository as a structured workspace where artifacts live by purpose and stage.

```text
CloudAgents/
├── docs/
│   └── project/
│       ├── *.md
│       ├── cursor-automations-architecture.md
│       ├── cursor-automations-usage-guidelines.md
│       ├── cursor-automations-vs-github-actions.md
│       └── labs/
│           ├── lab-series-outline.md
│           └── lab-roadmap-checklist.md
├── boards/
│   ├── *.md
├── .cursor/
│   ├── prompts/
│   ├── rules/
│   └── skills/
└── .github/
    └── workflows/
        └── README.md
```

## Where Artifacts Should Live
- `docs/project/`: durable source-of-truth context, architecture, and operating guidance.
- `docs/project/labs/`: curriculum roadmap, detailed labs, and master checklist.
- `boards/`: stage-by-stage board and checklist files that drive work progression.
- `.cursor/prompts/`: prompts for direct agent runs and automation-triggered runs.
- `.cursor/rules/`: persistent guardrails, including automation safety rules.
- `.cursor/skills/`: reusable task workflows for review, planning, board maintenance, and automation-safe handling.
- `.github/workflows/`: deterministic CI, merge-aware board promotion, and explicit workflow enforcement when implemented.

## Hybrid Orchestration Model

### Responsibility Split
| Layer | Primary Responsibility | Examples |
|---|---|---|
| GitHub | Source of truth and approval surface | Issues, PRs, branch protections, merge history, approval evidence |
| Cursor Automations | Event-driven or scheduled trigger layer | Issue intake kickoff, PR review kickoff, stale scan, optional next-task suggestions |
| Cursor Cloud Agents | Repo-aware execution | Drafting artifacts, reviews, edits, planning, implementation support |
| GitHub Actions | Deterministic workflow enforcement | CI, post-merge checks, board promotion, merge-dependent stage transitions |
| Humans | Approval and final decision points | Scope approval, architecture approval, PR approval, release go/no-go |

### Use Cursor Automations When
- a GitHub issue should trigger intake work automatically;
- a PR should receive a review-agent pass automatically;
- a schedule should scan for stale items, waiting reviews, or next-ready work;
- an automation can assist without becoming the final authority.

### Use Cloud Agents Directly When
- a human wants immediate interactive help;
- repo-aware multi-file reasoning is needed;
- the task requires judgment-heavy drafting, design, or review.

### Keep GitHub Actions When
- merge state matters;
- checks must be deterministic and reproducible;
- CI or branch protection is involved;
- promotion logic should only occur after explicit GitHub conditions are satisfied.

### Keep Human Gates When
- scope changes;
- architecture changes;
- business-visible logic changes;
- release readiness decisions;
- any stage requires accountability beyond automation suggestions.

### Approval-Mode Pattern
Use one of two approval modes on each board item or stage:
- `HUMAN_REQUIRED`: passing review leads to `READY_FOR_HUMAN_APPROVAL`.
- `AUTO_APPROVE_ALLOWED`: passing review may move directly to `APPROVED`.

Example:
- business-requirements through UI drafting may run in `AUTO_APPROVE_ALLOWED` mode;
- UI readiness becomes a milestone human gate;
- backend continuation then resumes only after the UI checkpoint is explicitly approved or reworked.

## Reference Hybrid Flow
```text
GitHub issue / PR / merge / schedule
        |
        v
Cursor Automation trigger
        |
        v
Cursor Cloud Agent run
        |
        v
Docs, board notes, PR feedback, draft changes
        |
        +--------------------------+
        |                          |
        v                          v
Human approval                GitHub Actions
        |                          |
        v                          v
Approved state                CI / merge-aware promotion / next-stage creation
```

## End-To-End Workflow Model

| Stage | Input Artifacts | Output Artifacts | Primary Owner | Typical Trigger | Review Path | Approval Mode | Deterministic Completion Path | Board |
|---|---|---|---|---|---|---|---|---|
| Feature Request | Vision, goals, roadmap, issue/request | Intake summary and scoped problem framing | Request Intake Agent | Issue-created automation or direct run | Review Agent | Usually `HUMAN_REQUIRED`, but may be `AUTO_APPROVE_ALLOWED` in early discovery windows | Board update recorded; no merge dependency required | `boards/business-requirements.md` |
| Business Requirements | Intake summary, personas, goals | BR artifact and acceptance framing | Business Requirements Agent | Direct run or automation-assisted handoff | Review Agent | Stage-configurable; use `HUMAN_REQUIRED` when scope accountability matters | Approval recorded before promotion | `boards/business-requirements.md` |
| Feature Breakdown | Approved business requirements | Feature and sub-feature breakdown | Feature Breakdown Agent | Direct run or optional board-polling automation | Review Agent | Stage-configurable; often `AUTO_APPROVE_ALLOWED` during rapid decomposition | Approval recorded before promotion | `boards/features.md` |
| Technical Architecture | Approved breakdown, standards | Technical design and dependency model | Technical Architecture Agent | Direct run | Review Agent | Usually `HUMAN_REQUIRED` because trade-offs are high impact | Approval recorded before promotion | `boards/technical-architecture.md` |
| Implementation Plan | Approved architecture | Sequenced execution plan | Implementation Planning Agent | Direct run | Review Agent | Stage-configurable; may be auto-approved before a later milestone gate | Approval recorded before fan-out | `boards/implementation-plan.md` |
| UI Build | Approved implementation plan | UI execution artifacts | UI Build Agent | Direct run or optional next-task suggestion automation | Review Agent | Common milestone gate: auto-approve drafting, then require human UI approval at readiness | Merge-aware completion if code changes are involved | `boards/ui-build.md` |
| Backend Build | Approved implementation plan and any configured UI checkpoint | Backend execution artifacts | Backend Build Agent | Direct run or optional next-task suggestion automation | Review Agent | Usually `HUMAN_REQUIRED` after UI milestone if downstream behavior depends on reviewed UI decisions | Merge-aware completion if code changes are involved | `boards/backend-build.md` |
| Integration Build | Approved implementation plan | Integration execution artifacts | Integration Build Agent | Direct run or optional next-task suggestion automation | Review Agent | `HUMAN_REQUIRED` for business-sensitive or external-system changes | Merge-aware completion if code changes are involved | `boards/integration-build.md` |
| End-to-End QA | Approved build artifacts | QA plan, results, release recommendation | QA Agent | Direct run or scheduled validation assistance | Review Agent | `HUMAN_REQUIRED` for go/no-go decisions | Merge plus QA evidence plus approval | `boards/e2e-qa.md` |

## Standard Promotion Pattern
Each stage item follows:
1. `TODO`
2. `IN_PROGRESS`
3. `NEEDS_REVIEW`
4. `IN_REVIEW`
5. `CHANGES_REQUESTED` or `READY_FOR_HUMAN_APPROVAL`
6. `APPROVED`
7. `DONE`

Promotion to the next stage happens only from `APPROVED`. `DONE` should be reserved for stages whose required work and required merge-aware checks have actually completed.

If the item is `AUTO_APPROVE_ALLOWED`, a passing review may move directly from `IN_REVIEW` to `APPROVED`. If a human reviewer later rejects the work with comments, the item returns to `CHANGES_REQUESTED` and those comments must be incorporated into the artifact and any invalidated upstream requirements or plans.

## Event-Driven Examples
- Issue created -> Cursor Automation triggers Request Intake Agent and drafts intake notes.
- Issue labeled `ready-for-brd` -> Cursor Automation suggests starting Business Requirements Agent.
- PR opened -> Cursor Automation triggers Review Agent using PR-review prompts.
- PR updated -> Cursor Automation may rerun review if changes are substantial.
- PR merged -> GitHub Action performs deterministic board promotion or opens the next-stage task.
- Nightly schedule -> Cursor Automation scans for stale `IN_PROGRESS` or `NEEDS_REVIEW` items and drafts reminders or next-task suggestions.

## Board / Checklist Model
All board files should use the same logical item structure.

| Field | Description |
|---|---|
| Item ID | Stable stage item identifier, such as `BR-001` or `ARCH-004` |
| Parent Feature | Shared feature name or feature ID |
| Stage | Current stage represented by the board |
| Status | Lifecycle state from the standard state model |
| Owner | Owning agent or human role |
| Reviewer | Review agent or named human reviewer |
| Approval Mode | `HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED` |
| Trigger Source | Direct run, issue automation, PR automation, schedule, or GitHub Action |
| Inputs | Upstream artifacts required |
| Output | Primary artifact produced |
| Exit Criteria | What must be true before promotion |
| Next Stage | Destination board after approval |
| Notes | Risks, assumptions, automation constraints, or dependencies |

## Promotion Rules By Stage
- Business requirements can promote to features only after business value, scope, and constraints are approved.
- Features can promote to architecture only after decomposition and dependency coverage are approved.
- Architecture can promote to implementation planning only after contracts, boundaries, and dependency decisions are approved.
- Implementation plans can promote to UI, backend, integration, and QA boards only after execution tracks are sequenced.
- UI, backend, and integration work can promote to QA only after implementation artifacts and readiness checks are approved.
- If a milestone human gate exists, such as UI readiness review before backend continuation, downstream promotion must wait for that gate even if earlier stages used auto-approval.
- QA can promote to release or pilot planning only after defects are resolved or explicitly accepted.
- Cursor Automations may propose status changes, but GitHub Actions should handle deterministic post-merge promotion where completion depends on merged repo state.

## Agent Role Model

### Request Intake Agent
- Purpose: turn an incoming idea or request into a structured project-aligned intake summary.
- Scope: problem framing, value framing, linkage to personas, roadmap fit.
- Typical trigger: issue-created automation or direct invocation.
- Auto-run suitability: high.
- Never auto-approve scope.
- Board: `boards/business-requirements.md`.

### Business Requirements Agent
- Purpose: define business problem, users, goals, constraints, and success criteria.
- Scope: business requirements only, not technical design.
- Typical trigger: direct run after intake approval; may be automation-suggested but not fully autonomous across stage gate.
- Auto-run suitability: medium.
- If a human reviewer rejects the BR with comments, update the BR and any affected intake assumptions before resubmitting.
- Board: `boards/business-requirements.md`.

### Feature Breakdown Agent
- Purpose: decompose approved requirements into major features and sub-features.
- Scope: feature structuring, dependencies, sequencing.
- Typical trigger: direct run or optional ready-item pickup automation.
- Auto-run suitability: medium.
- Board: `boards/features.md`.

### Technical Architecture Agent
- Purpose: define service boundaries, data flow, contracts, and trade-offs.
- Scope: implementation-oriented architecture.
- Typical trigger: direct run after explicit approval.
- Auto-run suitability: low.
- Board: `boards/technical-architecture.md`.

### Implementation Planning Agent
- Purpose: turn approved architecture into sequenced execution work.
- Scope: work packages, dependencies, handoffs, readiness gates.
- Typical trigger: direct run after architecture approval.
- Auto-run suitability: low to medium.
- Board: `boards/implementation-plan.md`.

### UI Build Agent
- Purpose: produce UI execution artifacts and, later, implementation support.
- Scope: screens, flows, states, telemetry expectations.
- Typical trigger: direct run or optional next-task suggestion automation.
- Auto-run suitability: medium for drafting, low for approval.
- Common checkpoint pattern: iterate autonomously until UI readiness, then stop for human review before backend-heavy continuation.
- Board: `boards/ui-build.md`.

### Backend Build Agent
- Purpose: produce backend execution artifacts and implementation support.
- Scope: services, APIs, persistence, telemetry.
- Typical trigger: direct run or optional next-task suggestion automation.
- Auto-run suitability: medium for drafting, low for completion.
- Board: `boards/backend-build.md`.

### Integration Build Agent
- Purpose: produce integration planning and implementation support artifacts.
- Scope: contracts, auth, retries, sync mode, rollout dependencies.
- Typical trigger: direct run or optional next-task suggestion automation.
- Auto-run suitability: medium for drafting, low for approval.
- Board: `boards/integration-build.md`.

### QA Agent
- Purpose: create QA coverage and release-readiness outputs.
- Scope: scenarios, traceability, defects, release recommendation.
- Typical trigger: direct run or scheduled validation assistance.
- Auto-run suitability: medium for scanning and drafting, low for final release recommendation.
- Board: `boards/e2e-qa.md`.

### Review Agent
- Purpose: perform structured rubric-based review for any stage or PR.
- Scope: critique, scoring, blockers, readiness recommendation.
- Typical trigger: PR-opened automation, review-requested automation, or direct run.
- Auto-run suitability: high for review assistance, never final approver.
- Board: all boards and PR review flows.

### Board Updater Agent
- Purpose: keep markdown boards synchronized with artifact progress.
- Scope: status suggestions, notes, cross-board references.
- Typical trigger: direct run, issue automation, or post-review automation.
- Auto-run suitability: medium with strict rules.
- Never mark `APPROVED` or `DONE` without required evidence.
- If a human rejection comment changes scope or assumptions, update the relevant upstream notes and approval-mode blockers before moving the item back to review.
- Board: all boards.

## Prompt / Rules / Skills Foundation

### Prompt Library Strategy
Maintain two prompt groups:
- direct-invocation stage prompts;
- automation-safe prompts for issue intake, PR review, and scheduled scans.

Each prompt should contain:
- objective,
- required inputs,
- output sections,
- stop conditions,
- board interaction rules,
- and explicit automation constraints if it can run unattended.

## Future Evolution
The current operating model is intentionally conservative. As the repository matures, future improvements may include:
- autonomous agent scheduling for recurring intake scans, review queues, stale-work detection, and readiness checks;
- dynamic agent orchestration that chooses the next agent, prompt, or review path based on board state, stage readiness, and dependency context;
- AI code review pipelines that combine review prompts, standards checks, rubric scoring, and PR feedback into a more cohesive review system;
- automated deployment agents that support release preparation, environment checks, rollout sequencing, and post-deploy verification;
- AI architecture evolution workflows that detect drift, propose architecture updates, and recommend roadmap or standards changes over time.

These evolutions should be treated as layered enhancements to the existing model, not replacements for it. In particular:
- approval gates should remain explicit;
- deterministic completion and merge-aware transitions should remain with GitHub Actions or equivalent deterministic controls;
- autonomous scheduling should prefer summary, suggestion, and controlled execution over silent stage mutation;
- and architecture or deployment agents should produce auditable evidence rather than opaque state changes.

### Rules Strategy
Maintain rules for:
- operating model and lifecycle discipline;
- domain terminology;
- docs and boards authoring conventions;
- review rigor;
- automation safety and stage-promotion limits.

### Skills Strategy
Maintain skills for:
- review loops;
- board maintenance;
- feature-pack planning;
- automation-safe intake and review handling.

## GitHub, Automations, And Human Approval Pattern
- GitHub stores the authoritative issue, PR, approval, and merge state.
- Cursor Automations initiate helpful work when events occur.
- Cursor Cloud Agents perform the reasoning-heavy work.
- GitHub Actions enforce deterministic workflow rules once code or docs reach merge-dependent checkpoints.
- Humans remain the authority for major approvals and go/no-go decisions.

## Prioritized Next Artifacts To Generate
1. Expand the hybrid workflow labs first: architecture, agent model, board model, and automation guidance.
2. Expand issue-intake and PR-review automation guidance next.
3. Use `Outfit Recommendations` as the first end-to-end example feature.
4. Expand `Recommendation Delivery API` second because it exercises contract and integration concerns.
5. Expand `Merchandising Rule Builder` third because it stresses governance and approval behavior.

## Remaining Decisions To Resolve Later
- Exact production system boundaries and target implementation stack.
- Source systems and data ownership for identity resolution and appointment history.
- How recommendation explainability should appear in customer-facing UI vs internal tools.
- Pilot channels and phased rollout order for web, email, and clienteling.
- Experimentation tooling and analytics platform choices.
- Exact GitHub Actions design once `.github/workflows/` is introduced.
