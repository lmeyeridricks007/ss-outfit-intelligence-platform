# Product Overview

## Purpose
Describe what the AI Outfit Intelligence Platform is, how it is used, and what major workflows and boundaries define the product.

## Practical usage
Use this document as the product-level reference for later feature breakdowns, architecture decisions, and delivery planning.

## What the product is
The AI Outfit Intelligence Platform is a shared recommendation system for SuitSupply that generates complete-look and related recommendations across ecommerce, marketing, and clienteling channels. It combines curated looks, merchandising rules, customer profile signals, contextual inputs, and AI ranking to deliver coherent recommendations that are both stylistically credible and commercially usable.

The platform is not just a widget. It is the underlying capability stack required to ingest data, model compatibility, decide recommendation outcomes, govern business controls, and expose results through reusable delivery interfaces.

## Recommendation modes in scope
- outfit recommendations
- cross-sell recommendations
- upsell recommendations
- curated style bundles
- occasion-based recommendations
- contextual recommendations
- personal recommendations

## Primary surfaces and channels
### Ecommerce surfaces
- product detail pages
- cart
- homepage or web personalization placements
- style inspiration and look builder pages

### Assisted and outbound channels
- personalized email campaigns
- in-store clienteling interfaces
- future mobile and API-driven consumers

## Major user journeys
### Journey 1: Anchor-product outfit completion
1. Customer views an anchor product such as a navy suit.
2. The platform resolves eligible catalog items, relevant look candidates, and context.
3. The recommendation engine returns a complete outfit plus cross-sell and upsell options.
4. The surface renders recommendations with inventory-valid items and tracks outcomes.

### Journey 2: Occasion-led discovery
1. Customer enters through an occasion-led or inspiration surface.
2. The platform interprets occasion, season, and location context.
3. Candidate looks are selected and ranked for the intended setting.
4. The customer receives a complete-look path to browse and shop.

### Journey 3: Personalized repeat-customer recommendation
1. A known customer browses or arrives from an email campaign.
2. Identity resolution and profile services retrieve relevant style and purchase signals.
3. The platform filters and ranks recommendations to complement prior wardrobe context.
4. Telemetry feeds optimization and campaign performance measurement.

### Journey 4: Stylist-assisted recommendation
1. A stylist or clienteling associate opens a customer profile or appointment context.
2. The platform returns recommendation sets informed by customer profile, context, and curated business logic.
3. The associate can tailor, explain, and share the output.

### Journey 5: Merchandising governance and campaign activation
1. Merchandising configures curated looks, rules, exclusions, boosts, or campaign priorities.
2. The platform applies these controls consistently during ranking and delivery.
3. Operators review telemetry, overrides, and business impact.

## Major capability areas
- catalog ingestion and product normalization
- customer signal ingestion and event tracking
- identity resolution and profile service
- outfit graph and compatibility graph management
- context engine for season, weather, location, and occasion inputs
- recommendation candidate generation and ranking
- merchandising governance and rule management
- delivery API and channel-specific rendering integration
- experimentation, analytics, explainability, and auditability

## Product boundaries
### In scope
- Shared recommendation intelligence across RTW and CM, delivered in phases.
- Multiple recommendation types and multiple delivery surfaces.
- Internal governance and admin capabilities required to operate the system responsibly.
- Measurement, experimentation, and operator-facing troubleshooting support.

### Out of scope for bootstrap docs
- Detailed feature-level UI flows for every channel.
- Full model architecture or algorithm specification.
- Final vendor or infrastructure decisions.
- Issue fan-out, implementation tickets, or board seeding beyond existing repo artifacts.

## Product shape by source type
The platform should deliberately blend three sources of recommendation truth:
1. **Curated:** stylist and merchandiser-authored looks.
2. **Rule-based:** compatibility, inventory, and business constraints.
3. **AI-ranked:** profile-aware and context-aware ordering within governed bounds.

## Product boundaries by mode
- **RTW:** prioritize purchasable, inventory-valid outfit completion and attachment opportunities.
- **CM:** support configuration-aware recommendation logic for fabrics, palettes, shirt and tie styles, premium options, and compatibility with customer-selected garment choices.
