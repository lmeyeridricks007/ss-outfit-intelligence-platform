# Personas

## Persona framework

This product serves both external shoppers and internal operators. The recommendation platform is only successful if it improves customer decision-making while giving internal teams enough control and visibility to trust the output.

## Primary personas

### 1. Outfit-building online shopper

**Who they are**
- A shopper browsing suits, shirts, shoes, and accessories online.
- Often enters through one PDP or a category page and needs help completing the rest of the outfit.

**Goals**
- understand what matches the item they are currently viewing
- complete a polished outfit quickly
- avoid stylistic mistakes or clashing combinations
- discover matching items without excessive browsing

**Pain points**
- recommendations often stay within the same category
- it is hard to judge compatibility across color, fabric, pattern, and formality
- manual outfit assembly takes time and confidence

**Behaviors**
- starts from one hero item, then explores complements
- compares several options before committing
- uses occasion and season as an implicit filter even if not explicitly selected

**Decision-making context**
- needs confidence and speed
- may purchase in a single session
- responds well to complete-look suggestions with clear item roles

**Success looks like**
- the shopper can add multiple compatible items to cart with minimal extra research
- recommendations feel like styling help, not random add-ons

### 2. Returning style-aware customer

**Who they are**
- A known customer with order history, browsing history, and possibly loyalty or account signals.

**Goals**
- receive recommendations that reflect existing wardrobe, fit, and style preferences
- avoid duplicate or irrelevant suggestions
- discover complementary items or upgraded choices aligned with past behavior

**Pain points**
- generic recommendations ignore what they already own
- repeated category-level suggestions can feel noisy or low-value
- the customer expects the brand to remember prior context

**Behaviors**
- logs in or can be identified through known behavior
- may browse multiple sessions before purchase
- engages with emails and return visits as part of the journey

**Decision-making context**
- expects relevance based on prior purchases and brand relationship
- may respond to personalized bundles or occasion prompts

**Success looks like**
- recommendations clearly feel more relevant than anonymous browsing defaults
- the customer sees useful complements, replenishment-adjacent suggestions, or occasion-based outfit ideas

### 3. Occasion-driven shopper

**Who they are**
- A shopper purchasing for a wedding, interview, business event, travel, or seasonal need.

**Goals**
- build an appropriate outfit for the event without deep product expertise
- understand how formality, climate, and occasion should shape product selection

**Pain points**
- occasion-specific styling is hard to infer from generic product cards
- formality and weather constraints can narrow good choices quickly

**Behaviors**
- searches with explicit intent signals
- may enter from content, search, category pages, or campaign traffic
- values ready-made combinations more than open-ended browsing

**Decision-making context**
- wants strong guidance and lower decision complexity
- may need multiple categories at once

**Success looks like**
- the shopper can choose from a small set of confident, context-appropriate outfits or bundles

## Secondary personas

### 4. In-store stylist / clienteling associate

**Goals**
- assemble or suggest complete looks quickly during appointments or assisted selling
- use customer history and current needs to guide recommendations

**Pain points**
- manual look assembly is time-consuming
- customer data and product knowledge may be spread across systems

**Behaviors**
- works under time pressure
- uses appointments, notes, and prior purchases as context
- may override system output with stylist judgment

**Success looks like**
- the stylist receives high-quality starting recommendations and can refine them without losing control

### 5. Merchandiser / style curator

**Goals**
- define curated looks, compatibility rules, exclusions, and seasonal campaigns
- ensure brand consistency while allowing AI-driven ranking

**Pain points**
- manual curation does not scale evenly across all channels
- opaque recommendation systems are hard to trust and govern

**Behaviors**
- plans by campaign, season, geography, assortment, and inventory context
- wants explicit tools for prioritization, suppression, and overrides

**Success looks like**
- curated looks and rules are easy to activate, measure, and adjust without code changes for routine work

### 6. Marketing / CRM manager

**Goals**
- send personalized recommendation emails and lifecycle journeys using reusable recommendation outputs

**Pain points**
- channel-specific recommendation logic causes inconsistency and slower campaign execution

**Behaviors**
- segments audiences by intent, purchase history, and seasonality
- needs API- or feed-driven recommendation delivery

**Success looks like**
- campaigns can request recommendation sets that are consistent with onsite and clienteling logic

### 7. Product / analytics / optimization lead

**Goals**
- measure recommendation performance, run experiments, and improve decision quality over time

**Pain points**
- weak telemetry or inconsistent definitions make recommendation impact hard to measure

**Behaviors**
- evaluates lift by surface, segment, and recommendation type
- needs traceable variants, recommendation set IDs, and clear experiment attribution

**Success looks like**
- the team can attribute business outcomes to recommendation logic and safely iterate on the system

## Persona implications for the platform

The platform must support:

- anonymous and known-customer recommendation modes
- contextual recommendation without requiring perfect profile data
- internal overrides and governance for merchandisers and stylists
- output formats suitable for web, clienteling, and campaign use
- telemetry strong enough for product and analytics teams to optimize performance
