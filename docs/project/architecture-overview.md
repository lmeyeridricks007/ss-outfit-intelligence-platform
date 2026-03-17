# Product Architecture Overview: AI Outfit Intelligence Platform

**Document owner:** Product / Architecture  
**Source:** Business requirements (`docs/project/business-requirements.md`), industry standards and best practices (`docs/project/industry-standards-and-best-practices.md`), vision, goals, domain model, API and data standards.  
**Traceability:** Downstream of approved BRs and feature breakdown; feeds technical architecture (`docs/boards/technical-architecture.md`) and implementation plan.  
**Terminology:** **Look** = product grouping (curated set of SKUs); **outfit** = customer-facing complete look. See `docs/.cursor/rules/recommendation-domain-language.mdc`.  
**Status:** Living document; update when BRs, scope, or technical decisions change.  
**Review:** This artifact is intended for architecture-stage review per `docs/project/review-rubrics.md` (implementation readiness, correctness of dependencies, consistency with standards).

---

## 1. Architecture Goals and Principles

### 1.1 Goals

- **Product runtime:** Provide a clear, implementable picture of the AI Outfit Intelligence Platform so that technical architecture and build stages can define components, contracts, and dependencies without re-deriving scope from BRs.
- **Delivery system:** Retain alignment between the product architecture and the delivery system (GitHub, Cursor agents, automations, GitHub Actions) that governs how work is designed, reviewed, and promoted.

### 1.2 Principles (from vision, goals, industry standards)

1. **Outfit first, item second.** The platform recommends complete looks and next-best items; architecture supports outfit-level and item-level outputs from a single engine.
2. **Single recommendation logic, multi-channel delivery.** Recommendation ranking and filtering live in one place; channels (web, email, clienteling) consume a common API and adapt presentation only (no duplicate logic per channel).
3. **Merchandising rules take precedence.** Pin, include, exclude, and inventory rules are first-class; algorithm output is filtered and ordered by rules before delivery.
4. **Measurable and explainable.** Every recommendation response and outcome event carries recommendation set ID and trace ID; responses include reason/source hints where required for analytics and debugging.
5. **Identity-resolved and consent-aware.** Customer data flows respect identity resolution confidence and consent; architecture supports canonical IDs and audit of critical actions.
6. **Context-aware.** Weather, season, occasion, location, and inventory are inputs to the engine; architecture includes a context capability and passes context through the delivery API.

---

## 2. High-Level Product Architecture (Runtime)

The platform is described as a **layered product architecture** with clear boundaries. Components integrate with existing systems (catalog, OMS, CRM, POS); the platform does not replace them.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  CHANNELS & CONSUMERS                                                        │
│  Webstore (PDP, cart, homepage, look builder) │ Email/CRM │ Clienteling   │
└─────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  EXPERIENCE DELIVERY LAYER                                                    │
│  Recommendation Delivery API · Placement/campaign config · Fallback behavior  │
└─────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  RECOMMENDATION & GOVERNANCE LAYER                                           │
│  Recommendation Engine │ Context Engine │ Merchandising Rules (pin/exclude)   │
│  Strategies: curated, rule-based, AI/ML · Hybrid ranking · Fallback strategies│
└─────────────────────────────────────────────────────────────────────────────┘
                                        │
                    ┌───────────────────┼───────────────────┐
                    ▼                   ▼                   ▼
┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐
│  CUSTOMER PROFILE     │  │  PRODUCT & OUTFIT    │  │  ADMIN & ANALYTICS   │
│  SERVICE              │  │  GRAPH               │  │  Look editor · Rules  │
│  Style profile ·      │  │  Product relations   │  │  Reporting ·         │
│  Segmentation · Intent│  │  Looks · Compatibility│  │  A/B · Attribution   │
└──────────────────────┘  └──────────────────────┘  └──────────────────────┘
                    │                   │                   │
                    └───────────────────┼───────────────────┘
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  INGESTION & EVENTS LAYER                                                     │
│  Event pipeline · Catalog sync · Behavioral events · Context (weather, etc.)│
│  Identity resolution (anonymous, logged-in, POS, email)                      │
└─────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  SOURCE SYSTEMS (integrate with; do not replace)                              │
│  PIM · Shopify · OMS · DAM · Custom Made · POS · Email/CRM · Analytics        │
└─────────────────────────────────────────────────────────────────────────────┘
```

Identity resolution is performed in the ingestion layer; the customer profile service consumes resolved identity for style profile build.

### 2.1 Layer summaries

| Layer | Responsibility | Key outputs |
|-------|----------------|-------------|
| **Channels & consumers** | Render recommendations; capture impression, click, add-to-cart, purchase, dismiss | Widgets, email blocks, clienteling UI; telemetry events |
| **Experience delivery** | Single recommendation API; placement/strategy config; fallback when strategy returns insufficient results | Recommendation response (set ID, trace ID, ranked items/looks, reason/source hints) |
| **Recommendation & governance** | Generate and rank candidates; apply context and merchandising rules; support multiple strategies and fallbacks | Ranked candidates (curated + rule + AI); rules applied; inventory filtered |
| **Customer profile** | Identity-resolved style profile; segmentation; intent signals | Style profile, affinity, segment |
| **Product & outfit graph** | Product relationships; look definitions; compatibility rules | Graph data; looks; rules |
| **Admin & analytics** | Look/rule authoring; campaign config; reporting; A/B; attribution | Published looks/rules; metrics; experiment config |
| **Ingestion & events** | Catalog and behavioral ingestion; event pipeline; context ingestion; identity resolution | Canonical events; normalized catalog; context; resolved identity |

---

## 3. Component Responsibilities and BR Traceability

| Component | Responsibility | Primary BR(s) | Industry alignment |
|-----------|----------------|---------------|--------------------|
| **Event pipeline** | Ingest and normalize behavioral events (view, add-to-cart, purchase, etc.); support real-time or near real-time; emit with recommendation set ID and trace ID when outcome of a recommendation | BR-2, BR-10 | Real-time events; attribution IDs on outcomes |
| **Catalog & context ingestion** | Ingest product catalog (PIM, Shopify, OMS, DAM, Custom Made); inventory; context (weather, location, season, calendar); incremental/delta where applicable | BR-2 | Product feed; delta updates; multi-source |
| **Identity resolution** | Merge anonymous, logged-in, POS, email identities; record confidence; respect consent and regional rules | BR-2, BR-12 | Stable canonical IDs; identity resolution confidence |
| **Customer profile service** | Build and maintain style profile (preferences, affinity, segmentation, intent) from orders, browsing, store visits, appointments, stated interests | BR-3 | Style profile; cold-start handling |
| **Product graph** | Model product relationships (e.g. suit → shirt → tie → shoes); support compatibility and substitution | BR-4 | Product relationships; outfit structure |
| **Outfit graph / look store** | Store curated looks and generated outfit definitions; compatibility rules (style, fabric, occasion) configurable by merchandising | BR-4, BR-6 | Looks; compatibility rules; merchandising control |
| **Recommendation engine** | Run multiple strategies (curated, rule-based, collaborative filtering, co-occurrence, similarity, popularity); hybrid ranking; context-aware filtering (weather, season, occasion, inventory); fallback when primary returns too few items | BR-5, BR-1 | Multiple strategies; fallbacks; context-aware; no empty widgets |
| **Context engine** | Supply weather, season, location, region/locale, occasion, and channel/placement context to the recommendation engine | BR-5 | Context in request; region/locale |
| **Merchandising rules engine** | Apply pin, include, exclude, inventory, category/price constraints; prioritization and targeting; rules take precedence over raw algorithm output | BR-6, BR-12 | Pin/whitelist/blacklist; inventory rules; audit |
| **Delivery API** | Single logical API for recommendations: request (customer/session, context, product, placement, channel); response (set ID, trace ID, ranked items/looks, reason/source hints); channel-specific formatting at consumer | BR-7, BR-8, BR-9 | Single API; request echo; traceability; latency/fallback |
| **Admin / merchandising UI** | Look editor; rule builder; campaign/placement setup; algorithm/strategy selection; preview; role-based access; approval workflows | BR-11, BR-6 | Rule builder; approval; no engineering for publish |
| **Analytics & optimization** | Store and report impression, click, add-to-cart, purchase, dismiss with set ID and trace ID; CTR, conversion, revenue attribution, AOV; A/B and experimentation support | BR-10 | Core metrics; attribution; placement/strategy breakdown |

---

## 4. Key Interfaces and Data Flow

### 4.1 Recommendation request and response (Delivery API)

Aligned with `docs/project/api-standards.md` and industry practice (single API, traceability, explainability).

**Request (conceptual):**

- **Customer/session:** Customer ID (when resolved) or session ID; channel and placement.
- **Context:** Optional anchor product or cart; placement; channel; optional weather, location, region/locale, occasion.
- **Campaign/experiment:** Optional campaign or experiment variant for attribution.

**Response (conceptual):**

- **Request context echo:** So consumers can correlate without re-sending.
- **Recommendation set identifier:** Stable ID for this response.
- **Recommendation type:** e.g. outfit, cross-sell, upsell, style bundle, occasion-based, contextual, personal (per product overview and BRs).
- **Ranked items or looks:** Ordered list of product IDs or look IDs (or both), with optional reason codes and source mix (curated, rules-based, graph-derived, model-ranked).
- **Trace identifier:** For attribution and debugging; must be carried on all outcome events (impression, click, add-to-cart, purchase, dismiss).

**Fallback:** When the primary strategy returns fewer items than required, the delivery layer returns results from a configured fallback strategy (e.g. popular in category, curated look) so that widgets never return empty or broken.

**Latency and availability:** Targets (e.g. p95 latency, availability %) are a missing decision in BRs; technical architecture must define them and document fallback behavior when SLA is missed.

### 4.2 Event flow (ingestion and telemetry)

Aligned with `docs/project/data-standards.md` and recommendation-domain-language.

**Ingested events (into the platform):**

- **Behavioral:** Product view, add-to-cart, remove-from-cart, checkout started, order completed, search, category view, store visits, appointments, email engagement; source systems (ecommerce, POS, etc.) — per BR-2 and product overview.
- **Catalog:** Product and inventory updates from PIM, Shopify, OMS, Custom Made.
- **Context:** Weather, location, season, calendar (from internal or external sources).

**Event schema (canonical):** event name, event timestamp, customer/session identifier, channel and surface, anchor product or look identifier where relevant. For recommendation outcome events: recommendation set ID and trace ID.

**Outcome events (emitted by consumers or platform):** Impression, click, add-to-cart, purchase, dismiss — each with recommendation set ID and trace ID so analytics can attribute revenue and conversion to placements and strategies.

### 4.3 Data flow (summary)

1. **Source systems** → **Ingestion:** Catalog, orders, behavioral events, context, identity signals.
2. **Ingestion** → **Customer profile service:** Behavioral and transactional data for profile build.
3. **Ingestion** → **Product & outfit graph:** Catalog and product data (look and rule definitions are authored in Admin and stored in look store / rules engine).
4. **Channel** → **Delivery API:** Request (customer/session, context, placement, channel).
5. **Delivery API** → **Recommendation engine:** Enriched request (with profile and context from profile service and context engine).
6. **Recommendation engine** → **Product & outfit graph, Merchandising rules:** Candidate generation and application of rules.
7. **Recommendation engine** → **Delivery API:** Ranked candidates (after rules and inventory filter).
8. **Delivery API** → **Channel:** Response (set ID, trace ID, ranked items/looks, reason/source hints).
9. **Channel** → **Event pipeline / Analytics:** Outcome events (impression, click, add-to-cart, purchase, dismiss) with set ID and trace ID.
10. **Admin UI** → **Look store, Rules engine, Campaign config:** Create/edit looks and rules; configure placement and strategy; approval workflows where required.

---

## 5. Cross-Cutting Concerns

### 5.1 Identity and consent

- **Canonical IDs:** Products, customers, looks, rules, campaigns, experiments use stable canonical IDs; source-system IDs are mapped explicitly.
- **Identity resolution:** When merging identities across anonymous, logged-in, POS, and email, the platform records identity resolution confidence and respects consent and regional rules (BR-2, BR-12).
- **Privacy:** Customer data use is scoped to permitted use cases and regions; sensitive profile reasoning is not exposed to customer-facing UI.

### 5.2 Governance and safety

- **Approval gates:** High-visibility or high-risk changes (as defined in BR-12 and open decisions) require human or governed approval before going live; approval mode (HUMAN_REQUIRED vs AUTO_APPROVE_ALLOWED) is explicit per item or stage.
- **Audit:** Critical actions (rule change, look publish, suppression) are logged with identity and timestamp for governance and rollback (BR-6).
- **Merchandising precedence:** Pin, include, exclude, and inventory rules are applied before delivery; algorithms do not override these rules.

### 5.3 Telemetry and attribution

- **Recommendation set ID and trace ID:** Every recommendation response and every outcome event (impression, click, add-to-cart, purchase, dismiss) carries these so performance and revenue can be attributed to placement, strategy, and experiment (BR-10; industry standard: no recommendations without attribution).
- **Attribution model:** Last-click, first-click, or assisted model is a missing decision in BRs; technical architecture and analytics implementation will apply the chosen model consistently.

---

## 6. Channels and Consumers

| Channel | Consumer role | API usage | Notes |
|---------|---------------|-----------|--------|
| **Webstore** | PDP, cart, homepage, look builder | Calls Delivery API with session/customer, placement, anchor product/cart, context | Same API for all placements; presentation (widget layout, copy) is channel-specific |
| **Email / CRM** | Campaign assembly (e.g. Customer.io) | Requests recommendation payloads by audience, region, occasion; may use open-time or batch | Payloads respect audience, region, availability; BR-8 |
| **In-store clienteling** | Associate-facing app or tablet | Same API with customer ID, store/region, optional appointment context; may scope to in-store inventory or full catalog | BR-9; RTW vs CM context when relevant |
| **Future mobile** | Mobile app | Same API as web; placement and context vary | In scope as future; no separate logic |

All channels use the **same recommendation logic and API**; they differ only in request context and presentation (format, layout, copy). This avoids the anti-pattern of duplicate logic per channel (industry standards). For **RTW**, the system emphasizes stock and immediate shoppability; for **CM**, it emphasizes appointment history, fabric context, and complementary items. Both modes use the same engine with different context (see `docs/project/product-overview.md`).

---

## 7. Alignment With Industry Standards and Best Practices

The following table summarizes how this architecture aligns with `docs/project/industry-standards-and-best-practices.md` and provider norms (e.g. Dynamic Yield).

| Practice | Architecture response |
|----------|------------------------|
| Single recommendation API for all channels | Experience delivery layer exposes one logical Delivery API; channels consume it and adapt presentation only. |
| Pin / include / exclude; rule prioritization and targeting | Merchandising rules engine is first-class; rules apply before delivery; BR-6, BR-12. |
| Multiple strategies per placement; fallbacks | Recommendation engine supports multiple strategies and fallback strategy when primary returns too few items. |
| Context in request (weather, location, region, occasion) | Context engine and Delivery API request contract include context; engine does context-aware filtering. |
| Recommendation set ID and trace ID on response and outcomes | Delivery API response and event schema require set ID and trace ID; analytics and attribution depend on them. |
| Inventory and availability filtering | Merchandising rules and recommendation engine apply inventory rules so recommendations are shoppable. |
| Real-time or near real-time events | Event pipeline and ingestion layer support defined latency for behavioral events (SLA TBD). |
| Audit and approval for high-visibility changes | Admin and governance; approval workflows and audit log for critical actions; BR-6, BR-12. |
| Cold start (users and products) | Customer profile service and recommendation engine support non-personalized and attribute-based strategies; fallbacks and curated defaults. |

---

## 8. Assumptions and Open Decisions

### 8.1 Assumptions

- Product metadata quality can be improved to support graph-based recommendation (from problem statement).
- Merchandising teams will use look editor and rule builder if workflows are simple and traceable.
- The platform integrates with existing systems (PIM, OMS, Shopify, POS, Custom Made, email/CRM); it does not replace them.
- A recommendation engine (first-party or third-party) capable of the described strategies will be available; AI/model ownership is a missing decision.
- Technical architecture will define deployment topology, technology choices, and concrete APIs; this overview is product-architecture level.

### 8.2 Open decisions (from BRs; resolved in technical architecture or later)

- Delivery API latency and availability targets (p95, %).
- Identity resolution coverage definition and targets.
- Profile coverage (N interactions and target % for non-empty style profile).
- Product/outfit graph coverage targets (% of categories or SKUs in graph).
- Time-to-change for merchandising (target from rule/look change request to live).
- Attribution model (last-click, assisted, etc.) and attribution window.
- Exact list of source systems and ownership for connectors (v1).
- High-visibility placement definition (which placements require human approval).
- Fallback strategy defaults per placement type.

---

## 9. References

- **Business requirements:** `docs/project/business-requirements.md` (BRs, scope, success metrics, open decisions).
- **Industry standards:** `docs/project/industry-standards-and-best-practices.md` (recommendation and personalization norms, provider approaches).
- **Product overview:** `docs/project/product-overview.md` (channels, recommendation types, inputs, key components).
- **Vision and goals:** `docs/project/vision.md`, `docs/project/goals.md`.
- **Domain model and glossary:** `docs/project/domain-model.md`, `docs/project/glossary.md` (entities, relationships, terminology).
- **API standards:** `docs/project/api-standards.md` (recommendation response expectations, readiness criteria).
- **Data standards:** `docs/project/data-standards.md` (identity, events, privacy).
- **Recommendation domain language:** `docs/.cursor/rules/recommendation-domain-language.mdc`.
- **Review rubrics:** `docs/project/review-rubrics.md` (architecture-stage focus: implementation readiness, dependencies, standards consistency).
- **Roadmap:** `docs/project/roadmap.md` (phases, BR mapping, milestone gates, dependencies).
- **Boards:** `docs/boards/technical-architecture.md`, `docs/boards/implementation-plan.md` (technical architecture and implementation plan; downstream of this document).

---

## 10. Delivery System Architecture

The delivery system governs how the team designs, reviews, implements, and promotes work. It is separate from the product runtime but must remain aligned so that artifacts (e.g. technical architecture, implementation plan) trace cleanly to BRs and this product architecture.

### 10.1 Component roles

| Component | Primary role | Good uses | Should not replace |
|----------|--------------|-----------|---------------------|
| **GitHub** | Source of truth for issues, PRs, docs, code, approvals, merge history | Issues, PRs, review evidence, merge history, explicit approval record | Agent execution or long-form artifact generation |
| **Cursor Cloud Agents** | Repo-aware execution engine | Artifact drafting, implementation support, review, repo-aware editing | Deterministic CI or merge-state enforcement |
| **Cursor Automations** | Event-driven or background trigger layer | Issue intake, PR review kickoff, stale-work scans | Human approvals, deterministic promotion after merge, CI checks |
| **GitHub Actions** | Deterministic and auditable automation | CI, post-merge promotion, branch protections, approval-gated transitions | LLM-first planning or nuanced artifact authoring |

### 10.2 Traceability

- **Product architecture** (this document) is downstream of **business requirements** and **feature breakdown**; it feeds **technical architecture** and **implementation plan**.
- Stage progression and approval modes follow `docs/project/agent-operating-model.md` and `docs/.cursor/rules/approval-and-rework.mdc`. Architecture-stage artifacts are reviewed for implementation readiness, correctness of dependencies, and consistency with standards per `docs/project/review-rubrics.md`.

---

## 11. Review Checklist (Architecture Stage)

Per `docs/project/review-rubrics.md`, architecture-stage review prioritizes **implementation readiness**, **correctness of dependencies**, and **consistency with standards**. Use this checklist when scoring.

| Dimension | Evidence in this document |
|-----------|---------------------------|
| **Clarity** | §1–2: Goals, principles, high-level diagram, layer summaries. §3: Component table with BR mapping. §6: Channel/consumer table. |
| **Completeness** | All 12 BRs mapped to components (§3). Key interfaces (§4), event flow (§4.2), data flow (§4.3). Cross-cutting: identity, governance, telemetry (§5). Channels (§6). Industry alignment (§7). Assumptions and open decisions (§8). |
| **Implementation readiness** | Next stage (technical architecture) can define deployment, tech stack, and concrete APIs from layers and components; fallback and SLA called out where TBD. Open decisions listed so no invented answers. |
| **Consistency with standards** | Terminology (look/outfit); references to api-standards, data-standards, domain-model, recommendation-domain-language. Single API, set ID/trace ID, merchandising precedence, no duplicate logic per channel. |
| **Correctness of dependencies** | Upstream: BRs, industry standards, vision, goals, domain model, API/data standards. Downstream: technical architecture, implementation plan. References (§9) and traceability (§10.2) explicit. |
| **Automation safety** | N/A for this artifact (no automation-triggered promotion implied); approval mode and milestone gates referenced in governance (§5.2) and delivery system (§10). |
