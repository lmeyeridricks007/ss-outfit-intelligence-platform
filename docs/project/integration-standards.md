# Integration Standards

## Scope
These standards apply to integrations with commerce, marketing, POS, analytics, weather, and other systems that provide data to or consume data from the platform.

## Integration principles
- Integrate with source systems through explicit contracts and ownership boundaries.
- Prefer repeatable, documented integration patterns over one-off channel-specific logic.
- Keep recommendation consumers decoupled from internal model or rule implementation details.
- Design integrations so the platform can degrade gracefully when a dependency is delayed or unavailable.

## Auth and secret handling expectations
- Use managed credentials appropriate to each integration type.
- Separate credentials by environment and by least-privileged access level.
- Do not embed secrets in code, documentation examples, or client-visible payloads.
- Audit changes to credentials, tokens, and integration permissions where feasible.

## Retries, timeouts, and idempotency guidance
- Define timeouts and fallback behavior per integration based on consumer sensitivity and data freshness needs.
- Use idempotent ingestion patterns for event replay, batch reprocessing, and catalog synchronization.
- Apply retry policies that distinguish transient failures from structural contract issues.
- Record failure outcomes with enough context to support operational recovery.

## Observability expectations
- Monitor integration health, latency, throughput, freshness, and error rates.
- Log contract mismatches and dropped records in a diagnosable way.
- Preserve traceability from upstream ingestion through downstream recommendation delivery.
- Alert on failures that materially affect recommendation correctness, freshness, or surface availability.

## Dependency management expectations
- Document each integration's owner, source of truth, contract type, and failure impact.
- Version integration contracts when a consumer or producer cannot safely absorb breaking changes.
- Avoid coupling channel rollout to dependencies that are not required for the target phase.
- Validate sandbox or staging behavior before enabling production traffic for new consumers.
