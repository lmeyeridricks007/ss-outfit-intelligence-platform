# Explainability and auditability

## Traceability / sources

| Kind | Reference |
|------|-----------|
| Canonical product | `docs/project/goals.md`, `docs/project/product-overview.md`, `docs/project/business-requirements.md` (BR-11), `docs/project/roadmap.md`, `docs/project/architecture-overview.md`, `docs/project/standards.md` |
| Business requirement | `docs/project/br/br-011-explainability-and-auditability.md` |
| Adjacent BR (governance, provenance) | `docs/project/br/br-009-merchandising-governance.md` |
| Adjacent BR (source blend, trace boundaries) | `docs/project/br/br-005-curated-plus-ai-recommendation-model.md` |
| Delivery & review | `docs/project/agent-operating-model.md`, `docs/project/review-rubrics.md` |
| Measurement overlap | `docs/project/br/br-010-analytics-and-experimentation.md` (shared IDs and experiment visibility; analytics does not replace operator trace UX) |

This feature deep-dive implements **BR-11** and **business-requirements.md §BR-11**. It must align with **BR-009** (governed-change audit history, linkage to live behavior) and **BR-005** (distinguishing curated, rule-based, AI-ranked, blended, and fallback paths in traces).

---

## 1. Purpose

Specify how the platform captures and surfaces a **recommendation decision trace**: enough structured provenance for internal operators to answer *why* a set was produced, *what* constrained it, *whether* experiments or governance intervened, and *how* to investigate incidents—while keeping **customer-facing explanations** within safe, respectful boundaries.

---

## 2. Core Concept

Explainability here is **operational and audit-oriented**, not model-card exhaustiveness. Each recommendation set carries a **trace spine**: identifiers, request/journey context, candidate **source families**, eligibility and governance signals, ranking/assembly mode, experiment variant, and **degraded-trace flags**. **Auditability** links that spine to **governed-change history** (who changed what, when, and why) for merchandising artifacts (BR-009).

---

## 3. Why This Feature Exists

Opaque recommendations erode trust, slow incident response, and hide governance or experiment effects. `docs/project/goals.md` operational goals require recommendations to be **auditable, observable, and safe**. `docs/project/architecture-overview.md` states the recommendation engine **preserves traceability** and API responses must carry **decision trace context**. BR-011 formalizes the business questions and layers that must remain reconstructable.

---

## 4. User / Business Problems Solved

- **Unexplainable outputs:** Teams cannot tell curated vs AI-ranked vs fallback behavior.
- **Slow incidents:** Debugging requires engineering log archaeology instead of operator tooling.
- **Invisible experiments:** Variants change behavior without durable visibility in traces.
- **Governance disconnect:** Overrides/campaigns affect live traffic without discoverable linkage to history.
- **Unsafe customer copy:** Risk of exposing sensitive profile reasoning on shopper-facing surfaces (`docs/project/business-requirements.md` §8).

---

## 5. Scope

**In scope:** Decision trace model, provenance fields, operator investigation workflows, governance linkage requirements, retention/retrieval expectations at a business level, and internal vs customer-facing explanation boundaries.

**Out of scope for this document:** Final admin UI pixel design, exact storage engine, full model interpretability (e.g., SHAP for every model), customer-facing marketing copy.

---

## 6. In Scope

- Set-level and result-level internal explanation (BR-011 §7).
- Traceable layers: request, sources, eligibility, ranking/assembly, experiments, governance (BR-011 §6).
- Audit trail for recommendation generation and **linkage** to governance change history (BR-011 §9).
- Progressive disclosure UX pattern for internal tools (BR-011 §10.2).
- Retention/retrieval expectations stated as business requirements pending legal policy (BR-011 §9.4).
- Quality measures for trace completeness (BR-011 §12.1).

---

## 7. Out of Scope

- Definitive multi-year legal retention schedules without policy input.
- Public customer explanation product copy (may be added later under separate spec).
- Low-level observability vendor selection.
- Detailed permission RBAC matrix (referenced as dependency).

---

## 8. Main User Personas

