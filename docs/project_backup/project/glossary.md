# Glossary

**Purpose:** Define terms used consistently across project artifacts (domain model, business requirements, architecture, capability map). When in doubt, use these definitions.

---

## Core domain terms

| Term | Definition | Used in |
|------|------------|--------|
| **look** | A product grouping: a set of products intended to be shown together (curated or generated). Identified by `look_id`. Stored and managed in the platform; has lifecycle (draft, review, approved, retired). | Domain model, BRs, recommendation-domain-language, capability map |
| **outfit** | The customer-facing complete-look concept: the coherent look presented to the user (e.g. “this full outfit”). May be backed by a **look** or by a dynamically generated set of items. | Domain model, BRs, recommendation-domain-language |
| **Product** | A catalog item (e.g. suit, shirt, tie). Has `product_id`, category, fabric, color, pattern, fit, season, occasion, price tier; RTW or CM applicability. | Domain model, data standards, API |
| **Customer** | Identity-resolved person with `customer_id`; may have identity links across ecommerce, CRM, and store systems. | Domain model, identity standards |
| **Customer Style Profile** | A durable profile of preferences, affinity, segmentation, and intent derived from behavior and stated interests; supports personal and intent-aware recommendations. One active profile per customer (plus historical versions). | Domain model, BRs, capability map |
| **Merchandising Rule** | A business rule that shapes recommendation behavior: pin, include, exclude, boost, demotion, category/price/inventory constraint, channel or campaign override. Has `rule_id`, effective dates, owner, approval status. | Domain model, BRs, architecture |
| **Campaign** | A marketing or placement configuration (e.g. email campaign, placement on PDP) that may scope **merchandising rules** or **recommendation requests** and is used for attribution. | Domain model, architecture |
| **Placement** | Where recommendations are shown (e.g. PDP “complete the look”, cart, homepage, email block, clienteling). Used to scope rules and strategies and for analytics. | Domain model, API, analytics |
| **Channel** | The surface or system through which the user is interacting (e.g. Webstore, Email, Clienteling). Used with placement in **Recommendation Request** and analytics. | Domain model, API, analytics |
| **Recommendation Request** | The incoming request for recommendations: customer/session, context (anchor product or cart, placement, channel), optional campaign or experiment. | Domain model, API standards |
| **Recommendation Result** | The output of the recommendation engine: recommendation set ID, trace ID, ranked items or looks, recommendation type, reason/source hints. | Domain model, API standards |
| **recommendation set ID** | Stable identifier for a single recommendation response; carried on all outcome events for attribution. | Data standards, API, recommendation-domain-language |
| **trace ID** | Identifier for a single request/response trace; used for debugging and attribution. | Data standards, API |
| **RTW** | Ready-to-Wear: emphasis on immediate shoppability, stock, basket building. | Product overview, BRs, recommendation-domain-language |
| **CM** | Custom Made: emphasis on appointments, fabric context, complementary items, follow-up. | Product overview, BRs, recommendation-domain-language |

---

## Recommendation types and sources

| Term | Definition |
|------|------------|
| **recommendation type** | Classification of output: outfit, cross-sell, upsell, style bundle, occasion-based, contextual, personal. |
| **curated** | Recommendation source: human-curated (e.g. merchandising-defined look). |
| **rule-based** | Recommendation source: explicit rules (e.g. compatibility, pin, exclude). |
| **AI-ranked** | Recommendation source: model or algorithm (e.g. collaborative filtering, co-occurrence). |
| **source mix** | Indication of how a result was produced: curated, rules-based, graph-derived, model-ranked. |

---

## Identity and governance

| Term | Definition |
|------|------------|
| **canonical ID** | Stable identifier used within the platform (e.g. `product_id`, `customer_id`, `look_id`, `rule_id`). Source-system IDs are mapped to canonical IDs. |
| **identity resolution** | Process of merging anonymous, logged-in, POS, and email identities into a stable customer view; **identity resolution confidence** is recorded when merging. |
| **consent** | Customer permission for data use; must be respected per use case and region. |

---

## References

- **Domain model:** `docs/project/domain-model.md` (entities and relationships using these terms).
- **Recommendation domain language:** `docs/.cursor/rules/recommendation-domain-language.mdc`.
- **Data standards:** `docs/project/data-standards.md`.
