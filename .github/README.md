# GitHub repo config

## Issue templates

- **Feature request** (`ISSUE_TEMPLATE/feature_request.md`) — Use for new capability intake. Asks for: problem, users, value, in/out scope, open questions. Keeps intake consistent for BR and feature breakdown. Default label: `feature`.

## Labels

Defined in `labels.yml` for filtering and reporting. Create them under **Settings → Labels** (or use a label-sync action).

| Label | Purpose |
|-------|--------|
| `feature` | Product feature (intake / BR / implementation) |
| `epic` | Large initiative spanning multiple features or phases |
| `phase-1` … `phase-5` | Roadmap phase (see `docs/boards/feature-issue-mapping.md`) |
| `br-done` | Business requirements approved; ready for feature breakdown |
| `in-development` | In active development (build or QA) |
| `bug` | Something isn't working |
| `documentation` | Docs, specs, or runbooks |

For creating phase-labeled feature issues (F1–F26), see `scripts/create-feature-issues.sh` and `docs/boards/feature-issue-mapping.md`.
