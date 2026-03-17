# Capability Map

**Document owner:** Product  
**Source:** Business requirements, product overview, personas, architecture overview.  
**Purpose:** List product-level capabilities the platform must deliver, with personas/channels served and BR traceability. No implementation detail—capability and outcome focused.  
**Traceability:** Feeds feature breakdown (`docs/boards/features.md`) and architecture; referenced by `docs/project/business-requirements.md`.  
**Status:** Living document; update when BRs, scope, or channels change.  
**Review:** Requirements-stage artifact; assess per `docs/project/review-rubrics.md` (clarity, completeness, business correctness).

---

## Document scope

- **Product modes:** Capabilities apply to both RTW (stock-aware, immediate shoppability) and CM (appointment, fabric, complementary items) unless stated otherwise; clienteling explicitly serves both.
- **Channels:** Webstore (PDP, cart, homepage, look builder), Email, Clienteling, Admin; future mobile consumes same API (no separate capability list).

---

## 1. Data and Identity

| Capability | Description | Personas / channels served | BR(s) |
|------------|-------------|----------------------------|-------|
| **Ingest product and catalog data** | Keep product catalog, inventory, and product metadata up to date from source systems so recommendations use current, shoppable assortment. | Merchandising Manager (indirect); all channels that show product recommendations | BR-2 |
| **Ingest customer behavioral data** | Capture orders, browsing, cart actions, store visits, appointments, and email engagement so the platform can build profiles and improve recommendations. | Returning Customer, Style-Seeking Customer (indirect); CRM (campaigns); all channels | BR-2 |
| **Ingest context data** | Bring in weather, location, season, and calendar context so recommendations can be occasion- and environment-aware. | Style-Seeking Customer, In-Store Sales Associate / Client Advisor (indirect); all delivery channels | BR-2 |
| **Resolve customer identity across channels** | Merge anonymous, logged-in, POS, and email identities into a stable customer view (with consent) so behavior and preferences are recognized across touchpoints. | Returning Customer, CRM / Email Marketing Manager; Webstore, Email, Clienteling | BR-2, BR-12 |

---

## 2. Customer Profile and Style Signals

| Capability | Description | Personas / channels served | BR(s) |
|------------|-------------|----------------------------|-------|
| **Build and maintain customer style profile** | Maintain a durable style profile (preferences, affinity, segmentation, intent) from behavior and stated interests so recommendations can be personal and intent-aware. | Returning Customer With Known Preferences, Style-Seeking Customer; Webstore, Email, Clienteling | BR-3 |

---

## 3. Product and Outfit Graph

| Capability | Description | Personas / channels served | BR(s) |
|------------|-------------|----------------------------|-------|
| **Model product relationships and compatibility** | Represent how products relate (e.g. suit → shirt → tie → shoes) and which items are compatible by style, fabric, and occasion so the engine can suggest coherent looks. | Merchandising Manager (indirect); all recommendation surfaces | BR-4 |
| **Store and manage curated looks** | Store outfit definitions and curated looks (product sets meant to be shown together) with compatibility rules that merchandising can configure. | Merchandising Manager; Admin; all delivery channels that show looks | BR-4, BR-6 |

---

## 4. Recommendation Intelligence

| Capability | Description | Personas / channels served | BR(s) |
|------------|-------------|----------------------------|-------|
| **Generate outfit and complete-the-look recommendations** | Produce complete looks and “complete the look” (cross-sell) suggestions using curated looks, rules, and ranking so customers see coherent outfits and next-best items. | Style-Seeking Customer, Returning Customer, In-Store Sales Associate / Client Advisor; Webstore, Email, Clienteling | BR-1, BR-5 |
| **Apply context-aware filtering** | Filter and rank recommendations by weather, season, occasion, location, and inventory so suggestions fit the moment and are shoppable. | Style-Seeking Customer, In-Store Sales Associate / Client Advisor; Webstore, Email, Clienteling | BR-5 |
| **Apply merchandising rules** | Apply pin, include, exclude, category, price, and inventory rules so merchandising controls what appears where; rules override raw algorithm output. | Merchandising Manager; all channels that receive recommendations | BR-6, BR-12 |
| **Support multiple recommendation strategies and fallbacks** | Support curated, rule-based, and AI/ML strategies (e.g. collaborative filtering, co-occurrence, similarity, popularity) with fallbacks so placements never return empty or broken. | All customer-facing personas; Webstore, Email, Clienteling | BR-5, BR-1 |

---

## 5. Delivery and Channel Activation

