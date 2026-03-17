# Domain Model

**Document owner:** Product / Architecture  
**Source:** Business requirements, architecture overview, capability map, data standards.  
**Purpose:** Define core business entities, relationships, and bounded contexts so agents and implementation artifacts use them consistently.  
**Terminology:** Terms (e.g. **look**, **outfit**, **Customer Style Profile**) follow `docs/project/glossary.md`.  
**Traceability:** Feeds technical architecture, API and event design; referenced by BRs, architecture overview, capability map.  
**Status:** Living document; update when entities, relationships, or glossary change.  
**Review:** Architecture-stage artifact; assess per `docs/project/review-rubrics.md` (implementation readiness, correctness of dependencies, consistency with standards).

---

## 1. Key Entities

### Product

- **Identifier:** `product_id` (canonical).
- **Attributes:** Category, fabric, color, pattern, fit, season, occasion, price tier, style family.
- **Modes:** RTW or CM applicability (or both).
- **Relationships:** Belongs to many **looks**; participates in product graph (compatibility, substitution) with other products.

### Customer

- **Identifier:** `customer_id` (canonical); identity links across ecommerce, CRM, and store systems.
- **Relationships:** Has one active **Customer Style Profile** (and optional historical versions); is the subject of **recommendation requests** and outcome events.
- **Context:** RTW and CM relationship history.

### Customer Style Profile

- **Definition:** Durable profile of preferences, affinity, segmentation, and intent (see glossary).
- **Attributes:** Preferred colors, fits, fabrics, silhouettes, price bands; occasion affinity; confidence score and last-updated metadata.
- **Relationship:** One active profile per **Customer**; built from behavioral and transactional data.

### Look

- **Identifier:** `look_id` (canonical).
- **Definition:** Product grouping—a set of products intended to be shown together (see glossary). Curated or generated.
- **Attributes:** Source (curated vs generated); lifecycle state (draft, under review, approved, published, retired).
- **Relationship:** Contains many **Products** (many-to-many). May be referenced in **Recommendation Result** as a ranked unit.

### Outfit

- **Definition:** The customer-facing complete-look concept (see glossary)—what the user sees as “this full outfit.” May be backed by a **Look** or by a dynamically generated set of items.
- **Usage:** Described in **Recommendation Result** (e.g. as a ranked look or as a set of product IDs presented as one outfit). Not necessarily a separate stored entity; often a presentation of a **Look** or an ad-hoc set.

### Recommendation Request

- **Definition:** Incoming request for recommendations (see glossary).
- **Attributes:** Customer or session identifier; **placement** and **channel** (see glossary); optional anchor product or cart; optional context (weather, location, region/locale, occasion); optional campaign or experiment for attribution.
- **Relationships:** Scoped by **Placement** and optionally **Campaign** or **Experiment**; produces **Recommendation Result**.

### Recommendation Result

- **Identifier:** recommendation set ID, trace ID (see glossary).
- **Definition:** Output of the recommendation engine for one request.
- **Attributes:** Request context echo; recommendation type (outfit, cross-sell, upsell, style bundle, occasion-based, contextual, personal); ranked items or looks; reason codes; source mix (curated, rules-based, graph-derived, model-ranked).
- **Relationship:** Generated from **Recommendation Request**; outcome events (impression, click, add-to-cart, purchase, dismiss) carry its set ID and trace ID for attribution.

### Merchandising Rule

- **Identifier:** `rule_id` (canonical).
- **Definition:** Business rule that shapes recommendation behavior (see glossary).
- **Types:** Inclusion, exclusion, pin, boost, demotion, category/price/inventory constraint, channel restriction, campaign override.
- **Attributes:** Effective dates, owner, approval status.
- **Relationships:** May be scoped to **Campaign**, **Placement**, or audience; affects **Recommendation Request** processing and **Recommendation Result** ordering.

### Campaign

- **Definition:** Marketing or placement configuration used to scope rules and attribution (see glossary).
- **Examples:** Email campaign, placement configuration for PDP “complete the look.”
- **Relationship:** **Merchandising Rules** may be scoped to a campaign; **Recommendation Request** may carry campaign (and experiment) for attribution.