- **Merchandising & governance operators:** Validate curation, overrides, campaigns, protections.
- **Product, analytics, optimization:** Interpret performance with source and experiment context (handoff to BR-010 consumers).
- **Clienteling, stylists, support:** Investigate customer-visible mismatches with **summarized** internal context.
- **Platform & operations:** Diagnose trace breakage, stale inputs, fallback storms.
- **Policy / audit stakeholders:** Review material changes and evidence trails (with legal process).

---

## 9. Main User Journeys

1. **Set-level review:** Operator receives complaint or anomaly → looks up `recommendationSetId` / `traceId` → views concise summary (sources, governance, experiment, fallback) → decides whether to escalate.
2. **Result-level drill-down:** Operator inspects why item X appeared or candidate Y was excluded → sees eligibility/compatibility/inventory/policy flags at appropriate depth.
3. **Change-over-time comparison:** Compare two timestamps/variants → trace links to governance history entries (rule publish, override activation, experiment start).
4. **Incident triage:** Trace shows `degradedTrace` or missing provenance → operator routes to data freshness vs ranking vs delivery fault.
5. **Customer-safe explanation (future):** Shopper sees high-level styling rationale only; full trace remains internal (BR-011 §10.3).

---

## 10. Triggering Events / Inputs

- Each **recommendation request** to the delivery API (customer, anchor product, surface, channel, context).
- **Engine pipeline stages:** candidate retrieval, rule evaluation, ranking, assembly, post-processing overrides.
- **Governance system events:** publish, activate, deactivate, rollback of looks, rules, campaigns, overrides (BR-009).
- **Experiment service:** assignment and configuration snapshots referenced by trace.
- **Data freshness signals:** catalog/inventory/context staleness indicators when material (BR-011 §8.5).

---

## 11. States / Lifecycle

- **Trace completeness:** `complete`, `partial`, `degraded` (visible to operators per BR-011 §4.7, §8.5).
- **Recommendation mode:** `normal`, `fallback`, `emergency_override` (business labels; exact enum for implementation).
- **Governance object lifecycle:** `draft` → `scheduled` → `active` → `expired` / `rolled_back` — must be reconstructable in audit history (BR-011 §9.2).
- **Experiment state:** active vs historical must be visible on trace for post-hoc review.

---

## 12. Business Rules

- Internal explainability is **mandatory** even when customer-facing explanation is minimal (BR-011 §4.1).
- Traces must reflect the **blended path**, not only final items (BR-011 §4.2).
- **Experiments and fallbacks must never be invisible** (BR-011 §4.6).
- Hard constraints and policy boundaries **must be visible** when they drive exclusion or reordering (BR-011 §4.5, §11.3).
- Customer-facing surfaces **must not** expose sensitive profile reasoning or raw audit fields (BR-011 §11.9; `docs/project/standards.md` §9).
- Trace quality must be **measurable** (BR-011 §12.1, §11.10).

---

## 13. Configuration Model

- **Trace detail tiers** per role (summary vs extended vs engineering export).
- **Field allowlists** for customer-facing explanation templates (future).
- **Retention classes:** operational incident window vs policy audit window (durations TBD).
- **Redaction rules** for exports (PII, stylist notes) per region/consent.
- **Sampling / truncation limits** for very large candidate sets — must not hide material governance decisions (policy decision).

---

## 14. Data Model

**Logical entities:**

- **RecommendationTrace:** `recommendationSetId`, `traceId`, `timestamp`, `requestContext` (type, surface, channel, anchor, market, RTW/CM), `customerContext` (as permitted), `sourceProvenance` (families available vs contributed), `eligibilitySummary`, `rankingMode`, `assemblyNotes`, `experimentContext`, `governanceInfluence[]`, `dataQualityFlags`, `traceCompleteness`.
- **ResultTrace (per slot or item):** `productId`/`lookId`, `inclusionReason` (high-level), `exclusionReasons` for top suppressed candidates (bounded list), `boost/suppress` indicators.
- **GovernanceAuditRecord:** `objectType`, `objectId`, `actor`, `action`, `reason`, `scope`, `effectiveFrom`, `effectiveTo`, `version` (aligned with BR-009 themes).
- **TraceGovernanceLink:** joins trace to audit records that materially influenced that request.

