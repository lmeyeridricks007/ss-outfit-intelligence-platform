# Product Overview

## What the product is

The AI Outfit Intelligence Platform is a shared recommendation platform for SuitSupply that combines curated looks, compatibility rules, contextual signals, and AI ranking to deliver complete outfit recommendations across customer and internal channels.

It serves both:

- Ready-to-Wear (RTW) recommendation scenarios, where customers browse products in the catalog
- Custom Made (CM) recommendation scenarios, where customers configure garments and need coordinated guidance on related choices and add-ons

The platform is not only a ranking service. It is a product capability stack that includes data ingestion, profile building, outfit intelligence, recommendation serving, merchandising controls, experimentation, and analytics.

## Core recommendation types

The platform should support the following recommendation types:

- outfit recommendations
- cross-sell recommendations
- upsell recommendations
- curated style bundles
- occasion-based recommendations
- contextual recommendations
- personal recommendations based on customer profile and behavior

## Primary surfaces and channels

The initial and future consuming surfaces include:

- product detail pages
- cart
- homepage and web personalization modules
- style inspiration or look builder pages
- email campaigns
- in-store clienteling interfaces
- future mobile or API-driven experiences

## Major user journeys

### 1. Product-led outfit completion

A customer views a product such as a suit or jacket. The platform returns a customer-facing outfit recommendation composed of compatible items across categories, such as shirt, tie, shoes, belt, and accessories.

### 2. Occasion-led discovery

A customer shops for a known use case, such as a wedding or seasonal business wardrobe. The platform emphasizes outfits and bundles aligned to occasion, climate, and geography.

### 3. Personal follow-up and reactivation

A returning customer receives recommendations in email, onsite personalization, or clienteling flows based on prior purchases, affinity, and current context.

### 4. Stylist-assisted selling

An in-store stylist or clienteling associate retrieves recommendations that account for customer history, occasion, and available products, then uses them to guide an appointment or outreach.

### 5. CM configuration support

A customer configuring a garment receives coordinated recommendations for shirt style, tie style, color palette, fabric combinations, and premium options compatible with the evolving CM selection.

## Major workflows

The platform should support these high-level workflows:

1. ingest product, customer, and context data
2. resolve identity and build customer profiles
3. build and maintain product relationships and curated looks
4. apply compatibility and business rules
5. rank recommendation candidates using AI and contextual logic
6. serve recommendation sets through APIs or channel adapters
7. capture recommendation telemetry and business outcomes
8. enable merchandising control, experimentation, and analysis

## Major capability areas

### Data and profile foundation

- product catalog ingestion
- customer signal ingestion
- event pipeline and session tracking
- identity resolution across channels
- customer profile service

### Recommendation intelligence

- purchase affinity and segmentation
- intent detection
- product relationship graph
- outfit graph and curated look model
- compatibility rules and business rules
- context engine
- recommendation engine

### Delivery and activation

- recommendation delivery API
- recommendation widgets and channel integrations
- campaign management activation
- support for ecommerce, email, clienteling, and future mobile surfaces

### Operations and optimization

- merchandising rule builder
- experimentation and A/B testing
- analytics and insights
- admin and merchandising interfaces
- governance and controls

## Product boundaries

### In scope for the platform

- centralized recommendation logic for outfit intelligence
- orchestration of curated, rule-based, and AI-ranked recommendation sources
- cross-channel delivery of recommendation sets
- analytics, experimentation, and governance for recommendation behavior

### Out of scope for the platform itself

- replacement of the core commerce platform, POS, or marketing automation systems
- full creative production workflows for imagery and campaign design
- complete wardrobe planning products beyond defined recommendation use cases
- physical inventory operations beyond consuming availability data needed for recommendation decisions

## Product framing conventions

To keep downstream work consistent:

- use "outfit" for the customer-facing complete recommendation concept
- use "look" for an internal curated or modeled grouping of compatible items
- distinguish recommendation sources as curated, rule-based, or AI-ranked
- explicitly call out whether logic applies to RTW, CM, or both
