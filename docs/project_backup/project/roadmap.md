# Roadmap: AI Outfit Intelligence Platform

**Document owner:** Product / Program  
**Source:** Business requirements, architecture overview, product overview (initial scope focus), vision, goals.  
**Traceability:** Informs `docs/boards/implementation-plan.md` and build boards (backend, UI, integration, e2e-qa). Feature-level traceability (BR + capability per feature) is in `docs/project/feature-list.md`.  
**Status:** Living document; update when phases are reprioritized or scope changes.

---

## 1. Roadmap Overview

The roadmap is organized into **phases** that follow the logical dependency order of the product architecture: data and graph first, then recommendation engine and API, then channel activation, then admin and clienteling, then optimization and future capabilities. Each phase has clear outcomes, primary BRs, and (where applicable) human gates per `docs/project/business-requirements.md` §8.

| Phase | Milestone (headline) | Primary outcome | Key BRs |
|-------|----------------------|------------------|----------|
| **0** | Foundation | Requirements and architecture approved; ready for technical design and build | — |
| **1** | Data and graph foundation | Ingestion and identity live; product and outfit graph populated; engine-ready | BR-2, BR-4 (foundation) |
| **2** | PDP recommendations + Delivery API | Engine, rules, Delivery API, and telemetry live; API contract stable; PDP path buildable | BR-2, BR-3, BR-4, BR-5, BR-6, BR-7, BR-10 |
| **3** | Cart + email + analytics | PDP, cart, homepage widgets live; email payloads; core reporting and attribution | BR-1, BR-7, BR-8, BR-10 |
| **4** | Clienteling + merchandising UI | Admin (looks, rules, placement config) and approval/audit; in-store clienteling on API | BR-6, BR-9, BR-11, BR-12 |
| **5** | Optimization + look builder | A/B and experimentation; customer-facing look builder; performance tuning | BR-10, product goals |
| **Future** | Long-term vision | Conversational AI, visual builder, dynamic PLP, full personalization (per vision and BR out of scope) | Backlog |

---

## 2. Phase 0: Foundation

**Goal:** Requirements and product architecture approved; feature breakdown and technical architecture can proceed.

**Deliverables**

- Business requirements approved (per `docs/boards/business-requirements.md`).
- Feature breakdown approved (`docs/boards/features.md`).
- Product architecture overview approved (`docs/project/architecture-overview.md`).
- Open decisions documented; no invented answers for missing decisions.

**Human gate**

- **Requirements approval** before feature breakdown and architecture (per BR document §8).
- **Architecture approval** before implementation plan and build tracks are finalized.

**Exit criteria**

- BRs and architecture pass review per `docs/project/review-rubrics.md`.
- Technical architecture and implementation plan can be created with clear dependency order.

**Target timing**

- TBD (entry point; no features).

**Dependencies**

- None (entry point for delivery). Phase 1 build starts after Phase 0 approval.

---

## 3. Phase 1: Data and Graph Foundation

**Milestone:** Data and graph foundation (engine-ready).

**Goal:** Catalog, behavioral events, and context are ingested; identity is resolved; product and outfit graph are populated so the recommendation engine can generate candidates.

**Main features (from feature list)**

| Feature | Name |
|---------|------|
| F1 | Catalog and inventory ingestion |
| F2 | Behavioral event ingestion |
| F3 | Context data ingestion |
| F4 | Identity resolution |
| F5 | Product graph |
| F6 | Outfit graph and look store |

**Deliverables**

- **Ingestion:** Event pipeline ingesting behavioral events (view, add-to-cart, purchase, etc.); catalog and inventory sync from committed source systems (PIM, Shopify, OMS, etc.); context ingestion (weather, location, season, calendar) where committed.
- **Identity resolution:** Anonymous, logged-in, POS, email identities merged with confidence and consent respected; canonical customer ID available for profile and API.
- **Product graph:** Product relationships (e.g. suit → shirt → tie → shoes) and compatibility/substitution modeled; catalog data available to graph.
- **Outfit graph / look store:** Curated looks and compatibility rules (style, fabric, occasion) storable and configurable (admin may be minimal in this phase; rules can be file- or config-driven initially).

