# Customer signal activation

## Traceability / sources used

- **Canonical:** `docs/project/vision.md`, `docs/project/goals.md`, `docs/project/problem-statement.md`, `docs/project/personas.md`, `docs/project/product-overview.md`, `docs/project/business-requirements.md`, `docs/project/roadmap.md`, `docs/project/architecture-overview.md`, `docs/project/standards.md`, `docs/project/data-standards.md`, `docs/project/review-rubrics.md`, `docs/project/agent-operating-model.md`
- **BR inputs:** `docs/project/br/br-006-customer-signal-usage.md` (**BR-006**), BR-6 in `business-requirements.md`.

---

## 1. Purpose

Define how **permitted customer signals** are ingested, classified, kept **fresh**, and **activated** for recommendation personalization—so **curated**, **rule-based**, and **AI-ranked** outputs improve **complete-look** relevance **without** bypassing compatibility, inventory, consent, or merchandising governance.

## 2. Core Concept

**Signal classes** (orders, browse, product views, cart, search, loyalty, email engagement, store signals, saved looks, etc.) flow through normalization pipelines, receive **freshness tiers** (active-session, operational, profile), and are **attributed** in recommendation traces. **Policy-gated** signals (e.g. free-text stylist notes) are excluded from default paths until explicitly approved.

## 3. Why This Feature Exists

BR-006 and roadmap Phase 2 require bounded personalization: stronger relevance for known customers while avoiding stale, low-confidence, or impermissible data driving **outfit** decisions.

## 4. User / Business Problems Solved

- Reduces irrelevant or “creepy” personalization; improves returning-customer usefulness.
- Gives operators traceability when debugging quality complaints.
- Aligns **surface**-appropriate use (PDP vs email vs clienteling) per BR-006 §10.

## 5. Scope

**In:** event ingestion contracts, classification (default-allowed vs policy-gated vs disallowed), freshness evaluation, decay, fallback behavior, trace metadata for signal attribution, channel/surface activation matrix.

**Out:** concrete feature-store technology choice; model training specifics.

## 6. In Scope

- Normalization of commerce, web, loyalty, ESP, and store feeds into a shared recommendation event model (`architecture-overview.md`, `data-standards.md`).
- Signal tiers: **active-session**, **operational**, **profile** per BR-006 §6.
- Explicit recording of which classes were **used**, **ignored**, or **stale** in internal trace context.
- Identity-confidence gating from customer identity and profile spec.

## 7. Out of Scope

- Using disallowed inference patterns listed in BR-006 §5.3.
- Replacing ESP, analytics warehouse, or CDP—integrate via contracts.

## 8. Main User Personas

- **Style-aware returning customer**, **Occasion-led shopper** with identifiable sessions.
- **In-store stylist** using structured store signals where permitted.
- **Analytics / optimization lead** measuring personalization lift safely.

## 9. Main User Journeys

1. **PDP session:** product views, anchor context, cart adds feed **active-session** tier; personalization ranks among **eligible** complements.
2. **Homepage personalization:** broader order/browse history when identity confidence and consent allow (**operational** / **profile**).
3. **Email async:** durable signals only; avoid over-reliance on transient session noise (BR-006 §8.5, BR-007 alignment for async **channels**).

## 10. Triggering Events / Inputs

- Page/product views, add-to-cart, purchase, search queries, filter changes, loyalty events, email opens/clicks, store visit structured events, wishlist/save actions.
- Optional appointment metadata (structured) vs notes (policy-gated).

## 11. States / Lifecycle

- Event **received** → **normalized** → **classified** → **available** / **stale** / **suppressed** (consent) / **quarantined** (quality).
- Session intent **decay** after inactivity windows (thresholds open).
- Profile signals **aged out** or downweighted when past freshness policy.

## 12. Business Rules

- Personalization is **bounded**: never overrides hard compatibility, inventory, campaign suppressions, protected curation (BR-006 §8.1).
- **Permission before optimization** (BR-006 §4.2).
- **Stale signals degrade** via fallback to contextual, curated, or non-personalized behavior (BR-006 §6.4, §8.6).
- **Respectful** customer-facing behavior—no invasive explanations (BR-006 §8.2).

## 13. Configuration Model

- Freshness thresholds per signal class and **surface** (downstream numeric values TBD).
- Surface activation matrix: which classes are eligible for PDP, cart, homepage, email, clienteling.
- Suppression rule hooks from merchandising governance spec.

