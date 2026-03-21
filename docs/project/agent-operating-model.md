# Agent Operating Model

## Purpose
Define how humans, cloud agents, automations, boards, and GitHub state should work together across the repository lifecycle.

## Practical usage
Use this document to understand stage progression, ownership boundaries, approval behavior, and how artifacts promote from one stage to the next.

## Source of truth hierarchy
1. `docs/project/` for product, standards, glossary, and operating guidance
2. `boards/` for stage-by-stage workflow state and explicit approval mode
3. GitHub for issues, pull requests, comments, approvals, merge history, and CI evidence
4. `.cursor/prompts/`, `.cursor/rules/`, and `.cursor/skills/` for execution guidance

## Roles
### Humans
- approve or reject work where approval mode requires it
- resolve missing business decisions and strategic trade-offs
- review milestone gates when needed

### Cursor cloud agents
- draft and revise artifacts
- perform repo-aware execution and implementation work
- follow project standards, stage prompts, and approval constraints

### Cursor automations
- trigger drafting, triage, or review workflows
- suggest board updates within authority limits
- avoid claiming approval or completion beyond configured policy

### GitHub Actions and deterministic checks
- run CI and other merge-aware validations
- provide evidence required for DONE states when policies require it

## Lifecycle states
Use the following lifecycle states exactly:
- `TODO`
- `IN_PROGRESS`
- `NEEDS_REVIEW`
- `IN_REVIEW`
- `CHANGES_REQUESTED`
- `READY_FOR_HUMAN_APPROVAL`
- `APPROVED`
- `DONE`

## Approval modes
- `HUMAN_REQUIRED`: passing review may advance only to `READY_FOR_HUMAN_APPROVAL`
- `AUTO_APPROVE_ALLOWED`: passing review may advance to `APPROVED` when rubric thresholds are met

Approval mode must be explicit per board item.

## Stage progression model
| Stage | Typical artifact | Promotes to |
| --- | --- | --- |
| Bootstrap | `docs/project/*` canonical docs | business requirements board and BR artifacts |
| Business requirements | `docs/project/br/*.md` | feature breakdown artifacts |
| Features | `docs/features/*.md` | architecture artifacts |
| Architecture | `docs/architecture/*.md` | implementation plans |
| Implementation planning | `docs/implementation/*.md` | UI, backend, and integration build artifacts |
| Build | UI, backend, integration artifacts and code | QA review |
| QA | QA artifact and verification evidence | merge or release workflow |

## Operating principles
- Do not skip stages when the repository defines them.
- Preserve traceability from upstream artifact to downstream artifact.
- Record missing decisions rather than inventing them.
- Keep approval mode and milestone gates visible in artifacts or board notes.
- Use review rubrics consistently before promotion.

## Review and promotion rules
- A review must score all six rubric dimensions.
- Artifacts with blocking issues or low confidence should not be promoted.
- `DONE` should not be used when merge, CI, or other required evidence is still pending.
- Human rejection comments must be treated as required rework inputs.

## Autonomous automation notes
In autonomous automation runs, agents may complete drafting, commit, and push work so the orchestrator can continue. Approval-gate language should still be recorded in notes, but autonomous execution should not hide approval requirements for later stages where humans or GitHub evidence remain necessary.

## Milestone gate handling
If a stage has a milestone human gate, record it in the artifact or board notes so downstream work can see the dependency. Do not imply that a blocked downstream stage is unblocked without explicit approval evidence.
