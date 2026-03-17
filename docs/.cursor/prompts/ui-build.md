# UI Build Prompt

## Objective
Create a UI delivery artifact for recommendation surfaces or admin tooling so that implementation can proceed with clear scope, flows, component states, and acceptance criteria. Align with `docs/project/data-standards.md` for events and identity.

## Required Inputs
- Approved implementation plan item (scope, dependencies, acceptance gates)
- UI standards (project or team; layout, accessibility, patterns)
- Relevant API or event contract (recommendation request/response, merchandising rules if admin)
- Approval mode for this item
- Any milestone human gate definition for UI readiness (e.g. "UI sign-off required before backend")

## Section-by-section guidance
- **Surface scope:** Which pages, routes, or app areas (e.g. PDP recommendation strip, cart cross-sell panel, admin rule editor). List by surface name and entry point. Exclude out-of-scope surfaces explicitly.
- **User flow:** Ordered steps (1, 2, 3…) with entry (e.g. "User lands on PDP with product X"), actions (e.g. "Sees Complete the look; clicks item"), and exit (e.g. "Add to cart or dismiss"). For admin flows, include role and permissions assumption.
- **Components:** Named UI units (e.g. RecommendationCarousel, RuleEditorForm) with a clear responsibility. For each, note: props/inputs, emitted events, and dependency on API/context. Include every component needed for the scope.
- **States (per component or flow):** Include all relevant states: loading, empty (no data), error (retry/fallback), success, and any others needed for the flow. Specify what the user sees and any actions (e.g. "Empty: show 'No recommendations' and CTA to browse").
- **Analytics events:** Per `docs/project/data-standards.md`: event name, timestamp, customer/session identifier, channel and surface, anchor product or look ID where relevant. For recommendations: impression, click, add-to-cart, dismiss, override. Include recommendation set ID and trace ID in payload where applicable.
- **Acceptance criteria:** Complete set of testable assertions. Prefer "Given [context], when [action], then [observable outcome]." Cover all relevant scenarios: happy path(s), empty state(s), error path(s), and every key analytics event. If the plan references specific metrics (e.g. CTR), include criteria that those events are emitted with correct payload. Do not cap the set—include every criterion needed to validate the deliverable.
- **Board blockers / milestone-gate notes:** If UI readiness is the human gate, state: "UI readiness is milestone gate; backend work blocked until this item is APPROVED." List any dependency blockers (e.g. API contract not finalized).

## Quality Rules
- Include fallback and empty states for every data-driven component; do not assume data is always present.
- Distinguish customer-facing (PDP, cart, email) from internal admin flows (rule editor, campaign config); auth and permissions differ.
- Ensure telemetry aligns with recommendation measurement (impression, click, save, add-to-cart, purchase, dismiss, override per data standards).
- If UI readiness is the milestone human gate, make the checkpoint explicit so backend continuation is blocked until review completes.
- If the last human review rejected the UI, incorporate those comments and update any affected requirements, plan notes, or dependency assumptions; do not only patch the UI artifact locally.

## Anti-patterns (avoid)
- Components or flows without loading/empty/error states.
- Analytics "to be defined" without event names and key payload fields.
- Acceptance criteria that are vague ("works correctly") or not testable.
- Omitting which surface or route the work applies to.

## Required Output
- Surface scope, user flow, components (with states), analytics events (name + payload), acceptance criteria (Given/When/Then or checklist), board blockers/milestone-gate notes, board update.

## Output template
```markdown
## UI deliverable: [Feature/surface name]

**Surface scope:** [PDP, cart, admin, ...]

**User flow:** [Steps]

**Components:** [List with states]

**States:** [Loading, empty, error, success]

**Analytics events:** [Event names and payloads]

**Acceptance criteria:** [Checklist]

**Board blockers / milestone-gate notes:** [e.g. UI readiness is human gate; backend blocked until approved]

**Board update:** Add/update row in `boards/ui-build.md`, status, Approval Mode, link to implementation plan item.
```