| Capability | Description | Personas / channels served | BR(s) |
|------------|-------------|----------------------------|-------|
| **Deliver recommendations via API** | Expose a single recommendation API so web, email, and clienteling can request outfits, cross-sell, upsell, and style bundles with set ID and trace ID for attribution. | CRM / Email Marketing Manager, Product Manager; Webstore, Email, Clienteling | BR-7 |
| **Recommend outfit on PDP** | Surface complete-the-look, “styled with,” and “you may also like” recommendations on the product detail page so customers see what matches and what to add. | Style-Seeking Customer, Returning Customer; Webstore (PDP) | BR-1, BR-7 |
| **Recommend complete the look on cart** | Surface “complete your outfit” recommendations on the cart so customers can add complementary items before checkout. | Style-Seeking Customer, Returning Customer; Webstore (cart) | BR-1, BR-7 |
| **Recommend looks on homepage and landing** | Surface “looks for you,” “trending outfits,” and inspiration on homepage and landing pages so customers discover curated and personalized looks. | Style-Seeking Customer, Returning Customer; Webstore (homepage, landing) | BR-1, BR-7 |
| **Provide recommendation payloads for email and CRM** | Supply recommendation content (e.g. “recommended looks,” “complete the look”) for email and CRM campaigns, respecting audience, region, and availability. | CRM / Email Marketing Manager; Email | BR-8 |
| **Provide in-store clienteling recommendations** | Supply recommended outfits, cross-sell items, and (where permitted) customer style profile to associate-facing surfaces, with store/region and appointment context for RTW and CM. | In-Store Sales Associate / Client Advisor; Clienteling | BR-9 |

---

## 6. Analytics and Optimization

| Capability | Description | Personas / channels served | BR(s) |
|------------|-------------|----------------------------|-------|
| **Measure recommendation performance and attribution** | Measure impression, click, add-to-cart, purchase, and dismiss with recommendation set ID and trace ID; report CTR, conversion, revenue attribution, and AOV by placement and strategy. | Merchandising Manager, CRM / Email Marketing Manager, Product Manager; all channels | BR-10 |
| **Support A/B and experimentation on recommendations** | Allow testing of strategies, layouts, and rules with defined primary metrics and attribution so teams can optimize recommendation performance. | Merchandising Manager, CRM / Email Marketing Manager; all channels | BR-10 |

---

## 7. Admin and Governance

| Capability | Description | Personas / channels served | BR(s) |
|------------|-------------|----------------------------|-------|
| **Admin: create and edit looks** | Let merchandising create and edit curated looks and publish (or submit for approval) without engineering so looks stay current and on-brand. | Merchandising Manager; Admin | BR-11, BR-6 |
| **Admin: define and edit merchandising rules** | Let merchandising define and edit pin, exclude, include, category, price, and inventory rules with targeting and scheduling so recommendation behavior is controllable. | Merchandising Manager; Admin | BR-11, BR-6 |
| **Admin: configure placement and campaign** | Let merchandising and CRM configure where recommendations appear, which strategy applies, and campaign/placement settings with preview. | Merchandising Manager, CRM / Email Marketing Manager; Admin | BR-11 |
| **Enforce approval and audit for high-visibility changes** | Require human or governed approval for high-visibility or high-risk recommendation content; log critical actions (rule change, look publish, suppression) with identity and timestamp. | Merchandising Manager; Admin; all channels (safety) | BR-12, BR-6 |
| **Respect privacy and consent in data use** | Use customer data only for permitted use cases and regions; respect consent and opt-out; do not expose sensitive profile reasoning to customer-facing surfaces. | All personas (trust); all channels | BR-12 |

---

## 8. Look Builder (Customer-Facing)

| Capability | Description | Personas / channels served | BR(s) |
|------------|-------------|----------------------------|-------|
| **Let customers explore curated looks (look builder)** | Let customers browse and explore curated looks as a dedicated surface, with recommendations delivered via the same API as PDP and cart. | Style-Seeking Customer, Returning Customer; Webstore (look builder) | BR-1, BR-7 |

---

## 9. Summary by Persona

| Persona | Primary capabilities served |
|---------|-----------------------------|
| **Style-Seeking Customer** | Build style profile; generate outfit/complete-the-look; context-aware filtering; recommend on PDP, cart, homepage; look builder |
| **Returning Customer With Known Preferences** | Build style profile; generate outfit/complete-the-look; context-aware filtering; recommend on PDP, cart, homepage; look builder |
| **In-Store Sales Associate / Client Advisor** | Resolve identity; build style profile; generate outfit/complete-the-look; context-aware filtering; clienteling recommendations |
| **Merchandising Manager** | Ingest catalog (indirect); model relationships; store/manage looks; apply merchandising rules; admin create/edit looks and rules; configure placement; approval and audit; measure performance; A/B and experimentation |
| **CRM / Email Marketing Manager** | Resolve identity; deliver via API; recommendation payloads for email; configure placement; measure performance; A/B and experimentation |
| **Product Manager / Product Architect** | Deliver via API; measure performance and attribution (traceability and planning) |

