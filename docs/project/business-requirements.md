# Business Requirements: AI Outfit Intelligence Platform

**Document owner:** Product / Business  
**Source:** Product overview, vision, problem statement, feature breakdown, goals  
**Traceability:** Promotes to `docs/boards/features.md`; feeds architecture and implementation plan.  
**Terminology:** In this document, **look** = product grouping (e.g. curated set of SKUs); **outfit** = customer-facing complete look. See `docs/.cursor/rules/recommendation-domain-language.mdc`.  
**Status:** Living document; update when BRs, scope, or success criteria change.

---

## 1. Problem Statement

**Who has the problem**  
SuitSupply customers (online and in-store), store associates (client advisors), merchandising managers, and CRM/email marketing teams.

**What the problem is**  
Customers struggle to build complete outfits: they know the anchor item (e.g. a navy suit) but not which shirt, tie, shoes, or accessories match. Current systems recommend similar products or “frequently bought together,” not coherent looks based on style, occasion, weather, or personal preference. Merchandising has strong internal curation that is not fully data-driven or personalized. Associates and CRM lack a shared recommendation engine for assisted selling and follow-up, so styling support is inconsistent and not scalable.

**Why it matters now**  
Competitors mostly offer item-level recommendations; few fashion brands provide full outfit recommendation engines. SuitSupply can differentiate with complete looks, contextual styling, and in-store + online integration. The business is leaving basket size, cross-sell, and conversion on the table by not operationalizing style intelligence. Encoding merchandising intent into a governed, measurable platform is a strategic priority.

For extended context (current gaps, design tensions, foundational assumptions), see `docs/project/problem-statement.md`.

---

## 2. Target Users

Target users are defined as personas in `docs/project/personas.md`. Summary:

| Persona | Role | Primary need from platform |
|--------|------|----------------------------|
| **Style-Seeking Customer** | Online/omnichannel shopper | Complete-look confidence; clear “what matches” and occasion cues |
| **Returning Customer With Known Preferences** | Repeat shopper with history | Personalized suggestions that complement prior purchases; no repetitive or irrelevant recommendations |
| **In-Store Sales Associate / Client Advisor** | Store associate, RTW + CM | Fast, complete-look suggestions; context-aware recommendations tied to appointment and customer history |
| **Merchandising Manager** | Style direction, curation, governance | Curated looks, rules, approval gates, and visibility into AI recommendation performance |
| **CRM / Email Marketing Manager** | Lifecycle and campaigns | Recommendation payloads for campaigns; targeting by occasion, region, profile; brand-consistent, available looks |
| **Product Manager / Product Architect** | Roadmap, delivery, cross-functional decisions | Clear feature decomposition, stage-gated workflow, traceability across requirement → build → QA |

---

## 3. Business Value

**Outcomes**

- **Conversion:** Show coherent, occasion-aware looks instead of disconnected products to increase purchase completion.
- **Basket size:** Increase units per order via cross-sell, upsell, and style bundles (complete the look).
- **Customer lifetime value:** Learn style preferences across purchases and channels; reduce repetition and improve relevance.
- **Operational efficiency:** Scale merchandising intent via rules and curated looks; reduce ad-hoc styling logic per channel.
- **Channel consistency:** One recommendation engine for web, email, clienteling, and future personalization.

**Measurable impact (targets for platform success)**

- Conversion increase: **+5–10%** (recommendation-driven sessions vs baseline).
- Average order value (AOV) uplift: **+10–25%** where recommendations are shown and acted on.
- Recommendation attach rate: measurable **add-to-cart** and **purchase** from recommendation widgets/surfaces.
- Email engagement: lift in **open/click/conversion** for recommendation-based campaigns vs non-personalized.
- Clienteling: **follow-up conversion** and **basket size** when associates use recommended looks.

These outcomes align with the project goals in `docs/project/goals.md` (business, customer, product, and governance goals).

---

## 4. Scope Boundaries

### In scope

**Channels and surfaces**

- **Online store:** PDP (“complete the look”, “styled with”, “you may also like”), cart (“complete your outfit”), homepage/landing (“looks for you”, “trending outfits”), look builder (curated looks).
- **Email:** Personalized recommendation blocks and campaign payloads (e.g. “Looks for your next meeting”, “Summer wedding style”).
- **In-store clienteling:** Associate-facing recommendations (outfits, cross-sell, customer style profile) for RTW and CM.
- **Delivery:** APIs consumed by webstore, email assembly, clienteling tools, and (future) mobile.

**Capabilities**

