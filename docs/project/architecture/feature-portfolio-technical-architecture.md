# Technical architecture: feature portfolio from features board

Trigger: issue-created automation from GitHub issue #202 (`workflow:architecture`).

## Purpose

Translate the feature portfolio in `boards/features.md` and `docs/features/` into implementation-oriented technical architecture items that can drive implementation planning without reinterpreting product intent.

## Inputs used

- `boards/features.md`
- `docs/features/*.md`
- `docs/project/architecture-overview.md`
- `docs/project/domain-model.md`
- `docs/project/api-standards.md`
- `docs/project/data-standards.md`
- `docs/project/standards.md`

## Shared architecture baseline

The portfolio uses one shared recommendation platform with explicit boundaries:

1. **Ingestion and normalization plane**: catalog, customer signal, and context ingestion into canonical IDs and projections.
2. **Decisioning plane**: eligibility, governance, and ranking over curated, rule-based, and AI-ranked sources.
3. **Delivery plane**: shared typed recommendation contract across ecommerce, email, and clienteling.
4. **Observation and governance plane**: analytics, experimentation, explainability, and auditable operator controls.

Cross-cutting invariants from project standards:

- Stable IDs for product, customer, look, rule, campaign, experiment, recommendation set, and trace.
- Recommendation type remains explicit (`outfit`, `cross-sell`, `upsell`, `style bundle`, `occasion-based`, `contextual`, `personal`).
- Public consumers never receive sensitive profile reasoning.
- Degraded and empty paths are first-class states, not hidden failures.

---

## ARCH-001 - Analytics and experimentation (Parent: FEAT-001)

**Component responsibilities:** Event collector; assignment service; attribution linker; semantic metrics service; alerting service.  
**Data flow:** Delivery response IDs -> impression/click/add-to-cart/purchase events -> enrichment -> warehouse -> metric projections.  
**API implications:** `POST /analytics/recommendation-events`, `GET /experiments/assignments/{key}`, metrics read API with recommendation dimensions.  
**Integration points:** Delivery API, ecommerce/clienteling/email producers, OMS order events, governance snapshot feed.  
**Risks/trade-offs:** Browser-only telemetry gaps; attribution ambiguity for delayed outcomes; event duplication during retries.  
**NFRs:** Idempotent ingestion, replay support, low-latency metric freshness, privacy-safe field masking.  
**Readiness criteria:** Canonical event schema versioned; assignment contract fixed; attribution confidence model documented.  
**Approval / milestone-gate notes:** No milestone gate; relies on explicit approval mode from board row.  
**Missing decisions:** `DEC-006`, `DEC-007`.

## ARCH-002 - Catalog and product intelligence (Parent: FEAT-003)

**Component responsibilities:** Catalog ingest adapters; normalization service; readiness evaluator; eligibility projection store.  
**Data flow:** PIM/commerce/inventory feeds -> canonical product projection -> readiness scoring -> serving projections for decisioning/delivery.  
**API implications:** Internal readiness read API by surface/type; catalog-change events with freshness metadata.  
**Integration points:** PIM, DAM, inventory, governance policy service, recommendation decisioning.  
**Risks/trade-offs:** Source precedence conflicts; stale inventory causing false-eligible candidates; mode-specific schema drift (RTW vs CM).  
**NFRs:** High freshness for sellability fields, deterministic precedence, auditable transformation lineage.  
**Readiness criteria:** Source precedence table ratified; readiness thresholds by surface codified; freshness policies enforceable.  
**Approval / milestone-gate notes:** No milestone gate.  
**Missing decisions:** `DEC-014`, `DEC-015`, `DEC-016`, `DEC-017`.

## ARCH-003 - Channel expansion: email and clienteling (Parent: FEAT-004)

**Component responsibilities:** Batch recommendation orchestrator; clienteling access gateway; channel packaging adapters.  
**Data flow:** Audience/customer context -> shared delivery contract -> channel packaging -> send/assist events -> analytics.  
**API implications:** Batch submit/status APIs, clienteling retrieval APIs with role-scoped metadata visibility.  
**Integration points:** CRM/ESP, clienteling tools, identity/profile, governance controls, analytics.  
**Risks/trade-offs:** Stale recommendations at send time; overexposure of internal trace detail to operators; channel-specific contract fork risk.  
**NFRs:** Strong authz for operator flows, freshness enforcement before send, parity with shared delivery taxonomy.  
**Readiness criteria:** Batch freshness policy agreed; role matrix for clienteling fields defined; telemetry parity tests passing.  
**Approval / milestone-gate notes:** Governance-sensitive channel; human review recommended for role/PII policies.  
**Missing decisions:** `DEC-010`, `DEC-011`, `DEC-023`, `DEC-031`.

