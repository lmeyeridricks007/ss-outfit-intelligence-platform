# Backend Build Prompt

## Objective
Create a backend delivery artifact for a platform capability, service, or API so that implementation can proceed with clear boundaries, contracts, and acceptance criteria. Align with `docs/project/data-standards.md` for identity, events, and data quality.

## Required Inputs
- Approved implementation plan item (scope, dependencies, handoffs)
- Approved architecture artifact (component boundaries, data flow, integration points)
- API and data standards: `docs/project/data-standards.md`, any service/API conventions
- Approval mode for this item
- Any upstream milestone human gate (e.g. reviewed UI readiness) and whether it is satisfied

## Section-by-section guidance
- **Service responsibilities:** Name the service or module. List: (1) inputs it consumes (API requests, events, triggers), (2) outputs it produces (responses, events, side effects), (3) ownership boundary (what it does vs delegates). Use as much detail as needed for a complete picture; avoid vague "handles recommendations."
- **Business logic checklist:** Ordered or categorized list of rules and behaviors (e.g. "Apply merchandising inclusion/exclusion rules before ranking"; "Resolve customer identity with confidence score"; "Emit impression event with recommendation set ID"). Each item should be testable or reviewable.
- **Contract requirements:** For each API or event: (1) endpoint or topic/channel, (2) request shape (key fields, required vs optional), (3) response or emitted payload, (4) error cases and codes, (5) idempotency or retry expectations if relevant. Reference architecture artifact and data standards for identity (canonical IDs, source-system mappings).
- **Data dependencies:** Data stores, caches, or upstream services; what is read/written; freshness (e.g. "Product catalog: eventual consistency, max 5 min"; "Customer profile: real-time"). Identity resolution and consent/opt-out must be stated where customer data is used.
- **Observability:** Logs (what is logged at entry/exit and on error), metrics (latency, error rate, recommendation request/response counts), alerts (e.g. error rate threshold). Align with recommendation telemetry (impression, click, add-to-cart, etc.) where the service participates in that pipeline.
- **Acceptance criteria:** Complete set of testable assertions: happy path(s), all relevant error paths (e.g. "Given invalid customer ID, returns 400 and no recommendation"), and integration or data-quality checks where applicable (e.g. "Recommendation set ID is persisted with outcome events"). Do not limit to a minimum—include every criterion needed to validate the deliverable.
- **Board blockers / milestone-gate notes:** If backend is blocked on UI readiness or other gate, state: "Blocked until [gate] is APPROVED." If unblocked, state "None" or list remaining dependencies.

## Quality Rules
- Include error handling and fallback paths for every external dependency (DB, cache, upstream API).
- Identify data freshness and consistency assumptions so QA and ops can validate.
- Keep dependencies explicit and testable (contracts, not "talks to X").
- If backend work is blocked on an upstream milestone gate, state that explicitly; do not write the artifact as if the dependency were already cleared.
- If human rejection comments changed contracts, flows, or assumptions, propagate those changes into the linked plan or requirement notes before resubmitting.

## Anti-patterns (avoid)
- Vague "service handles recommendations" without inputs, outputs, and boundaries.
- Contracts without error cases or identity/consent considerations.
- Missing data freshness or identity-resolution assumptions.
- Marking "No blockers" when a milestone human gate (e.g. UI approval) is not yet met.

## Required Output
- Service responsibilities, business logic checklist, contract requirements (API/events), data dependencies (stores, freshness), observability (logs, metrics, alerts), acceptance criteria, board blockers/milestone-gate notes, board update.

## Output template
```markdown
## Backend deliverable: [Service/capability name]

**Service responsibilities:** [Scope]

**Business logic checklist:** [Items]

**Contract requirements:** [API, events]

**Data dependencies:** [Stores, freshness]

**Observability:** [Logs, metrics, alerts]

**Acceptance criteria:** [Checklist]

**Board blockers / milestone-gate notes:** [e.g. Blocked until UI readiness approved; or "None"]

**Board update:** Add/update row in `boards/backend-build.md`, status, Approval Mode, link to plan item.
```

## Autonomous mode (see `docs/project/autonomous-automation-config.md`)
- When autonomous mode is ON: produce the backend deliverable, update `boards/backend-build.md`, then **commit and push** the branch (e.g. `be/issue-<number>-<slug>`). Do not stop for human approval or "Mark as ready." Allow PR creation.
