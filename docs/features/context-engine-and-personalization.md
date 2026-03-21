# Feature: Context engine and personalization

**Upstream traceability:** `docs/project/business-requirements.md` (BR-007, BR-006, BR-002); `docs/project/br/br-007-context-aware-logic.md`, `br-006-customer-signal-usage.md`, `br-012-identity-and-profile-foundation.md`, `br-002-multi-type-recommendation-support.md`; `docs/project/glossary.md` (context engine); `docs/project/roadmap.md` (Phase 2).

---

## 1. Purpose

Normalize **request-time context** (market, location, weather, season, holidays, session, explicit occasion) into features that adjust **contextual** and **occasion-based** recommendations—and combine safely with **personal** signals when permitted (BR-007, BR-002).

## 2. Core Concept

Context families have different confidence; **session** and **occasion-led** inputs outrank weak calendar defaults when explicit (BR-007 precedence themes).

## 3. Why This Feature Exists

Makes recommendations situationally appropriate (wedding in summer heat vs winter commute—`vision.md`).

## 4. User / Business Problems Solved

- P3 occasion-led shoppers get relevant **outfits**.
- P1 gets weather-aware layering suggestions when confidence high.
- Reduces absurd seasonal mismatches.

## 5. Scope

Context providers, normalization service, fallback policies, feature packaging into decisioning, telemetry of context usage. **Missing decisions:** weather vendor per market; geolocation consent; holiday calendar ownership.

## 6. In Scope

- Inputs per BR-007 taxonomy: country/market, location, weather, season, holiday calendar, session context, occasion entry points.
- Degraded behavior when inputs missing/stale.
- Context features attached to **trace ID** summaries.

## 7. Out of Scope

Full travel itinerary parsing; precise indoor venue climate modeling.

## 8. Main User Personas

P1, P3, S3 marketing (campaign context), S1 stylist (appointment context).

## 9. Main User Journeys

User selects “summer wedding” → occasion feature locks → ranking biases lightweight fabrics; anonymous user in rainy locale → outerwear emphasis if weather confidence high.

## 10. Triggering Events / Inputs

Request payload hints, IP/geo (if allowed), browser locale, server-side market from storefront config, weather API lookup keyed to location, date-time UTC.

## 11. States / Lifecycle

`inputs collected → validated → confidence scored → feature vector built → attached to decision request`; stale weather triggers refresh or fallback.

## 12. Business Rules

- Weather strong only when fresh and location-linked (BR-007).
- Holiday overlays must not invent occasion specificity alone.
- **Contextual** type is not synonymous with **personal** (BR-002).

## 13. Configuration Model

Market→calendar mapping; feature flags for weather-aware ranking per market; season definitions.

## 14. Data Model

`ContextSnapshot` { requestId, market, geoPrecision, weatherBand?, season?, activeHolidays[], sessionSummary, occasionIntent?, confidenceScores }.

## 15. Read Model / Projection Needs

Cached weather by geo tile with TTL; precomputed holiday tables per market/year.

## 16. APIs / Contracts

Internal `POST /context/resolve` returning features + degradation flags; consumers embed snapshot id in recommendation requests.

## 17. Events / Async Flows

Optional async refresh for email assembly; weather provider failure events to monitoring.

## 18. UI / UX Design

Occasion pickers, copy that reflects context; customer controls for location where required by privacy.

## 19. Main Screens / Components

Occasion landing pages; session context banner (optional); admin calibration for holiday campaigns.

## 20. Permissions / Security Rules

Geo requires consent where mandated; do not log precise location in customer-facing errors.

## 21. Notifications / Alerts / Side Effects

Alerts on provider outage; automatic fallback mode broadcast to decisioning.

## 22. Integrations / Dependencies

Weather/calendar providers, storefront config, decisioning, profile service (for blending personal+context).

## 23. Edge Cases / Failure Cases

Traveler shopping for home market vs current location—**missing decision** on precedence; conflicting session signals vs declared occasion → explicit occasion wins per BR-007.

## 24. Non-Functional Requirements

Tight latency budget for PDP context resolution; resilient timeouts with defaults.

## 25. Analytics / Auditability Requirements

Record which context features influenced ranking summary in trace (BR-011); experiment stratification by climate band optional.

## 26. Testing Requirements

Scenario tests per market; fallback tests on provider failure; A/B on context-aware modules.

## 27. Recommended Architecture

Dedicated context service; provider adapters; circuit breakers; shared library for client hints.

## 28. Recommended Technical Design

Immutable `contextSnapshotId` referenced in ranking for reproducibility; versioned normalization rules.

## 29. Suggested Implementation Phasing

- **Phase 1:** Market/session/season baselines only for RTW PDP/cart (lightweight).
- **Phase 2:** Weather + holidays + occasion-led surfaces; tie to **contextual** / **occasion-based** types.
- **Phase 3+:** Rich clienteling appointment context.

## 30. Summary

Context engine bridges environment and intent (BR-007). Phase 1 can stay shallow; Phase 2 activates differentiated **recommendation types**. Provider choices and geo privacy are **missing decisions** to close in architecture.
