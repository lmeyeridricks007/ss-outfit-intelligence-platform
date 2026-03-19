# Bootstrap Master Project

## Purpose

Use a single GitHub bootstrap issue to generate the initial canonical project documentation for a brand-new product repository.

This prompt is the top-level wrapper for the bootstrap flow. It should be used when the repository is still at the "define the product" stage and the issue body is the primary source of product intent.

## Trigger Context

You were started from a GitHub issue intended to bootstrap a new project.

Use the GitHub issue title and body as the primary source of truth for:
- product idea
- business problem
- target users
- value proposition
- scope boundaries
- major workflows
- open questions

## Required Repository Context

Read and follow:
- `.cursor/prompts/bootstrap-project-docs.md`
- `.cursor/prompts/bootstrap-review-loop.md`
- `docs/project/review-rubrics.md`
- `docs/project/agent-operating-model.md`

If any of these files are missing, say so clearly in the issue response and stop.

## Objective

Generate the initial canonical project docs for this new project in `docs/project/`.

This bootstrap flow should produce only the initial doc layer. It should not yet fan out downstream work such as:
- feature deep-dive generation
- sub-feature generation
- board seeding
- downstream GitHub issue creation
- architecture issue fan-out
- implementation-plan issue fan-out
- UI/backend/integration/QA issue creation

## Required Outputs

Create or update:
- `docs/project/vision.md`
- `docs/project/goals.md`
- `docs/project/problem-statement.md`
- `docs/project/personas.md`
- `docs/project/product-overview.md`
- `docs/project/business-requirements.md`
- `docs/project/roadmap.md`
- `docs/project/architecture-overview.md`
- `docs/project/standards.md`

Create these only if clearly needed by the product:
- `docs/project/api-standards.md`
- `docs/project/data-standards.md`
- `docs/project/ui-standards.md`
- `docs/project/integration-standards.md`

## Execution Rules

1. Treat `docs/project/` as the canonical concise operational doc layer.
2. Use the bootstrap issue as the source project description.
3. Create practical, implementation-oriented documents, not shallow summaries.
4. Use the review loop in `.cursor/prompts/bootstrap-review-loop.md`.
5. Improve the docs enough to be useful for later feature and architecture fan-out.
6. Commit and push the resulting changes automatically.
7. Do not wait for human approval before commit/push for this bootstrap flow.
8. Do not create unrelated artifacts outside the initial project docs unless clearly required.
9. Do not create downstream issues or board rows in this run.

## Quality Standard

The output should be:
- clear
- structured
- consistent across files
- implementation-oriented
- useful as source of truth for later prompts and stage work

## Suggested Commit Scope

Commit only the new or updated bootstrap docs and any directly required supporting files.

**Commit and push** your changes on the branch provided by the orchestrator (e.g. `bootstrap/issue-42`). Open a pull request if the run is configured to do so. If the PR is created as a **draft**, you do not need to mark it ready — the orchestrator will mark it ready, approve it, and merge it automatically.

## Final Issue Response

When done, leave a concise issue response that includes:
- what docs were created
- any docs that were skipped and why
- branch name
- PR link if available
- notable assumptions or open questions