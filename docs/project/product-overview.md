# Product Overview

## What the product is
AI Outfit Intelligence Platform is a shared recommendation capability that assembles, ranks, and delivers complete-look and related recommendations for SuitSupply. It combines curated outfit knowledge, compatibility rules, contextual signals, and machine-assisted personalization to support multiple channels.

The platform should produce several recommendation types:
- outfit recommendations
- cross-sell recommendations
- upsell recommendations
- curated style bundles
- occasion-based recommendations
- contextual recommendations
- personal recommendations

## Core product concept
The product treats a recommendation as a decision produced from four inputs:
1. **Catalog understanding:** category, fabric, color, pattern, fit, season, occasion, style tags, price tier, inventory, imagery, RTW and CM attributes.
2. **Customer understanding:** orders, browsing, engagement, loyalty signals, store activity, appointments, notes, favorites, and wishlists where available.
3. **Context understanding:** location, country, weather, season, holiday or event calendar, device or session context, and inferred intent.
4. **Business and style control:** curated looks, compatibility rules, campaign rules, overrides, and experimentation.

## Major user journeys
### 1. Product-detail styling journey
A customer views a garment and receives a complete-look recommendation that includes supporting categories such as shirts, ties, shoes, belts, and accessories. The system should prioritize stylistic compatibility, occasion fit, availability, and relevance to the viewed item.

### 2. Cart completion journey
A customer adds one or more items to cart. The platform recommends missing outfit components, upgrades, or occasion-relevant additions that increase basket completeness without overwhelming the customer.

### 3. Home and inspiration journey
A customer arrives with weak or mixed intent. The platform assembles curated and personalized looks for homepage modules or look builder experiences based on season, geography, prior behavior, and active campaigns.

### 4. Lifecycle marketing journey
A marketing system requests recommendation sets for an audience or individual customer. The platform returns outfit or cross-sell content suitable for email placement, seasonal messaging, or re-engagement journeys.

### 5. Clienteling journey
A stylist or clienteling interface requests recommendations for a customer profile, appointment, or configured garment. The platform produces explainable outfit suggestions that can be adapted in conversation.

### 6. Custom Made guidance journey
A customer or stylist configures a CM garment. The platform recommends compatible shirt styles, tie styles, color palettes, premium options, or complementary garments that work with the configuration.

## Primary surfaces and channels
- product detail pages
- cart
- homepage and web personalization surfaces
- style inspiration and look builder pages
- email campaigns
- in-store clienteling interfaces
- future mobile or API-driven experiences

## Major workflows
- catalog ingestion and normalization
- customer signal ingestion and identity resolution
- outfit graph and product relationship maintenance
- recommendation generation, ranking, and filtering
- merchandising rule management and campaign controls
- recommendation delivery through API and channel adapters
- experimentation, analytics, and feedback collection

## Major capability areas
- product catalog service
- event and session pipeline
- customer profile service
- affinity, segmentation, and intent detection
- outfit graph and curated look model
- compatibility and business rules engine
- recommendation engine and ranking layer
- context engine
- recommendation delivery API
- widgets and consuming surface integration
- merchandising and admin interfaces
- analytics, experimentation, and governance

## Product boundaries
### In scope
- Recommendation generation and delivery for RTW and CM use cases.
- Merchandising controls needed to curate, override, and govern recommendations.
- Telemetry required to measure effectiveness and learn from outcomes.
- Multi-channel activation through API and channel-specific integrations.

### Out of scope for bootstrap and early phases
- Full replacement of search, navigation, or editorial CMS capabilities.
- End-to-end ownership of checkout, fulfillment, pricing, or inventory systems.
- General-purpose customer data platform replacement.
- Fully autonomous creative generation for all content surfaces.
