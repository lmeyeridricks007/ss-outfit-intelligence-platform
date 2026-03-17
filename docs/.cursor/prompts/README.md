# Prompt Library

## Purpose
Reusable prompt templates for each delivery stage in the AI Outfit Intelligence Platform workflow. Each prompt includes objective, required inputs, required output, quality rules, board instructions, and a **complete output template** (copy-paste structure for agent responses).

## Prompt categories
- **Stage prompts:** feature-request-to-br, business-requirements-to-breakdown, feature-breakdown-to-architecture, architecture-to-implementation-plan, ui-build, backend-build, integration-build, qa-review.
- **Review and board:** review-pass, board-update.
- **Automation:** automation-issue-intake, automation-pr-review, automation-next-task-pickup.

## Authoring standard
Each prompt includes:
- **Objective** — What the run produces and when to use it.
- **Required inputs** — Concrete inputs (artifacts, docs, board state); references to project docs (e.g. `docs/project/review-rubrics.md`) where applicable.
- **Section-by-section guidance** (where useful) — What each output section must contain, what "good" looks like, and references to standards (e.g. data-standards for events).
- **Scoring anchors or criteria** (for review prompt) — How to score dimensions and when to use blocking vs required edit vs optional.
- **Quality rules** — Must-follow behavior and references to project standards.
- **Anti-patterns** — What to avoid so outputs are actionable.
- **Board instruction** — Which board to update and what columns to set.
- **Approval-mode handling** — When to recommend READY_FOR_HUMAN_APPROVAL vs APPROVED; milestone gates.
- **Output template** — Markdown skeleton with placeholders for consistent agent output.
- **Explicit stop conditions** — When to stop or request clarification (e.g. insufficient issue body).

## Prompt set (complete)
| Prompt | Use |
|--------|-----|
| feature-request-to-br | Request → BR artifact + board row |
| business-requirements-to-breakdown | BR → feature breakdown + features board |
| feature-breakdown-to-architecture | Feature breakdown → technical architecture |
| architecture-to-implementation-plan | Architecture → implementation plan + gate map |
| ui-build | Plan item → UI deliverable |
| backend-build | Plan item → backend deliverable |
| integration-build | Plan item → integration deliverable |
| qa-review | Build artifacts → QA scenario matrix + go/no-go |
| review-pass | Any artifact → rubric review + disposition |
| board-update | Evidence → board row update + promotion |
| automation-issue-intake | Issue event → intake summary + suggested board update |
| automation-pr-review | PR event → review findings + board impact |
| automation-next-task-pickup | Schedule → next eligible items + blockers |

## Automation prompt rules
- Identify the trigger source explicitly in output.
- Stop when issue, PR, board, or context references are missing.
- Do not imply approval-path authority or merged-state completion unless the recorded approval mode explicitly allows it.
- Keep repo mutations narrow and explainable.
