# Bootstrap: Seed Features Board

You are running in the **target repository**. Your task is to create or update the features board file.

## Purpose

Read business requirements, feature deep-dives, sub-feature docs, and roadmap. Create or update `boards/features.md` with feature-level rows that reflect the actual feature structure.

## Source of Truth

Use these docs as source of truth:
- `docs/project/business-requirements.md`
- `docs/project/roadmap.md`
- `docs/features/feature-spec-index.md`
- Feature deep-dive files in `docs/features/` (e.g., `authentication.md`, `organizations.md`)
- Sub-feature docs in `docs/features/sub-features/` if present

## Board Structure

Create or update `boards/features.md` with a table structure like:

```markdown
# Features (spec) board

| FEAT ID | Parent BR | Feature | Status | Owner | Reviewer | Approval Mode | Trigger Source | Output | Exit Criteria | Notes | Promotes To |
|---------|-----------|---------|--------|-------|----------|---------------|----------------|--------|---------------|-------|-------------|
| FEAT-001 | BR-001 | Feature Name | TODO | | | autonomous | docs/features/feature-name.md | docs/features/feature-name.md | Feature spec complete and reviewed | ... | ARCH-001 |
```

## Feature Row Fields

Each feature row must include:

- **FEAT ID**: Stable identifier (e.g., `FEAT-001`, `FEAT-002`). Use consistent numbering.
- **Parent BR**: Link to parent BR ID (e.g., `BR-001`) if this feature maps to a BR.
- **Feature**: Feature name from feature deep-dive docs.
- **Status**: Start with `TODO` unless clearly justified otherwise. Other valid statuses: `In Progress`, `In PR`, `Done`.
- **Owner**: Leave empty initially, or set if specified in source docs.
- **Reviewer**: Leave empty initially.
- **Approval Mode**: Set to `autonomous` for this milestone.
- **Trigger Source**: Path to feature deep-dive doc (e.g., `docs/features/authentication.md`).
- **Output**: Expected output artifact (typically the feature spec doc itself, e.g., `docs/features/authentication.md`).
- **Exit Criteria**: Clear criteria for when this feature spec is complete (e.g., "Feature spec complete, reviewed, and approved").
- **Notes**: Additional context or notes.
- **Promotes To**: Link to related architecture item ID (e.g., `ARCH-001`) if known. Leave empty for this milestone.

## Requirements

1. **Derive features from feature deep-dives**: Each feature deep-dive file in `docs/features/` should correspond to a feature row. Use `docs/features/feature-spec-index.md` as the primary index.

2. **Link to BRs**: Where possible, link features to parent BRs via the Parent BR field. This creates traceability from requirements to features.

3. **Use stable IDs**: FEAT IDs should be stable across reruns. If the board already exists, preserve existing FEAT IDs and only add new rows for new features.

4. **Avoid duplication**: Before adding a new row, check if a similar feature already exists. Use the FEAT ID as the correlation key.

5. **Reflect actual structure**: The board should reflect the actual feature structure from the deep-dive docs, not a shallow feature list. Include all major features identified in the feature specs.

6. **Status management**: Start with `TODO` status. Only change status if the feature spec is clearly already in progress or done.

## Process

1. Read `docs/features/feature-spec-index.md` to get the list of features.
2. Read each feature deep-dive file in `docs/features/`.
3. Read `docs/project/business-requirements.md` to understand BRs.
4. Check if `boards/features.md` already exists.
5. If it exists, parse existing rows and preserve FEAT IDs.
6. For each feature:
   - Check if a matching feature row already exists (by content, not just ID).
   - If not, create a new row with a stable FEAT ID.
   - Link to parent BR if applicable.
   - Fill in all required fields.
7. Update the board file with all feature rows.
8. Ensure the table is properly formatted and readable.

## Example Feature Row

```
| FEAT-001 | BR-001 | User Authentication | TODO | | | autonomous | docs/features/authentication.md | docs/features/authentication.md | Authentication feature spec complete and reviewed | Maps to BR-001 for user auth | |
```

## Do Not

- Create duplicate feature rows for the same feature.
- Change existing FEAT IDs unless absolutely necessary.
- Set status to `Done` unless the feature spec is clearly complete.
- Create feature rows for features that don't exist in the feature deep-dive docs.
- Create architecture or implementation rows in this milestone.

Begin now.
