# Business requirements board

Trigger: issue-created automation from GitHub issue #140 (`workflow:br`).

Source of truth: stage artifact created on `br/issue-140` for BR-003 multi-surface delivery.

Note: this branch did not contain the expected seeded `docs/project/` and `boards/` structure, so this board file was created as part of the autonomous run.

| BR ID | Feature | Status | Owner | Reviewer | Approval Mode | Trigger Source | Inputs | Output | Exit Criteria | Notes | Promotes To |
|-------|---------|--------|-------|----------|---------------|----------------|--------|--------|---------------|-------|-------------|
| BR-003 | Multi-surface delivery | DONE | Cursor |  | AUTO_APPROVE_ALLOWED | GitHub issue #140; issue-created automation | goals for shared API-first delivery; ecommerce, email, clienteling, and future API consumer expectations | docs/project/br/br-003-multi-surface-delivery.md | BR artifact defines shared delivery expectations, surface-specific needs, rollout order, and contract assumptions for downstream feature and architecture work. | Autonomous run completed on `br/issue-140`; seeded missing board/doc paths on this branch; non-blocking follow-ups captured for latency expectations, payload-shape boundaries, clienteling-first workflow selection, and versioning policy. | Feature breakdown and architecture planning |
