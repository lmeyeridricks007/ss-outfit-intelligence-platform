# Customer identity and profile

## Traceability / sources used

- **Canonical:** `docs/project/vision.md`, `docs/project/goals.md`, `docs/project/problem-statement.md`, `docs/project/personas.md`, `docs/project/product-overview.md`, `docs/project/business-requirements.md`, `docs/project/roadmap.md`, `docs/project/architecture-overview.md`, `docs/project/standards.md`, `docs/project/data-standards.md`, `docs/project/review-rubrics.md`, `docs/project/agent-operating-model.md`
- **BR inputs:** **BR-12** (*Identity and profile foundation*) in `business-requirements.md`. *There is no separate `docs/project/br/br-012-*.md` artifact in this repository; BR-12 is taken from canonical BR-12 wording and architecture/data standards.*

---

## 1. Purpose

Provide **stable canonical customer identity**, **merge confidence**, and a **consent-aware customer profile** so recommendations behave consistently across **channels** (ecommerce, email, clienteling) and **surfaces** (PDP, cart, homepage, etc.), without hiding privacy or policy boundaries inside ranking logic.

## 2. Core Concept

**Identity resolution** maps source-system identifiers (web account, loyalty ID, email hash, POS or clienteling IDs where available) to a **canonical customer ID**. The **profile** aggregates permitted signals with **recency**, **provenance**, and **suppression/consent** state. **Personal** recommendations use this profile; **outfit** presentation still follows eligibility and governance.

## 3. Why This Feature Exists

BR-12 and the product overview require cross-session and cross-channel continuity for returning customers. The architecture overview mandates identity as an explicit service, not an implicit assumption in models.

## 4. User / Business Problems Solved

- **Style-aware returning customer** sees continuity instead of repeated irrelevant suggestions.
- **Clienteling** associates store context with the right profile when policy allows.
- **Compliance**: consent and regional constraints are enforceable at activation time.
- **Analytics** can attribute journeys to a stable ID where confidence supports it.

## 5. Scope

**In:** identity graph (mappings), confidence scoring for merges, profile storage model, consent/suppression flags, APIs for recommendation consumers, audit fields.

**Out:** legal copy for consent UX; full CRM replacement; definitive ML feature engineering for ranking (orchestration spec).

## 6. In Scope

- Canonical `customerId` and source identifier mappings with history.
- Identity resolution **confidence** for probabilistic matches (`data-standards.md`, `standards.md`).
- Profile segments: orders, browse, views, cart, search, loyalty, email engagement, store visits, appointments, stylist notes placeholders (policy-gated), saved looks / wishlists where permitted.
- Session/anonymous fallback linking when identifiable events occur.

## 7. Out of Scope

- Storing raw PII beyond what the profile contract requires; secrets handling is platform-standard (`standards.md`).
- Using **policy-gated** signals (e.g. free-text stylist notes) without explicit approval paths (see customer signal activation spec).

## 8. Main User Personas

- **Style-aware returning customer**, **Occasion-led shopper** (when logged in or identifiable).
- **In-store stylist** — needs confident identity for assisted selling.
- **Marketing / CRM manager** — needs segment-safe reuse across **channels**.
- **Product / analytics lead** — needs measurable identity coverage and confidence distributions.

## 9. Main User Journeys

1. **Anonymous browse → login:** session events optionally attach to canonical profile; prior session may merge with rules for confidence.
2. **Cross-channel continuity:** email click-through resolves to web identity when permitted; clienteling pulls profile for appointment.
3. **Low-confidence merge:** treat as weaker **personal** personalization or anonymous behavior per `review-rubrics.md` / data standards expectations.

## 10. Triggering Events / Inputs

- Account creation, login, order placement, loyalty enrollment.
- Ingested events carrying device/session tokens and authenticated IDs.
- Manual merge or split tools (future operational workflow).
- Consent updates from preference center or CRM.

## 11. States / Lifecycle

- **Anonymous session** → **identified** → **profile active** with current consent.
- **Merged** identities (with confidence) vs **pending review** matches.
- **Suppressed** or **opted-out** states that block personalization categories.
- **Stale profile** segments flagged when beyond freshness policy (handoff to signal activation spec).

## 12. Business Rules

- Personalization must respect **consent** and **regional** policy (`business-requirements.md` constraints).
- **Low-confidence** cross-channel identity must **not** drive assertive **personal** recommendations (`data-standards.md`).
- Customer-facing **surfaces** must not expose sensitive profile reasoning (`vision.md`, `standards.md`).

## 13. Configuration Model

- Markets and **channels** where certain identifiers are authoritative.
- Thresholds mapping identity confidence → allowed personalization depth by **surface**.
- Retention windows per signal class (aligned with legal/policy—not fully specified in bootstrap docs).

