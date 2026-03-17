---
name: automation-safe-triage
description: Handles issue-triggered, PR-triggered, or scheduled automation runs safely within the project lifecycle. Use when a workflow was started by Cursor Automations and the run must respect approval, promotion, and merge-aware limits. Ensures bounded output and stop conditions. Follows .cursor/prompts/automation-*.md and .cursor/rules/automation-safety.mdc.
---

# Automation Safe Triage

## When to use
- An automation was triggered by: **issue** (created/updated), **PR** (opened/updated), or **schedule** (e.g. stale scan, next-task pickup).
- The run must produce useful output (intake, review, suggestion) without overclaiming approval or completion.
- You must stay within automation authority: draft, review, summarize, suggest—never approve or complete without evidence and configured path.

## Required inputs
- **Trigger source:** issue-created, issue-updated, PR-opened, PR-updated, scheduled, or other. Must be stated explicitly in every output.
- **Target:** The specific artifact, board item, or PR (e.g. issue URL, PR number, board name + item ID). If target cannot be identified, do not suggest status changes.
- **Context:** Issue body, PR description/diff, or current board state as needed. If context is insufficient (e.g. empty issue body), stop and request clarification.

## Stop conditions (must not proceed)
- **Insufficient context:** Issue body or PR description is empty or too thin to produce a responsible summary or recommendation. Output: "Insufficient context; request more detail from [issue author / PR author]." Do not guess or fill with placeholders.
- **Wrong or missing target:** Cannot identify which board item or artifact the run applies to. Do not suggest board status changes or approval. Ask for the correct target or link.
- **Conflicting human or GitHub state:** Automation recommendation would contradict explicit human decision or GitHub state (e.g. human already rejected; PR already merged). Align output with actual state; do not override.

## Workflow
1. **Identify** the trigger source. State it at the start of the output (e.g. "Trigger: issue-created automation").
2. **Confirm** the target artifact, board item, or PR. If missing or ambiguous, stop and request clarification; do not suggest status changes for the wrong item.
3. **Determine** the run type: **draft** (intake, artifact), **review** (findings, no approval grant), **summarize** (status, stale work), or **suggest** (next-task pickup, board update suggestion). Do not mix in approval or completion authority unless the configured approval mode explicitly allows it.
4. **Identify** approval mode and any milestone human gate for the target stage (from board or plan). Use them to bound recommendations: do not suggest APPROVED for HUMAN_REQUIRED; do not suggest downstream pickup when a milestone gate is not yet approved.
5. **Apply** project standards and automation safety rules from `.cursor/rules/automation-safety.mdc`: no APPROVED/DONE without evidence; no bypassing milestone gates; no replacing human decisions.
6. **Produce** a bounded output. Include what evidence supports any suggestion and what still requires human or deterministic validation.

## Safe outputs (allowed)
- **Intake summary:** Structured summary of issue/request; in/out scope; recommended feature area; missing decisions; suggested board update (e.g. new row, status TODO or IN_PROGRESS). Explicit note: "Human approval required before BR promotion" or "Next: [human action]."
- **Review findings:** Scores, blockers, required edits, recommended board impact (e.g. move to IN_REVIEW). Explicit: approval mode and whether human approval is still required; do not grant approval.
- **Stale-work summary:** Items stuck in review or waiting; suggested human or agent follow-up. No status changes without evidence.
- **Suggested board update:** Concrete suggestion (e.g. "Add BR-002, status TODO") with rationale. Do not suggest APPROVED or DONE unless approval path and evidence are explicit.
- **Suggested next-task pickup:** Candidate items, blockers, milestone-gate note ("Backend blocked until UI-001 APPROVED"), suggested action (run prompt X, human to approve Y). Do not change board state; recommend only.

## Unsafe outputs (never do)
- Mark a stage **APPROVED** without approval-path evidence and configured AUTO_APPROVE_ALLOWED.
- Mark a stage **DONE** when completion depends on merge, CI, or GitHub Actions and that evidence is not present.
- **Replace** human go/no-go decisions (e.g. "Human approval required" → do not say "approved").
- **Bypass** a milestone human gate (e.g. recommend backend work when UI readiness is not yet approved).
- **Invent** approval mode; use only what is on the board or in the artifact.
- **Guess** when context is insufficient; stop and request clarification instead.

## Required output (by trigger type)
- **Issue intake:** Intake summary, in/out scope, recommended feature area, missing decisions, suggested board update (TODO/IN_PROGRESS only), explicit next step (human approval required or governed auto-approval note). Trigger stated.
- **PR review:** Findings by severity, missing tests/dependencies, standards alignment, recommended board impact (no APPROVED unless AUTO_APPROVE_ALLOWED and criteria met), approval-mode statement, rejection-propagation note if applicable. Trigger stated.
- **Next-task pickup:** Candidate items with eligibility and blockers, milestone-gate note, suggested action. Trigger stated. No board state change; suggestion only.

## References
- Prompts: `.cursor/prompts/automation-issue-intake.md`, `.cursor/prompts/automation-pr-review.md`, `.cursor/prompts/automation-next-task-pickup.md`.
- Rule: `.cursor/rules/automation-safety.mdc`.
- "Never use Cursor Automations to": `docs/project/standards.md`.

## Example (issue intake)
**Trigger:** issue-created automation.

**Output must include:** "Trigger: issue-created automation." Intake summary (complete, no truncation); in-scope/out-of-scope; recommended feature area; missing decisions; suggested board update (e.g. Add BR-002, status TODO, Approval Mode HUMAN_REQUIRED). Do not suggest APPROVED or DONE. End with: "Next: human review of intake; approval required before BR stage promotion."

## Example (next-task pickup)
**Trigger:** scheduled.

**Output:** Candidate next items (board, ID, title, why eligible). Per item: blockers (none | milestone gate | merge/CI pending). Explicit: "Milestone human gate: Backend work blocked until UI-001 is APPROVED; do not recommend backend pickup yet." Suggested action: "Run [prompt] for UI-002" or "Human to approve UI-001 first."
