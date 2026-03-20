# Bootstrap: Seed Business Requirements Board

You are running in the **target repository**. Your task is to create or update the business requirements board file.

## Purpose

Read canonical project docs and derive the required business requirements work items. Create or update `boards/business-requirements.md` with properly structured BR rows.

## Source of Truth

Use these canonical docs as source of truth:
- `docs/project/vision.md`
- `docs/project/goals.md`
- `docs/project/problem-statement.md`
- `docs/project/personas.md`
- `docs/project/product-overview.md`
- `docs/project/business-requirements.md`
- `docs/project/roadmap.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`

## Board Structure

Create or update `boards/business-requirements.md` with a table structure like:

```markdown
# Business requirements board

| BR ID | Feature | Status | Owner | Reviewer | Approval Mode | Trigger Source | Inputs | Output | Exit Criteria | Notes | Promotes To |
|-------|---------|--------|-------|----------|---------------|----------------|--------|--------|---------------|-------|-------------|
| BR-001 | Feature Name | TODO | | | autonomous | docs/project/business-requirements.md | ... | ... | ... | ... | FEAT-001 |
```

## BR Row Fields

Each BR row must include:

- **BR ID**: Stable identifier (e.g., `BR-001`, `BR-002`). Use consistent numbering.
- **Feature**: Feature name or capability area this BR belongs to.
- **Status**: Start with `TODO` unless clearly justified otherwise. Other valid statuses: `In Progress`, `In PR`, `Done`.
- **Owner**: Leave empty initially, or set if specified in source docs.
- **Reviewer**: Leave empty initially.
- **Approval Mode**: Set to `autonomous` for this milestone.
- **Trigger Source**: Path to source doc(s) that triggered this BR (e.g., `docs/project/business-requirements.md`).
- **Inputs**: Key inputs or dependencies for this BR.
- **Output**: Expected output artifact (e.g., `docs/project/br/br-001-feature-name.md`).
- **Exit Criteria**: Clear criteria for when this BR is complete.
- **Notes**: Additional context or notes.
- **Promotes To**: Link to related feature ID (e.g., `FEAT-001`) if known.

## Requirements

1. **Derive BRs from canonical docs**: Extract business requirements from the source docs. Each major requirement or capability should become a BR row.

2. **Use stable IDs**: BR IDs should be stable across reruns. If the board already exists, preserve existing BR IDs and only add new rows for new requirements.

3. **Avoid duplication**: Before adding a new row, check if a similar BR already exists. Use the BR ID as the correlation key.

4. **Detailed enough**: Each BR row should be detailed enough to become a GitHub issue work item. Include enough context in the row fields.

5. **Traceability**: Link BRs to source docs via Trigger Source and to features via Promotes To.

6. **Status management**: Start with `TODO` status. Only change status if the BR is clearly already in progress or done.

## Process

1. Read all canonical project docs listed above.
2. Identify all major business requirements and capabilities.
3. Check if `boards/business-requirements.md` already exists.
4. If it exists, parse existing rows and preserve BR IDs.
5. For each requirement:
   - Check if a matching BR row already exists (by content, not just ID).
   - If not, create a new row with a stable BR ID.
   - Fill in all required fields.
6. Update the board file with all BR rows.
7. Ensure the table is properly formatted and readable.

## Example BR Row

```
| BR-001 | User Authentication | TODO | | | autonomous | docs/project/business-requirements.md | docs/project/personas.md | docs/project/br/br-001-user-authentication.md | Authentication system implemented and tested | Initial BR for user auth capability | FEAT-001 |
```

## Do Not

- Create duplicate BR rows for the same requirement.
- Change existing BR IDs unless absolutely necessary.
- Set status to `Done` unless the BR is clearly complete.
- Create BR rows for requirements that don't exist in the source docs.

Begin now.
