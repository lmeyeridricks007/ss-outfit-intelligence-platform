# Boards

## What board files are

Each board file in `boards/` is **one markdown file** that contains **two parts**:

1. **Instructions (top)** — Schema and rules that agents and humans need to read and update the board correctly. **Keep these.**
2. **Actual board (table)** — The live list of current items. **This is the board.** Add, update, and remove rows as work progresses.

Instructions and the live board live in the **same file** so that schema, promotion rules, and current state stay in one place and stay in sync.

## Structure of each board file

```
# [Stage] Board

## Purpose
[What this board tracks]

## Item Structure
[Table: column names and descriptions — defines the schema]

## Lifecycle States
[Allowed status values]

## Ownership
[Who owns, reviews, approves]

## Trigger Guidance
[When and how work gets triggered]

## Promotion Rules
[When items can move to the next stage; rejection and gate handling]

---
## Current Items
[Table: one row per work item — the live board. Update this table as work progresses.]
```

- **Instructions (Purpose through Promotion Rules):** Do not remove. They define how to interpret and update the board. Agents use them (see `.cursor/prompts/board-update.md` and `.cursor/skills/board-maintenance/SKILL.md`).
- **Current Items table:** This is the actual board. Rows are real work items. When you create a new requirement, feature, or build item, add a row. When status changes, update the row. When an item is promoted or done, update or archive as your process requires.

## Should the “actual board” be here or elsewhere?

**The actual board is here** — in the same file, in the **Current Items** (or equivalent) table. There is no separate “data only” file or external system required. The table in each board file is the source of truth for that stage’s items.

If you later integrate with GitHub Projects, Jira, or another tool, you can sync to/from these tables or document that the external system is the source of truth; by default, the markdown table in each board file is the live board.

## Naming the table section

- Use **"Current Items"** (or **"Board"**) for the live table so it’s clear the rows are real work, not only examples.
- If you keep sample rows for onboarding or templates, you can either:
  - Keep them in the same table and treat them as starter backlog (replace IDs/names as you add real work), or
  - Add a short **"Example row"** in the instructions and use **"Current Items"** for the real table only.

## Feature ↔ GitHub issues

Every Phase 1–5 feature (F1–F26) should have a corresponding GitHub issue with a **phase label** (`phase-1` … `phase-5`) and links to the feature list and BRs. See **[feature-issue-mapping.md](feature-issue-mapping.md)** for the mapping and **`scripts/create-feature-issues.sh`** to create issues (run after `gh auth login`).

## Board list

| File | Stage | Promotes to |
|------|--------|-------------|
| `business-requirements.md` | Business requirements | `features.md` |
| `features.md` | Feature breakdown | `technical-architecture.md` |
| `technical-architecture.md` | Technical architecture | `implementation-plan.md` |
| `implementation-plan.md` | Implementation plan | `ui-build.md`, `backend-build.md`, `integration-build.md`, `e2e-qa.md` |
| `ui-build.md` | UI build | `e2e-qa.md` |
| `backend-build.md` | Backend build | `e2e-qa.md` |
| `integration-build.md` | Integration build | `e2e-qa.md` |
| `e2e-qa.md` | E2E QA | Release / done |

## References

- Board update prompt and skill: `.cursor/prompts/board-update.md`, `.cursor/skills/board-maintenance/SKILL.md`.
- Docs and boards standards: `.cursor/rules/docs-and-boards-standards.mdc`.
- Lab on board files and lifecycle: `docs/project/labs/lab-03-board-files-and-lifecycle-model.md`.
