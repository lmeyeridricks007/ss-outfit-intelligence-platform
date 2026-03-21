# Feature: Customer signal ingestion

**Upstream traceability:** `docs/project/business-requirements.md` (BR-006); `docs/project/br/br-006-customer-signal-usage.md`, `br-012-identity-and-profile-foundation.md`, `br-010-analytics-and-experimentation.md`; `docs/project/data-standards.md`; `docs/project/architecture-overview.md`.

---

## 1. Purpose

Ingest and normalize **customer signals** (orders, browse, cart, search, email, loyalty, store, stylist notes) with freshness tiers, provenance, and consent boundaries so personalization is optional and safe (BR-006).

## 2. Core Concept

Signals are **families** with different trust, decay, and permitted uses; unknown freshness must not drive personalized ranking (BR-006).

## 3. Why This Feature Exists

Enables relevant **personal** recommendations without channel-specific guesswork (`vision.md` personalization principle).

## 4. User / Business Problems Solved

- P2 returning customers see complementary **outfits**.
- Operators audit which signals influenced outcomes.
- Privacy-safe activation.

## 5. Scope

Pipelines, schemas, consent gates, deduplication, linkage to canonical customer ID where confident. **Missing decisions:** event bus choice; PII handling in raw logs; stylist note approval workflow depth.

## 6. In Scope

- Signal categories per BR-006 table (orders, browsing, product views, ATC, search, loyalty, email, store, stylist notes).
- Freshness tier enforcement hooks for profile builders.
- Provenance metadata requirements.

## 7. Out of Scope

Full CRM replacement; unstructured note NLP in Phase 1.

## 8. Main User Personas

P1–P3; S1 stylist; S4 analytics.

## 9. Main User Journeys

Shopper browses → session signals update → PDP ranking uses short-term intent; later order enriches durable profile.

## 10. Triggering Events / Inputs

Web/mobile events, commerce webhooks, ESP events, POS feeds, stylist tooling saves.

## 11. States / Lifecycle

`received → validated → enriched (identity) → stored → aggregated into profile features → expired per decay rules`.

## 12. Business Rules

- Unconsented signals excluded from personalization paths (BR-006, BR-012).
- Stylist notes require review state before customer-facing use when policy demands (BR-006).
- Conflicting signals: fresher explicit intent wins unless operator context overrides (**tie policy** partially in BR-006, details **missing decision**).

## 13. Configuration Model

Consent taxonomy mapping; per-region permitted uses; sampling; retention schedules per signal family.

## 14. Data Model

`CustomerEvent` { id, type, ts, sourceSystem, sourceRecordId, customerRefOrSession, market, consentTags, payloadRef }.

**Example:** `product_view { productId, surface: PDP, sessionId, ts }`.

## 15. Read Model / Projection Needs

Session rolling windows; customer aggregates (last N categories, owned products); email engagement summaries.

## 16. APIs / Contracts

Ingestion API with HMAC auth; batch files for legacy sources; profile builder internal API.

## 17. Events / Async Flows

Stream processing for near-real-time; nightly reconciliation batch from OMS.

## 18. UI / UX Design

Minimal customer UI; stylist note capture UI with structured tags preferred (BR-006).

## 19. Main Screens / Components

Data ops monitoring; consent state inspector (internal); signal replay debugger.

## 20. Permissions / Security Rules

Least privilege to raw events; encryption; regional residency **missing decision**.

## 21. Notifications / Alerts / Side Effects

Alerts on ingestion lag; consent revocation triggers profile feature invalidation events.

## 22. Integrations / Dependencies

Shopify/commerce, ESP, POS, appointments, identity service, analytics.

## 23. Edge Cases / Failure Cases

Clock skew; duplicate events; orphaned session without merge; revocated consent mid-session → subsequent requests drop personalized features.

## 24. Non-Functional Requirements

High throughput; at-least-once delivery with idempotent writes; observability per pipeline.

## 25. Analytics / Auditability Requirements

Signal lineage surfaces in traces when used (BR-011); profile usage flags in telemetry (BR-010).

## 26. Testing Requirements

Contract tests per source; dedupe tests; consent enforcement tests; chaos on pipeline.

## 27. Recommended Architecture

Medallion or stream-first ingestion → identity resolver → feature builders → profile service.

## 28. Recommended Technical Design

Schema registry for events; dead-letter queues; feature snapshots versioned `profileFeatureVersion`.

## 29. Suggested Implementation Phasing

- **Phase 1:** Anonymous session + basic product view/ATC for on-site context only as permitted.
- **Phase 2:** Full cross-channel ingestion with identity-confidence gating for **personal** type expansion.

## 30. Summary

Signal ingestion unlocks Phase 2 personalization (BR-006) but must ship with consent, freshness, and provenance discipline. Several regional and note-governance details remain **missing decisions**.