**Primary BRs**

- BR-2 (data ingestion and identity).
- BR-4 (product and outfit graph) — foundation: graph populated, rules executable.

**Success criteria (from BRs)**

- Data freshness within agreed SLA (e.g. catalog &lt; 24h, event latency defined).
- Identity resolution coverage (target TBD).
- Graph coverage: key categories participate in at least one relationship or outfit (target TBD).

**Target timing**

- TBD (set when program dates are committed).

**Human gate**

- **Data and graph readiness review** before Phase 2 (engine and API) build starts — e.g. validate catalog and event flow, identity resolution, and graph coverage.

**Exit criteria**

- Catalog and behavioral data flowing; identity resolution producing canonical IDs where consent exists.
- Product and outfit graph (or equivalent) can serve relationship and look data to the recommendation engine.
- Telemetry schema supports recommendation set ID and trace ID for future outcome events.

**Dependencies**

- **Phase 0 complete** before Phase 1 build starts.
- **Committed source systems and ownership** for connectors (or minimal viable set documented).
- **F5 and F6** depend on F1 (catalog); ingestion (F1–F4) and graph (F5–F6) can be parallelized within Phase 1.

---

## 4. Phase 2: PDP Recommendations + Delivery API

**Milestone:** PDP recommendations + Delivery API (engine, rules, API, telemetry live; PDP path buildable).

**Goal:** Customer profile, recommendation engine, context engine, merchandising rules, and Delivery API are implemented. At least one consumer (e.g. internal test or web stub) can call the API and receive recommendations with set ID and trace ID. **Backend API is live before UI widgets** — Phase 3 builds on this.

**Main features (from feature list)**

| Feature | Name |
|---------|------|
| F7 | Customer profile service |
| F8 | Context engine |
| F9 | Recommendation engine core |
| F10 | Merchandising rules engine |
| F11 | Delivery API |
| F12 | Recommendation telemetry |

**Deliverables**

- **Customer profile service:** Style profile (preferences, affinity, segmentation, intent) built from orders, browsing, store visits, appointments, stated interests; consumed by recommendation engine.
- **Context engine:** Weather, season, location, region/locale, occasion, channel/placement supplied to the engine.
- **Recommendation engine:** Multiple strategies (curated, rule-based, collaborative filtering, co-occurrence, similarity, popularity); hybrid ranking; context-aware filtering (weather, season, occasion, inventory); fallback when primary returns too few items.
- **Merchandising rules engine:** Pin, include, exclude, inventory, category/price constraints; rules take precedence over raw algorithm output.
- **Delivery API:** Single logical API: request (customer/session, context, product, placement, channel), response (set ID, trace ID, ranked items/looks, reason/source hints); fallback behavior when strategy returns insufficient results.
- **Telemetry:** Outcome events (impression, click, add-to-cart, purchase, dismiss) with set ID and trace ID captured and available for analytics.

**Primary BRs**

- BR-2, BR-3, BR-4, BR-5, BR-6, BR-7, BR-10 (foundation for attribution).

**Success criteria (from BRs)**

- API availability and latency per targets (TBD in technical architecture).
- At least one channel or test consumer calling the API in a target environment (PDP placement path validated).
- Strategy performance and context adherence measurable via telemetry.

**Target timing**

- TBD. **Phase 3 starts after Phase 2 Delivery API is live** and API readiness gate passed.

**Human gate**

- **API readiness review** before Phase 3 (channel activation) — e.g. contract stable, fallback and latency documented, telemetry validated.

**Exit criteria**

- Delivery API returns recommendations (outfit, cross-sell, upsell, style bundle, etc.) with set ID and trace ID.
- Merchandising rules (pin, exclude, inventory) applied; no empty widgets when fallback is configured.
- Analytics can receive outcome events with attribution IDs.

**Dependencies**

