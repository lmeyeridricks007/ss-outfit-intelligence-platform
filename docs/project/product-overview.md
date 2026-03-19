# Product Overview

## What the product is

The AI Outfit Intelligence Platform is a recommendation system for SuitSupply that generates complete-look, cross-sell, upsell, contextual, occasion-based, and personalized recommendations across digital and assisted-selling channels. It combines catalog intelligence, curated merchandising looks, compatibility rules, customer behavior, and real-time context to recommend coordinated outfits rather than isolated products.

The platform must support both:

- Ready-to-Wear (RTW) recommendation journeys
- Custom Made (CM) recommendation journeys, including guidance for fabrics, palettes, shirt and tie pairings, and premium option selection around configured garments

Both RTW and CM are in scope at the platform and architecture level from bootstrap. Delivery depth is intentionally phased: early production launches should prioritize RTW journeys on high-intent ecommerce surfaces while preserving the data model, API contract, and governance needed to expand into richer CM decision support later.

## Primary channels and surfaces

- product detail pages
- cart
- homepage and web personalization surfaces
- style inspiration and look-builder pages
- email campaigns
- in-store clienteling interfaces
- future mobile or API-driven consumer experiences

## Core recommendation types

- outfit recommendations
- cross-sell recommendations
- upsell recommendations
- curated style bundles
- occasion-based recommendations
- contextual recommendations
- personal recommendations based on customer profile and behavior

## Recommendation expression model

For product and contract design, the platform should distinguish between:

- **response groups** such as outfits, cross-sell, upsell, and style bundles
- **strategy dimensions** such as occasion-based, contextual, and personal recommendation logic that can influence any response group

This distinction keeps customer-facing presentation stable while allowing recommendation generation to blend multiple strategies behind the same surface contract.

## Major user journeys

## 1. Anchor-product outfit completion

A customer views or purchases an anchor item such as a suit, jacket, or shirt and receives compatible items to complete the outfit.

Example outcome:

- navy suit -> white shirt, burgundy tie, brown shoes, matching belt, pocket square

## 2. Occasion-driven look discovery

A customer expresses or implies an occasion such as business formal, wedding guest, travel, or seasonal dressing and receives a pre-coordinated, shoppable look.

## 3. Contextual session-based recommendation

A customer browsing in a specific country, season, or weather context receives recommendations optimized for climate, region, and dress expectations.

Example outcome:

- browsing linen jackets in Italy during summer -> linen suit, lightweight shirt, loafers, summer belt, sunglasses

## 4. Returning-customer wardrobe extension

A known customer receives recommendations that complement prior purchases and inferred preferences rather than generic product similarity suggestions.

## 5. Assisted selling and clienteling support

Stylists and clienteling teams use the same recommendation logic, with room for human override, to assemble and discuss looks with customers.

## Major workflows

### Customer-facing workflow

1. Collect relevant context from session, product, customer, and environment.
2. Determine recommendation intent such as outfit completion, occasion, upsell, or personal extension.
3. Generate candidate looks and product combinations from curated looks, compatibility rules, graph relationships, and model-based ranking.
4. Filter by availability, price context, business rules, and channel constraints.
5. Return ranked recommendations through a delivery API.
6. Capture impression and outcome telemetry for measurement and optimization.

### Merchandising and operations workflow

1. Ingest and enrich product catalog data.
2. Define curated looks, compatibility rules, exclusions, and campaign priorities.
3. Monitor recommendation performance by type, surface, and customer segment.
4. Run experiments and adjust rule or ranking strategies.

## Major capability areas

- product catalog ingestion and enrichment
- customer signal ingestion
- event pipeline and session tracking
- identity resolution and customer profile management
- purchase affinity and segmentation
- intent detection
- product relationship graph
- outfit graph and curated look management
- compatibility and business rules engine
- recommendation generation and ranking
- context engine for location, weather, season, and event signals
- recommendation delivery API
- experimentation and analytics
- merchandising admin and governance controls

## Product boundaries

## In scope at the platform level

- generating recommendation sets for multiple surfaces
- supporting both RTW and CM recommendation logic
- enabling curated, rule-based, and AI-ranked recommendation strategies
- measuring recommendation outcomes and experimentation
- supporting merchandiser and operator controls

## Out of scope at bootstrap level

- final feature-level implementation plans for each surface
- downstream issue fan-out or board seeding
- replacing core commerce, POS, or marketing systems
- full editorial content management beyond recommendation-oriented look curation