## 14. Data Model

- **Event envelope:** `eventId`, `timestamp`, `sourceSystem`, `customerOrSessionRef`, `signalClass`, `payloadRef`, `ingestedAt`.
- **Materialized aggregates** for ranking (e.g. recent categories, last N views) with `computedAt` and `freshnessState`.
- **Trace extension:** list of signal classes with `used|ignored|stale` and reason codes.

## 15. Read Model / Projection Needs

- Real-time session features for **surfaces** with near-real-time expectation (BR-006 §6.1).
- Batch or streaming aggregates for operational/profile tiers.
- Operator/debug projections listing last-known freshness by class.

## 16. APIs / Contracts

- Ingestion APIs or stream schemas (Kafka/event bus—architecture phase).
- Internal `GET /signals/summary?customerId&sessionId&surface=…` style access for recommendation orchestration (illustrative).

## 17. Events / Async Flows

- High-volume clickstream ingestion; periodic reconciliation with orders and loyalty systems.
- Downstream `SignalStaleDetected` for monitoring.

## 18. UI / UX Design

- Mostly non-customer-facing; optional indicators that recommendations are “personalized” without exposing behavioral detail (`standards.md`).

## 19. Main Screens / Components

- Internal operator views: signal freshness, consent blocks, identity confidence at recommendation time.

## 20. Permissions / Security Rules

- Strict access to raw events; recommendation path uses minimized projections.
- Audit reads for policy investigations.

## 21. Notifications / Alerts / Side Effects

- Alert when active-session pipeline lag exceeds threshold for PDP/cart.
- Auto-fallback increases when classes bulk-stale (metrics).

## 22. Integrations / Dependencies

- Commerce analytics, ESP, loyalty, POS/clienteling (`architecture-overview.md`).
- **Upstream:** identity and profile; **downstream:** recommendation orchestration, **delivery API**, analytics.

## 23. Edge Cases / Failure Cases

- Partial outage of browse stream while purchases still arrive—avoid contradictory personalization.
- Shared devices / family accounts—identity confidence may be low; prefer weaker personalization.
- Email delay: clicks attributed long after send—recency rules for **channel**=email.
- Accidental single-click signals should not dominate (BR-006 §8.2).

## 24. Non-Functional Requirements

- Near-real-time latency for **active-session** tier on digital **surfaces**.
- Durability and ordering guarantees sufficient for analytics parity with commerce truth.

## 25. Analytics / Auditability Requirements

- Telemetry per `data-standards.md`: **recommendation set ID**, **trace ID**, signal class attribution, identity confidence band.
- KPIs from BR-006 §11: freshness compliance, trace completeness, policy violations rate.

## 26. Testing Requirements

- Freshness boundary tests; consent flip tests; load tests on peak traffic; simulations of pipeline lag.

## 27. Recommended Architecture

- Dedicated **event and customer signal pipeline** subsystem feeding feature materialization (`architecture-overview.md`).

## 28. Recommended Technical Design

- Lambda or streaming architecture with dead-letter queues and replay.
- Idempotent consumers keyed by source event ID.
- Separate “cold” and “hot” stores for profile vs session features.

## 29. Suggested Implementation Phasing

- **Phase 1:** foundational events (views, ATC, purchase) for telemetry and light ranking inputs (`roadmap.md`).
- **Phase 2:** expand classes, cross-channel continuity, stricter traceability (BR-006 Phase 2 scope).
- **Phase 3+:** richer store signals with governance tooling.

## 30. Summary

Customer signal activation turns raw behavior into **governed, fresh, attributable** inputs so **personal** recommendations improve **outfit** usefulness while staying safe, auditable, and **surface**-appropriate.

## 31. Assumptions

- Phase 2 is the primary expansion window for broader signal usage (`roadmap.md`, BR-006).
- Identity and consent foundations will exist before aggressive cross-channel personalization.
- Mixed batch and near-real-time ingestion is acceptable (`architecture-overview.md` operational assumptions).

## 32. Open Questions / Missing Decisions

- Numeric freshness thresholds per **surface** for browse, view, ATC, search (BR-006 §14).
- Which structured store/appointment fields are approved first vs policy-gated.
- Minimum identity-confidence threshold for homepage, email, clienteling personalization.
- Customer-facing copy strategy for acknowledging personalization without exposing detail.
- How operators surface stale-signal suppression in debugging tools.
