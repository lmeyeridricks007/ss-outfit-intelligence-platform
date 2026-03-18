# Business Requirements To Feature Breakdown

## Objective
Decompose approved business requirements into major features, sub-features, dependencies, and sequencing hints.

## Required Inputs
- Approved business requirements
- Roadmap
- Capability map
- Standards
- Approval mode and any milestone-gate constraints inherited from the BR

## Required Output
- Major feature list
- Sub-feature list
- Dependency map
- Risks and edge cases
- Recommended execution order
- Approval or milestone-gate notes
- Recommended board update

## Section-by-section guidance
- **Major features:** The complete set of high-level capabilities or user-facing outcomes implied by the BR (e.g. "PDP outfit recommendations," "Admin rule editor," "Recommendation analytics pipeline"). Include every capability needed; each should map to a testable deliverable. Do not cap or limit the number—decompose fully.
- **Sub-features:** For each major feature, the complete set of concrete sub-features or work slices (e.g. "API for recommendation request/response," "UI carousel component," "Event emission for impressions/clicks"). Include all work needed to deliver the feature; avoid single vague sub-features or omitting slices.
- **Dependency map:** Feature → dependencies (e.g. "PDP recommendations depends on: product catalog, outfit graph, merchandising rules API"). Call out shared dependencies: profile, graph, API, analytics, admin approvals—surfaced early so implementation plan can sequence.
- **Risks and edge cases:** Technical or product risks (e.g. "Catalog latency for real-time ranking"; "Rule conflict resolution"). Edge cases that could block or delay (e.g. "Empty look; no fallback defined in BR").
- **Recommended execution order:** Sequence that respects dependencies (e.g. "API contract and graph service before UI"). Note parallelizable work.
- **Approval / milestone-gate notes:** Inherit from BR (e.g. "UI gate before backend"; "Human approval at BR and at UI readiness"). Carry into features board so downstream boards can enforce.

## Quality Rules
- Break work into implementation-meaningful slices; a developer or agent should be able to pick up a sub-feature and know scope.
- Separate user-facing features (PDP, cart, admin UI) from enabling capabilities (API, graph, event pipeline, analytics).
- Highlight shared dependencies (profile, graph, API, analytics) so the implementation plan does not duplicate or assume incorrectly.
- If rejection comments changed the BR, propagate those changes through the decomposition; do not keep stale feature slices.

## Anti-patterns (avoid)
- One giant "Feature 1" with no sub-features or a single vague sub-feature.
- Dependency map that omits shared systems (profile, graph, API).
- Execution order that ignores dependencies (e.g. UI before API contract).

## Board Instruction
Update `boards/features.md`: add one row per major feature (or per logical work item per project convention), link to originating BR item, set Approval Mode and milestone-gate notes from BR.

## Autonomous mode (see `docs/project/autonomous-automation-config.md`)
- When autonomous mode is ON: produce the feature breakdown, update `boards/features.md`, then **commit and push** the branch (e.g. `feat/issue-<number>-<slug>`). Do not stop for human approval or "Mark as ready." Allow PR creation.

## Output template
```markdown
## Feature breakdown: [BR title]

**Major features:** [F1, F2, ...]

**Sub-features:** [Per major feature]

**Dependency map:** [Feature → dependencies; shared: profile, graph, API, analytics]

**Risks and edge cases:** [List]

**Recommended execution order:** [Sequence]

**Approval / milestone-gate notes:** [Inherited from BR; e.g. UI gate before backend]

**Board update:** Add rows to `boards/features.md` with status TODO, Approval Mode, link to BR-xxx.
```
