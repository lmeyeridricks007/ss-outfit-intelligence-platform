# Phase Hookup (`workflow:hookup`)

## Objective

Connect existing UI, backend, and integration outputs for a specific phase into a working, testable phase slice. This milestone is about wiring together previously generated work, not creating new track-specific artifacts.

## Source of Truth

- **Roadmap**: `docs/project/roadmap.md` — defines phase boundaries
- **Implementation Plan**: `boards/implementation-plan.md` — contains the work items for each phase
- **UI Board**: `boards/ui-build.md` — UI items for the phase
- **Backend Board**: `boards/backend-build.md` — Backend items for the phase
- **Integration Board**: `boards/integration-build.md` — Integration items for the phase
- **Architecture**: `docs/project/architecture-overview.md` — provides technical context
- **Standards**: `docs/project/standards.md`, `docs/project/api-standards.md`, `docs/project/data-standards.md`, `docs/project/ui-standards.md`, `docs/project/integration-standards.md` (if present) — define conventions

## Output Folder Structure

Update existing artifacts and create connection/wiring artifacts in:
- The project's existing UI/backend/integration paths
- Shared configuration/environment files
- Connection/wiring documentation in `docs/project/hookup/` or project's chosen path

## Steps

### 1. Resolve Phase Scope

- Read the issue body and title to identify the requested phase (e.g., Phase 1)
- Check `docs/project/roadmap.md` to understand phase boundaries
- Check `boards/implementation-plan.md` to find items for that phase
- **Only work on connecting items for the requested phase** — do not continue beyond the phase boundary

### 2. Identify Related Items

- Review `boards/ui-build.md` for UI items in the phase
- Review `boards/backend-build.md` for backend items in the phase
- Review `boards/integration-build.md` for integration items in the phase
- Correlate items that should be connected based on implementation plan
- Identify which UI components should connect to which backend services
- Identify which integrations are needed for the phase slice

### 3. Verify Upstream Readiness

Before proceeding:
- Ensure UI items for the phase are `cursor:done` or sufficiently complete
- Ensure backend items for the phase are `cursor:done` or sufficiently complete
- Ensure integration items for the phase are `cursor:done` or sufficiently complete
- If upstream work is not ready, add `needs-info` label and comment what is missing

### 4. Connect the Phase Slice

Perform the following connection work:

**UI to Backend Wiring:**
- Wire UI components to backend API endpoints
- Align request/response payloads and data models
- Update API client code in UI components
- Ensure endpoint contracts match between UI and backend

**Backend to Integration Wiring:**
- Configure integration clients and connectors
- Wire backend services to integration endpoints
- Align data formats and schemas
- Update integration configuration

**Environment and Configuration:**
- Update environment/config wiring
- Ensure API endpoints are correctly configured
- Update service discovery/config if applicable
- Align environment variables and secrets

**Shared Artifacts:**
- Create or update shared DTOs/schemas as needed
- Align data models across UI, backend, and integration layers
- Update type definitions if using TypeScript or similar

**Documentation:**
- Generate developer/test notes for the connected slice
- Document API contracts and endpoints
- Document integration points and data flows
- Create testing instructions for the connected slice

### 5. Update Boards

- Update relevant UI/backend/integration board rows to reflect hookup progress
- Add notes indicating the phase slice is connected
- Update status fields appropriately (e.g., "Connected" or "Ready for QA")
- Preserve existing schema and traceability
- Do not create a whole new board unless truly necessary

### 6. Commit and Push

- Use branch: `hook/issue-{ISSUE_NUMBER}` or `hook/phase-{PHASE}-{FEATURE}`
- Commit all changes
- Push to origin
- PR will be opened automatically by GitHub Actions workflow or orchestrator detection

## Required Structure for Hookup Artifacts

Each hookup should result in:
- **Connected Phase Slice**: Clear identification of what was connected
- **Phase**: Phase number
- **Related Items**: Links to UI, backend, and integration items
- **API Contracts**: Documented endpoint contracts and payloads
- **Configuration**: Environment/config changes made
- **Data Models**: Shared DTOs/schemas created or updated
- **Testing Notes**: How to test the connected slice
- **Known Issues**: Any remaining issues or limitations

## Level of Detail

- **Connection Focus**: Focus on wiring and alignment, not creating new track-specific work
- **Phase Scoping**: Only include work for the requested phase
- **Traceability**: Link back to implementation-plan items and related UI/backend/integration items
- **Testability**: Ensure the connected slice is testable end-to-end

## Important Requirements

1. **Phase Scoping**: Only connect items for the requested phase. Do not continue beyond the phase boundary.
2. **Source of Truth**: Use roadmap, implementation plan, and track boards as the authoritative source.
3. **Upstream Readiness**: Verify UI, backend, and integration work is complete before connecting.
4. **No New Track Work**: Do not create new UI, backend, or integration artifacts. Focus on connecting existing ones.
5. **Idempotency**: If hookup work already exists, update it rather than creating duplicates.
6. **Stop Condition**: Stop when the phase slice is connected and ready for QA/human testing.

## Iteration Process

1. Read issue and source materials
2. Identify phase scope and related UI/backend/integration items
3. Verify upstream readiness
4. Connect the phase slice (wiring, contracts, config)
5. Update boards
6. Commit and push
7. Self-review (see `review-pass.md`)
8. Document any follow-ups as non-blocking PR notes

## Review/Audit Requirements

- Self-review using `review-pass.md`
- Ensure phase scoping is correct
- Verify upstream readiness is satisfied
- Verify traceability to implementation-plan items
- Check that connections follow project standards
- Ensure the connected slice is testable

## Commit/Push Instructions

- Branch: `hook/issue-{ISSUE_NUMBER}` or `hook/phase-{PHASE}-{FEATURE}`
- Commit message: `Hookup: Connect Phase {PHASE} UI, backend, and integrations`
- Push to origin
- PR will be opened automatically

## Do NOT

- Create new UI, backend, or integration artifacts
- Continue to QA automatically
- Perform release or go-live automation
- Continue beyond the requested phase scope
- Skip upstream readiness validation
- Proceed if UI, backend, or integration work is not complete