- **Data ingestion:** Product catalog (PIM, Shopify, OMS, DAM, Custom Made); customer/behavioral data (orders, browsing, POS, store visits, appointments, email engagement); session/event tracking; context (location, weather, season, calendar); identity resolution across anonymous, logged-in, POS, email.
- **Customer profile engine:** Style profile, purchase affinity, segmentation, intent detection.
- **Product and outfit graph:** Product relationships (e.g. suit → shirt → tie → shoes), outfit definitions, style/fabric compatibility rules.
- **Recommendation engine:** Curated looks, rule-based logic, AI/ML strategies (collaborative filtering, co-occurrence, similarity, popularity); outfit generation; context-aware and personal recommendations.
- **Merchandising and rules:** Rule builder, pinning/suppression, category and price constraints, inventory rules; approval and override for high-visibility placements.
- **Experience delivery:** Recommendation API(s); placement and campaign configuration (where, when, which strategy); widgets (carousel, outfit card, look builder).
- **Analytics and optimization:** Recommendation CTR, add-to-cart, conversion, revenue attribution, AOV uplift; A/B and experimentation where configured.
- **Admin and governance:** Look editor, rule builder, campaign/algorithm settings, approval workflows, audit, role-based access.
- **Product modes:** RTW (immediate shoppability, stock-aware) and CM (complementary items, fabric/context, appointment-aware).

### Out of scope (explicit)

- **Dynamic PLP sorting** (e.g. sort by predicted relevance) — future capability unless explicitly added to a later BR.
- **Conversational AI stylist** (e.g. “What should I wear to a wedding?”) — future capability.
- **Visual outfit builder** (upload photo → recommend items) — future capability.
- **Full website personalization** (e.g. dynamic homepage per user) — future; initial scope is defined recommendation placements.
- **Third-party marketplaces or white-label** — not in current scope.
- **Recommendation engine replacement for non-SuitSupply brands** — single-tenant SuitSupply focus.
- **Replacing core commerce systems** (catalog, OMS, CRM) — integrate with existing systems, not replace them (see also `docs/project/goals.md` Non-Goals).

### Scope notes

- **Integrations:** In scope as needed for data (PIM, OMS, Shopify, POS, Custom Made) and activation (email/CRM, analytics). Exact system list is a missing decision where not yet committed.
- **AI model ownership:** Use of first-party vs third-party (e.g. Dynamic Yield) models and hosting is a missing decision; BRs assume a recommendation engine that can deliver the described types.

---

## 5. Business Requirements and Success Metrics

Each BR has at least one measurable success criterion. BRs are grouped by capability area and ordered to reflect logical dependency where possible (e.g. data and graph before engine and delivery).

### BR-1: Outfit and complete-look recommendations

**Description:** The platform delivers complete-look recommendations (outfit-level) and “complete the look” suggestions (cross-sell) on PDP, cart, and designated inspiration surfaces, for both RTW and CM.

**Success metrics**

- At least one measurable criterion: **Recommendation CTR** (click-through rate on outfit/cross-sell recommendations) ≥ baseline or target set at launch; or **add-to-cart rate from recommendation** (percentage of recommendation impressions that lead to add-to-cart) tracked per placement.

### BR-2: Data ingestion and identity

**Description:** Product catalog, customer behavioral data, and context data (e.g. weather, location, season) are ingested and kept up to date. Customer identity is resolved across anonymous, logged-in, POS, and email where technically and consent-wise feasible.

**Success metrics**

- At least one measurable criterion: **Data freshness** — product and inventory data within agreed SLA (e.g. &lt; 24h for catalog, defined latency for events); **identity resolution coverage** — percentage of recognized sessions that resolve to a stable customer ID where consent exists (target TBD — missing decision).

### BR-3: Customer profile and style signals

**Description:** A customer profile (or style profile) is built and maintained from orders, browsing, store visits, and stated interests. It supports personal and intent-aware recommendations.

**Success metrics**

- At least one measurable criterion: **Profile coverage** — percentage of logged-in or identified users with a non-empty style profile after N interactions (N and threshold TBD — missing decision); or **personal recommendation lift** — conversion or AOV lift for users with profiles vs without, in comparable placements.

### BR-4: Product and outfit graph

**Description:** A product graph models relationships (e.g. suit → shirt → tie → shoes). An outfit graph (or equivalent) supports curated looks and compatibility rules (style, fabric, occasion). Rules are configurable by merchandising.

**Success metrics**

- At least one measurable criterion: **Graph coverage** — percentage of key product categories (e.g. suits, shirts, ties, shoes) that participate in at least one relationship or outfit (target TBD — missing decision); **rule execution** — recommendations respect defined compatibility and suppression rules (measured by audit or sampling).

### BR-5: Recommendation strategies and algorithms