- **Phase 1 complete** — ingestion, identity, and graph must be live before engine and API build.
- **Technical architecture and implementation plan** approved for engine and API.
- **Backend API (F11) before UI** — PDP, cart, and other widgets (F13–F15) depend on F11; Phase 2 delivers F11 so Phase 3 can integrate.
- Feature order within Phase 2: F7, F8 depend on F2–F4, F3; F9 depends on F5, F6, F7, F8; F10 on F6; F11 on F9, F10; F12 on F11.

---

## 5. Phase 3: Cart + Email + Analytics

**Milestone:** Cart + email + analytics (PDP, cart, homepage live; email payloads; core reporting).

**Goal:** Webstore (PDP, cart, homepage) and email/CRM consume the Delivery API. Recommendations are visible to customers; analytics report CTR, add-to-cart, conversion, and attribution.

**Main features (from feature list)**

| Feature | Name |
|---------|------|
| F13 | PDP recommendation widgets |
| F14 | Cart recommendation widgets |
| F15 | Homepage and landing recommendation widgets |
| F16 | Email and CRM recommendation payloads |
| F17 | Core analytics and reporting |

**Deliverables**

- **Webstore integration:** Recommendation widgets on PDP (“complete the look”, “styled with”, “you may also like”), cart (“complete your outfit”), homepage/landing (“looks for you”, “trending outfits”); widgets call Delivery API and send outcome events with set ID and trace ID.
- **Email/CRM:** Recommendation payloads available for campaigns (e.g. Customer.io); payloads respect audience, region, availability; open-time or batch as designed.
- **Analytics and reporting:** Core recommendation metrics (CTR, add-to-cart, conversion, revenue attribution, AOV) available in agreed reporting tool or dashboard; attribution model applied consistently (model TBD in open decisions).

**Primary BRs**

- BR-1 (outfit and complete-look recommendations delivered on web and email).
- BR-7 (channel activation: web + email).
- BR-8 (email recommendation payloads).
- BR-10 (reporting and attribution).

**Success criteria (from BRs)**

- Recommendation CTR or add-to-cart rate from recommendation per placement.
- Email recommendation engagement lift vs control or non-personalized.
- Core metrics in reporting; revenue/conversion attributable to recommendation placements.

**Target timing**

- TBD. **Phase 3 starts after Phase 2 PDP path is validated** and API readiness gate passed. Phase 4 can start after or in parallel with Phase 3 once web/email baseline is sufficient for admin to configure.

**Human gate**

- **Human review before go-live** for any surface that serves customer-facing recommendations (per BR document §8). No customer-facing recommendation surface goes live without designated approval.

**Exit criteria**

- PDP, cart, and at least one other web placement (e.g. homepage) live with recommendations.
- At least one email campaign or block using recommendation payloads.
- Reporting shows recommendation-driven metrics and attribution.

**Dependencies**

- **Phase 2 complete** — Delivery API (F11) and telemetry (F12) must be live before UI and email integration.
- **Backend API before UI** — F13, F14, F15, F16 all depend on F11; F17 depends on F12.
- Web and email consumer apps/clients ready to integrate (or in scope of this phase).

---

## 6. Phase 4: Clienteling + Merchandising UI

**Milestone:** Clienteling + merchandising UI (admin for looks, rules, placement; approval and audit; in-store clienteling on API).

**Goal:** Merchandising can create and edit looks and rules, configure placement and strategy, and approve high-visibility content without engineering. In-store clienteling consumes the same API; governance and audit are in place.

**Main features (from feature list)**

| Feature | Name |
|---------|------|
| F18 | Admin: look editor |
| F19 | Admin: rule builder |
| F20 | Admin: placement and campaign config |
| F21 | Approval workflows and audit |
| F22 | Privacy and consent enforcement |
| F23 | In-store clienteling integration |

**Deliverables**

