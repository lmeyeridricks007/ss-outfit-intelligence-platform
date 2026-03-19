# Automation Next-Task Pickup Prompt

## Objective
Scan boards for approved or ready items and suggest the next useful task pickup without bypassing stage controls or milestone human gates. Output is recommendation only; do not change board state.

## Required Inputs
- Trigger source: "scheduled" or "manual" (state in output).
- Target board or board set (e.g. all boards, or implementation-plan + ui-build + backend-build).
- Current item states: for each relevant item, status, approval mode, and dependency (e.g. "Blocked by UI-001").
- Promotion rules and milestone gates from `docs/project/agent-operating-model.md` or implementation plan (e.g. "Backend blocked until UI readiness approved").

## Eligibility and blockers
- **Eligible for pickup:** Item is TODO or IN_PROGRESS with no blocking dependency; or item is APPROVED and has a defined "next stage" and that stage is not blocked by a gate.
- **Blocked:** Item depends on another item that is not yet APPROVED (e.g. backend item when UI gate is not approved). Item depends on merge/CI that is not complete. Item is in READY_FOR_HUMAN_APPROVAL (human must act first).
- **Milestone human gate:** If the project defines a gate (e.g. "UI readiness reviewed before backend"), do not recommend any downstream item (e.g. backend) until the gate item is APPROVED. State explicitly: "Backend work blocked until UI-001 is APPROVED."

## Required Output
- List of candidate next items: board, item ID, title, current status, and why eligible (e.g. "UI-002 is TODO and unblocked; implementation plan defines it as next in UI track").
- For each candidate, any blockers (none, or "Blocked by [gate/dependency]").
- Explicit milestone-gate note when applicable: "Milestone human gate: [description]. Do not recommend [downstream] until [gate item] is APPROVED."
- Suggested action: "Run [prompt/skill] for [item ID]" or "Human to approve [item ID] first" or "Wait for merge of PR #N / CI for [branch]."

## Automation constraints
- Do not auto-promote or change board status; only suggest.
- Do not mark items DONE.
- Do not recommend downstream pickup when a configured milestone human gate is unmet; call it out instead.
- If work depends on merge or GitHub Actions, say so in suggested action.
- Prefer clear, auditable summary over silent or implicit state change.

## Autonomous mode (see `docs/project/autonomous-automation-config.md`)
- When autonomous mode is ON: suggested action can be "Run [prompt] for [item ID]" so the orchestrator can queue the next run without human pickup. Do not require "Human to approve first" for the run to proceed; human gates remain as notes for later.

## Output template
```markdown
## Next-task pickup

**Trigger:** [scheduled | manual]

**Candidate next items:** [Board, Item ID, title, why eligible]

**Blockers:** [Per item: none | milestone gate (e.g. UI readiness not approved) | merge/CI pending]

**Milestone human gate:** [e.g. Backend work blocked until UI-001 is APPROVED; do not recommend backend pickup yet]

**Suggested action:** [Direct agent run for item X | Human to approve UI-001 first | Wait for merge of PR #N]
```
