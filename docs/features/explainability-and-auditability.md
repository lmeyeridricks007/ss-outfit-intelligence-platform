# Feature: Explainability and auditability

**Upstream traceability:** `docs/project/business-requirements.md` (BR-011); `docs/project/br/br-011-explainability-and-auditability.md`, `br-009-merchandising-governance.md`, `br-010-analytics-and-experimentation.md`; `docs/project/data-standards.md`; `docs/project/standards.md`.

---

## 1. Purpose

Enable internal operators to reconstruct **why** a **recommendation set** was produced, which inputs and governance controls applied, and what changed over time—without exposing unsafe customer inference detail (BR-011).

## 2. Core Concept

**Trace layers**: request, input state, source provenance, governance, experiment, ranking/assembly, audit linkage (BR-011 table).

## 3. Why This Feature Exists

Blending curated, rules, AI, and campaigns fails operationally if support cannot diagnose surprises (`goals.md` explainability).

## 4. User / Business Problems Solved

- S2/S4 troubleshoot quality regressions.
- Compliance: bounded explanation depth.
- Faster incident recovery.

## 5. Scope

Trace capture, storage, retention policy requirements, operator UIs, APIs for lookup by **trace ID** / **recommendation set ID**, role-based detail. **Missing decisions:** retention durations; which fields customer-facing if any (`business-requirements.md` missing decision).

## 6. In Scope

- Minimum trace questions answerable per BR-011.
- Linkage to telemetry and governance audit history.
- Privacy-safe summaries for stylists vs engineers.

## 7. Out of Scope

Full model interpretability (SHAP on every score); legal ediscovery tooling.

## 8. Main User Personas

S2, S1, S4, support, privacy reviewers.

## 9. Main User Journeys

Customer complains → support enters trace ID → views governance + inputs summary → opens ticket to merchandising with evidence.

## 10. Triggering Events / Inputs

Each recommendation request completion emits trace package; governance changes emit audit records linked by snapshot IDs.

## 11. States / Lifecycle

`captured → indexed → retained → expired`; legal hold override.

## 12. Business Rules

- Distinguish curated vs rule-based vs **AI-ranked** vs fallback in summaries (`glossary.md`).
- Low-confidence identity visible in trace (BR-012).
- Overrides must appear in governance trace (BR-009).

## 13. Configuration Model

Retention by environment; role templates; field redaction maps per region.

## 14. Data Model

`RecommendationTrace` { traceId, recommendationSetIds[], requestContext, inputStateSummary, sourceProvenance[], governanceRefs[], experimentRefs[], rankingSummary, degradationFlags, catalogVersionId, governanceSnapshotId }.

## 15. Read Model / Projection Needs

Search index by product, customer id (access-controlled), campaign id, time range.

## 16. APIs / Contracts

Internal `GET /traces/{traceId}` with role-scoped views; support proxy integration.

## 17. Events / Async Flows

Trace write async to store; optional export to SIEM.

## 18. UI / UX Design

Layered disclosure UI: summary → governance tab → technical JSON for engineers.

## 19. Main Screens / Components

Trace viewer, audit timeline, diff viewer for governance changes, export bundle.

## 20. Permissions / Security Rules

Strict RBAC; mask sensitive profile features; log all trace views (meta-audit).

## 21. Notifications / Alerts / Side Effects

Optional alerts on trace write failures (must not block customer response—**policy missing decision**).

## 22. Integrations / Dependencies

Delivery API, decisioning, governance service, analytics pipeline.

## 23. Edge Cases / Failure Cases

Partial trace when subsystem times out → mark `incompleteTrace` with reasons; GDPR delete requests vs traces **missing decision**.

## 24. Non-Functional Requirements

Queryable within seconds for ops; cost-controlled storage; PII encryption at rest.

## 25. Analytics / Auditability Requirements

This feature *is* the audit backbone; cross-link to BR-010 events via IDs.

## 26. Testing Requirements

Synthetic traces for regression; authorization tests; redaction verification per locale.

## 27. Recommended Architecture

Append-only trace store; governance audit as separate service; unified query façade.

## 28. Recommended Technical Design

Structured trace schema versioned; compress large candidate lists to summaries + pointers to internal debug blobs.

## 29. Suggested Implementation Phasing

- **Phase 1:** Capture core trace fields for PDP/cart; internal API only.
- **Phase 3:** Rich operator UI, cross-channel trace, stylist-appropriate summaries.

## 30. Summary

Explainability underpins trust in a blended stack (BR-011). Implement trace schema early even if UI lags. Retention and customer-facing explanation remain explicit **missing decisions**.
