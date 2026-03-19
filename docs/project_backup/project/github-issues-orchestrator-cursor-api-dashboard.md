# GitHub Issues → Orchestrator → Cursor API (Autonomous Flow)

**Purpose:** Describe the fully autonomous flow from labeled GitHub issue to Cursor Cloud Agent run, branch push, PR creation, and completion. No human intervention is required to finish a run.  
**Source of truth:** GitHub (issues, labels, comments, PRs). Run state is stored in a **machine-readable issue comment** (no database).  
**Config:** `docs/project/autonomous-automation-config.md` — autonomous mode is ON by default.

---

## Flow overview

1. **Issue labeled** with a stage (e.g. `workflow:br`, `workflow:feature-spec`) → orchestrator accepts the run.
2. **Orchestrator** adds `cursor:queued`, comments "Run accepted", then launches the Cursor agent via API.
3. **On Cursor run started:** orchestrator removes `cursor:queued`, adds `cursor:running`, posts a **machine-readable comment** with `run_id`, `issue`, `stage`, `branch`, `started_at`, and comments "Cursor agent started".
4. **Agent** (per stage prompt and autonomous rule) produces the artifact, updates the board, **commits and pushes** the branch without waiting for "Mark as ready" or human approval.
5. **Branch push** to a stage branch (`br/`, `feat/`, `arch/`, etc.) triggers GitHub Actions, which **opens a PR** if one does not exist and comments on the issue: "PR opened: \<url\>".
6. **On run completion:** orchestrator (or poller) removes `cursor:running`, adds `cursor:done`, and comments a short success summary with PR URL. **No** `human-required` label is added in autonomous mode.
7. **On run failure:** orchestrator removes `cursor:running`, adds `cursor:error`, and comments "Run failed: \<reason\>".

---

## No human intervention

- **Do not stop** for "Mark as ready" or for human approval before commit/push/PR.
- The agent **commits and pushes** automatically.
- The orchestrator **updates labels and issue comments** automatically.
- **PR is opened** automatically when the agent pushes a stage branch (GitHub Actions).
- **Completion/failure** is reflected in labels and comments; no human click is required to complete the run.

---

## Machine-readable run comment (no-DB)

The orchestrator stores run state in a **single** issue comment that it creates or updates. Format:

```html
<!-- cursor-run run_id="..." issue="123" stage="workflow:br" branch="br/123-title" started_at="2025-03-17T12:00:00Z" -->
```

- **run_id:** From Cursor API when the run is launched; used by the poller to check status.
- **issue:** GitHub issue number.
- **stage:** Stage label (e.g. `workflow:br`).
- **branch:** Branch name (e.g. `br/123-feature-name`).
- **started_at:** ISO timestamp.

The poller (or a Cursor webhook callback) reads this comment to know which `run_id` to poll and which issue to update on success/failure.

---

## Stage → board mapping

| Stage label           | Board file                           |
|----------------------|--------------------------------------|
| `workflow:br`        | `docs/boards/business-requirements.md` |
| `workflow:feature-spec` | `docs/boards/features.md`         |
| `workflow:architecture` | `docs/boards/technical-architecture.md` |
| `workflow:implementation` | `docs/boards/implementation-plan.md` |
| `workflow:ui`        | `docs/boards/ui-build.md`            |
| `workflow:backend`   | `docs/boards/backend-build.md`       |
| `workflow:integration` | `docs/boards/integration-build.md` |
| `workflow:qa`        | `docs/boards/e2e-qa.md`              |

---

## Branch families (stage-specific)

| Stage label           | Branch prefix |
|-----------------------|---------------|
| `workflow:br`         | `br/`         |
| `workflow:feature-spec` | `feat/`    |
| `workflow:architecture` | `arch/`    |
| `workflow:implementation` | `impl/`  |
| `workflow:ui`         | `ui/`         |
| `workflow:backend`    | `be/`         |
| `workflow:integration` | `int/`     |
| `workflow:qa`         | `qa/`         |

---

## Labels

- **Stage:** `workflow:br`, `workflow:feature-spec`, `workflow:architecture`, `workflow:implementation`, `workflow:ui`, `workflow:backend`, `workflow:integration`, `workflow:qa`
- **Operational:** `cursor:queued`, `cursor:running`, `cursor:done`, `cursor:error`, `needs-info`
- In autonomous mode, **`human-required` is not added** on completion.

---

## Orchestrator implementation

- **Location:** `apps/orchestrator/`
- **Webhook:** `POST /webhook/github` — receives GitHub `issues` and `pull_request` events; verifies `X-Hub-Signature-256`.
- **On issue opened/labeled** with a stage label and no cursor label: add `cursor:queued` → comment "Run accepted" → call Cursor API to launch run → remove `cursor:queued` → add `cursor:running` → create/update machine-readable run comment → comment "Cursor agent started".
- **On pull_request opened** for a stage branch: comment on the linked issue "PR opened: \<url\>".
- **Poller:** `node src/poller.js` — lists issues with `cursor:running`, reads `run_id` from the run comment, polls Cursor API for status; on completed → remove `cursor:running`, add `cursor:done`, comment success + PR URL; on failed → remove `cursor:running`, add `cursor:error`, comment failure.
- **Config:** `AUTONOMOUS_MODE=true` (default), `GITHUB_WEBHOOK_SECRET`, `GITHUB_TOKEN`, `CURSOR_AGENT_API_URL`, `CURSOR_AGENT_API_KEY`. See `apps/orchestrator/.env.example`.

---

## PR workflow

- **Workflow:** `.github/workflows/open-pr-on-push.yml`
- **Trigger:** Push to `br/**`, `feat/**`, `arch/**`, `impl/**`, `ui/**`, `be/**`, `int/**`, `qa/**`
- **Behavior:** If no open PR exists for that branch, create one (base = default branch); comment on the issue "PR opened: \<url\>".

---

## Agent behavior (autonomous mode)

- Stage prompts and the rule `docs/.cursor/rules/autonomous-automation.mdc` instruct the agent to:
  - Generate the artifact and update the relevant board.
  - **Commit and push** the branch (no wait for "Mark as ready" or human approval).
  - Allow PR creation (GitHub Actions open the PR on push).
- Approval-gate language (e.g. "Human approval at UI readiness") is kept as **notes** in artifacts/boards but does **not** block the run from completing.

---

## References

- Autonomous config: `docs/project/autonomous-automation-config.md`
- Autonomous rule: `docs/.cursor/rules/autonomous-automation.mdc`
- Automation safety (with autonomous exception): `docs/.cursor/rules/automation-safety.mdc`
- Boards: `docs/boards/README.md`
