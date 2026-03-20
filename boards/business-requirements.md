# Business requirements board

Trigger: issue-created automation. This board tracks business-requirements stage artifacts and uses the repository lifecycle and approval fields.

## Item structure

| Column | Description |
|---|---|
| BR ID | Stable business-requirement identifier |
| Feature | Requirement title |
| Status | Lifecycle state for the board item |
| Owner | Current owner if assigned |
| Reviewer | Reviewer if assigned |
| Approval Mode | `HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED` |
| Trigger Source | Source issue or canonical document that triggered the item |
| Inputs | Primary requirement inputs |
| Output | Expected artifact |
| Exit Criteria | Condition for completing the BR item |
| Notes | Non-blocking context, risks, or follow-up notes |
| Promotes To | Downstream feature breakdown item or board |

## Items

| BR ID | Feature | Status | Owner | Reviewer | Approval Mode | Trigger Source | Inputs | Output | Exit Criteria | Notes | Promotes To |
|---|---|---|---|---|---|---|---|---|---|---|---|
| BR-008 | Product and inventory awareness | DONE |  |  | AUTO_APPROVE_ALLOWED | GitHub issue #57; `docs/project/business-requirements.md` (BR-8); `docs/project/product-overview.md`; `docs/project/roadmap.md`; `docs/project/standards.md` | Catalog attributes, inventory constraints, assortment relevance, freshness expectations | `docs/project/br/br-008-product-and-inventory-awareness.md` | Documents required product and inventory inputs, operational boundaries, freshness expectations, and success measures for purchasable recommendations | Autonomous BR run completed on branch `br/issue-57`; branch pushed and PR creation was requested via automation settings. Missing decisions remain documented in the artifact for exact system-of-record mapping and freshness thresholds. | `boards/features.md` (future fan-out) |
