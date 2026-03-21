# Review Rubrics

## Purpose

This document defines the common review model for project artifacts in this repository. It gives later agents and human reviewers a shared way to evaluate document quality, implementation readiness, dependency correctness, and approval posture across business requirements, architecture, plans, and build artifacts.

## Applicability

Use this rubric when reviewing:
- bootstrap project docs in `docs/project/`
- business requirements artifacts
- feature breakdown and feature-spec artifacts
- architecture artifacts
- implementation plans
- UI, backend, integration, and QA delivery artifacts
- board-driven review passes triggered by issues, pull requests, or automations

## Review dimensions

Score all six dimensions from 1 to 5.

### 1. Clarity
How understandable the artifact is for the next reader or downstream agent.

Questions to ask:
- Is the scope easy to understand?
- Are important terms used consistently?
- Are the intended outcomes and decisions explicit?

### 2. Completeness
How fully the artifact covers the required scope for its stage.

Questions to ask:
- Does it cover the required inputs, outputs, users, workflows, and constraints?
- Does it include the details the next stage would need?
- Are assumptions and open questions recorded instead of omitted?

### 3. Implementation Readiness
How actionable the artifact is for the next delivery stage.

Questions to ask:
- Could another agent or engineer continue without guessing?
- Are contracts, behaviors, dependencies, and acceptance expectations concrete enough?
- Does the artifact avoid hand-waving on critical path decisions?

### 4. Consistency With Standards
How well the artifact aligns with project terminology, structure, quality bar, and documented standards.

Questions to ask:
- Does it match `docs/project/standards.md` and any applicable standards docs?
- Does it use the repo lifecycle and approval vocabulary correctly?
- Does it avoid contradicting product, roadmap, or data expectations?

### 5. Correctness Of Dependencies
How accurately the artifact represents upstream sources, downstream consumers, and stage sequencing.

Questions to ask:
- Are upstream source docs cited correctly?
- Are milestone gates and approval dependencies reflected accurately?
- Does it avoid assuming unavailable inputs or skipped stages?

### 6. Automation Safety
How safe the artifact is for autonomous and automation-assisted workflows.

Questions to ask:
- Does it distinguish facts from assumptions?
- Does it avoid implying approvals or completion without evidence?
- Does it preserve the boundaries between drafting, review, approval, and done states?

## Scoring scale

### 5 - Strong
Clear, complete, actionable, and safe for the next stage with little or no rework.

### 4 - Good
Solid and usable with only minor edits or clarifications needed.

### 3 - Adequate but incomplete
Directionally correct, but still missing important clarity, coverage, or readiness details.

### 2 - Weak
Contains significant gaps, contradictions, or dependency problems that would make downstream work risky.

### 1 - Unusable
Mis-scoped, misleading, or missing essential content to the point that a new draft is required.

## Thresholds and disposition rules

### Automatic changes requested
Recommend `CHANGES_REQUESTED` when:
- the average score is below 3.5, or
- any dimension is 2 or lower, or
- a critical missing decision, contradiction, or dependency error blocks safe continuation

### Eligible for promotion
An artifact is eligible for promotion only when:
- the average score is above 4.1, and
- no dimension is below 4, and
- no blocker or required edit remains open

### Approval-mode interpretation
If the artifact is eligible for promotion:
- `HUMAN_REQUIRED` -> recommend `READY_FOR_HUMAN_APPROVAL`
- `AUTO_APPROVE_ALLOWED` -> may recommend `APPROVED`

If the artifact does not meet the promotion bar, recommend `CHANGES_REQUESTED` with explicit required edits.

## Confidence levels

Every review should include a confidence level:

- `HIGH`: the reviewer had enough context to assess scope, dependencies, and readiness reliably
- `MEDIUM`: the review is directionally reliable, but some context is inferred or incomplete
- `LOW`: key context is missing, which should force either `CHANGES_REQUESTED` or escalation

## Required review output format

Each formal review pass should include:
- trigger source, if the review came from automation or a PR
- artifact under review
- approval mode
- blockers, if any
- required edits
- scored dimensions
- overall disposition
- confidence
- approval-mode interpretation
- residual risks or open questions

## Approval modes

### HUMAN_REQUIRED
A passing review may only recommend `READY_FOR_HUMAN_APPROVAL`. Human approval must be recorded before the item becomes `APPROVED`.

### AUTO_APPROVE_ALLOWED
A passing review may recommend `APPROVED` when the scoring threshold is met and no milestone human gate is being bypassed.

## Milestone human gates

Some stages may have milestone gates even when parts of the workflow are otherwise automation-friendly. Examples include:
- UI readiness before backend continuation
- production release approval before broad rollout
- legal or data-policy approval before using sensitive customer signals

If a milestone gate exists, the review must state whether that gate is already satisfied, still pending, or not applicable.

## Rejection and rework rules

If a human reviewer rejected an artifact:
- keep or move the item to `CHANGES_REQUESTED`
- treat every rejection comment as required rework input
- update the current artifact, plus any upstream assumptions or dependency notes invalidated by the feedback
- do not self-approve or promote the item from the same rework pass without a new review

## Stage-specific review focus

### Bootstrap and project docs
Prioritize:
- internal consistency across files
- completeness of product scope and roadmap framing
- explicit assumptions and open questions
- usefulness for later BR and architecture fan-out

### Business requirements
Prioritize:
- scope boundaries
- target users and business value
- measurable outcomes
- absence of premature technical design

### Feature and feature-spec artifacts
Prioritize:
- traceability to the originating BR
- complete scenario and acceptance coverage
- separation of feature behavior from implementation mechanics

### Architecture
Prioritize:
- correctness of interfaces and boundaries
- explicit dependencies and operational assumptions
- technical decisions on the critical path

### Implementation plans
Prioritize:
- workstream sequencing
- approval-mode mapping
- milestone-gate mapping
- downstream board readiness

### UI, backend, and integration build artifacts
Prioritize:
- testability
- dependency correctness
- completeness of interfaces and acceptance criteria
- readiness to execute without ambiguity

### QA artifacts
Prioritize:
- coverage of happy path, edge cases, failures, and fallback behavior
- traceability back to requirements and implementation
- clarity on what still requires deterministic validation or human sign-off

## Escalation rules

Escalate to a human decision instead of guessing when:
- scope conflicts with the master product direction
- an approval mode or milestone gate is unknown
- data usage touches legal, consent, or policy uncertainty
- architecture trade-offs cannot be resolved from current repo context
- repeated review cycles do not converge

## Autonomous workflow note

When autonomous mode is enabled for the run, a passing review may support repository progress without waiting for a human click-path. Even then, the review must still:
- record the approval mode accurately
- avoid inventing evidence
- preserve any milestone gate as an explicit note
- distinguish review passage from merge, release, or production completion
