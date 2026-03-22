# Sub-feature capability: Canonical Catalog Identity And Mapping

**Parent feature:** `Catalog and product intelligence`  
**Parent feature file:** `docs/features/catalog-and-product-intelligence.md`  
**Parent feature priority:** `P0`  
**Sub-feature directory:** `docs/features/sub-features/catalog-and-product-intelligence/`  
**Upstream traceability:** `docs/features/catalog-and-product-intelligence.md`; `docs/features/feature-spec-index.md`; `docs/project/business-requirements.md` (BR-008, BR-004); `docs/project/data-standards.md`; `docs/project/glossary.md`; `docs/features/open-decisions.md` (`DEC-014`, `DEC-015`, `DEC-016`, `DEC-017`)  
**Tracked open decisions:** `DEC-014`, `DEC-015`, `DEC-016`, `DEC-017`

---

## 1. Purpose

Provide one stable, recommendation-safe identity plane for products, variants, looks, and compatibility references across PIM, commerce, DAM, and curation sources.

This capability exists to prevent every downstream system from inventing its own product identity logic. It guarantees that recommendation decisioning, delivery, explainability, analytics, and operator tooling all refer to the same canonical entities and can reconstruct how each source record was mapped.

## 2. Core Concept

Canonical catalog identity is an identity graph plus deterministic mapping policy:

`source record -> source normalization -> canonical match/create -> provenance + confidence -> canonical entity + mapping history`

The module owns:

- canonical IDs for product and variant entities
- source-to-canonical mapping lineage
- field-level provenance and conflict state
- merge/split handling for wrongly linked entities

The module does **not** own final readiness eligibility thresholds (DEC-015), freshness windows (DEC-016), or CM minimum readiness policy (DEC-017). It emits the normalized identity and evidence those capabilities depend on.

## 3. User Problems Solved

| User / stakeholder | Problem | Capability outcome |
| --- | --- | --- |
| Recommendation service owners | Candidate generation breaks when sources disagree on IDs | All candidate services resolve through one canonical product and variant keyspace |
| Ecommerce and channel teams | Surface teams create local ID translation hacks | Shared API and events remove per-surface identity forks |
| Merchandising operators | Cannot explain why one source update did not appear downstream | Mapping lineage and conflict queues show source precedence and unresolved discrepancies |
| Analytics and experimentation | Metrics split across duplicate product identities | Canonical IDs make recommendation set, impression, and outcome joins reliable |
| Explainability / support | Traces cannot reconstruct source truth at decision time | Mapping version and source lineage are queryable in trace context |
| Architecture / governance | Upstream source precedence is implicit and brittle | Policy-versioned precedence and conflict handling are explicit (DEC-014) |

## 4. Trigger Conditions

- New product or variant payload from PIM, commerce, DAM, compatibility graph, or look-authoring source
- Change to source identifiers, lifecycle state, or identity-critical attributes
- New mapping policy version or precedence configuration rollout
- Operator merge/split or conflict-resolution action
- Replay/backfill run for source correction or incident recovery
- Downstream request for canonical lookup by source ID

## 5. Inputs

- Source payloads with product/variant identifiers and identity evidence
- Source namespace metadata (`pim`, `commerce`, `dam`, `curation`, etc.)
- Identity-critical attributes (brand, style code, season, mode, option dimensions, region where relevant)
- Current mapping policy (`policyVersionId`) including precedence and matching strategy
- Existing canonical entities and mapping history
- Operator resolution actions for previously blocked conflicts

## 6. Outputs

- `canonicalProductId` and `canonicalVariantId` for resolved records
- Source mapping records with confidence, provenance, and validity windows
- Conflict records where deterministic mapping cannot be safely completed
- Mapping change events for downstream projections and cache invalidation
- Queryable lineage model used by explainability, support, and governance workflows

## 7. Workflow / Lifecycle

1. **Ingest + normalize source identity**
   - Validate source namespace and source-local IDs.
   - Normalize identity-critical fields into canonical schema.