---

## 10. Summary by Channel

| Channel | Primary capabilities |
|---------|----------------------|
| **Webstore (PDP)** | Recommend outfit on PDP |
| **Webstore (cart)** | Recommend complete the look on cart |
| **Webstore (homepage, landing)** | Recommend looks on homepage and landing |
| **Webstore (look builder)** | Let customers explore curated looks |
| **Email** | Provide recommendation payloads for email and CRM; deliver via API |
| **Clienteling** | Provide in-store clienteling recommendations; deliver via API; resolve identity; style profile (where permitted) |
| **Admin** | Create/edit looks; define/edit rules; configure placement and campaign; approval and audit |
| **Future mobile** | Same capabilities as Webstore via same API (no separate capability list; in scope as future) |

---

## 11. References

- **Business requirements:** `docs/project/business-requirements.md` (BRs and success metrics).
- **Product overview:** `docs/project/product-overview.md` (channels, recommendation types).
- **Personas:** `docs/project/personas.md` (persona definitions and needs).
- **Architecture overview:** `docs/project/architecture-overview.md` (component-to-BR mapping).
- **Review rubrics:** `docs/project/review-rubrics.md` (requirements-stage focus: clarity, completeness, business correctness).

---

## 12. Review Checklist (Requirements Stage)

Per `docs/project/review-rubrics.md`, requirements-stage review prioritizes **clarity**, **completeness**, and **business correctness**. Use this checklist when scoring.

| Dimension | Evidence in this document |
|-----------|---------------------------|
| **Clarity** | Purpose, traceability, status, and review note (header); Document scope (product modes, channels). Structure: capability areas 1–8 with consistent table (name, description, personas/channels, BRs). Summaries by persona (§9) and channel (§10). |
| **Completeness** | All 12 BRs mapped to at least one capability. All 6 personas and all in-scope channels (Webstore, Email, Clienteling, Admin; future mobile noted). RTW/CM and document scope stated. References (§11) and traceability in header. |
| **Implementation Readiness** | Feature breakdown and architecture can use capability-to-BR and capability-to-persona/channel mapping without re-deriving from BRs. No implementation detail; product-level only. |
| **Consistency With Standards** | Terminology: look, outfit, RTW, CM per project. Persona names match `docs/project/personas.md`. BR identifiers match `docs/project/business-requirements.md`. Paths use `docs/project/` and `docs/boards/`. |
| **Correctness Of Dependencies** | Upstream: BRs, product overview, personas, architecture (References). BR mappings verified against BR document. Downstream: feature breakdown, architecture (Traceability in header). |
| **Automation Safety** | N/A (no automation-triggered promotion implied). Artifact does not assert approval or completion. |

---

## Review Record (per `docs/project/review-rubrics.md`)

| Item | Value |
|------|--------|
| **Stage** | Requirements |
| **Overall disposition** | Eligible for promotion (thresholds met). |
| **Clarity** | 5 — Scope, intent, structure, and document scope are clear. |
| **Completeness** | 5 — All 12 BRs, 6 personas, all channels; RTW/CM and future mobile covered; references and traceability explicit. |
| **Implementation Readiness** | 5 — Feature breakdown and architecture can use capability-to-BR and persona/channel mapping. |
| **Consistency With Standards** | 5 — Terminology (look, outfit, RTW, CM); persona names match personas.md; BR IDs match business-requirements.md. |
| **Correctness Of Dependencies** | 5 — Upstream (BRs, product overview, personas, architecture) and downstream (feature breakdown, architecture) referenced correctly. |
| **Automation Safety** | 5 — N/A; no promotion or completion asserted. |
| **Average** | 5.0 |
| **Confidence** | HIGH — Inputs stable; BR and persona coverage verified. |
| **Recommendation** | Move to **READY_FOR_HUMAN_APPROVAL** (approval mode for requirements-stage is HUMAN_REQUIRED unless otherwise set). |
| **Propagation to upstream** | None required — no human rejection comments. |
| **Pending confirmation** | Human approval required before APPROVED; no GitHub Actions or merge dependency for this artifact. |