## ARCH-004 - Complete-look orchestration (Parent: FEAT-005)

**Component responsibilities:** Intent resolver; template/slot engine; grouped outfit assembler; degradation controller.  
**Data flow:** Anchor/cart/occasion request -> candidate inputs from decisioning -> slot fill + validation -> grouped outfit response.  
**API implications:** Internal assemble contract returning grouped look members, slot roles, fallback reason codes.  
**Integration points:** Decisioning/ranking, catalog readiness, governance snapshots, delivery API.  
**Risks/trade-offs:** Weak slot coverage causing misleading "outfit" semantics; anchor ambiguity in cart flows; overaggressive fallback.  
**NFRs:** Deterministic grouped output, fast interactive execution for PDP/cart, explicit degraded markers.  
**Readiness criteria:** Slot completeness policy ratified; grouped payload contract fixed; fallback suppression thresholds defined.  
**Approval / milestone-gate notes:** No milestone gate.  
**Missing decisions:** `DEC-018`, `DEC-019`, `DEC-020`, `DEC-036`.

## ARCH-005 - Context engine and personalization (Parent: FEAT-006)

**Component responsibilities:** Context normalizer; precedence resolver; personalization eligibility evaluator; context snapshot emitter.  
**Data flow:** Weather/season/location/session inputs + profile summary -> normalized context -> eligibility envelope -> decisioning hints.  
**API implications:** Context snapshot contract; precedence policy projection APIs; personalization eligibility envelope schema.  
**Integration points:** External context providers, identity/profile, decisioning, governance, channel consumers.  
**Risks/trade-offs:** Conflicting context signals by market; over-personalization with weak identity confidence; policy drift across channels.  
**NFRs:** Graceful fallback when context unavailable, low-latency context resolution, policy version traceability.  
**Readiness criteria:** Precedence matrix documented; eligibility envelope approved; context snapshot IDs linked to trace model.  
**Approval / milestone-gate notes:** No milestone gate.  
**Missing decisions:** `DEC-008`, `DEC-009`, `DEC-021`.

## ARCH-006 - Customer signal ingestion (Parent: FEAT-007)

**Component responsibilities:** Signal collectors; canonical envelope normalizer; consent/policy gate; projection emitter; deletion/replay processor.  
**Data flow:** Commerce/browse/email/store signals -> canonical envelope -> consent+identity gating -> downstream projections + replay logs.  
**API implications:** Signal ingest contract; replay/deletion control APIs; downstream projection topics.  
**Integration points:** Commerce/OMS, CRM/email, clienteling notes, identity service, privacy controls, analytics.  
**Risks/trade-offs:** Policy non-compliance in cross-region use; replay inconsistency after revocation; noisy operator-entered signals.  
**NFRs:** Policy-safe activation, durable provenance, deterministic deletion propagation, replay idempotency.  
**Readiness criteria:** Consent matrix codified; envelope schema frozen; revocation/replay runbook approved.  
**Approval / milestone-gate notes:** Privacy-sensitive; human policy review recommended.  
**Missing decisions:** `DEC-021`, `DEC-022`, `DEC-023`, `DEC-024`.

## ARCH-007 - Ecommerce surface experiences (Parent: FEAT-009)

**Component responsibilities:** Placement registry; storefront recommendation adapter; typed module view-model mapper; telemetry/fallback emitter.  
**Data flow:** Surface request context -> shared delivery response -> module state machine (loading/ready/degraded/empty) -> interaction telemetry.  
**API implications:** Shared delivery request/refresh usage; optional placement-config read contract; telemetry fallback contract.  
**Integration points:** Delivery API, commerce cart APIs, analytics, complete-look orchestration, experiments.  
**Risks/trade-offs:** Generic carousel rendering that erodes type semantics; blocked browser telemetry; cart duplicate leakage.  
**NFRs:** Interactive performance, accessibility parity, reliable fallback telemetry, deterministic placement behavior.  
**Readiness criteria:** Typed UI contract tests passing; module state policy implemented; telemetry lineage fields end-to-end verified.  
**Approval / milestone-gate notes:** No milestone gate.  
**Missing decisions:** `DEC-002`, `DEC-004`, `DEC-005`, `DEC-006`, `DEC-016`.

## ARCH-008 - Explainability and auditability (Parent: FEAT-010)

