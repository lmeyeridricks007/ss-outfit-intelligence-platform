# Product Overview

## What the product is

The AI Outfit Intelligence Platform is a shared recommendation system for SuitSupply that generates complete-look and context-aware recommendations across ecommerce, marketing, and stylist-assisted channels. It combines:

- curated looks from merchandisers
- compatibility and business rules
- customer profile and behavior signals
- contextual signals such as location, season, weather, and occasion
- AI ranking and selection logic

The product supports both:

- **RTW (Ready-to-Wear)** recommendations for standard catalog products
- **CM (Custom Made)** recommendations for compatible styling choices and premium option guidance around configured garments

## Core recommendation outputs

The platform should support these recommendation types:

- outfit recommendations
- cross-sell recommendations
- upsell recommendations
- curated style bundles
- occasion-based recommendations
- contextual recommendations
- personal recommendations based on customer profile and behavior

## Primary surfaces and channels

Recommendations should be consumable by:

- product detail pages
- cart
- homepage and web personalization surfaces
- style inspiration or look-builder pages
- email campaigns
- in-store clienteling interfaces
- future mobile or API-driven experiences

## Major user journeys

### 1. Product-led outfit completion

1. Customer views a product such as a suit or jacket.
2. The platform identifies compatible complements and complete-look options.
3. The surface presents a mix of outfit, cross-sell, and upsell recommendations.
4. Customer adds individual items or a curated bundle to cart.

### 2. Occasion-driven styling

1. Customer expresses intent through search, navigation, campaign entry, or explicit occasion selection.
2. Context and product availability narrow the recommendation space.
3. The platform returns a set of occasion-appropriate outfits or bundles.
4. Customer refines or purchases based on formality, weather, and style preference.

### 3. Personalized repeat engagement

1. Known customer returns via site, email, or stylist-assisted interaction.
2. The platform uses profile, purchase history, and behavior signals with consent-aware logic.
3. Recommendations prioritize relevant additions, upgrades, and complementary looks.
4. Telemetry and conversion outcomes feed later optimization.

### 4. Stylist-assisted selling

1. A stylist or clienteling interface requests recommendations for a customer, appointment, or selected garment.
2. The platform blends customer history, curated looks, and compatibility rules.
3. The stylist reviews and refines the output.
4. Outcome events and overrides are recorded for analysis.

### 5. Custom Made styling assistance

1. Customer configures or explores a CM garment.
2. The platform recommends compatible shirt styles, tie styles, color palettes, fabrics, and premium options.
3. CM-specific compatibility rules and styling boundaries are applied.
4. Recommendations remain aligned with broader customer profile and occasion context when available.

## Major workflows

The platform requires the following high-level workflows:

1. **Catalog ingestion**
   - ingest RTW and CM product data, attributes, imagery, price tiers, and inventory-related signals
2. **Customer signal ingestion**
   - ingest orders, browsing, search, cart, email, loyalty, store visit, appointment, and stylist-note signals where available
3. **Identity and profile management**
   - resolve customer identity across channels and maintain a consent-aware profile
4. **Look and relationship modeling**
   - model product compatibility, curated looks, product relationships, and exclusions
5. **Context evaluation**
   - apply location, weather, season, holiday, and session context
6. **Recommendation generation**
   - select, rank, and package recommendation sets by surface and use case
7. **Recommendation delivery**
   - expose recommendation sets through APIs or feeds for channel consumption
8. **Merchandising control**
   - let operators curate looks, rules, overrides, and campaign priorities
9. **Measurement and experimentation**
   - capture telemetry and evaluate recommendation performance by surface, audience, and variant

## Major capability areas

- product catalog ingestion and normalization
- customer signal ingestion and event pipeline
- identity resolution and customer profile service
- product relationship graph
- outfit / curated look model
- compatibility rules and business rules
- context engine
- recommendation engine
- recommendation delivery API
- merchandising rule builder and campaign controls
- analytics, insights, and experimentation
- admin and governance controls

## Product boundaries

### In scope at product level

- decisioning for complete-look recommendations
- omnichannel recommendation delivery
- operator control over recommendation inputs and constraints
- analytics and experimentation for recommendation performance

### Out of scope at product level

- replacing source systems such as Shopify, OMS, POS, CRM, or ESP
- full content management for all customer-facing pages
- standalone inventory planning, pricing, or search products
- fully autonomous styling without governance or override controls

## Canonical terminology

- **Look**: the internal grouping of compatible products or curated combinations.
- **Outfit**: the customer-facing complete-look recommendation.
- **Recommendation set**: a served package of one or more recommendations returned for a specific request, surface, and context.
- **Context-aware**: influenced by signals such as location, weather, season, occasion, session state, and known customer profile.