2. **Attempt deterministic resolution**
   - Resolve via existing active mapping first.
   - If missing, evaluate match strategy (exact keys -> constrained heuristic -> conflict).
3. **Create or link canonical entity**
   - Create new canonical product/variant if no safe match exists.
   - Link source record to canonical entity when confidence meets policy.
4. **Persist lineage**
   - Write mapping with `effectiveFrom/effectiveTo`, confidence, evidence, and `policyVersionId`.
   - Store field-level provenance for identity-critical attributes.
5. **Handle unresolved states**
   - Emit conflict case when multiple possible matches or contradictory source evidence exists.
   - Keep record in `PENDING_REVIEW` or `BLOCKED` instead of force-linking.
6. **Publish downstream updates**
   - Emit mapping events and trigger projection refresh.
   - Expose canonical lookup and lineage APIs.

### Lifecycle states (mapping record)

`DISCOVERED -> LINKED_PENDING_VERIFICATION -> ACTIVE -> SUPERSEDED | CONFLICTED -> RETIRED`

## 8. Business Rules

- Canonical IDs are immutable once issued; corrections happen by remapping/superseding, not ID reuse.
- One source ID in one namespace maps to at most one active canonical entity at a time.
- Mapping must preserve temporal validity (`effectiveFrom`, `effectiveTo`) to support replay and trace reconstruction.
- Field conflicts across sources must be explicit and auditable; never silently discard disagreement.
- Source-of-truth precedence must be policy-driven and versioned; do not hard-code precedence in consumers (`DEC-014`).
- RTW and CM mode identity must remain explicit. Similar style codes across modes are related but not implicitly identical.
- Curated look membership and compatibility edges must reference canonical IDs, not raw source IDs.
- Unknown identity confidence must default to safe behavior (conflict/pending) rather than speculative auto-merge.
- This sub-feature cannot locally resolve DEC-015/016/017; it only provides identity/evidence inputs those decisions require.

## 9. Configuration Model

`IdentityMappingPolicy` should include:

- `policyVersionId`
- `sourcePrecedence` (ordered by field group and source namespace)
- `matchStrategies` (exact keys, constrained fuzzy keys, disallowed heuristics)
- `confidenceThresholds` (`AUTO_LINK`, `REVIEW_REQUIRED`, `REJECT`)
- `modeSeparationRules` (`RTW`, `CM`, mixed-mode handling)
- `mergeSplitPermissions` by role
- `conflictEscalationSLA` and queue routing
- `replayBehavior` for backfills and historical corrections

All configuration updates must be versioned and auditable because mapping policy directly affects recommendation quality and traceability.

## 10. Data Model

### Core entities

| Entity | Purpose | Required fields |
| --- | --- | --- |
| `CanonicalProduct` | Canonical parent identity | `canonicalProductId`, `mode`, `status`, `createdAt`, `updatedAt` |
| `CanonicalVariant` | Sellable/configurable child identity | `canonicalVariantId`, `canonicalProductId`, option dimensions, `status` |
| `SourceProductMapping` | Product-level source linkage | `sourceNamespace`, `sourceProductId`, `canonicalProductId`, `confidence`, `effectiveFrom`, `effectiveTo`, `policyVersionId` |
| `SourceVariantMapping` | Variant-level source linkage | `sourceNamespace`, `sourceVariantId`, `canonicalVariantId`, `confidence`, validity window |
| `IdentityEvidence` | Evidence used for linking decisions | key/value evidence set, source timestamps, normalization hash |
| `MappingConflictCase` | Unresolved or risky link decision | `conflictId`, competing candidates, `reasonCode`, `state`, `assignedTo` |
| `MappingChangeLog` | Append-only history for audit/replay | actor/system, action type, before/after references, timestamp |

### Example mapping record

```json
{
  "sourceNamespace": "commerce",
  "sourceProductId": "SKU_PARENT_4451",
  "canonicalProductId": "prd_01JPDW47Q3NRC8JHSC9W4M8AEV",
  "confidence": "HIGH",
  "evidence": {
    "brand": "example-brand",
    "styleCode": "A-1942",
    "mode": "RTW"
  },
  "policyVersionId": "identity_policy_v7",
  "effectiveFrom": "2026-03-22T09:15:00Z",
  "effectiveTo": null
}
```