**Component responsibilities:** Trace writer; trace index/search API; explanation view adapter; access-audit logger; redaction policy enforcer.  
**Data flow:** Decision/delivery events + governance snapshots -> trace store -> role-based retrieval and explanation views -> access audit.  
**API implications:** Trace lookup APIs, filtered explanation APIs, redaction-aware export endpoints.  
**Integration points:** Decisioning, delivery, governance controls, identity/role service, analytics.  
**Risks/trade-offs:** Overexposure of sensitive ranking rationale; weak trace retention governance; incomplete linkage to overrides/experiments.  
**NFRs:** Fast trace lookup, immutable linkage to recommendation sets, strict RBAC and redaction, auditable read access.  
**Readiness criteria:** Canonical trace schema approved; role matrix defined; retention and deletion interaction policy defined.  
**Approval / milestone-gate notes:** Governance/security sensitive; human approval path recommended for role policy.  
**Missing decisions:** `DEC-025`, `DEC-026`, `DEC-027`, `DEC-028`, `DEC-029`.

## ARCH-009 - Identity and style profile (Parent: FEAT-011)

**Component responsibilities:** Identity resolution engine; source mapping registry; style-profile projection service; activation envelope evaluator.  
**Data flow:** Source identifiers + customer signals -> canonical identity with confidence -> profile projections -> activation envelopes.  
**API implications:** Identity resolution confidence contract; profile read API with permitted domains; conflict-case review APIs.  
**Integration points:** Signal ingestion, decisioning/personalization, clienteling, privacy controls, analytics.  
**Risks/trade-offs:** False-positive identity merges; profile overreach across channels; stale ownership/suppression cues.  
**NFRs:** Deterministic confidence scoring, policy-bounded profile activation, strong conflict traceability.  
**Readiness criteria:** Confidence thresholds agreed; allowed profile domains by channel defined; conflict-review workflow specified.  
**Approval / milestone-gate notes:** Privacy-sensitive; human policy validation recommended.  
**Missing decisions:** `DEC-030`, `DEC-031`, `DEC-032`, `DEC-033`.

## ARCH-010 - Merchandising governance and operator controls (Parent: FEAT-012)

**Component responsibilities:** Rule/campaign service; approval workflow engine; snapshot publisher; rollback/emergency override controller.  
**Data flow:** Operator policy change -> approval workflow -> versioned snapshot -> decisioning/delivery consumption -> audit + analytics annotation.  
**API implications:** Rule CRUD with approval states; snapshot publish/retrieve APIs; rollback/emergency override endpoints.  
**Integration points:** Decisioning, delivery, explainability, analytics, operator identity/access systems.  
**Risks/trade-offs:** Overly permissive overrides destabilizing relevance; unclear dual-approval thresholds; stale snapshot propagation.  
**NFRs:** Deterministic precedence, auditable policy lifecycle, safe emergency controls with expiration.  
**Readiness criteria:** Approval-role matrix ratified; precedence semantics fixed; snapshot propagation latency budget set.  
**Approval / milestone-gate notes:** Governance control plane typically HUMAN_REQUIRED.  
**Missing decisions:** `DEC-034`, `DEC-035`, `DEC-036`.

## ARCH-011 - Open decisions lifecycle architecture (Parent: FEAT-013)

**Component responsibilities:** Decision registry maintenance process; dependency and stage-impact projection; reconciliation workflow.  
**Data flow:** Feature/architecture reviews identify unresolved decisions -> register update -> canonical-doc resolution -> downstream reconciliation updates.  
**API implications:** Documentation contract only (stable `DEC-###` references); optional machine-readable export later.  
**Integration points:** Feature specs, architecture docs, review artifacts, boards, canonical project docs.  
**Risks/trade-offs:** Decision drift across artifacts; unresolved blockers hidden in narrative; ID reuse causing traceability breaks.  
**NFRs:** Stable IDs, low-overhead maintenance, explicit owner and downstream impact per decision.  
**Readiness criteria:** Decision register linked by all architecture rows; resolution ownership clear; reconciliation process documented.  
**Approval / milestone-gate notes:** No technical gate; governance relies on disciplined artifact updates.  
**Missing decisions:** `DEC-013` (ID policy formalization), plus all unresolved `DEC-###` tracked in feature portfolio.

## ARCH-012 - Recommendation decisioning and ranking (Parent: FEAT-014)

