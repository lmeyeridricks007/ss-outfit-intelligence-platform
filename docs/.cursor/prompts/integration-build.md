# Integration Build Prompt

## Objective
Create an integration delivery artifact for external systems, channels, or supporting services.

## Required Inputs
- Approved implementation plan item
- Architecture artifact
- Integration standards
- Approval mode
- Any milestone human gate or external validation gate

## Required Output
- Systems involved
- Trigger and data flow
- Auth and secrets assumptions
- Retry and failure behavior
- Monitoring checks
- Validation plan
- Board blockers or milestone-gate notes
- Board update

## Section-by-section guidance
- **Systems involved:** Internal (our APIs, queues, stores) and external (third-party APIs, channels, partners). Name each system and its role (producer, consumer, source of truth).
- **Trigger and data flow:** What triggers the integration (event, schedule, API call); direction (inbound, outbound, bidirectional); key payloads and transformations. Per `docs/project/data-standards.md`: identity, timestamps, source system.
- **Auth and secrets:** How each system is authenticated (API key, OAuth, mTLS); where secrets live; rotation and scope. Do not embed secrets in artifacts; reference "secrets store" or env.
- **Retry and failure behavior:** Retry policy (count, backoff), dead-letter or fallback, idempotency where relevant. What happens when external system is down or slow.
- **Monitoring:** Health checks, alerts (e.g. failure rate, latency), dashboards or logs that ops will use. Link to observability expectations in architecture.
- **Validation plan:** How to verify the integration (contract tests, staging run, manual checklist). Who approves production cutover if human gate applies.
- **Board blockers / milestone-gate notes:** Any human gate (e.g. "Production cutover requires human approval") or external validation gate (e.g. "Partner sign-off required"). If AUTO_APPROVE_ALLOWED for this stage, still state any later human gate.

## Quality Rules
- Define direction of data flow clearly (who pushes, who pulls; sync vs async).
- Make freshness and sync mode explicit (real-time, batch, max delay).
- Include human approval points when production behavior or external contracts change.
- If the stage is AUTO_APPROVE_ALLOWED, still make any later milestone human gate explicit so automation does not bypass it.

## Anti-patterns (avoid)
- "Integrates with X" without trigger, direction, and failure behavior.
- Missing auth/secrets approach or retry policy.
- No validation plan or approval step for production impact.

## Output template
```markdown
## Integration deliverable: [System/channel name]

**Systems involved:** [Internal + external]

**Trigger and data flow:** [Event/API → flow]

**Auth and secrets:** [Assumptions]

**Retry and failure behavior:** [Policy]

**Monitoring:** [Checks]

**Validation plan:** [How to verify]

**Board blockers / milestone-gate notes:** [Any human gate or external validation]

**Board update:** Add/update row in `boards/integration-build.md`, status, Approval Mode.
```