## 11. API Endpoints

Illustrative contract surfaces:

- `POST /catalog/identity/resolve`
  - Resolve source payload to canonical product/variant IDs
- `GET /catalog/identity/products/{canonicalProductId}`
  - Fetch canonical entity and source mappings
- `GET /catalog/identity/lookup?sourceNamespace=...&sourceId=...`
  - Reverse lookup by source ID
- `POST /catalog/identity/conflicts/{conflictId}/resolve`
  - Operator/system resolution action (merge, split, reject link)
- `POST /catalog/identity/replay`
  - Controlled replay for correction/backfill workflows

Required response concepts:

- canonical IDs
- mapping confidence + reason codes
- source lineage and policy version
- conflict status when unresolved

## 12. Events Produced

- `catalog.identity.resolved`
- `catalog.identity.created`
- `catalog.identity.mapping.updated`
- `catalog.identity.conflict.detected`
- `catalog.identity.conflict.resolved`
- `catalog.identity.replayed`

## 13. Events Consumed

- `catalog.product.discovered`
- `catalog.product.updated`
- `catalog.variant.updated`
- `catalog.compatibility.updated`
- `catalog.look.membership.updated`
- `catalog.policy.identity.updated`
- `catalog.operator.mapping_resolution.requested`

## 14. Integrations

- PIM and commerce source systems for product/variant identity feeds
- DAM and curation systems for identity-adjacent references
- Compatibility/look-authoring systems for canonical edge references
- Readiness evaluation module (consumes canonical IDs and lineage)
- Market/channel/mode eligibility module (consumes canonical IDs)
- Shared delivery contracts and explainability services (consume mapping version and provenance)
- Governance/operator tooling for conflict review and merge/split controls

## 15. UI Components

- **Mapping conflict queue table** (source IDs, candidate canonical IDs, confidence, reason codes)
- **Entity lineage timeline** (source links and supersession history)
- **Merge/split preview panel** (impact before commit)
- **Policy version badge + diff viewer** (which mapping policy was applied)
- **Source lookup widget** (source ID -> canonical ID quick check)

## 16. UI Screens

- **Catalog Identity Console** - operational overview of mapping health
- **Conflict Triage Screen** - review and resolve ambiguous mappings
- **Canonical Entity Detail** - canonical product/variant plus full source lineage
- **Replay and Correction Screen** - controlled reprocessing and audit trail

## 17. Permissions & Security

- Only service principals and authorized catalog operators can create/modify mappings.
- Merge/split and policy overrides require elevated role and explicit audit annotation.
- Read APIs may be broader, but sensitive source internals must be role-filtered.
- Every mapping mutation must log actor, reason, timestamp, and before/after linkage.
- No customer PII is required for this capability; enforce product-data-only boundaries.

## 18. Error Handling

- Return structured validation errors for missing namespace/IDs or schema violations.
- Return deterministic conflict responses when safe matching is impossible.
- Distinguish:
  - `INVALID_INPUT` (malformed payload),
  - `NO_MATCH` (safe create-or-review decision),
  - `AMBIGUOUS_MATCH` (conflict queue),
  - `POLICY_BLOCKED` (policy disallows auto-link),
  - `DEPENDENCY_UNAVAILABLE` (temporary retry path).
- Never silently fallback to low-confidence auto-linking.
- Preserve idempotency keys for retried ingestion requests.

## 19. Edge Cases

- Same source ID reused by upstream system after archival (must use validity windows, not overwrite history)
- Parent product match is clear, but variant option mapping is ambiguous
- Source correction arrives out of order and appears older than current mapping
- RTW and CM share style code but should remain separate canonical products
- One source deletes item while another still marks active; mapping remains active but conflict flagged
- Manual merge later requires split rollback because initial evidence was wrong
- Replay run under new policy version changes confidence outcome for historical records

