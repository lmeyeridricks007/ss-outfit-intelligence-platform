# Personas

## Purpose

Capture the primary and secondary personas that the AI Outfit Intelligence Platform must serve, including their goals, pain points, behaviors, and definition of success.

## Practical usage

Use this document to:
- check whether proposed features solve a real user problem
- shape workflows for shopper, stylist, merchandising, and marketing surfaces
- keep later requirements grounded in real decision-making contexts

## Primary personas

| Persona | Goals | Pain points | Behaviors | Decision-making context | What success looks like |
| --- | --- | --- | --- | --- | --- |
| **P1. Occasion-led online shopper** | Find a complete outfit for a wedding, interview, business meeting, travel, or seasonal need. | Unsure which items work together; fears getting formality or color combinations wrong; does not want to browse every category manually. | Starts with an occasion, hero product, or inspiration image; compares options quickly; may buy across multiple categories in one session. | Needs recommendations that balance style coherence, occasion fit, seasonality, and ease of purchase. | Can move from one entry point to a credible outfit with minimal guesswork. |
| **P2. Returning style-aware customer** | Extend or refresh wardrobe with pieces that fit prior purchases and personal taste. | Gets generic recommendations that ignore purchase history, closet context, or preferred silhouettes; does not want redundant suggestions. | Logs in, revisits previously browsed categories, reacts well to personal recommendations in web and email. | Expects the platform to recognize existing style profile and recommend complementary items rather than generic bestsellers. | Sees recommendations that feel tailored, relevant, and worth acting on. |
| **P3. Custom Made customer** | Configure shirts, ties, fabrics, and premium options that complement a custom garment or appointment context. | CM choices are more complex; compatibility is harder to judge; generic RTW suggestions can feel mismatched. | Engages in longer consideration cycles, often with higher intent; may shop with appointment, stylist, or event context. | Needs recommendation logic that respects CM attributes, color palettes, premium options, and compatibility with configured garments. | Receives guided CM recommendations that reduce decision fatigue and increase confidence in premium selections. |

## Secondary personas

| Persona | Goals | Pain points | Behaviors | Decision-making context | What success looks like |
| --- | --- | --- | --- | --- | --- |
| **S1. In-store stylist or client advisor** | Build looks quickly, personalize advice, and increase basket size during assisted selling. | Manual look assembly is time-consuming; digital tools may not reflect real inventory, context, or prior purchases. | Uses clienteling tools before and during appointments; combines platform suggestions with human judgment. | Needs trustworthy, inventory-aware recommendations that can be edited or overridden. | Can use platform recommendations as a fast starting point rather than rebuilding every outfit manually. |
| **S2. Merchandiser** | Publish curated looks, define merchandising rules, and control campaign emphasis. | Rules and curated intent are hard to scale consistently across surfaces; manual updates do not propagate well. | Thinks in seasonal collections, look stories, category priorities, and exclusions. | Needs clear control over how curated, rule-based, and AI-ranked recommendations interact. | Can steer recommendation behavior without slowing delivery or requiring custom engineering. |
| **S3. Marketing or CRM manager** | Send more relevant recommendation emails and journey-based follow-ups. | Channel logic is fragmented; recommendations may not reflect current inventory or customer intent. | Works with campaign audiences, triggers, and performance metrics. | Needs a reusable recommendation service and metadata suitable for campaign assembly and measurement. | Can activate personalized looks and complementary products with measurable lift. |
| **S4. Product, analytics, or optimization lead** | Measure recommendation performance and improve the system over time. | Hard to attribute results when surfaces, rules, and data are inconsistent. | Defines KPIs, experiments, telemetry, and rollout decisions. | Needs traceable recommendation decisions, experiment hooks, and reliable event data. | Can determine which recommendation strategies improve business outcomes and why. |

## Persona priorities for early delivery

The first delivery phases should optimize for:
1. P1 Occasion-led online shopper
2. P2 Returning style-aware customer
3. S1 In-store stylist or client advisor

These personas are most directly connected to conversion, average order value, and visible recommendation quality on core channels.

## Shared needs across personas

Across shopper and internal personas, the platform must provide:
- credible complete-look recommendations rather than isolated product suggestions
- visibility into why a recommendation is relevant, at least through reason codes or contextual labeling
- inventory-aware outputs that can actually be sold or used in clienteling
- a clear path for curated looks and merchandising rules to shape outcomes
- measurable events that connect recommendation delivery to downstream behavior

## Risks if personas are underspecified

- shopper experiences may overfit to one channel and fail in assisted selling or CRM use cases
- CM needs may be lost if RTW-only logic becomes the default mental model
- merchandising and governance needs may be treated as afterthoughts, creating brand and operational risk

## Missing decisions

- Missing decision: whether saved looks, wishlists, and stylist notes exist consistently enough to include in first-release profile logic.
- Missing decision: how strongly the first release should optimize for stylist workflows versus shopper self-service journeys.