- **Admin / merchandising UI:** Look editor; rule builder (pin, include, exclude, inventory, category/price); campaign/placement setup; algorithm/strategy selection; preview; role-based access; approval workflows for high-visibility changes.
- **Governance and safety:** Approval gates for high-visibility or high-risk changes; audit log for critical actions (rule change, look publish, suppression); privacy and consent respected; no unapproved bulk overrides.
- **In-store clienteling:** Associate-facing surface (app or tablet) calls Delivery API with customer ID, store/region, optional appointment context; recommendations consider store/region and CM when relevant; customer style profile (where permitted) visible to associates.

**Primary BRs**

- BR-6 (merchandising control and governance).
- BR-9 (in-store clienteling recommendations).
- BR-11 (admin and merchandising UI).
- BR-12 (governance and safety).

**Success criteria (from BRs)**

- Merchandising users can create or edit a look and publish (or submit for approval) without engineering.
- Override-to-live SLA and audit log for critical actions.
- Clienteling usage and outcome (e.g. basket size or follow-up conversion when recommendations used; targets TBD).
- Approval gates enforced; no unapproved bulk overrides.

**Target timing**

- TBD. **Phase 4 starts after Phase 2 (API) and Phase 3 (web/email)** — admin configures live placements; clienteling consumes same API.

**Human gate**

- **Governance and clienteling readiness review** — approval workflows and audit validated; clienteling integration and permissions approved.

**Exit criteria**

- Merchandising can manage looks and rules and configure campaigns/placements via admin UI.
- Clienteling surface consumes API and shows recommendations and (where permitted) style profile.
- High-visibility changes go through defined approval path; critical actions are audited.

**Dependencies**

- **Phase 2 (API) and Phase 3 (web/email)** — live placements and API required for admin to configure and for clienteling to consume.
- **Admin UI (F18–F20) depends on F11** (and F6, F10); **approval (F21) depends on F18, F19**; **F22 on F4**; **F23 on F11, F7**.
- Clienteling tool or integration available (or in scope of this phase).

---

## 7. Phase 5: Optimization + Look Builder

**Milestone:** Optimization + look builder (A/B and experimentation; customer-facing look builder; performance tuning).

**Goal:** A/B and experimentation at scale; look builder as a customer-facing surface; performance tuning and personalization refinement.

**Main features (from feature list)**

| Feature | Name |
|---------|------|
| F24 | A/B and experimentation |
| F25 | Customer-facing look builder |
| F26 | Performance and personalization tuning |

**Deliverables**

- **Experimentation:** A/B and multi-armed bandit (where configured) for strategy, layout, and rules; primary metric and sample size defined; results in reporting.
- **Look builder:** Customer-facing look builder (curated looks) consuming Delivery API; placement and metrics tracked.
- **Performance and personalization:** Profile coverage and personal recommendation lift improved; graph coverage and strategy mix tuned using analytics.

**Primary BRs**

- BR-10 (analytics and optimization; experimentation).
- BR-1 (look builder as inspiration surface).
- Product goals (serve complete-look recommendations across homepage, etc.).

**Success criteria (from BRs and goals)**

- Experiment velocity and clear read on winning variants.
- Recommendation CTR, add-to-cart, conversion, and attribution by placement and strategy.
- Time-to-change for merchandising within target (TBD).

**Target timing**

- TBD. **Phase 5 starts after Phases 1–4 complete**; requires stable baseline metrics to optimize against.

**Exit criteria**

- Look builder live (or committed to next release).
- A/B/experimentation available for key placements; results actionable.
- Roadmap for further personalization and graph refinement documented.

**Dependencies**

- **Phases 1–4 complete** — stable baseline metrics and live placements required.
- **F24** depends on F17, F11; **F25** on F11, F6; **F26** on F7, F17, F9.

---

## 8. Future Capabilities (Backlog)

These items are **out of scope** for the current roadmap or explicitly **future** in the BRs and vision. They are listed here for context and prioritization in later planning.