## 14. Data Model

- **Customer:** `canonicalCustomerId`, created/updated timestamps, market, consent references.
- **Identifier mappings:** `(sourceSystem, sourceId) → canonicalCustomerId`, `confidence`, `firstSeen`, `lastSeen`.
- **Profile facets:** typed collections per signal class with `lastUpdated`, `source`, optional `stale` flag.
- **Suppression / consent:** boolean or enum dimensions tied to use case (recommendation personalization).

## 15. Read Model / Projection Needs

- Fast lookup: by session token, authenticated account, or clienteling ID.
- **Recommendation-facing projection**: permitted facets only, pre-filtered by consent.
- Analytics projection: coverage rates, confidence histograms, merge outcomes.

## 16. APIs / Contracts

- Illustrative: `POST /identity/resolve`, `GET /customers/{canonicalCustomerId}/profile?purpose=recommendation&surface=…`.
- Responses must state **identity confidence** and **which facets were included/excluded** for internal consumers (traceability to explainability spec).

## 17. Events / Async Flows

- `CustomerIdentityLinked`, `CustomerProfileUpdated`, `ConsentChanged`—downstream invalidation of personalization caches and ranking feature stores.

## 18. UI / UX Design

- Customer-facing: transparent account and preference experiences owned by commerce; this spec assumes signals **about** consent flow exist.
- Internal: tools to inspect identity mappings and confidence (implementation phase).

## 19. Main Screens / Components

- Internal identity debugger / support view (deferred).
- Optional profile preview for stylists in clienteling **surface** (channel-specific UI spec).

## 20. Permissions / Security Rules

- Role-based access to PII-heavy views; audit reads of full profile.
- Encryption at rest/in transit per platform standards; no embedding of secrets in events.

## 21. Notifications / Alerts / Side Effects

- Alerts on abnormal merge rates or identifier conflicts.
- Suppression events immediately affect **personal** recommendation requests.

## 22. Integrations / Dependencies

- Commerce accounts, loyalty, CRM, ESP, POS/clienteling identifiers (`architecture-overview.md`).
- **Downstream:** customer signal activation, recommendation orchestration, **delivery API**, analytics.

## 23. Edge Cases / Failure Cases

- Duplicate accounts after marriage of records delayed—temporary low confidence.
- Customer deletes account or revokes consent mid-session.
- Cross-device anonymous sessions that should not merge aggressively.
- Regional travel: market vs profile country mismatch—explicit precedence needed with context engine.

## 24. Non-Functional Requirements

- High read availability; strict latency budget for real-time **surfaces**.
- Auditable changes to merges and consent.
- Data minimization: profile projection for recommendation path excludes unused fields.

## 25. Analytics / Auditability Requirements

- Log identity confidence band on **recommendation set** traces when **personal** signals used.
- Measure % of sessions with resolved identity vs anonymous fallback.

## 26. Testing Requirements

- Resolution tests with conflicting inputs; consent revocation tests; performance tests on hot paths.
- Property tests: profile projection never includes facets without consent.

## 27. Recommended Architecture

- Standalone **identity resolution and customer profile service** (`architecture-overview.md`), not buried inside rankers.

## 28. Recommended Technical Design

- Deterministic rules first for merges; ML-assisted matching only with human review workflow if introduced later (open decision).
- Event-sourced profile updates with idempotent consumers.
- Feature store or materialized views for ranking consumers (coordination with orchestration spec).

## 29. Suggested Implementation Phasing

- **Phase 1:** authenticated web identity + orders; basic anonymous session; single market.
- **Phase 2:** cross-channel resolution, confidence-aware personalization, richer facets (`roadmap.md` Phase 2).
- **Phase 3+:** clienteling-heavy identifiers and operational tooling maturity.

## 30. Summary

Customer identity and profile is the **trust and continuity layer**: canonical IDs, merge confidence, and consent-aware facets enable **personal** recommendations and measurement without violating policy or overstating certainty.

## 31. Assumptions

- SuitSupply can integrate authoritative identifiers from commerce and at least one loyalty or CRM source in early phases.
- Consent and regional rules will be supplied as enforceable signals, not only legal prose.
- Anonymous sessions remain common; the platform must **degrade gracefully** (`product-overview.md`).

## 32. Open Questions / Missing Decisions

- Initial **systems of record** for identity (`business-requirements.md` open questions).
- Legal constraints on stylist notes, appointments, and cross-channel linking—operational policy outputs needed.
- Exact **confidence thresholds** per **surface** and **channel**.
- Retention and deletion semantics for profile facets at account closure.
- Whether probabilistic merges ever auto-link without human review in regulated markets.
