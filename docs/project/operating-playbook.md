# Operating Playbook

## Purpose
Provide day-to-day operating guidance for working with project artifacts, boards, reviews, and promotions.

## Practical usage
Use this playbook when moving work between stages, preparing reviews, handling rejections, or recording milestone gates.

## Review and approval model
- Prepare artifacts with explicit assumptions, dependencies, and missing decisions.
- Run review using `docs/project/review-rubrics.md` before promotion.
- Respect the board item's approval mode.
- Record milestone human gates in notes when downstream work depends on them.

## Rejection handling
- Move or keep the item in `CHANGES_REQUESTED` when a human reviewer rejects it.
- Treat every rejection comment as a required input for the next revision.
- Update upstream artifacts when comments invalidate earlier assumptions.

## Promotion pattern
- Bootstrap docs promote into BR artifacts.
- BR artifacts promote into features.
- Features promote into architecture.
- Architecture promotes into implementation planning.
- Plans promote into build artifacts.
- Build artifacts promote into QA.

## Evidence expectations
- Do not claim `DONE` when merge, CI, or required human approvals are still outstanding.
- Prefer narrow, auditable updates over broad speculative changes.
