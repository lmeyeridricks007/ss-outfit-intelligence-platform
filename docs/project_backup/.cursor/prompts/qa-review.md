# QA Review Prompt

## Objective
Create a test and release-readiness artifact for a feature that has approved UI, backend, and integration outputs.

## Required Inputs
- Approved implementation plan
- UI, backend, and integration artifacts
- Review rubrics
- Approval mode
- Release or milestone go/no-go gate

## Required Output
- Scenario matrix
- Happy path coverage
- Fallback and error coverage
- Analytics validation
- Defect logging approach
- Go or no-go recommendation
- Explicit note on any remaining human gate or deterministic completion requirement
- Board update

## Section-by-section guidance
- **Scenario matrix:** Rows = scenarios (e.g. "PDP recommendation load," "Empty recommendation," "Rule override applied"); columns = environment (e.g. dev, staging), result (pass/fail/blocked), traceability (requirement or BR id). Cover happy path, fallbacks, and errors.
- **Happy path coverage:** Complete set of scenarios that represent "success" (e.g. "User sees recommendations; clicks one; add to cart"). Include every major user flow; link each to requirement or acceptance criteria.
- **Fallback and error coverage:** Empty state, timeout, partial failure, invalid input. Expected behavior and any user-facing message or recovery action.
- **Analytics validation:** Which events must fire (impression, click, add-to-cart, etc. per data-standards) and what to assert (payload fields, recommendation set ID, trace ID). Not only "events are sent" but "payload matches schema."
- **Defect logging approach:** Where defects are logged (e.g. GitHub issue, project board), severity levels, and when to block release vs defer.
- **Go / no-go recommendation:** "Ready for release" only if scenarios pass and no blocking defects; otherwise "No-go: [blockers]." Do not mark release-approved unless human gate is explicitly satisfied or waived by workflow.
- **Remaining human gate or completion requirement:** E.g. "Human release approval required" or "CI green + human sign-off on staging." Final go/no-go remains human-gated unless the workflow explicitly says otherwise.

## Quality Rules
- Trace tests back to the original requirement or BR/acceptance criteria so coverage is auditable.
- Include telemetry validation (events, payloads) per data-standards; not only UI behavior.
- Call out blocking defects and unresolved dependencies explicitly in the no-go section.
- QA may summarize readiness; final release or go/no-go approval remains human-gated unless the workflow explicitly says otherwise.

## Anti-patterns (avoid)
- Scenario matrix with no traceability to requirements.
- Omitting analytics or event validation when the feature emits recommendation/outcome events.
- Stating "ready for release" without human approval when the project requires a human gate.
- Vague "test coverage" without concrete scenarios or environments.

## Output template
```markdown
## QA review: [Feature/release name]

**Scenario matrix:** [Scenario × environment × result]

**Happy path coverage:** [List]

**Fallback and error coverage:** [List]

**Analytics validation:** [Events and assertions]

**Defect logging:** [Process]

**Go / no-go recommendation:** [Ready for release | Blockers: ...]

**Remaining human gate or completion requirement:** [e.g. Human release approval required]

**Board update:** Add/update row in `boards/e2e-qa.md`, status, link to approved build items.
```

## Autonomous mode (see `docs/project/autonomous-automation-config.md`)
- When autonomous mode is ON: produce the QA review artifact, update `boards/e2e-qa.md`, then **commit and push** the branch (e.g. `qa/issue-<number>-<slug>`). Do not stop for human approval or "Mark as ready." Allow PR creation. Go/no-go can be recorded as a recommendation; do not block the run on human release approval.