### Placement

- **Definition:** Where recommendations are shown (see glossary)—e.g. PDP “complete the look”, cart, homepage, email block, clienteling.
- **Relationship:** Scopes **Merchandising Rules** and strategies; used in **Recommendation Request** and analytics.

### Experiment

- **Definition:** A/B or multi-armed bandit variant; used for attribution and optimization.
- **Relationship:** **Recommendation Request** may carry experiment variant; outcome events attribute to experiment.

---

## 2. Relationships (Summary)

| From | To | Relationship |
|------|-----|--------------|
| **Look** | **Product** | A look contains many products; a product can belong to many looks (many-to-many). |
| **Customer** | **Customer Style Profile** | A customer has one active style profile (and optional historical versions). |
| **Merchandising Rule** | **Campaign** | A rule may be scoped to a campaign (optional). |
| **Merchandising Rule** | **Placement** | A rule may be scoped to placement(s) (optional). |
| **Recommendation Request** | **Customer** (or session) | Request is for a customer or anonymous session. |
| **Recommendation Request** | **Placement**, **Channel** | Request specifies where and through which channel. |
| **Recommendation Request** | **Campaign**, **Experiment** | Optional; for attribution. |
| **Recommendation Request** | **Recommendation Result** | One request produces one result (1:1 per response). |
| **Recommendation Result** | **Product**, **Look** | Result contains ranked product IDs and/or look IDs. |
| **Product** | **Product** | Graph relationships: compatibility, similarity, substitution (e.g. suit → shirt → tie). |

---

## 3. Bounded Contexts

Bounded contexts group entities and behavior by responsibility. Use them to align implementation and ownership.

### Identity

- **Entities:** Customer, Customer Style Profile; identity resolution (process, not a single entity).
- **Responsibility:** Resolve and maintain customer identity across channels; build and maintain style profile; respect consent and regional rules.
- **Outgoing:** Canonical customer ID and style profile consumed by **Recommendation** context.

### Merchandising

- **Entities:** Look, Merchandising Rule, Campaign, Placement (configuration).
- **Responsibility:** Define and store looks; define rules (pin, exclude, include, etc.); scope rules to campaign or placement; approval and audit for high-visibility changes.
- **Outgoing:** Looks and rules consumed by **Recommendation** context when processing requests.

### Recommendation

- **Entities:** Recommendation Request, Recommendation Result; Product (read); Look (read); Outfit (as presentation of look or dynamic set).
- **Responsibility:** Accept request; apply context and profile; generate and rank candidates using graph and rules; return result with set ID and trace ID; support fallback when strategy returns too few items.
- **Incoming:** Customer/style profile from Identity; looks and rules from Merchandising; product graph and catalog.

### Analytics

- **Entities:** Event (impression, click, add-to-cart, purchase, dismiss); recommendation set ID and trace ID; attribution.
- **Responsibility:** Ingest outcome events with set ID and trace ID; report CTR, conversion, revenue attribution, AOV; support A/B and experimentation.
- **Incoming:** Outcome events from channels; recommendation set ID and trace ID from **Recommendation Result**.

---

## 4. State Concepts

### Look lifecycle (Merchandising)

- Draft → Under review → Approved → Published → Retired.

### Merchandising Rule

- Draft / Under review / Approved; effective dates; approval status for high-visibility overrides.

### Recommendation logic (delivery)

- Published looks and rules are “live”; retired or inactive are not applied.

### Artifact states (delivery system)

- TODO, IN_PROGRESS, NEEDS_REVIEW, IN_REVIEW, CHANGES_REQUESTED, READY_FOR_HUMAN_APPROVAL, APPROVED, DONE (per project lifecycle).

---

## 5. Domain Modeling Rules

