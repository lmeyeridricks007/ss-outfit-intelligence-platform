# Business Requirements

## Bootstrap source

- Source issue: GitHub issue #37
- Product: AI Outfit Intelligence Platform (SuitSupply Recommendation Engine)
- Document purpose: canonical business requirements for initial project definition and later feature/architecture fan-out

## Product objective

Build a recommendation platform that helps SuitSupply recommend complete outfits and compatible product combinations across major customer channels, using a controlled blend of curated looks, business rules, contextual signals, and customer-aware personalization.

## Target users

### Primary users

- online shoppers browsing suits, shirts, shoes, and accessories
- returning customers with purchase history and style signals
- customers shopping for specific occasions such as weddings, business meetings, interviews, travel, and seasonal wardrobe needs

### Secondary users

- in-store stylists and clienteling teams
- merchandisers curating looks, rules, and campaigns
- marketing teams delivering personalized recommendation emails
- product, analytics, and optimization teams improving recommendation performance

## Business value

The product is intended to:

- increase conversion rate
- increase basket size / average order value
- increase customer lifetime value
- improve style inspiration and product discovery
- improve recommendation relevance across channels
- preserve merchandising control while enabling AI-driven personalization
- differentiate SuitSupply from competitors that recommend only similar products or co-purchase items

## Success measures

### Business targets

- conversion increase target: +5% to +10%
- average order value increase target: +10% to +25%
- stronger engagement with recommendation modules and style inspiration surfaces
- improved repeat purchase behavior and lifecycle performance
- improved recommendation-driven email and clienteling performance

### Operating measures

- recommendation coverage across required channels and recommendation types
- measurable lift by surface, segment, and experiment
- healthy fallback behavior when customer identity or context is unavailable
- operator ability to curate, suppress, or prioritize recommendation sets without engineering changes for routine tasks

## Scope boundaries

### In scope

- outfit recommendations
- cross-sell recommendations
- upsell recommendations
- curated style bundles
- occasion-based recommendations
- contextual recommendations
- personal recommendations based on customer profile and behavior
- support for RTW and CM recommendation use cases
- recommendation delivery to ecommerce, email, and clienteling surfaces
- analytics, experimentation, and merchandising governance needed for production operation

### Out of scope for bootstrap definition

- detailed downstream feature breakdowns
- board seeding and implementation issue fan-out
- replacing commerce, POS, CRM, or email platforms
- pricing optimization, search ranking, or inventory planning as separate product lines
- customer-facing social/community styling experiences

## In-scope channels and surfaces

- product detail pages
- cart
- homepage / web personalization
- style inspiration / look-builder pages
- email campaigns
- in-store clienteling interfaces
- future mobile and API-driven experiences

## Input data sources

### Customer signals

- orders from Shopify / OMS / commerce systems
- browsing behavior
- page views and product views
- add-to-cart events
- search behavior
- email engagement
- loyalty or account behavior
- store visits
- appointments
- stylist notes
- saved looks, favorites, or wishlists where available

### Context signals

- location and country
- weather
- season
- holiday and event calendar
- useful device or session context

### Product signals

- category
- fabric
- color
- pattern
- fit
- season
- occasion
- style tags
- price tier
- inventory
- imagery
- RTW and CM attributes

## Business requirements

### BR-001 Product catalog ingestion and normalization

The platform must ingest and normalize product data for both RTW and CM so recommendation logic can rely on a consistent set of catalog attributes, identifiers, imagery, and availability-related signals.

### BR-002 Customer signal ingestion

The platform must ingest customer activity and outcome signals from relevant commerce, marketing, and store systems to support personalization, segmentation, and measurement.

### BR-003 Identity resolution

The platform must support cross-channel identity resolution for customers and preserve confidence-aware mappings between source-system identifiers and canonical customer identities.

### BR-004 Customer profile service

The platform must maintain a usable profile of customer behavior, purchase history, preferences, and consent-aware eligibility for recommendation use cases.

### BR-005 Look and relationship modeling

The platform must represent:

- curated looks
- product compatibility relationships
- exclusions and incompatibilities
- cross-category complements
- RTW and CM-specific styling relationships

### BR-006 Recommendation generation

The platform must generate recommendation sets for:

- outfit recommendations
- cross-sell recommendations
- upsell recommendations
- curated style bundles
- occasion-based recommendations
- contextual recommendations
- personal recommendations