## 20. Performance Considerations

- Keep source-ID lookup latency low with dedicated indexes on `(sourceNamespace, sourceId, effectiveTo)`.
- Separate hot read path (lookup/projection) from heavier reconciliation path (merge/split/replay).
- Use incremental event-driven updates for normal ingestion; reserve full replay for controlled batches.
- Ensure conflict queue operations do not block safe deterministic mappings.
- Size mapping history retention to support audit/replay needs from BR-008 and trace requirements.

## 21. Observability

Track at minimum:

- mapping resolution throughput and latency
- auto-link vs review-required rates
- conflict rate by source namespace and category
- merge/split frequency and rollback frequency
- idempotency conflict rate
- replay backlog and replay success rate

Operational logs should include:

- `canonicalProductId` / `canonicalVariantId`
- source namespace and source ID
- `policyVersionId`
- mapping decision reason code
- correlation IDs used by downstream trace systems

## 22. Example Scenarios

### Scenario A: New product appears in PIM then commerce

1. PIM sends product + variants with internal IDs.
2. Identity resolver creates canonical product and variant IDs.
3. Commerce payload arrives with different source IDs but matching evidence.
4. Resolver links commerce IDs to existing canonical entities.
5. `catalog.identity.mapping.updated` is emitted; downstream readiness projection updates.

### Scenario B: Ambiguous source update triggers conflict

1. DAM payload references style code matching two canonical products.
2. Confidence does not meet `AUTO_LINK` threshold.
3. Resolver emits `catalog.identity.conflict.detected` and creates conflict case.
4. Operator reviews evidence and resolves with merge/split action.
5. Resolution event updates downstream lineage and trace context.

### Illustrative resolve response

```json
{
  "requestId": "req_01JPDX5HEM7B6Q5SFTTV9ED9QW",
  "result": "resolved",
  "canonicalProductId": "prd_01JPDW47Q3NRC8JHSC9W4M8AEV",
  "canonicalVariantId": "var_01JPDW4V07T4R8DV6JMY8SPW2G",
  "mappingConfidence": "HIGH",
  "policyVersionId": "identity_policy_v7",
  "reasonCodes": ["exact_style_code_match", "mode_match_rtw"]
}
```

## 23. Implementation Notes

- Implement as a dedicated identity-mapping module under `catalog-and-product-intelligence`; do not embed mapping logic in ranking or UI services.
- Prefer append-only change logs plus effective-dated active mapping views.
- Keep merge/split actions explicit commands with compensating actions (undo path), not direct row edits.
- Treat precedence policy as data/configuration, not static code constants (`DEC-014` dependency).
- Publish stable canonical IDs and mapping metadata required by readiness/eligibility modules (`DEC-015`/`DEC-016`/`DEC-017` dependencies).
- Ensure compatibility/look references are rewritten to canonical IDs at ingestion boundaries.

Implementation implications:

- **Backend services:** identity resolver, conflict manager, replay worker
- **Storage:** canonical entities, mapping tables, conflict queue, append-only changelog
- **Jobs/workers:** reconciliation worker, replay/backfill worker, projection invalidation worker
- **External APIs:** source ingestion adapters for PIM/commerce/DAM/curation
- **Operator tooling:** conflict triage UI and lineage explorer

## 24. Testing Requirements

- **Unit tests**
  - exact/heuristic matching behavior
  - confidence threshold transitions
  - mode separation and merge/split command validation
- **Contract tests**
  - resolve/lookup API schemas
  - mapping/conflict event payload schema and version compatibility
- **Integration tests**
  - PIM + commerce dual-source linking
  - conflict creation and operator resolution flow
  - replay behavior under policy-version changes
- **Data integrity tests**
  - one-active-mapping invariant per source namespace + source ID
  - effective-date validity and supersession correctness
- **Performance tests**
  - high-volume source ingestion and lookup latency under load
  - replay batch processing impact on online resolution
- **Audit/security tests**
  - role enforcement for merge/split operations
  - immutable audit trail and traceability of mapping decisions
