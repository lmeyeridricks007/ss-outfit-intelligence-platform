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

### A. Per architecture item (ARCH-###)

For **each** ARCH row you are defining (from `boards/technical-architecture.md`, the issue, or the component map):

1. **Exactly one canonical markdown file** under `docs/project/architecture/`, named with the ARCH ID first, e.g.:
   - `docs/project/architecture/ARCH-001-analytics-experimentation.md`
   - `docs/project/architecture/ARCH-002-catalog-product-intelligence.md`  
   (Use a short kebab-case slug after the ID; stay consistent across the repo.)

2. **That file** must contain the **full** architecture write-up for that item (not a high-level blurb). Include at minimum:
   - Title line with ARCH ID and parent FEAT
   - Components and responsibilities
   - Data flow
   - APIs / contracts / interfaces
   - Integration points
   - Risks and trade-offs
   - NFRs
   - Readiness / exit criteria
   - Open decisions (DEC-###) if any
   - Mapping to `architecture-overview.md`, `domain-model.md`, standards when relevant

Do **not** rely on a single “portfolio” or “feature portfolio” document to hold all of this depth for every ARCH — that doc must stay summary-level (see B).

### B. Portfolio / umbrella doc (batch or map-style issues)

When the issue is a **batch** (e.g. component map ARCH-001…ARCH-014, “Technical architecture: feature portfolio…”):

- You may keep **one** umbrella markdown file for:
  - Architecture **component map** (table: ARCH ID, parent feature, primary components, interfaces)
  - **Shared** cross-cutting context (planes, invariants, portfolio-level risks) **only at summary depth**
- The umbrella doc must **link** to each `docs/project/architecture/ARCH-###-*.md` (relative links). It must **not** duplicate the long per-ARCH sections that belong in the dedicated files.

### C. Index

- Maintain **`docs/project/architecture/README.md`** as a table: ARCH ID → doc path → one-line purpose (update when adding files).

### D. Board

Update **`{{BOARD_PATH}}`** (typically `boards/technical-architecture.md`) for **#{{ISSUE_NUMBER}}** (create scaffold if missing):

- Every row’s **Output** column = path to that row’s **canonical** `ARCH-###-*.md` file (primary artifact). You may add a secondary note linking the umbrella map doc if useful.
- Status: **Pushed** or **Done** after push (this workflow does **not** use pull requests).
- Traceability: issue number, FEAT ID, ARCH ID, exit criteria.

## Section-by-section guidance
- **Component responsibilities:** Per component or service: name, inputs (API/events), outputs, and ownership boundary. No "TBD" for components on the critical path; call out as missing decision if unknown.
- **Data flow:** Source → processing → sink (e.g. "PDP request → recommendation service → graph + rules → ranking → response"). Key entities (product, look, profile, rule) and where they are read/written.
- **API implications:** New or changed endpoints: path, method, request/response shape, errors. Event contracts: topic, payload, producer/consumer. Reference data-standards for identity and event schema.
- **Integration points:** External systems, auth, sync/async, retry and failure behavior. Explicit about what is in-repo vs external.
- **Risks and trade-offs:** Technology or scale trade-offs (e.g. "Ranking in-request vs async"; "Cache invalidation strategy"). Document chosen direction and alternatives considered.
- **Readiness criteria:** Checklist for "implementation plan can be written" (e.g. "Contract for recommendation API agreed"; "Graph service boundary and deployment model defined"). No hand-wavy "will be decided later" on critical path.
- **Approval / milestone-gate notes:** From feature item; state if UI gate or other human gate applies so implementation plan can encode it.
 - Read `boards/features.md` when it exists to find the corresponding feature row; **if the file is missing, create a minimal `boards/features.md`** (scaffold table + rows inferred from the issue and `docs/features/`) as part of this run — do **not** refuse to proceed only because the board was absent
 - **Output**: Path to the **canonical per-ARCH** file (e.g. `docs/project/architecture/ARCH-004-complete-look-orchestration.md`), not only a portfolio overview

## Completion discipline (critical — autonomous run)

This workflow is **fully autonomous**. Do **not** treat any of these as an acceptable stopping point:

- “Environment ready”
- “I’ve confirmed the gap…”
- “Next I’m going to…” without immediately doing it
- A plan or summary **without** new/edited files on disk

You **must** in **this same run** (unless a hard tool error blocks you):

1. **Write** every required `docs/project/architecture/ARCH-###-*.md` file (batch = all rows in scope — use tight but complete sections if long; do not defer to a follow-up).
2. **Trim** the umbrella/portfolio doc to map + links + short shared context only (move detail into per-ARCH files).
3. **Update** `docs/project/architecture/README.md`.
4. **Rewire** `boards/technical-architecture.md` so each row’s **Output** points at the canonical per-ARCH path.
5. **Commit and push** to **`{{BRANCH_NAME}}`**.

If you run low on space, **prioritize**: create all per-ARCH files with minimum viable depth → board → push; then expand depth in a follow-up only if the platform forces a limit. **Do not** stop after narrative alone.

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

## Autonomous mode (see `docs/project/autonomous-automation-config.md`)
- When autonomous mode is ON: produce the architecture artifact, update `boards/technical-architecture.md`, then **commit and push** the branch (e.g. `arch/issue-<number>-<slug>`). Do not stop for human approval or "Mark as ready." Allow PR creation.

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

## Do Not

- Create implementation-plan rows or issues
- Create UI/backend/integration/QA issues
- Wait for manual approval before committing
- Use blocking statuses that require human intervention
- Stop after “Environment ready”, gap confirmation, or intent-only narration — see **Completion discipline** above

```
