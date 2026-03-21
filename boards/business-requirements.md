# Business Requirements Board

This board tracks business-requirements stage artifacts for the AI Outfit Intelligence Platform.

## Item Structure

| Column | Description |
|--------|-------------|
| ID | Stable business-requirements identifier, e.g. `BR-004` |
| Title | Requirement or request title |
| Status | Lifecycle state for the board item |
| Owner | Current delivery owner |
| Reviewer | Reviewer or review role |
| Approval Mode | `HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED` |
| Trigger Source | How the work entered the board |
| Inputs | Source issue and upstream artifacts |
| Output | Required artifact path |
| Exit Criteria | Completion condition for this stage |
| Notes | Non-blocking assumptions, risks, or workflow notes |
| Promotes To | Downstream board or next-stage artifact |

## Items

| ID | Title | Status | Owner | Reviewer | Approval Mode | Trigger Source | Inputs | Output | Exit Criteria | Notes | Promotes To |
|----|-------|--------|-------|----------|---------------|----------------|--------|--------|---------------|-------|-------------|
| BR-004 | RTW and CM support | IN_PROGRESS | Cursor | TBD | HUMAN_REQUIRED | issue-created automation (#78) | Issue #78; `docs/project/business-requirements.md`; `docs/project/personas.md`; `docs/project/product-overview.md`; `docs/project/roadmap.md` | `docs/project/br/br-004-rtw-and-cm-support.md` | Defines RTW and CM scope boundaries, differentiated user outcomes, governance needs, and phased rollout assumptions. | Approval mode for BR stage TBD; defaulted to HUMAN_REQUIRED per prompt. Workflow requires branch-only completion on `br/issue-78` with no PR. | `boards/features.md` |
