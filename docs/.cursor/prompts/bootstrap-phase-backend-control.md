# Phase Backend Control (`delivery-control` + `workflow:backend`)

## Purpose

This prompt guides the orchestrator's behavior when processing a delivery-control issue for phase-scoped backend work. The orchestrator uses this to understand how to:
- Resolve the requested phase
- Identify implementation-plan items for that phase
- Check milestone gates (especially UI readiness)
- Create or update backend issues and board rows
- Launch backend work for the phase scope
- Stop when phase backend work is complete

## Control Issue Structure

A delivery-control issue for backend work should have:
- **Title**: e.g., `Continue backend build through Phase 1`
- **Labels**:
  - `delivery-control`
  - `workflow:backend`
  - `phase:1` (or phase number)
- **Body**: Should specify:
  - Intent: continue
  - Track: backend
  - Phase: {number}
  - Scope: use roadmap and implementation plan as source of truth
  - Stop condition: stop when all backend items for that phase are complete

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
- `boards/backend-build.md` exists
- `docs/project/standards.md` exists
- `docs/project/architecture-overview.md` exists
- If milestone-gate logic depends on UI state:
  - `boards/ui-build.md` exists
  - The relevant UI item(s) are in a state that allows backend continuation

If prerequisites are missing:
- Add `needs-info` label
- Comment clearly what is missing
- Do not launch Cursor agents

### 3. Milestone Gate Checking

Before creating backend issues, check milestone gates:
- Read `boards/ui-build.md` to check UI readiness for the phase
- Read `boards/implementation-plan.md` for milestone gate notes
- If backend is blocked on UI readiness:
  - Check if all UI issues for the phase are `cursor:done`
  - If not, do not proceed with backend work
  - Add `needs-info` label and comment what UI condition is missing
- Do not silently skip milestone gates

### 4. Implementation-Plan Item Resolution

For the requested phase:
- Read `docs/project/roadmap.md` to understand phase boundaries
- Read `boards/implementation-plan.md` to find items for that phase
- Filter items to only those belonging to the requested phase
- Identify which items have backend workstreams

### 5. Backend Issue Creation/Update

For each implementation-plan item in the requested phase:
- Check if backend issue already exists (by BE item ID or parent plan ID + phase)
- If missing, create backend issue with:
  - Title: `BE-{ID}: Phase {PHASE} backend build for {FEATURE}`
  - Body: Include control issue reference, phase, track, source docs, requirements, milestone gate notes
  - Labels: `feature`, `workflow:backend`, `phase:{N}`
- Issue creation must be idempotent (no duplicates on rerun)

### 6. Backend Board Row Creation/Update

For each backend issue:
- Check if backend board row exists in `boards/backend-build.md`
- If missing, create row with:
  - BE ID
  - Parent Plan ID
  - Feature name
  - Status: `In Progress` or `Queued`
  - Phase
  - Trigger Source: control issue number
  - Output: (to be filled by agent)
  - Exit Criteria: (to be filled by agent)
  - Notes: Include milestone-gate notes if relevant
- Board updates must be idempotent

### 7. Agent Launch

For each backend issue:
- Build prompt using `backend-build.md` and related prompts
- Launch Cursor Cloud Agent against target repo
- Update backend issue labels: add `cursor:running`, remove `cursor:queued`
- Create machine-readable comment on backend issue with run state

### 8. Control Issue State

On control issue:
- Add `cursor:running` label
- Remove `cursor:queued` label
- Create machine-readable comment with:
  - run_id (first backend issue run ID or "control")
  - stage: backend-control
  - phase: {N}
  - track: backend
  - created_backend_items: list of backend issue numbers
  - started_at: timestamp
- Comment: "Backend phase execution started. Created/updated {N} backend issue(s): #{...}"

### 9. Completion Detection

The orchestrator (via poller) should:
- Monitor all backend issues for the phase
- Detect when all backend issues are complete (`cursor:done`)
- Detect PR URLs for completed backend work
- When all phase backend work is complete:
  - Update control issue: remove `cursor:running`, add `cursor:done`
  - Post summary comment on control issue:
    - Which backend items were processed
    - Which PRs were opened
    - What was built
    - How to test it
    - Any remaining known dependencies before integration
  - Do NOT automatically continue to integration

## Stop Condition

The backend control issue is complete when:
- All targeted backend items for the requested phase are complete (`cursor:done`)
- Corresponding PRs/branches exist
- Control issue receives summary comment

## Do NOT

- Continue to integration automatically
- Continue to QA automatically
- Create integration or QA issues
- Process backend work beyond the requested phase scope
- Skip milestone gate validation
- Proceed if UI milestone gates are not satisfied