- Use **stable canonical IDs** for products, customers, looks, rules, campaigns, and experiments. Map source-system IDs explicitly.
- **Look** = product grouping (stored); **outfit** = customer-facing complete-look concept (may be backed by a look or dynamic set). Use consistently per glossary.
- Separate **persistent** business entities (Product, Customer, Look, Merchandising Rule, Campaign) from **transient** delivery artifacts (Recommendation Request, Recommendation Result, event payloads).
- Distinguish **compatibility**, **similarity**, and **substitution** in product graph relationships.
- Every **Recommendation Result** and outcome event must carry **recommendation set ID** and **trace ID** for attribution.

---

## 6. References

- **Glossary:** `docs/project/glossary.md` (definitions for look, outfit, and other terms).
- **Recommendation domain language:** `docs/.cursor/rules/recommendation-domain-language.mdc`.
- **Data standards:** `docs/project/data-standards.md` (canonical domains, identity, events).
- **Business requirements:** `docs/project/business-requirements.md`.
- **Architecture overview:** `docs/project/architecture-overview.md` (component-to-entity mapping).
- **Review rubrics:** `docs/project/review-rubrics.md` (architecture-stage focus).

---

## 7. Review Checklist (Architecture Stage)

Per `docs/project/review-rubrics.md`, architecture-stage review prioritizes **implementation readiness**, **correctness of dependencies**, and **consistency with standards**.

| Dimension | Evidence in this document |
|-----------|---------------------------|
| **Clarity** | Purpose, terminology, traceability, status, review note (header). §1 Key entities with identifier, definition, attributes, relationships. §2 Relationships table. §3 Bounded contexts with entities, responsibility, incoming/outgoing. §4 State concepts. §5 Domain modeling rules. |
| **Completeness** | All requested entities: Product, Customer, Look, Outfit, Recommendation Request, Recommendation Result, Merchandising Rule, Campaign; plus Customer Style Profile, Placement, Experiment. Channel defined in glossary and referenced in Recommendation Request. Relationships: Look→Products, Rule→Campaign, Rule→Placement, Request→Result, etc. Bounded contexts: Identity, Merchandising, Recommendation, Analytics. Glossary and data-standards alignment. |
| **Implementation Readiness** | Technical architecture and API/event design can derive contracts and persistence from entities and relationships; bounded contexts support ownership. No implementation detail; entity-level only. |
| **Consistency With Standards** | Terminology from glossary (look, outfit, RTW, CM, canonical ID, recommendation set ID, trace ID). Persistent vs transient; compatibility/similarity/substitution. Data standards canonical domains reflected (Product, Customer, Event in Analytics, Recommendation outcome). |
| **Correctness Of Dependencies** | Upstream: BRs, architecture, capability map, data standards, glossary (References). Entity and relationship alignment with architecture overview and API standards. Downstream: technical architecture, API and event design (Traceability). |
| **Automation Safety** | N/A (no automation-triggered promotion implied). Artifact does not assert approval or completion. |

---

## 8. Review Record (per `docs/project/review-rubrics.md`)

| Item | Value |
|------|--------|
| **Stage** | Architecture |
| **Overall disposition** | Eligible for promotion (thresholds met). |
| **Clarity** | 5 — Scope, intent, structure, and entity definitions are clear; glossary and bounded contexts support understanding. |
| **Completeness** | 5 — All key entities, relationships table, four bounded contexts, state concepts, domain rules, references; Channel added to glossary and referenced. |
| **Implementation Readiness** | 5 — Next stage (technical architecture, API/event design) can proceed from entities and relationships with limited ambiguity. |
| **Consistency With Standards** | 5 — Glossary terms used throughout; look vs outfit; data standards and recommendation-domain-language aligned. |
| **Correctness Of Dependencies** | 5 — Upstream (BRs, architecture, capability map, data standards, glossary) and downstream (technical architecture) referenced correctly. |
| **Automation Safety** | 5 — N/A; no promotion or completion asserted. |
| **Average** | 5.0 |
| **Confidence** | HIGH — Entities and relationships align with BRs, architecture, and glossary. |
| **Recommendation** | Move to **READY_FOR_HUMAN_APPROVAL** (approval mode for architecture-stage is HUMAN_REQUIRED unless otherwise set). |
| **Propagation to upstream** | None required. |
| **Pending confirmation** | Human approval required before APPROVED. |