Physical storage may combine document + relational indices; logical model is normative for feature design.

---

## 15. Read Model / Projection Needs

- **Operator trace view projection:** Denormalized read model for fast lookup by `recommendationSetId` / `traceId`.
- **Governance timeline projection:** Change history filtered by scope (market, surface, type).
- **Incident search:** Filters on degraded traces, missing experiment context, spike in fallback.
- **Analytics handoff:** Subset of trace fields exportable to BR-010 pipelines (IDs and modes, not necessarily full narrative).

---

## 16. APIs / Contracts

- **Delivery API response** includes a **trace handle** (`traceId`, `recommendationSetId`) and optionally a **compact trace summary** for internal consumers; external/public clients may receive handles only for support correlation, not full provenance (`docs/project/architecture-overview.md`).
- **Internal trace API:** `GET /traces/{id}` with role-gated detail levels.
- **Governance audit API:** `GET /governance/{objectType}/{id}/history` for linkage from trace UI.
- **Webhook or event:** Optional `RecommendationTraceRecorded` for async indexing (implementation choice).

---

## 17. Events / Async Flows

- **Trace persistence** after recommendation assembly, before or with response emission (latency budget TBD).
- **Governance change events** propagate to invalidate caches and annotate future traces (not retroactively rewrite past traces except via explicit correction workflow).
- **Async enrichment:** Late-arriving inventory freshness may append to trace with `lateEnrichment` flag.

---

## 18. UI / UX Design

- **Progressive disclosure:** Summary card → tabs for sources, eligibility, governance, experiment, data quality (BR-011 §10.2).
- **Operator-first language:** Business-meaningful labels; avoid raw model dumps by default.
- **Degraded trace banner:** Explicit when trace is partial or unsafe for strong conclusions (BR-011 §16 open questions on thresholds).
- **Customer-facing:** Only curated, non-sensitive copy; no internal IDs in shopper UI unless support workflow explicitly requires a minimal correlation code (product decision).

---

## 19. Main Screens / Components

- Trace lookup (by IDs, order id, session id where policy allows).
- Set summary panel with **source mode** and **governance/experiment chips**.
- Result table with expandable **inclusion/exclusion** reasons.
- Governance timeline side panel linked from trace.
- Compare view (two traces or two timestamps) for change diagnosis.
- Admin/settings: retention class viewer (read-only for most roles).

---

## 20. Permissions / Security Rules

- Role-gated access to **PII-bearing** trace fields (customer id, session linkage).
- Support vs merchandising vs engineer: differing depth; engineering export may include additional technical fields under audit logging.
- Customer-facing surfaces: strict redaction; internal-only identifiers removed.
- All trace access logged for sensitive roles (implementation detail, requirement at policy level).

---

## 21. Notifications / Alerts / Side Effects

- Alerts when **trace completeness** drops below threshold or **experiment context missing** while experiments active.
- Optional workflow integration: create investigation ticket prefilled with trace ID.

---

## 22. Integrations / Dependencies

- **Recommendation engine:** Emits structured trace payload; must not discard governance/experiment metadata.
- **Governance services (BR-009):** Source of truth for change history and object versions.
- **Experimentation:** Experiment IDs and variants consistent with BR-010 telemetry.
- **Identity service:** Confidence and consent flags for what may appear on trace.
- **Catalog/inventory/context services:** Freshness metadata for BR-011 §8.5.
- **Analytics (BR-010):** Consumes compatible identifiers; does not replace trace store.

---

## 23. Edge Cases / Failure Cases

- **Partial trace write failure:** Response still returns recommendations but marks `traceCompleteness=degraded`; alert fired.
- **Conflicting governance rules:** Trace summarizes **effective precedence** and cites winning rule ids.
- **Emergency override:** Visibly tagged distinct from normal governance (BR-011 §16).
- **Large candidate pools:** Truncation with explicit “N candidates summarized” indicator.
- **Cross-channel:** Same logical recommendation may have different presentation; trace preserves channel/surface-specific context (BR-011 §11.8).

