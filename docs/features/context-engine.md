# Context engine

## Traceability / sources used

- **Canonical:** `docs/project/vision.md`, `docs/project/goals.md`, `docs/project/problem-statement.md`, `docs/project/personas.md`, `docs/project/product-overview.md`, `docs/project/business-requirements.md`, `docs/project/roadmap.md`, `docs/project/architecture-overview.md`, `docs/project/standards.md`, `docs/project/data-standards.md`, `docs/project/review-rubrics.md`, `docs/project/agent-operating-model.md`
- **BR inputs:** `docs/project/br/br-007-context-aware-logic.md` (**BR-007**), BR-7 in `business-requirements.md`.

---

## 1. Purpose

Normalize **contextual inputs**—country, location/region, **season**, **weather**, holiday/event calendars, and **session** context—so recommendations gain local and occasion relevance **without** overriding hard eligibility, **explicit customer intent**, or merchandising governance. Supports **RTW** (more real-time context) vs **CM** (more durable, appointment-aware context) nuances.

## 2. Core Concept

A **context engine** produces **recommendation-ready context features** with classification: **explicit vs derived**, **durable vs transient**, known **confidence** and **freshness**. It enforces **precedence** (BR-007 §7): hard constraints and explicit intent beat weak inferred context.

## 3. Why This Feature Exists

BR-007 and the problem statement highlight mismatches (season, weather, occasion) that erode trust; the vision emphasizes context-aware **outfits** across **channels**.

## 4. User / Business Problems Solved

- Fewer obviously wrong **complete-look** suggestions for climate and occasion.
- Measurable uplift when context is **fresh** vs graceful fallback when not (BR-007 §12).
- Safer use of third-party enrichments (weather providers) with traceable degradation.

## 5. Scope

**In:** context ingestion, normalization taxonomies, freshness handling, precedence rules, surface-specific activation policies, trace fields for context attribution.

**Out:** final provider selection contracts; exact UI for occasion pickers (ecommerce surface spec).

## 6. In Scope

- Context classes from BR-007 §5.1: country, location/region, weather, season, holiday/event calendar, session context.
- **Strong vs soft** contextual influence patterns (BR-007 §7.4).
- **Surface** rules: PDP, cart, homepage, email, clienteling (BR-007 §8).
- **RTW** vs **CM** handling differences (BR-007 §8.6).

## 7. Out of Scope

- Inferring sensitive attributes from location or calendar (disallowed BR-007 §5.4).
- Precise customer tracking beyond coarse, respectful location use (BR-007 §10.7).

## 8. Main User Personas

- **Occasion-led online shopper** benefits from occasion and calendar-aware **outfits**.
- **Style-aware returning customer** benefits from market-appropriate assortment context.
- **Custom Made customer** benefits from durable occasion and appointment context over transient weather swings.
- **Stylist** uses richer structured context in clienteling **channel** when policy allows.

## 9. Main User Journeys

1. **Wedding occasion selected** in session → explicit occasion **strong** signal → prioritizes occasion **look** families even if generic season suggests otherwise (precedence).
2. **PDP in summer heat** → fresh weather band nudges lighter fabrics among **eligible** candidates (**soft** or **strong** bias per configuration).
3. **Email campaign** → uses durable country/season/event windows; avoids claiming live weather unless designed for it.

## 10. Triggering Events / Inputs

- Request-time parameters: market, locale, store selection, anchor product, cart, search query, explicit occasion filters.
- Providers: weather API, holiday calendars, regional season tables.
- Session attributes: entry **surface**, referrer campaign, journey step.

## 11. States / Lifecycle

- Context snapshot **computed** per recommendation request (and optionally cached with tight TTL for weather/session).
- Fields marked **used**, **ignored**, **stale**, **weak** in trace (BR-007 §9).
- Conflict resolution outcomes logged when multiple inputs disagree.

## 12. Business Rules

- Context **never** overrides hard compatibility, inventory, suppressions, protected curation (BR-007 §7.3).
- **Explicit intent > inferred context** (BR-007 §4.2, §7.5).
- **Asynchronous channels** favor durable context; transient weather/session not treated as durable truth (BR-007 §4.6, §8.4).
- **Respectful** customer-facing behavior—no precise location exposition (BR-007 §10.7).

## 13. Configuration Model