**Description:** The engine supports multiple strategies: curated looks, rule-based logic, and AI/ML (e.g. collaborative filtering, co-occurrence, similarity, popularity). It supports hybrid ranking (curated + dynamic) and context-aware filtering (weather, season, occasion, inventory).

**Success metrics**

- At least one measurable criterion: **Strategy performance** — per-strategy or per-placement metrics (CTR, add-to-cart, conversion) tracked and available for optimization; **context adherence** — when context (e.g. season, weather, occasion) is applied, recommended items align with context (measured by sampling or business review).

### BR-6: Merchandising control and governance

**Description:** Merchandisers can create and edit looks, define and edit rules (pinning, suppression, category/price/inventory constraints), and approve or override high-visibility AI recommendations. Changes are auditable and versioned where required.

**Success metrics**

- At least one measurable criterion: **Override and approval** — time from merchandising action (e.g. pin, suppress, approve look) to live effect within agreed SLA; **audit** — critical actions (rule change, look publish, suppression) are logged with identity and timestamp.

### BR-7: Delivery API and channel activation

**Description:** A stable delivery API provides recommendations (outfits, cross-sell, upsell, style bundles) to webstore, email assembly, and clienteling. Inputs include customer (or session), context, product, placement; outputs are structured for each channel and include recommendation set ID, trace ID, and (where required) reason or source hints for explainability and analytics (see `docs/project/api-standards.md`).

**Success metrics**

- At least one measurable criterion: **API availability and latency** — e.g. p95 latency &lt; X ms, availability ≥ Y% (X, Y TBD — missing decision); **channel activation** — at least web (PDP/cart/homepage) and one other channel (email or clienteling) consuming the API in production.

### BR-8: Email and CRM recommendation payloads

**Description:** Recommendation payloads are available for email and CRM (e.g. Customer.io) so campaigns can use “recommended looks” and “complete the look” content. Payloads respect audience, region, and availability where specified.

**Success metrics**

- At least one measurable criterion: **Email recommendation engagement** — open/click/conversion lift for recommendation-based campaigns vs control (or vs non-personalized) within a defined test window.

### BR-9: In-store clienteling recommendations

**Description:** Store associates (client advisors) can see recommended outfits, cross-sell items, and customer style profile (where permitted) on clienteling surfaces. Recommendations consider store/region, appointment context, and CM when relevant.

**Success metrics**

- At least one measurable criterion: **Clienteling usage and outcome** — e.g. percentage of clienteling sessions where recommendations are viewed or used; **basket size or follow-up conversion** when recommendations are used vs not (target TBD — missing decision).

### BR-10: Analytics and optimization

**Description:** Recommendation performance is measured (impression, click, add-to-cart, purchase, dismiss) with recommendation set ID and trace ID. Core metrics: recommendation CTR, add-to-cart rate, conversion, revenue attribution, AOV uplift. Support for A/B or experimentation on strategies/placements where configured.

**Success metrics**

- At least one measurable criterion: **Reporting availability** — core recommendation metrics available in agreed reporting tool or dashboard within N days of go-live; **attribution** — revenue and conversion attributable to recommendation placements (e.g. last-click or defined attribution model).

### BR-11: Admin and merchandising UI

**Description:** Admin interface supports look creation/editing, rule configuration, campaign/placement setup, algorithm/strategy selection, and preview. Role-based access and approval workflows where required by governance.

**Success metrics**

- At least one measurable criterion: **Adoption** — merchandising users can create or edit a look and publish (or submit for approval) within the tool without engineering; **time to change** — time from “request” to “live” for a typical rule or look change (target TBD — missing decision).

### BR-12: Governance and safety

**Description:** Recommendation content and rules respect brand and compliance. Sensitive or high-visibility changes can be gated by human approval. Privacy and consent are respected; customer data use is scoped to permitted use cases and regions.

**Success metrics**

- At least one measurable criterion: **Approval gates** — high-visibility or high-risk changes (as defined) require human approval before going live; **no unapproved bulk overrides** — no single action applies to all users/placements without designated approval path (policy/process measure).

---

## 6. Success Metrics Summary

| BR | Primary success metric |
|----|------------------------|
| BR-1 | Recommendation CTR or add-to-cart rate from recommendation (per placement) |
| BR-2 | Data freshness SLA; identity resolution coverage (target TBD) |
| BR-3 | Profile coverage or personal recommendation conversion/AOV lift |
| BR-4 | Graph coverage; rule execution (audit/sampling) |
| BR-5 | Per-strategy/placement performance; context adherence |
| BR-6 | Override-to-live SLA; audit log for critical actions |
| BR-7 | API latency/availability (TBD); at least two channels live |
| BR-8 | Email recommendation engagement lift vs control |
| BR-9 | Clienteling usage; basket/conversion when recommendations used |
| BR-10 | Core metrics in reporting; revenue/conversion attribution |
| BR-11 | Merchandising can publish look/rule without engineering; time-to-change (TBD) |
| BR-12 | Approval gates enforced; no unapproved bulk overrides |