---

## 24. Non-Functional Requirements

- **Latency:** Trace persistence must meet API SLO budgets; async enrichment acceptable for non-blocking fields if labeled.
- **Durability:** Traces and audit records durable enough for incident review and policy windows (exact SLA TBD).
- **Search performance:** p95 lookup targets for operator workflows (TBD).
- **Consistency:** Trace reflects decisions **as-of** request time; documented clock-skew handling.

---

## 25. Analytics / Auditability Requirements

- Explainability supplies **ground truth narrative** for operators; analytics (BR-010) measures outcomes. Shared IDs bind both worlds.
- Auditability requires **immutable governance history** for material changes and **linkage** from trace to history (BR-011 §9.3).
- Metrics: % traces with full provenance, time-to-diagnose incidents, rate of degraded traces (BR-011 §12).

---

## 26. Testing Requirements

- Golden-path tests: known input → expected trace summary fields.
- Governance linkage tests: published change appears on subsequent traces; rollback reflected.
- Experiment visibility tests: variant always present when experiment active.
- Redaction tests: customer-facing API responses exclude forbidden fields.
- Load tests on trace write path under campaign spikes.

---

## 27. Recommended Architecture

- **Trace builder** inside recommendation service (synchronous core) + **trace store** (document or wide-column) + **index** for lookup.
- **Governance audit service** as system of record; trace stores foreign keys only.
- **Internal GraphQL/BFF** for operator UI aggregation.
- **Retention jobs** per policy class with legal hold support.

---

## 28. Recommended Technical Design

- Structured trace JSON schema versioned (`traceSchemaVersion`).
- Normalized **enum** for source families and ranking modes to align analytics and UI.
- **Bounded** exclusion candidate list with scoring threshold for “near-miss” explanations to avoid noise.
- **Correlation IDs** propagated from ingress through engine for distributed tracing alignment.

---

## 29. Suggested Implementation Phasing

1. **Phase 1:** Set-level trace, source families, experiment + governance chips, degraded flags, basic internal lookup UI/API; governance history linkage for key object types.
2. **Phase 2:** Richer personalization/context provenance; better compare tooling; improved eligibility narratives.
3. **Phase 3:** Multi-channel operator maturity; deeper historical audit workflows; optional customer-safe explanation templates.

Matches BR-011 §13 and `docs/project/roadmap.md` governance/telemetry themes.

---

## 30. Summary

Explainability and auditability turn the blended recommendation model into something **operators can trust and review**. The design centers on a **versioned trace spine**, **governance linkage**, **visible experiments and fallbacks**, and **strict customer-facing boundaries**—fulfilling BR-011 while interoperating with analytics (BR-010) and governance (BR-009).

---

## 31. Assumptions

- Operators need **set- and result-level** answers even when shoppers see no rationale (BR-011 §15).
- Stable identifiers for looks, rules, campaigns, experiments, and recommendation sets are available across consumers (BR-011 §15).
- A dedicated **internal** audience will use trace tools; customers will at most see limited, non-sensitive explanations.
- Governance audit records can be trusted as **authoritative** for change history when linked from traces.
- Some trace detail may be **async-enriched** without blocking the shopper response, provided completeness flags are honest.

---

## 32. Open Questions / Missing Decisions

- **Minimum first operator view:** set-level only vs result-level in v1 (BR-011 §16).
- **Depth of ranking explanation** appropriate for non-technical users vs engineers (BR-011 §16).
- **Retention periods** for operational vs policy audit classes (BR-011 §16).
- **Role matrix** for trace detail tiers and exports (BR-011 §16).
- **Emergency vs normal governance** labeling rules and visibility (BR-011 §16).
- **Threshold** marking traces as incomplete/degraded for decision comparison (BR-011 §16).
- **Customer-facing explanation** product scope and copy governance process.
- **Cross-border** data residency implications for trace storage and export.