- Approved holiday/event taxonomies per market (governance).
- Weather freshness TTL per **surface** (TBD).
- Matrices defining **strong** vs **soft** contextual influence by module and market.
- Season model: reconcile merchandising season tags vs climate/hemisphere logic (open).

## 14. Data Model

- **ContextSnapshot:** `country`, `marketId`, `regionBucket`, `weatherBand`, `conditions`, `seasonClass`, `eventWindowIds[]`, `sessionContext`, `explicitOccasion`, timestamps, `providerRefs`, `classification` (explicit/derived, durable/transient), `confidence`.

## 15. Read Model / Projection Needs

- Lightweight serializer embedded in recommendation requests/responses for traceability.
- Analytics-friendly flattening of context classes and fallback reasons.

## 16. APIs / Contracts

- Recommendation **delivery API** accepts optional `context` block; server may enrich server-side where permitted.
- Internal `POST /context/resolve` illustrative endpoint for provider fan-out and normalization.

## 17. Events / Async Flows

- Scheduled refresh of calendars and season maps; async weather fetch with circuit breaker; cache warming per region.

## 18. UI / UX Design

- Customer-facing: subtle module emphasis (e.g. seasonally labeled **outfit** modules)—details in ecommerce spec.
- No customer-facing display of raw provider payloads or precise geo reasoning.

## 19. Main Screens / Components

- Optional occasion selector, season messaging modules on homepage—owned by surface activation spec.

## 20. Permissions / Security Rules

- Provider API keys secured; logged access; minimize PII in context payloads.

## 21. Notifications / Alerts / Side Effects

- Alerts on weather provider failures or stale feeds; automatic fallback rates monitored (BR-007 §12.3).

## 22. Integrations / Dependencies

- Geo, weather, calendar providers; commerce market/locale configuration (`architecture-overview.md`).
- **Upstream:** catalog/eligibility for market assortment; **downstream:** recommendation orchestration, **delivery API**, analytics, experimentation.

## 23. Edge Cases / Failure Cases

- Stale weather contradicting obvious user intent—precedence must favor intent.
- Customer VPN location vs shipping country—explicit shipping country should win when available.
- Weak session cues causing oscillation—apply smoothing / minimum evidence thresholds.
- **CM** long lead times: transient weather should not reorder premium configured **looks** aggressively.

## 24. Non-Functional Requirements

- Tight latency budget on real-time **surfaces**; async acceptable for enrichments that are best-effort.
- Resilience: partial context still returns valid recommendations.

## 25. Analytics / Auditability Requirements

- BR-007 §9 fields included in **recommendation set** trace: which context classes influenced output, which were degraded.
- Experimentation: context-aware variants vs non-contextual baselines (BR-007 §12).

## 26. Testing Requirements

- Precedence unit tests; provider failure simulations; A/B harness for context-off vs context-on; market-specific calendar tests.

## 27. Recommended Architecture

- **Context engine** subsystem as described in `architecture-overview.md`, separate from ranker implementation details.

## 28. Recommended Technical Design

- Pluggable provider adapters producing normalized snapshot; feature flags per market for rollout.
- Deterministic conflict resolver implementing BR-007 §7.5 ordering.

## 29. Suggested Implementation Phasing

- **Phase 1:** durable country/market + basic session context on PDP/cart.
- **Phase 2:** weather, richer season, event windows, homepage personalization (BR-007 §11.1, `roadmap.md` Phase 2).
- **Later:** deeper clienteling context and CM nuance.

## 30. Summary

The context engine supplies **normalized, classified, fresh** context so **outfit** recommendations feel locally and occasion-relevant while staying subordinate to eligibility, governance, and explicit customer intent—**surface**- and **channel**-aware by design.

## 31. Assumptions

- Supported markets will eventually have sufficient calendar and regional coverage to beat generic fallback (BR-007 §14).
- Merchandising/optimization teams can configure strong vs soft contextual behaviors per market (BR-007 §14).
- Session **surfaces** can expose enough explicit cues (anchor, filters) for occasion-led journeys.

## 32. Open Questions / Missing Decisions

- Acceptable location granularity by market and **surface** (BR-007 §15).
- Weather freshness thresholds for PDP, cart, homepage, clienteling.
- Who governs holiday/event taxonomies and regional calendar quality.
- How to reconcile merchandising **season** tags with climate/hemisphere models.
- Evidence threshold distinguishing explicit occasion-led journeys from weak inference.
- Which contextual triggers deserve dedicated modules vs ranking bias only.
