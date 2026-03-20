# Phase UI Control (`delivery-control` + `workflow:ui`)

## Purpose

This prompt guides the orchestrator's behavior when processing a delivery-control issue for phase-scoped UI work. The orchestrator uses this to understand how to:
- Resolve the requested phase
- Identify implementation-plan items for that phase
- Create or update UI issues and board rows
- Launch UI work for the phase scope
- Stop when phase UI work is complete

## Control Issue Structure

A delivery-control issue for UI work should have:
- **Title**: e.g., `Continue UI build through Phase 1`
- **Labels**:
  - `delivery-control`
  - `workflow:ui`
  - `phase:1` (or phase number)
- **Body**: Should specify:
  - Intent: continue
  - Track: ui
  - Phase: {number}
  - Scope: use roadmap and implementation plan as source of truth
  - Stop condition: stop when all UI items for that phase are complete

## Orchestrator Behavior

### 1. Phase Resolution

The orchestrator should:
- Parse phase from `phase:{N}` label
- Fall back to parsing from issue title (e.g., "Phase 1")
- Fall back to parsing from issue body (e.g., "Phase: 1")
- If phase cannot be resolved, add `needs-info` label and comment

### 2. Prerequisite Checking

Before processing, verify:
- `docs/project/roadmap.md` exists
- `boards/implementation-plan.md` exists
- `boards/ui-build.md` exists
- `docs/project/standards.md` exists
- `docs/project/architecture-overview.md` exists
- Implementation-plan items contain enough information to derive UI work
- The requested phase exists in the roadmap

If prerequisites are missing:
- Add `needs-info` label
- Comment clearly what is missing
- Do not launch Cursor agents

### 3. Implementation-Plan Item Resolution

For the requested phase:
- Read `docs/project/roadmap.md` to understand phase boundaries
- Read `boards/implementation-plan.md` to find items for that phase
- Filter items to only those belonging to the requested phase
- Identify which items have UI workstreams

### 4. UI Issue Creation/Update

For each implementation-plan item in the requested phase:
- Check if UI issue already exists (by UI item ID or parent plan ID + phase)
- If missing, create UI issue with:
  - Title: `UI-{ID}: Phase {PHASE} UI build for {FEATURE}`
  - Body: Include control issue reference, phase, track, source docs, requirements
  - Labels: `feature`, `workflow:ui`, `phase:{N}`
- Issue creation must be idempotent (no duplicates on rerun)

### 5. UI Board Row Creation/Update

For each UI issue:
- Check if UI board row exists in `boards/ui-build.md`
- If missing, create row with:
  - UI ID
  - Parent Plan ID
  - Feature name
  - Status: `In Progress` or `Queued`
  - Phase
  - Trigger Source: control issue number
  - Output: (to be filled by agent)
  - Exit Criteria: (to be filled by agent)
- Board updates must be idempotent

### 6. Agent Launch

For each UI issue:
- Build prompt using `ui-build.md` and related prompts
- Launch Cursor Cloud Agent against target repo
- Update UI issue labels: add `cursor:running`, remove `cursor:queued`
- Create machine-readable comment on UI issue with run state

### 7. Control Issue State

On control issue:
- Add `cursor:running` label
- Remove `cursor:queued` label
- Create machine-readable comment with:
  - run_id (first UI issue run ID or "control")
  - stage: ui-control
  - phase: {N}
  - track: ui
  - created_ui_items: list of UI issue numbers
  - started_at: timestamp
- Comment: "UI phase execution started. Created/updated {N} UI issue(s): #{...}"

### 8. Completion Detection

The orchestrator (via poller) should:
- Monitor all UI issues for the phase
- Detect when all UI issues are complete (`cursor:done`)
- Detect PR URLs for completed UI work
- When all phase UI work is complete:
  - Update control issue: remove `cursor:running`, add `cursor:done`
  - Post summary comment on control issue:
    - Which UI items were processed
    - Which PRs were opened
    - What was built
    - How to test it
  - Do NOT automatically continue to backend

## Stop Condition

The UI control issue is complete when:
- All targeted UI items for the requested phase are complete (`cursor:done`)
- Corresponding PRs/branches exist
- Control issue receives summary comment

## Do NOT

- Continue to backend automatically
- Continue to integration automatically
- Create backend or integration issues
- Process UI work beyond the requested phase scope
- Skip phase scoping validation
