# Product Overview

**Purpose:** High-level summary of the AI Outfit Intelligence Platform for stakeholders and downstream artifacts.  
**Source:** Vision, goals, problem statement, feature breakdown.  
**Traceability:** Feeds business requirements and capability map; referenced by architecture overview, roadmap, and implementation plan.  
**Terminology:** **Look** = product grouping (curated set of SKUs); **outfit** = customer-facing complete look. See `docs/project/glossary.md` and `docs/.cursor/rules/recommendation-domain-language.mdc`.  
**Status:** Living document; update when scope, channels, or strategic focus change.

---

## Product Summary
The AI Outfit Intelligence Platform powers personalized complete-look recommendations for SuitSupply customers and internal teams. It combines customer signals, product metadata, business rules, curated looks, and contextual inputs to generate recommendations that are relevant, on-brand, and channel-ready.

## Supported Business Modes
### Ready-to-Wear
- Emphasis on immediate shoppability, basket building, and size-available assortment.
- High-value surfaces include PDP, cart, homepage, email, and occasion-led landing pages.
- Compatibility and substitution logic must account for stock, season, and price tier.

### Custom Made
- Emphasis on guided styling around bespoke garments, appointments, fabric choices, and follow-up purchases.
- Recommendations may include complementary shirts, ties, shoes, coats, and future wardrobe extensions.
- Context such as appointment history, fabric selection, and formalwear purpose matters more heavily.

## Primary Channels
- Online store (PDP, cart, homepage, look builder).
- Email marketing and triggered CRM journeys.
- In-store clienteling.
- Future: conversational styling, mobile (same delivery API).

## Core Recommendation Types
- Outfit recommendations.
- Cross-sell recommendations.
- Upsell recommendations.
- Style bundles.
- Occasion-based recommendations.
- Contextual recommendations.
- Personal recommendations.

## Inputs
### Customer and Behavioral Inputs
- Orders and returns.
- Browsing behavior.
- Store visits.
- Appointments.
- Saved interests.
- Email engagement.

### Contextual Inputs
- Weather.
- Seasonality.
- Geography.
- Calendar context.
- Campaign context.
- Channel and placement context.

### Product and Merchandising Inputs
- Category.
- Fabric.
- Color.
- Pattern.
- Season.
- Occasion.
- Fit.
- Price tier.
- Style family.
- Merchandising curation and editorial looks.

## Key Components
- Event pipeline.
- Customer profile service.
- Product graph and outfit graph.
- Recommendation engine and context engine.
- Delivery API (recommendation set ID, trace ID, reason/source hints for attribution and explainability).
- Admin interface (looks, rules, reporting).
- Analytics and experimentation layer.

## User Value
- **Customers:** Better style confidence and faster outfit building; personalized inspiration without feeling random.
- **In-store sales associates / client advisors:** Clienteling support and follow-up selling prompts; context-aware recommendations.
- **Merchandising managers:** Control, override capability, approval gates, and performance insights.
- **Product and engineering:** A scalable recommendation platform instead of isolated channel logic.

## Initial Scope Focus
1. Product and customer data ingestion.
2. Product and outfit graph foundations.
3. Outfit recommendation and cross-sell use cases.
4. Recommendation delivery API.
5. Web and email activation.
6. Merchandising controls and analytics.

The platform integrates with existing catalog, OMS, CRM, and POS; it does not replace core commerce systems (see `docs/project/goals.md` Non-Goals).

---

## References
- `docs/project/vision.md` — Vision, north star, product principles.
- `docs/project/goals.md` — Business, customer, product, and governance goals; non-goals.
- `docs/project/problem-statement.md` — Problem statement and design tensions.
- `docs/project/business-requirements.md` — BRs, scope, success metrics.
- `docs/project/capability-map.md` — Capabilities by persona and channel.
- `docs/project/architecture-overview.md` — Layered architecture and component responsibilities.
- `docs/project/glossary.md` — Domain terms (look, outfit, placement, channel, RTW, CM, etc.).
- `docs/project/roadmap.md` — Phases, gates, and dependencies.
