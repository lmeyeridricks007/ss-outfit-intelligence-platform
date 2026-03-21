# Feature: Channel expansion — email and clienteling

**Upstream traceability:** `docs/project/business-requirements.md` (BR-003); `docs/project/br/br-003-multi-surface-delivery.md`, `br-006-customer-signal-usage.md`, `br-012-identity-and-profile-foundation.md`, `br-011-explainability-and-auditability.md`, `br-009-merchandising-governance.md`; `docs/project/roadmap.md` (Phase 2 email, Phase 3 clienteling).

---

## 1. Purpose

Extend **multi-surface delivery** to **email** and **clienteling** using the same recommendation meaning, identifiers, and governance—while honoring freshness, consent, authentication, and role-appropriate explainability (BR-003).

## 2. Core Concept

Email and clienteling are **consumers** of the shared contract with stricter non-interactive freshness rules and operator trust requirements (BR-003 surface matrix).

## 3. Why This Feature Exists

Unlocks lifecycle marketing and assisted selling dimensions of the vision (`vision.md` long-term ambition).

## 4. User / Business Problems Solved

- S3: measurable campaigns with recommendation content.
- S1: faster, coherent assisted **outfits**.
- P2: consistent personalization when identity confidence allows.

## 5. Scope

Send-time assembly, caching/regeneration, authenticated clienteling APIs, UI for associates, share/follow-up flows. **Missing decisions:** freshness threshold to block send; clienteling vendor; PII in email HTML extent.

## 6. In Scope

- Preserve **recommendation set ID**, **trace ID**, type, campaign linkage in email payloads.
- Clienteling: operator-readable summaries, adaptation workflows, governance parity.
- Suppression and consent checks before personalized email content.

## 7. Out of Scope

Full ESP migration; POS replacement.

## 8. Main User Personas

S3, P2; S1 stylist; compliance.

## 9. Main User Journeys

Campaign generation → recommendations fetched → packaged into template → send → clickthrough continues same trace lineage optional (**missing decision**); stylist opens customer → fetches **personal**+**outfit** sets → tweaks → shares.

## 10. Triggering Events / Inputs

ESP schedule, CRM triggers, appointment start, stylist manual refresh.

## 11. States / Lifecycle

Email: `generated → validated freshness → approved → sent → click`; clienteling: `draft recommendation → associate edited → customer shared`.

## 12. Business Rules

- Do not send stale inventory silently (BR-003 email must-not list).
- Clienteling must not expose raw sensitive profile reasoning (BR-011).
- Unsubscribe/suppression overrides personalization (BR-006).

## 13. Configuration Model

Freshness SLAs per campaign type; market send windows; role permissions for associates.

## 14. Data Model

Email package: `{ traceId, recommendationSetId, renderedProductIds[], generatedAt, ttl, campaignId }`; clienteling session links `appointmentId`, `associateId`.

## 15. Read Model / Projection Needs

Precomputed audience×product grids for batch (**optional**); clienteling customer context cache.

## 16. APIs / Contracts

Batch recommendation API or async jobs; clienteling authenticated endpoints with elevated trace detail tier.

## 17. Events / Async Flows

Queue workers for large sends; regeneration jobs on inventory shifts; clienteling audit logs.

## 18. UI / UX Design

Email: modular content blocks reflecting **style bundle**/**outfit** semantics. Clienteling: compare platform vs associate edits side-by-side; clear governance indicators.

## 19. Main Screens / Components

Campaign builder integration, recommendation preview, stylist tablet UI, share link generator.

## 20. Permissions / Security Rules

Associate RBAC; customer PII minimization in logs; secure share tokens time-bound.

## 21. Notifications / Alerts / Side Effects

Alerts when email regeneration backlog high; customer notifications only per marketing policy.

## 22. Integrations / Dependencies

ESP, CRM, identity/profile, catalog inventory snapshots, analytics.

## 23. Edge Cases / Failure Cases

Last-minute stockout before send → regeneration or drop block; associate offline → cached degraded guidance.

## 24. Non-Functional Requirements

Batch throughput for email; low latency for in-store clienteling calls.

## 25. Analytics / Auditability Requirements

Email engagement events include recommendation IDs; clienteling actions log **override** telemetry where applicable (BR-010).

## 26. Testing Requirements

Freshness drills; consent tests; load tests on batch; UX usability with stylists.

## 27. Recommended Architecture

Recommendation batch service + ESP content API; clienteling app as authenticated consumer with local caching.

## 28. Recommended Technical Design

Content hash + `generatedAt` in email; webhook callbacks for click ingestion tying to **trace ID** campaign child ids if used.

## 29. Suggested Implementation Phasing

- **Phase 2:** Email activation after Phase 1 telemetry stable (roadmap).
- **Phase 3:** Clienteling depth + operator tooling + cross-channel reporting.

## 30. Summary

Email and clienteling prove the shared contract scales beyond web (BR-003). Freshness, consent, and operator UX are the critical risks; multiple commercial thresholds remain **missing decisions**.
