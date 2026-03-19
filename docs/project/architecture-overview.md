# Architecture Overview

## Purpose

This document defines the product-level architecture shape for the AI Outfit Intelligence Platform. It is intentionally high level but implementation-oriented enough to support later feature architecture and planning work.

## System objective

Provide a shared decisioning and delivery layer that can ingest product, customer, and context data; model compatible looks; generate recommendation sets; and deliver them consistently to ecommerce, email, and clienteling channels.

## High-level system view

At a product level, the platform should consist of the following layers:

1. **Source systems**
   - commerce catalog and product systems
   - order / OMS systems
   - customer/account and loyalty systems
   - web and app analytics/event sources
   - email engagement systems
   - store visit, appointment, and stylist-note systems where available
   - context providers such as weather and holiday/event calendars

2. **Ingestion and normalization**
   - catalog ingestion and attribute normalization
   - event ingestion and session signal capture
   - source-system identifier mapping
   - data quality checks and freshness monitoring

3. **Identity and profile**
   - customer identity resolution
   - consent-aware customer profile service
   - purchase affinity and segmentation inputs
   - intent and session context enrichment

4. **Recommendation knowledge layer**
   - product relationship graph
   - curated look / outfit model
   - compatibility rules and exclusions
   - campaign and merchandising overlays

5. **Decisioning layer**
   - context engine
   - candidate generation
   - ranking / selection logic
   - fallback and suppression logic
   - recommendation packaging by surface and use case

6. **Delivery and activation**
   - recommendation delivery API
   - channel-specific adapters or consumers for web, email, and clienteling
   - admin / merchandising interface for control workflows

7. **Measurement and governance**
   - telemetry pipeline
   - experimentation support
   - analytics and insight outputs
   - auditability and operational monitoring

## Major subsystems

### 1. Product catalog service

Responsible for normalizing product attributes required for compatibility and styling decisions, including RTW and CM attribute distinctions.

### 2. Event and signal pipeline

Responsible for ingesting customer behavior and outcome events from digital and store-adjacent systems with consistent schemas and timestamps.

### 3. Identity resolution service

Responsible for mapping source-system identities into canonical customer IDs with confidence tracking and consent-aware usage rules.

### 4. Customer profile service

Maintains accessible customer state for recommendation decisions, including purchase history, browsing behavior aggregates, segmentation signals, and eligibility constraints.

### 5. Look graph and rule service

Stores and evaluates curated looks, product relationships, style compatibility rules, exclusions, and campaign overlays.

### 6. Context engine

Normalizes live context such as location, country, season, weather, holiday/event context, and useful session state.

### 7. Recommendation engine

Generates recommendation candidates, applies rules and context, ranks outputs, and packages recommendation sets according to recommendation type and consuming surface.

### 8. Recommendation delivery API

Exposes the serving contract for consumers requesting recommendation sets by customer, product, context, or surface.

### 9. Merchandising and admin tools

Provide operator workflows for curation, rule control, suppression, campaign management, and recommendation QA.

### 10. Analytics and experimentation layer

Captures recommendation impressions and outcomes, supports variant testing, and feeds performance reporting.

## Data flow overview

### Inbound flow

1. Product and customer-related source systems publish or expose catalog, order, and behavior data.
2. The platform normalizes identifiers and attributes.
3. Identity/profile services consolidate known customer and session context where allowed.
4. Look/rule services store curated and rule-based relationships.

### Decision flow

1. A consuming surface requests recommendations.
2. The request includes available identifiers and context such as customer ID, product ID, surface, country, and weather.
3. The engine fetches candidates from curated looks, compatibility relationships, and candidate-generation logic.
4. Rules, exclusions, context, and ranking logic are applied.
5. A recommendation set is returned with enough metadata for telemetry and troubleshooting.

### Feedback flow

1. The surface records impression and interaction events against the recommendation set ID.
2. Outcome events such as add-to-cart and purchase are linked back to the served set where possible.
3. Analytics and experimentation layers use those events to evaluate performance and improve later decisioning.

## External integrations at a high level

- commerce and catalog systems
- OMS / order history systems
- analytics / event collection systems
- CRM / loyalty / account systems
- email campaign systems
- POS / clienteling / appointment systems
- weather and calendar context providers

## Key technical boundaries

- The platform is a recommendation and decisioning layer, not the system of record for commerce transactions.
- Canonical product and customer IDs must coexist with source-system mappings rather than replacing upstream IDs.
- Customer data usage must be consent-aware and region-appropriate.
- The recommendation engine must support both anonymous and authenticated scenarios.
- RTW and CM share core platform services, but CM-specific compatibility rules may require dedicated logic paths.

## Operational assumptions

- A hybrid processing model is expected: batch or scheduled ingestion for some data domains and near-real-time serving for recommendation requests.
- Some signals will be missing or delayed; the platform must still serve safe fallback recommendations.
- Operator overrides and curated looks remain first-class inputs, not afterthoughts.
- Recommendation decisions must be observable through logs, telemetry, and stable recommendation set identifiers.

## Implementation-oriented constraints

- Serving contracts must remain stable enough for multiple consumers to integrate safely.
- Latency expectations for customer-facing surfaces should favor precomputed or efficiently generated candidates where needed.
- Recommendation responses should include enough metadata for attribution, debugging, and experiment analysis.
- Inventory- or sellability-related constraints must be incorporated before channel activation.
- Data freshness requirements will differ by source; architecture should preserve freshness metadata rather than assuming all inputs are real time.

## Architecture assumptions that need later validation

- Which systems will own final product availability and assortment gating
- Whether weather/context data will be fetched at request time or pre-enriched upstream
- How much of ranking logic will be rule-driven versus model-driven in early phases
- Whether clienteling interfaces will consume the same API shape as ecommerce surfaces or require a dedicated adapter
- Which storage approach best fits look graph, rule evaluation, and recommendation telemetry workloads
