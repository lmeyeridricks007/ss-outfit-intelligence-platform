# Phase Integration Control (`delivery-control` + `workflow:integration`)

## Purpose

This prompt guides the orchestrator's behavior when processing a delivery-control issue for phase-scoped integration work. The orchestrator uses this to understand how to:
- Resolve the requested phase
- Identify implementation-plan items for that phase
- Check upstream readiness (UI and backend)
- Create or update integration issues and board rows
- Launch integration work for the phase scope
- Stop when phase integration work is complete

## Control Issue Structure

A delivery-control issue for integration work should have:
- **Title**: e.g., `Continue integration build through Phase 1`
- **Labels**:
  - `delivery-control`
  - `workflow:integration`
  - `phase:1` (or phase number)
- **Body**: Should specify:
  - Intent: continue
  - Track: integration
  - Phase: {number}
  - Scope: use roadmap and implementation plan as source of truth
  - Stop condition: stop when all integration items for that phase are complete

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
- `boards/integration-build.md` exists
- `docs/project/standards.md` exists
- `docs/project/architecture-overview.md` exists
- If dependency logic depends on UI/backend state:
  - `boards/ui-build.md` exists where needed
  - `boards/backend-build.md` exists where needed
  - Relevant upstream item states allow integration continuation

If prerequisites are missing:
- Add `needs-info` label
- Comment clearly what is missing
- Do not launch Cursor agents

### 3. Upstream Readiness Checking

Before creating integration issues, check upstream readiness:
- Read `boards/ui-build.md` to check UI readiness for the phase
- Read `boards/backend-build.md` to check backend readiness for the phase
- Read `boards/implementation-plan.md` for upstream dependency notes
- If integration is blocked on UI or backend readiness:
  - Check if all UI issues for the phase are `cursor:done`
  - Check if all backend issues for the phase are `cursor:done`
  - If not, do not proceed with integration work
  - Add `needs-info` label and comment what upstream condition is missing
- Do not silently skip dependency gates

### 4. Implementation-Plan Item Resolution

For the requested phase:
- Read `docs/project/roadmap.md` to understand phase boundaries
- Read `boards/implementation-plan.md` to find items for that phase
- Filter items to only those belonging to the requested phase
- Identify which items have integration workstreams

### 5. Integration Issue Creation/Update

For each implementation-plan item in the requested phase:
- Check if integration issue already exists (by INT item ID or parent plan ID + phase)
- If missing, create integration issue with:
  - Title: `INT-{ID}: Phase {PHASE} integration build for {FEATURE}`
  - Body: Include control issue reference, phase, track, source docs, requirements, upstream readiness notes
  - Labels: `feature`, `workflow:integration`, `phase:{N}`
- Issue creation must be idempotent (no duplicates on rerun)

### 6. Integration Board Row Creation/Update

For each integration issue:
- Check if integration board row exists in `boards/integration-build.md`
- If missing, create row with:
  - INT ID
  - Parent Plan ID
  - Feature name
  - Status: `In Progress` or `Queued`
  - Phase
  - Trigger Source: control issue number
  - Output: (to be filled by agent)
  - Exit Criteria: (to be filled by agent)
  - Notes: Include upstream dependency notes if relevant
- Board updates must be idempotent

### 7. Agent Launch

For each integration issue:
- Build prompt using `integration-build.md` and related prompts
- Launch Cursor Cloud Agent against target repo
- Update integration issue labels: add `cursor:running`, remove `cursor:queued`
- Create machine-readable comment on integration issue with run state

### 8. Control Issue State

On control issue:
- Add `cursor:running` label
- Remove `cursor:queued` label
- Create machine-readable comment with:
  - run_id (first integration issue run ID or "control")
  - stage: integration-control
  - phase: {N}
  - track: integration
  - created_integration_items: list of integration issue numbers
  - started_at: timestamp
- Comment: "Integration phase execution started. Created/updated {N} integration issue(s): #{...}"

### 9. Completion Detection

The orchestrator (via poller) should:
- Monitor all integration issues for the phase
- Detect when all integration issues are complete (`cursor:done`)
- Detect PR URLs for completed integration work
- When all phase integration work is complete:
  - Update control issue: remove `cursor:running`, add `cursor:done`
  - Post summary comment on control issue:
    - Which integration items were processed
    - Which PRs were opened
    - What was completed
    - How to test it
    - Any remaining known issues before QA
  - Do NOT automatically continue to QA

## Stop Condition

The integration control issue is complete when:
- All targeted integration items for the requested phase are complete (`cursor:done`)
- Corresponding PRs/branches exist
- Control issue receives summary comment

## Do NOT

- Continue to QA automatically
- Create QA issues
- Process integration work beyond the requested phase scope
- Skip upstream readiness validation
- Proceed if UI or backend readiness gates are not satisfied
