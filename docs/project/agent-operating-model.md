# Agent operating model

How Cursor Cloud Agents are expected to operate in this repo when triggered by the orchestrator.

## Autonomous runs (bootstrap and staged workflows)

- The orchestrator starts an agent with a prompt that references prompt files **in this repo** (e.g. under `.cursor/prompts/`).
- The agent should **read those prompt files** and follow their instructions.
- For **bootstrap**: generate the initial canonical docs in `docs/project/`, then **commit and push** on the branch provided by the orchestrator (e.g. `bootstrap/issue-42`), and open a PR if configured.
- Do **not** wait for human approval before commit/push for the bootstrap milestone; the run is autonomous.

## Branch and PR

- Use the **branch name** provided in the run context (e.g. `bootstrap/issue-N`, `arch/issue-N`).
- Push changes to that branch and open a pull request when the run is configured to do so.
- The orchestrator will track run state via machine-readable issue comments and update labels (`cursor:running`, `cursor:done`, `cursor:error`).

## Quality

- Apply the repo’s review model (e.g. `docs/project/review-rubrics.md`) as a first-pass before committing; do not block on manual review for bootstrap.
