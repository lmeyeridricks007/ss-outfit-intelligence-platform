# Autonomous Automation Config

## Purpose
Record the repository's expected autonomous automation behavior at a project-documentation level.

## Practical usage
Use this as reference when automation-triggered runs draft artifacts, perform review loops, commit changes, and push branch updates.

## Operating posture
- Autonomous automation may draft, revise, commit, and push artifacts required for the active run.
- Autonomous automation must still respect recorded approval modes, milestone gates, and evidence boundaries.
- Autonomous automation should not invent missing decisions or imply merge-coupled completion that has not happened.

## Current expectation
- Bootstrap and documentation-generation runs may complete without pausing for manual approval.
- Later-stage approvals should continue to follow explicit board approval mode and review thresholds.