**Component responsibilities:** Mission resolver; candidate enumerator; hard-filter and governance gate; ranking engine; deterministic post-processor.  
**Data flow:** Normalized request + candidate projections -> policy gates -> ranking objective by recommendation type -> ranked set + trace metadata.  
**API implications:** Internal decisioning contract (`decide(...) -> set[]`) consumed by delivery; policy snapshot references in outputs.  
**Integration points:** Catalog readiness, governance snapshots, context engine, identity/profile, analytics/trace systems.  
**Risks/trade-offs:** Unclear precedence between campaign/context/personalization on expansion surfaces; model timeout fallback quality.  
**NFRs:** Deterministic precedence, interactive latency support, reproducible traces, safe degraded outputs.  
**Readiness criteria:** Precedence stack approved; objective definitions per recommendation type finalized; fallback policy encoded.  
**Approval / milestone-gate notes:** No milestone gate.  
**Missing decisions:** `DEC-008`, `DEC-015`, `DEC-016`, `DEC-036`.

## ARCH-013 - RTW and CM mode support (Parent: FEAT-015)

**Component responsibilities:** Mode resolver; mode-aware eligibility validator; CM gating policy service; mode-sliced telemetry annotator.  
**Data flow:** Request mode + catalog/profile context -> mode-specific constraints -> decision/delivery path -> mode-aware telemetry.  
**API implications:** Mode field required in delivery and decisioning requests; CM validation result descriptors in responses/traces.  
**Integration points:** Catalog intelligence, governance controls, clienteling, decisioning, analytics.  
**Risks/trade-offs:** Premature CM self-service exposure; incompatible CM data quality in customer-facing flows.  
**NFRs:** Strong mode isolation, explicit fallback between modes, auditable mode-specific suppressions.  
**Readiness criteria:** RTW baseline paths fixed; CM gating thresholds approved; clienteling-assisted CM boundaries documented.  
**Approval / milestone-gate notes:** CM exposure often requires explicit human readiness checkpoint.  
**Missing decisions:** `DEC-012`, `DEC-017`, `DEC-036`.

## ARCH-014 - Shared contracts and delivery API (Parent: FEAT-016)

**Component responsibilities:** Request normalizer; contract validator/version manager; response packager; snapshot store; batch orchestrator.  
**Data flow:** Consumer request -> normalized context -> decision/orchestration calls -> typed envelope -> snapshot + telemetry linkage.  
**API implications:** Interactive and batch delivery APIs; contract version discovery; immutable snapshot retrieval; structured error/degradation envelopes.  
**Integration points:** Decisioning, complete-look orchestration, governance, identity, analytics, explainability, channel consumers.  
**Risks/trade-offs:** Contract fragmentation via channel-specific forks; stale batch payloads at send time; weak compatibility governance.  
**NFRs:** Version-safe evolution, low-latency interactive path, robust authz, immutable trace-linked snapshots.  
**Readiness criteria:** Contract baseline frozen for Phase 1; compatibility tests for consumers defined; freshness/degradation semantics finalized.  
**Approval / milestone-gate notes:** Contract changes should require explicit compatibility review.  
**Missing decisions:** `DEC-001`, `DEC-002`, `DEC-003`, `DEC-010`.

---

## Portfolio-level risks and trade-offs

1. **One shared contract vs channel-specific agility:** Shared contract reduces drift; trade-off is stricter version governance.
2. **Deterministic governance vs optimization freedom:** Safety and brand consistency reduce short-term model freedom.
3. **Fast interactive latency vs explainability depth:** Deep traces should be asynchronous and retrieval-based, not inline payload bloat.
4. **Freshness strictness vs availability:** Strong freshness may increase empty/degraded outcomes without robust fallback policy.

## Portfolio NFR baseline

- **Performance:** Interactive PDP/cart requests must support near-real-time usage; batch channel paths can accept longer latency.
- **Reliability:** Degraded/empty states are explicit and measured; retries and idempotency are mandatory for event and batch flows.
- **Security/privacy:** Role-scoped visibility, consent enforcement, and redaction across delivery, trace, and analytics.
- **Auditability:** Every recommendation set remains reconstructable through stable IDs, policy snapshots, and trace linkage.
- **Interoperability:** All consumers use canonical recommendation taxonomy and shared identifiers.

## Missing decisions summary

Architecture work is implementation-ready, but final hardening still depends on resolving high-impact decisions from `docs/features/open-decisions.md`, especially:

- Contract freeze and versioning (`DEC-001`, `DEC-003`)
- Interactive SLO/freshness constraints (`DEC-002`, `DEC-016`)
- Governance precedence and ordering freedom (`DEC-008`, `DEC-036`)
- Privacy/identity/trace policy boundaries (`DEC-021` to `DEC-033`)