| Capability | Source | Notes |
|------------|--------|--------|
| **Dynamic PLP sorting** | BR out of scope, vision | Sort product listing by predicted relevance; add via new BR if prioritized. |
| **Conversational AI stylist** | BR out of scope, vision long-term | e.g. “What should I wear to a wedding?”; requires new BR and architecture. |
| **Visual outfit builder** | BR out of scope, vision | Upload photo → recommend items; future capability. |
| **Full website personalization** | BR out of scope | Dynamic homepage per user; initial scope is defined recommendation placements only. |
| **Guided wardrobe building** | Vision long-term | Multi-season wardrobe progression. |
| **Generative look ideation** | Vision long-term | For merchandising teams. |
| **Mobile app** | Product overview | Future mobile consumer of same API; no separate logic. |

---

## 9. Dependencies and Critical Path

**Cross-phase dependencies (summary)**

- **Phase 1 starts after Phase 0** — Requirements and architecture approved.
- **Phase 2 starts after Phase 1** — Data and graph (ingestion, identity, product graph, look store) must be live; engine and API build on F1–F6.
- **Backend API before UI** — Delivery API (F11) is built in Phase 2; PDP, cart, and homepage widgets (F13–F15) and email (F16) in Phase 3 depend on F11. No UI widget goes live without the API.
- **Phase 3 starts after Phase 2** — Delivery API live and API readiness gate passed; PDP path validated so web and email can integrate.
- **Phase 4 starts after Phase 2 and Phase 3** — Admin configures live placements (Phase 3); clienteling consumes same API (Phase 2). Phase 4 can overlap with late Phase 3 (e.g. merchandising UI in parallel with email activation).
- **Phase 5 starts after Phases 1–4** — Optimization and look builder require stable baseline metrics and live placements.

```
Phase 0 (Foundation)
    ↓
Phase 1 (Data & Graph) ─────────────────────────────────────────┐
    ↓                                                              │
Phase 2 (PDP + Delivery API) ◄───────────────────────────────────┘
    ↓
    ├──► Phase 3 (Cart + Email + Analytics)
    │         ↓
    └──► Phase 4 (Clienteling + Merchandising UI) ◄── Phase 3
                ↓
          Phase 5 (Optimization + Look Builder)
                ↓
          Future (backlog)
```

- **Critical path:** 0 → 1 → 2. Phases 3 and 4 can be sequenced (e.g. 3 then 4) or partially parallelized (e.g. admin UI in parallel with web activation) depending on capacity; both depend on Phase 2.
- **Parallelization:** Within Phase 2, profile service, context engine, recommendation engine, rules engine, and Delivery API can be split across build tracks with clear interfaces; same for Phase 3 (web vs email) and Phase 4 (admin vs clienteling).

---

## 10. Milestone Gates (Summary)

| Gate | When | Purpose |
|------|------|---------|
| Requirements approval | Before feature breakdown and architecture | BR document §8; no build from unapproved BRs. |
| Architecture approval | Before implementation plan and build | Review per `docs/project/review-rubrics.md`. |
| Data and graph readiness | Before Phase 2 engine/API build | Validate ingestion, identity, graph. |
| API readiness | Before Phase 3 channel activation | Validate contract, fallback, telemetry. |
| Go-live approval | Before any customer-facing recommendation surface | Per BR document §8; human review. |
| Governance and clienteling readiness | Before Phase 4 sign-off | Approval workflows and audit; clienteling permissions. |

---

## 11. References

- **Feature list:** `docs/project/feature-list.md` (features per phase with BR and capability traceability, dependencies).
- **Business requirements:** `docs/project/business-requirements.md` (BRs, scope, success metrics, approval notes).
- **Capability map:** `docs/project/capability-map.md` (capabilities, personas/channels, BR mapping).
- **Architecture overview:** `docs/project/architecture-overview.md` (layers, components, data flow).
- **Product overview:** `docs/project/product-overview.md` (initial scope focus, channels, recommendation types).
- **Vision:** `docs/project/vision.md` (strategic outcomes, long-term vision).
- **Goals:** `docs/project/goals.md` (business, customer, product, governance goals; non-goals).
- **Implementation plan board:** `docs/boards/implementation-plan.md` (promotion rules, tracks, dependencies).
- **Approval and milestone notes:** `docs/project/business-requirements.md` §8, `docs/.cursor/rules/approval-and-rework.mdc`.
