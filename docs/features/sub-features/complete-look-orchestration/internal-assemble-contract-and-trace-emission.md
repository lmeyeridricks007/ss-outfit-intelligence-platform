# Sub-feature capability: Internal Assemble Contract And Trace Emission

**Parent feature:** `Complete-look orchestration`  
**Parent feature file:** `docs/features/complete-look-orchestration.md`  
**Parent feature priority:** `P1`  
**Sub-feature directory:** `docs/features/sub-features/complete-look-orchestration/`  
**Upstream traceability:** `docs/features/complete-look-orchestration.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-001, BR-002, BR-005, BR-008, BR-011); `docs/project/glossary.md` (`look` vs `outfit`); `docs/project/data-standards.md`; `docs/features/open-decisions.md` (`DEC-018`, `DEC-019`, `DEC-020`)  
**Tracked open decisions:** `DEC-018`, `DEC-019`, `DEC-020`

---

## 1. Purpose

Define the internal contract that represents a completed outfit assembly and emit deterministic trace events for every significant assembly outcome.

This capability ensures downstream systems consume a canonical, grouped `outfit` representation with stable IDs (`recommendationSetId`, `traceId`), slot lineage, degradation metadata, and policy context. It prevents delivery, analytics, and explainability teams from reconstructing outfit semantics from ad hoc item lists.

## 2. Core Concept

`Internal Assemble Contract And Trace Emission` is the handoff boundary between outfit assembly logic and downstream consumers. It standardizes:

1. the internal assembly payload shape (what was assembled)
2. lineage and rationale metadata (why it was assembled that way)
3. lifecycle events (when state changed and what consumers should react to)

The capability is internal-facing. Customer-facing contracts remain owned by shared delivery APIs, but they must be derivable from this internal payload without losing grouped outfit meaning.

## 3. User Problems Solved

- **Backend/API teams:** get one canonical assembly payload instead of surface-specific payload variants.
- **Analytics teams:** receive stable correlation keys and reason codes to join impression-to-outcome telemetry.
- **Explainability/support teams:** can reconstruct slot decisions, substitutions, and degraded outcomes.
- **Merchandising/governance teams:** can audit how curated, rule-based, and generated candidates contributed to final output.

## 4. Trigger Conditions

- An assembly reaches a terminal serving state: `assembled`, `degraded`, or `suppressed`.
- An assembly changes state after a policy or inventory refresh requiring re-publication.
- A replay/backfill process rebuilds assembly output for trace or analytics consistency.
- A downstream consumer requests assembly details by `traceId` for support or diagnostics.

## 5. Inputs

Required inputs:

- normalized request context (`requestId`, `surface`, `placement`, `market`, `mode`, trigger type)
- mission context (anchor product or occasion intent resolution)
- selected template and slot requirements
- final slot assignments including optional-slot outcomes
- policy snapshot (`policyVersion`) and governance context (rule/campaign references)
- source-mix and lineage (`curated`, `rule-based`, `AI-ranked`, generated fills)
- stable identifiers (`recommendationSetId`, `traceId`)

Optional inputs:

- experiment and variant context
- bounded customer/profile context for internal debugging (role-gated)
- projection or snapshot IDs used in assembly

## 6. Outputs

Primary outputs:

- `OutfitAssemblyContract` record for downstream delivery mapping
- `AssemblyTraceSummary` for explainability and support tooling
- lifecycle events (`outfit.assembly.*`) for analytics and async processors

Each output must carry enough context to answer:

- what outfit was assembled
- whether it was degraded or suppressed
- which slot-level decisions were made
- which policy and data snapshots were applied

## 7. Workflow / Lifecycle

1. Receive completed assembly plan from upstream orchestration stages.
2. Materialize internal contract with grouped slots, source lineage, and IDs.
3. Validate contract invariants (identifier presence, slot-label coherence, policy linkage).
4. Persist versioned contract snapshot and trace summary.
5. Emit one terminal lifecycle event:
   - `outfit.assembly.completed` when full acceptable composition is produced
   - `outfit.assembly.degraded` when fallback policy was applied
   - `outfit.assembly.suppressed` when no safe outfit should be delivered
6. Publish trace metadata for downstream joins and operator retrieval.
7. Support idempotent re-emission for replay/backfill without generating duplicate semantic outcomes.

## 8. Business Rules

- `look` (internal grouping) and `outfit` (customer-facing grouped answer) semantics must stay explicit and non-interchangeable.
- Every emitted assembly outcome must include both `recommendationSetId` and `traceId`.
- Degraded outcomes are valid only when policy says the result is still an honest complete-look answer (`DEC-019`).
- Suppressed outcomes must emit explicit machine-readable reason codes (for example, template miss, required-slot failure, hard governance block).
- Slot-level lineage must identify source type per member (`anchor`, `curated`, `rule_fill`, `generated_fill`, `substitute`).
- Contract schema evolution must be versioned; downstream consumers must never infer behavior from field order or optional omission.
- Open decisions remain unresolved here and must not be silently fixed by this document:
  - `DEC-018` mandatory vs optional slot composition by context
  - `DEC-019` substitution vs omission boundaries
  - `DEC-020` multi-anchor mission resolution policy

## 9. Configuration Model

| Key | Purpose |
| --- | --- |
| `enabled` | Enable capability per environment. |
| `contractSchemaVersion` | Internal payload schema version. |
| `eventSchemaVersion` | Lifecycle event payload schema version. |
| `traceEmissionEnabled` | Toggle trace event emission independently of assembly persistence. |
| `traceRetentionClass` | Select retention policy profile for persisted trace detail. |
| `surfaceModePolicyRef` | Resolve market/channel/surface/mode-specific rules used at assembly time. |
| `idempotencyWindow` | Deduplication window for replay and repeated emissions. |

All config keys should be versioned and auditable so support teams can reconstruct behavior by policy snapshot.

## 10. Data Model

Core entities:

1. `OutfitAssemblyContract`
   - `assemblyId`
   - `recommendationSetId`
   - `traceId`
   - `requestContext`
   - `templateId`
   - `slots` (required and optional with explicit labels)
   - `degradation` (`null` for non-degraded)
   - `sourceMix[]`
   - `policyVersion`
   - `createdAt`
2. `SlotLineageRecord`
   - `assemblyId`
   - `slotName`
   - `productId`
   - `sourceType`
   - `candidateRef`
   - `substitutionReasonCode` (nullable)
3. `AssemblyTraceSummary`
   - `traceId`
   - `assemblyId`
   - `resultState` (`completed|degraded|suppressed`)
   - `reasonCodes[]`
   - `ruleContext[]`
   - `experimentContext` (nullable)
4. `AssemblyLifecycleEvent`
   - `eventId`
   - `eventType`
   - `eventVersion`
   - `occurredAt`
   - `traceId`
   - `recommendationSetId`
   - `payload`

Identifier and event field expectations align with `docs/project/data-standards.md`.

## 11. API Endpoints

Illustrative internal endpoints (non-customer-facing):

- `POST /internal/outfit-assemblies`  
  Persist and publish assembly contract for a resolved orchestration run.
- `GET /internal/outfit-assemblies/{assemblyId}`  
  Retrieve versioned contract snapshot.
- `GET /internal/traces/{traceId}/outfit-assembly`  
  Retrieve trace summary and slot lineage for diagnostics.

Illustrative write request shape:

```json
{
  "requestId": "REQ-20091",
  "assemblyId": "ASM-88431",
  "recommendationSetId": "RS-9001",
  "traceId": "TR-12345",
  "contractSchemaVersion": "1.0",
  "policyVersion": "pol-2026-03-22",
  "resultState": "degraded"
}
```

Final transport and governance details depend on architecture-stage resolution, but payload semantics above are required.

## 12. Events Produced

Primary lifecycle events:

- `outfit.assembly.completed`
- `outfit.assembly.degraded`
- `outfit.assembly.suppressed`
- `outfit.trace.published`

Required event payload fields (where applicable):

- `eventId`, `eventType`, `eventVersion`, `occurredAt`
- `traceId`, `recommendationSetId`, `assemblyId`
- `surface`, `channel`, `recommendationType` (`outfit`)
- `resultState`, `reasonCodes[]`
- `ruleContext`, `experimentContext` (if present)

These fields allow deterministic joins to recommendation outcome telemetry events (`impression`, `click`, `add-to-cart`, `purchase`, and others).

## 13. Events Consumed

- `outfit.intent.resolved`
- `outfit.template.selected`
- `outfit.slot.fill.completed`
- `outfit.validation.completed`
- `outfit.fallback.applied`
- `catalog.eligibility.changed` (for replay/rebuild paths)

Consumed events should include enough correlation metadata to avoid ambiguous assembly reconstruction.

## 14. Integrations

- **Complete-look orchestration module:** receives final assembly decisions.
- **Shared contracts and delivery API:** maps internal contract to customer-facing response.
- **Explainability and auditability:** consumes trace summaries and lineage records.
- **Analytics and experimentation:** consumes lifecycle events for outcome analysis.
- **Merchandising governance:** receives rule/campaign context and override reasons.
- **Catalog/product intelligence:** provides eligibility and inventory context used in reason codes.
- **RTW/CM mode support:** drives mode-specific composition behavior and trace labeling.

## 15. UI Components

Operator/support-facing components that consume this capability:

- assembly trace timeline panel
- slot lineage table
- degraded/suppressed reason badge set
- policy snapshot summary card

No customer-facing component should render internal-only sensitive fields from this contract directly.

## 16. UI Screens

- support trace inspection screen (`traceId` lookup)
- merchandising diagnostics view (grouped outfit validation details)
- internal QA/replay screen for assembly-state comparison across policy versions

## 17. Permissions & Security

- Write endpoints are service-to-service only; no direct customer-client write access.
- Read access is role-gated:
  - support roles: summary + bounded lineage
  - governance roles: summary + rule context
  - engineering/on-call: full technical trace where policy permits
- Sensitive customer/profile context must be redacted from non-authorized views.
- Access to trace retrieval endpoints must be logged with actor, purpose, and timestamp.
- Retention and deletion behavior must respect regional/privacy policy from canonical project standards.

## 18. Error Handling

- Validation failures return structured error codes (`INVALID_SCHEMA`, `MISSING_ID`, `UNSUPPORTED_VERSION`).
- Idempotency conflicts return deterministic outcomes (`DUPLICATE_EVENT_IGNORED`) rather than hard failures where safe.
- Persistence failures should not silently drop events; the system must retry or dead-letter with correlation IDs.
- Event publish failures must preserve a replay path from persisted contract state.
- Partial success (contract persisted but event not emitted) must be observable and recoverable.

## 19. Edge Cases

- **Replay after policy update:** old assembly contracts must remain queryable with original policy version context.
- **Out-of-order event arrival:** consumer side must handle state transitions without regressing final state.
- **Duplicate emission attempts:** same semantic assembly event should not create duplicate downstream metrics.
- **Suppressed-with-trace:** even when no outfit is delivered, trace output must still support diagnostics.
- **Schema drift during rollout:** producer and consumer versions overlap during migration windows.

## 20. Performance Considerations

- Emission path should add minimal latency to serving-critical orchestration completion.
- Prefer append-only trace/event writes for high-throughput reliability.
- Keep trace summaries query-optimized (`traceId`, `recommendationSetId`, `assemblyId` indexes).
- Batch non-critical enrichment asynchronously to keep synchronous path lean.
- Monitor replay backlog to avoid delayed analytics consistency after partial outages.

## 21. Observability

Minimum metrics:

- `assembly_contract_write_total`
- `assembly_event_emit_total` by `eventType`
- `assembly_event_emit_failure_total`
- `assembly_degraded_rate`
- `assembly_suppressed_rate`
- `assembly_replay_lag_seconds`

Minimum structured logs/traces:

- include `traceId`, `recommendationSetId`, `assemblyId`, `policyVersion`, `eventType`
- include reason codes for degraded/suppressed outcomes
- include idempotency decisions and retry outcomes

Alerting recommendations:

- spike in suppressed rate by surface/mode
- sustained event emit failures
- replay lag beyond configured threshold

## 22. Example Scenarios

### Scenario A: Happy-path completed outfit

1. Orchestration finalizes a non-degraded outfit assembly.
2. Contract is persisted with required IDs and slot lineage.
3. `outfit.assembly.completed` and `outfit.trace.published` are emitted.
4. Delivery, analytics, and support systems consume correlated data.

### Scenario B: Degraded but valid output

1. One optional slot cannot be filled under current inventory constraints.
2. Policy allows omission; contract sets `resultState=degraded` with reason code.
3. `outfit.assembly.degraded` is emitted and tied to downstream outcomes.

### Illustrative internal contract payload

```json
{
  "assemblyId": "ASM-88431",
  "recommendationSetId": "RS-9001",
  "traceId": "TR-12345",
  "recommendationType": "outfit",
  "templateId": "tpl-pdp-suit-v3",
  "resultState": "degraded",
  "reasonCodes": ["OPTIONAL_SLOT_OMITTED"],
  "slots": {
    "anchor": { "productId": "P-001", "sourceType": "anchor" },
    "shirt": { "productId": "P-210", "sourceType": "curated" },
    "tie": { "productId": "P-330", "sourceType": "rule_fill" }
  },
  "optionalSlots": {
    "belt": null
  },
  "policyVersion": "pol-2026-03-22",
  "contractSchemaVersion": "1.0"
}
```

## 23. Implementation Notes

- Implement as a dedicated internal module in the complete-look orchestration service boundary.
- Keep write-path idempotent using deterministic keys (for example: `assemblyId + resultState + eventVersion`).
- Persist contract snapshot before publishing lifecycle events to enable replay safety.
- Use append-only event/outbox pattern to decouple persistence and event transport reliability.
- Store slot lineage at write time; avoid reconstructing lineage from transient ranking payloads later.
- Ensure internal schema and event schema versions can evolve independently with compatibility guards.
- For integration with analytics, guarantee stable mapping from assembly events to recommendation telemetry identifiers from `data-standards.md`.

Implementation implications by layer:

- **Backend services:** assembly contract writer, trace summary generator, event publisher, replay handler.
- **Storage:** versioned contract table/document, slot lineage table, event outbox/dead-letter support.
- **Jobs/workers:** replay job, dead-letter reprocessor, summary backfill worker.
- **APIs:** internal read/write + trace retrieval endpoints only.
- **UI/internal tooling:** diagnostics views consume read models, never raw write-side logs.

## 24. Testing Requirements

- **Unit tests**
  - contract invariant validation
  - reason-code mapping for `completed|degraded|suppressed`
  - idempotency key behavior
- **Contract tests**
  - internal API request/response schema compatibility
  - event payload schema and required field presence
- **Integration tests**
  - end-to-end correlation: assembly output -> event -> analytics join keys
  - replay flow after simulated publish failure
  - role-based access control for trace retrieval
- **Regression tests**
  - schema version migration compatibility
  - out-of-order and duplicate event handling
  - degraded/suppressed path consistency by surface/mode
- **Performance tests**
  - write and emit throughput under hot-anchor traffic conditions
  - replay backlog drain within operational thresholds
