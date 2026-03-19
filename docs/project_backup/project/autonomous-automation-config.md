# Autonomous Automation Config

**Purpose:** When enabled, the GitHub issue → orchestrator → Cursor Agent → branch → PR flow runs without human intervention. No "Mark as ready" or approval pause before commit/push/PR.  
**Source of truth:** GitHub (issues, labels, comments, PRs). Run state is stored in a machine-readable issue comment (no DB).  
**Status:** Living document. Autonomous mode is **enabled** by default per repo config until otherwise changed.

---

## Autonomous mode (current: ON)

- **AUTONOMOUS_MODE:** `true` — agents must not stop for human approval before committing, pushing, or opening a PR.
- Agents must: generate the artifact, update the board row, commit and push the branch, and allow PR creation.
- Do not wait for "Mark as ready" or for a human to approve before push/PR.
- Approval-gate language in prompts is treated as **notes for later** (e.g. "Human gate at UI readiness") but must **not block** the automation run from completing (commit → push → PR).
- Board updates: use non-blocking statuses so the run can finish cleanly (e.g. IN_PROGRESS → NEEDS_REVIEW or APPROVED when review thresholds are met; in autonomous mode the agent may set APPROVED for the current run so the stage completes).
- The orchestrator updates issue labels and comments; it does not add `human-required` when autonomous mode is on.

---

## Stage → board mapping

| Stage label         | Board file                          |
|---------------------|-------------------------------------|
| `workflow:br`       | `docs/boards/business-requirements.md` |
| `workflow:feature-spec` | `docs/boards/features.md`        |
| `workflow:architecture` | `docs/boards/technical-architecture.md` |
| `workflow:implementation` | `docs/boards/implementation-plan.md` |
| `workflow:ui`       | `docs/boards/ui-build.md`           |
| `workflow:backend`  | `docs/boards/backend-build.md`      |
| `workflow:integration` | `docs/boards/integration-build.md` |
| `workflow:qa`       | `docs/boards/e2e-qa.md`             |

---

## Branch families (stage-specific)

| Stage label         | Branch prefix |
|---------------------|---------------|
| `workflow:br`       | `br/`         |
| `workflow:feature-spec` | `feat/`   |
| `workflow:architecture` | `arch/`   |
| `workflow:implementation` | `impl/` |
| `workflow:ui`       | `ui/`         |
| `workflow:backend`  | `be/`         |
| `workflow:integration` | `int/`    |
| `workflow:qa`       | `qa/`         |

---

## Labels

- **Stage:** `workflow:br`, `workflow:feature-spec`, `workflow:architecture`, `workflow:implementation`, `workflow:ui`, `workflow:backend`, `workflow:integration`, `workflow:qa`
- **Operational:** `cursor:queued`, `cursor:running`, `cursor:done`, `cursor:error`, `needs-info`

---

## Reference

- Orchestrator and flow: `docs/project/github-issues-orchestrator-cursor-api-dashboard.md`
- Prompts: `docs/.cursor/prompts/` (each stage prompt includes an Autonomous mode section when this config is ON).
