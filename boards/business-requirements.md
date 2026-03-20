# Business requirements board

## Purpose

Track business-requirements artifacts from canonical project docs through drafting, review, and promotion into downstream feature work.

## Item structure

| Column | Meaning |
| --- | --- |
| BR ID | Stable business-requirement identifier. |
| Feature | Requirement title or capability area. |
| Issue | GitHub issue driving the current run or latest update. |
| Status | Lifecycle state. Use exact values from project standards. |
| Owner | Current owner if assigned. |
| Reviewer | Current reviewer if assigned. |
| Approval Mode | `HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED`. |
| Trigger Source | Source docs or automation context that created or updated the item. |
| Inputs | Key scope inputs or constraints. |
| Output | Current BR artifact path. |
| Exit Criteria | Conditions required before the BR can promote. |
| Notes | Dependencies, trigger context, PR/review notes, and follow-ups. |
| Promotes To | Expected downstream feature IDs or board items. |

## Items

| BR ID | Feature | Issue | Status | Owner | Reviewer | Approval Mode | Trigger Source | Inputs | Output | Exit Criteria | Notes | Promotes To |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| BR-012 | Identity and profile foundation | #61 | IN_REVIEW |  |  | HUMAN_REQUIRED | `docs/project/business-requirements.md` (BR-12); issue-created automation | Identity resolution; customer profile scope; cross-channel consistency; privacy constraints | `docs/project/br/br-012-identity-and-profile-foundation.md` | Defines identity and profile outcomes, cross-channel expectations, risk boundaries, and dependencies for personalization work | Trigger: issue-created automation. Branch pushed on `br/issue-61`; draft PR creation requested. Approval mode for BR stage not otherwise recorded, so defaulted to `HUMAN_REQUIRED`. Phase 2 dependency for personalization and cross-channel relevance. | F4, F7, F22, F26 |