---

## 7. Open Decisions

The following are **unresolved**. They are marked as **missing decision**; do not invent answers. Resolve before or during the stage where they block work.

- **Identity resolution scope and targets:** Exact definition of “identity resolution coverage,” consent boundaries, and target percentage. **Missing decision.**
- **Profile coverage and N:** Definition of “N interactions” and target percentage for “non-empty style profile.” **Missing decision.**
- **Product/outfit graph coverage targets:** Percentage of categories or SKUs that must participate in graph. **Missing decision.**
- **Delivery API SLA:** Numerical targets for latency (e.g. p95) and availability. **Missing decision.**
- **Clienteling success targets:** Numerical targets for usage rate and basket/conversion lift when recommendations are used. **Missing decision.**
- **Time-to-change for merchandising:** Target time from rule/look change request to live. **Missing decision.**
- **Attribution model:** Last-click, first-click, or other model for “revenue from recommendations.” **Missing decision.**
- **Integration ownership and roadmap:** Which systems (PIM, OMS, Shopify, POS, Custom Made, email/CRM, analytics) are committed for v1 and ownership for connectors. **Missing decision.**
- **AI/model ownership:** First-party vs third-party (e.g. Dynamic Yield) for algorithms and hosting. **Missing decision.**
- **Approval mode per BR or stage:** Which BRs or stages are HUMAN_REQUIRED vs AUTO_APPROVE_ALLOWED (see Approval / milestone notes). **Missing decision** where not yet set.
- **High-visibility placement definition:** Which placements or campaigns require human (or governed) approval before go-live; exact list for merchandising-sensitive outputs. **Missing decision.**

---

## 8. Approval / Milestone Notes

- **Approval mode:** Each BR (or stage) has an **Approval Mode**: `HUMAN_REQUIRED` or `AUTO_APPROVE_ALLOWED`. It must be explicit on the board or in the artifact; do not assume.  
  - **HUMAN_REQUIRED:** After a passing review, recommend `READY_FOR_HUMAN_APPROVAL` only; a human must approve before `APPROVED`.  
  - **AUTO_APPROVE_ALLOWED:** After a passing review and thresholds met, governed auto-approval may recommend `APPROVED` when explicitly configured.

- **Milestone human gates (examples):**  
  - **Human review at requirements approval** before feature breakdown and architecture.  
  - **Human review at UI readiness** before backend/integration continues (if applicable).  
  - **Human review before go-live** for any surface that serves customer-facing recommendations.  
  Gates must be recorded in the implementation plan or board notes so agents and humans can see dependencies.

- **BR-level note:** This BR document itself is a **requirements-stage** artifact. Progression to feature breakdown (`docs/boards/features.md`) should follow review and approval per project lifecycle. Until approval mode is set per item, treat **requirements and feature breakdown** as **HUMAN_REQUIRED** (human approval before promotion to architecture/build).

- **Merchandising-sensitive outputs:** Any placement or campaign that drives high-visibility recommendation content (e.g. homepage, hero email) should have a defined approval path (human or governed) before going live; exact list is a **missing decision**.

---

## 9. References

- **Personas:** `docs/project/personas.md`
- **Problem statement:** `docs/project/problem-statement.md`
- **Product overview:** `docs/project/product-overview.md`
- **Vision:** `docs/project/vision.md`
- **Domain and terminology:** `docs/project/domain-model.md`, `docs/project/glossary.md`, `docs/.cursor/rules/recommendation-domain-language.mdc`
- **Goals:** `docs/project/goals.md` (business, customer, product, operational, governance goals; non-goals)
- **Industry standards:** `docs/project/industry-standards-and-best-practices.md` (recommendation and personalization norms, provider approaches)
- **Operating model and approval:** `docs/project/agent-operating-model.md`, `docs/.cursor/rules/approval-and-rework.mdc`
- **Board:** `docs/boards/business-requirements.md` (lifecycle and promotion to features)
- **Architecture:** `docs/project/architecture-overview.md` (downstream of BRs; see also `docs/boards/technical-architecture.md`).
- **Roadmap:** `docs/project/roadmap.md` (phases, BR mapping, milestone gates; informs implementation plan).
- **Capability map:** `docs/project/capability-map.md` (product capabilities, personas/channels, BR traceability).
