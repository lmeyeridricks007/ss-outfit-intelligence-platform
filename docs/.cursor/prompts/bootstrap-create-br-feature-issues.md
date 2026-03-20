# Bootstrap: Create BR and Feature Issues

You are running in the **target repository**. Your task is to create GitHub issues for BR board rows and feature board rows.

## Purpose

Create GitHub issues needed for:
- BR board rows (from `boards/business-requirements.md`)
- Feature board rows (from `boards/features.md`)

Issue creation should be clean, repeatable, and idempotent.

## Source of Truth

Read the board files:
- `boards/business-requirements.md`
- `boards/features.md`

## Issue Creation Strategy

### Idempotency

To avoid duplicate issues:
1. Use the board item ID (BR ID or FEAT ID) as the primary correlation key.
2. Before creating an issue, search for existing issues that mention the board item ID in the title or body.
3. If an issue already exists for a board item, skip creating a new one.
4. You can search issues by label (e.g., `workflow:br`, `workflow:feature-spec`) and then check titles/bodies for the board item ID.

### BR Issues

For each BR row in `boards/business-requirements.md`:

1. **Check if issue exists**: Search for issues with label `workflow:br` that mention the BR ID (e.g., "BR-001").
2. **If not exists, create issue**:
   - **Title**: `BR-001: <Feature Name>` (use BR ID and feature name from the row)
   - **Body**: Use the template below
   - **Labels**: `feature`, `workflow:br`, and optionally `phase:<n>` if determinable from roadmap
   - **Stage label**: `workflow:br`

### Feature Issues

For each feature row in `boards/features.md`:

1. **Check if issue exists**: Search for issues with label `workflow:feature-spec` that mention the FEAT ID (e.g., "FEAT-001").
2. **If not exists, create issue**:
   - **Title**: `FEAT-001: <Feature Name>` (use FEAT ID and feature name from the row)
   - **Body**: Use the template below
   - **Labels**: `feature`, `workflow:feature-spec`, and optionally `phase:<n>` if determinable from roadmap
   - **Stage label**: `workflow:feature-spec`

## Issue Body Template

Use this template for BR issues:

```markdown
## Context

Board Item ID: BR-001
Parent Item: (none, or parent ID if applicable)
Stage: workflow:br

## Source Artifacts

- Trigger Source: docs/project/business-requirements.md
- Related Docs: (list related source docs)

## Requirements

- **Inputs**: (from board row)
- **Output**: (from board row)
- **Exit Criteria**: (from board row)

## Stop Condition

This BR is complete when: (exit criteria from board row)

## Phase

(Include phase label if determinable from roadmap, e.g., "Phase 1")
```

Use this template for feature issues:

```markdown
## Context

Board Item ID: FEAT-001
Parent Item: BR-001 (from board row)
Stage: workflow:feature-spec

## Source Artifacts

- Trigger Source: docs/features/authentication.md
- Related Docs: (list related feature docs, sub-feature docs)

## Requirements

- **Inputs**: Feature deep-dive spec and related project docs
- **Output**: (from board row, typically the feature spec doc itself)
- **Exit Criteria**: (from board row)

## Stop Condition

This feature spec is complete when: (exit criteria from board row)

## Phase

(Include phase label if determinable from roadmap, e.g., "Phase 1")
```

## Process

1. Read `boards/business-requirements.md` and parse all BR rows.
2. For each BR row:
   - Extract BR ID, feature name, and other fields.
   - Search for existing issues with the BR ID.
   - If no issue exists, create one using the BR issue template.
3. Read `boards/features.md` and parse all feature rows.
4. For each feature row:
   - Extract FEAT ID, feature name, parent BR, and other fields.
   - Search for existing issues with the FEAT ID.
   - If no issue exists, create one using the feature issue template.
5. Document which issues were created (you can add a comment to the seeding issue or update a tracking file).

## GitHub API Usage

To create issues, you can use:
- GitHub CLI: `gh issue create --title "..." --body "..." --label "feature,workflow:br"`
- GitHub API: `POST /repos/{owner}/{repo}/issues` with JSON payload
- Or use any available GitHub integration in your environment

## Important Notes

1. **Idempotency is critical**: Never create duplicate issues for the same board item.
2. **Use board item ID as correlation key**: This ensures you can safely rerun this process.
3. **Include all required fields**: Each issue should have enough context to be actionable.
4. **Link to source docs**: Always include paths to source artifacts.
5. **Set correct labels**: Use `workflow:br` for BR issues and `workflow:feature-spec` for feature issues.

## Do Not

- Create duplicate issues for existing board items.
- Create issues for board items that don't have a valid ID.
- Create architecture, implementation, UI, backend, integration, or QA issues in this milestone.
- Skip idempotency checks.

Begin now.