### BR-007 Context-aware decisioning

The platform must incorporate context such as location, country, season, weather, holiday/event calendar, and session context when those signals materially improve recommendation quality.

### BR-008 Omnichannel delivery

The platform must support recommendation delivery patterns appropriate for web surfaces, email workflows, clienteling interfaces, and future API-driven channels.

### BR-009 Recommendation delivery API

The platform must expose a recommendation delivery interface that can accept inputs such as customer ID, product ID, and context, and return structured recommendation sets including outfits, cross-sell, upsell, and style bundles.

### BR-010 Merchandising controls

The platform must provide business users with controls for:

- curating looks
- defining compatibility rules
- prioritizing or suppressing outputs
- managing campaigns and seasonal overlays
- preserving brand and assortment consistency

### BR-011 Analytics and experimentation

The platform must support telemetry, attribution, and experimentation so teams can measure recommendation performance and iterate safely.

### BR-012 Governance and privacy

The platform must honor consent, region-aware data usage constraints, auditability expectations, and internal governance over recommendation rules and customer data usage.

### BR-013 Availability and assortment awareness

The platform must account for inventory or sellability-related constraints so recommendations remain commercially useful and channel-appropriate.

### BR-014 RTW and CM coexistence

The platform must share a common operating model across RTW and CM while preserving scenario-specific logic for configured garments, premium options, fabric combinations, and appointment-driven flows.

## Major workflows

### Workflow 1: Product detail page recommendation

1. Shopper views a product.
2. Surface requests recommendations using product, session, and optional customer context.
3. Platform applies look relationships, compatibility rules, context, and ranking logic.
4. Surface receives a recommendation set containing complete-look and complementary options.

### Workflow 2: Occasion and context recommendation

1. Shopper expresses or implies an occasion or seasonal intent.
2. Platform combines context, catalog tags, and known customer signals.
3. Output favors a smaller set of coherent outfits or bundles for the use case.

### Workflow 3: Personalized repeat-customer recommendation

1. Known customer returns or is targeted through marketing/clienteling.
2. Platform uses purchase history, browsing behavior, and style patterns when allowed.
3. Recommendations reflect likely preferences and avoid low-value repetition where possible.

### Workflow 4: Clienteling recommendation

1. Associate requests recommendations for a customer or appointment.
2. Platform uses profile, prior purchases, and curated rules.
3. Associate can review, adapt, and act on the recommendation output.

### Workflow 5: CM recommendation

1. Customer configures or considers a custom garment.
2. Platform applies CM-specific styling compatibility and premium-option logic.
3. Output supports styling decisions around shirts, ties, palettes, fabrics, and related products.

## Constraints

- Must integrate with existing commerce, order, marketing, and store systems rather than replace them.
- Must preserve merchandising control instead of acting as an ungoverned black box.
- Must operate with incomplete identity or context data and provide sensible fallback behavior.
- Must support regional privacy and consent expectations before using customer data for personalization.
- Must support both anonymous and known-customer use cases.
- Must avoid recommendation patterns that conflict with brand presentation or product compatibility.

## Assumptions

- SuitSupply can provide catalog attributes rich enough to model compatibility and style relationships.
- At least some customer identity resolution across channels is feasible.
- Weather, season, and geography signals are available or can be integrated for relevant markets.
- Merchandising teams are willing to curate looks and rules that seed recommendation quality.
- Early releases will focus on a subset of channels before all surfaces are activated.

## Open questions

- Which channel should be the first production launch surface: PDP, cart, homepage, email, or clienteling?
- What is the first supported geography, and how should regional assortment differences be handled?
- Which source systems are authoritative for customer identity, product availability, and stylist notes?
- How should CM recommendation scope be phased relative to RTW?
- What level of operator tooling is required in phase one versus later phases?
- What legal or policy constraints apply to stylist notes, store visits, and email engagement data by region?
- What recommendation explainability needs exist for internal users and customer-facing surfaces?

## Governance notes

- Bootstrap source of truth: this document plus the other canonical docs in `docs/project/`
- Downstream work should preserve traceability from these business requirements into feature breakdowns, architecture, implementation plans, and build artifacts.
- Open questions must remain explicit until resolved; downstream docs should not assume answers without recording the decision source.
