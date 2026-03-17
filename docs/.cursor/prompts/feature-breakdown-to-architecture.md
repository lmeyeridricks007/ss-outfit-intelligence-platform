# Feature Breakdown To Technical Architecture

## Objective
Produce an implementation-oriented technical architecture artifact from an approved feature breakdown.

## Required Inputs
- Approved feature breakdown
- Architecture overview
- Domain model
- API, data, and integration standards
- Approval mode and any milestone-gate constraints inherited from the feature item

## Required Output
- Component responsibilities
- Data flow
- API implications
- Integration points
- Risks and trade-offs
- Readiness criteria
- Approval or milestone-gate notes
- Recommended board update

## Section-by-section guidance
- **Component responsibilities:** Per component or service: name, inputs (API/events), outputs, and ownership boundary. No "TBD" for components on the critical path; call out as missing decision if unknown.
- **Data flow:** Source → processing → sink (e.g. "PDP request → recommendation service → graph + rules → ranking → response"). Key entities (product, look, profile, rule) and where they are read/written.
- **API implications:** New or changed endpoints: path, method, request/response shape, errors. Event contracts: topic, payload, producer/consumer. Reference data-standards for identity and event schema.
- **Integration points:** External systems, auth, sync/async, retry and failure behavior. Explicit about what is in-repo vs external.
- **Risks and trade-offs:** Technology or scale trade-offs (e.g. "Ranking in-request vs async"; "Cache invalidation strategy"). Document chosen direction and alternatives considered.
- **Readiness criteria:** Checklist for "implementation plan can be written" (e.g. "Contract for recommendation API agreed"; "Graph service boundary and deployment model defined"). No hand-wavy "will be decided later" on critical path.
- **Approval / milestone-gate notes:** From feature item; state if UI gate or other human gate applies so implementation plan can encode it.

## Quality Rules
- Do not stay conceptual; every component and flow should be implementation-oriented (names, contracts, failure modes).
- Define dependencies and failure modes explicitly (timeouts, fallbacks, degradation).
- Call out missing platform decisions in a dedicated section; do not hide them in narrative.
- If rejection comments invalidated the feature breakdown, update architecture assumptions to match before recommending review readiness.

## Anti-patterns (avoid)
- Vague "recommendation service" without inputs, outputs, and boundaries.
- Data flow without entities or read/write ownership.
- "To be decided" on critical path without listing as missing decision.
- Omitting error or failure behavior for external integrations.

## Board Instruction
Update `boards/technical-architecture.md` with architecture readiness, blockers (e.g. "Awaiting API contract sign-off"), and approval mode.

## Output template
```markdown
## Technical architecture: [Feature set name]

**Component responsibilities:** [Service/module → responsibility]

**Data flow:** [Source → sink; key entities]

**API implications:** [New/changed endpoints, contracts]

**Integration points:** [External systems, events]

**Risks and trade-offs:** [List]

**Readiness criteria:** [Checklist for implementation plan]

**Approval / milestone-gate notes:** [From feature item]

**Board update:** Add/update row in `boards/technical-architecture.md`, status, Approval Mode, blockers.
```
