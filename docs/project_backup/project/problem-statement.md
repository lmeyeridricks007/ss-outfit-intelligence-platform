# Problem Statement

## Core Problem
Customers often know the anchor item they want, but not the complete outfit they should buy with it. Traditional e-commerce recommendation systems optimize around product similarity or co-purchase frequency, which is insufficient for style-led, occasion-driven shopping.

## Current Gaps
- Similar-item recommendations do not answer "what matches this?"
- Frequently-bought-together logic misses style coherence and occasion fit.
- Personalization is often limited to transactional patterns rather than wardrobe intent.
- Internal merchandising knowledge exists, but is not consistently operationalized across channels.
- RTW and CM journeys are not connected through a shared style intelligence layer.

## Customer Friction
- Customers hesitate because they are unsure whether items coordinate.
- Customers fail to discover complementary products that would complete a look.
- Customers receive recommendations that feel generic, repetitive, or disconnected from context.
- Associates and CRM teams lack a shared recommendation engine for assisted selling and follow-up journeys.

## Business Impact
- Lower basket size than a complete-look strategy could achieve.
- Lost cross-sell and upsell opportunities.
- Inconsistent recommendation quality across channels.
- Manual curation effort that does not scale well or learn from performance.
- Difficulty testing and optimizing styling logic systematically.

## Why This Matters For SuitSupply
SuitSupply has a strong point of view on style, tailoring, and occasion dressing. That brand strength is not fully reflected in current recommendation patterns if the experience only surfaces adjacent products. The opportunity is to encode style intelligence into a governed platform that combines brand curation with customer and context awareness.

## Target Outcome
Build a platform that can recommend complete looks and next-best purchases with enough intelligence to account for occasion, weather, season, customer preference, past purchases, product compatibility, merchandising priorities, and channel-specific presentation needs.

## Key Design Tensions
- Personalization vs brand control.
- Automation vs human approval.
- RTW speed vs CM nuance.
- Explainability vs model complexity.
- Reusable platform components vs channel-specific experience needs.

## Foundational Assumptions
- Product metadata quality can be improved to support graph-based recommendation.
- Merchandising teams are willing to curate rules and looks if workflows are simple and traceable.
- Customers respond better to complete-look guidance than isolated recommendations in style-led categories.
- Delivery teams need a structured operating model, not only a product spec, to scale implementation with agents.
