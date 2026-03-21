# Domain Model

## Purpose
Provide the high-level business and system entities that define how the AI Outfit Intelligence Platform thinks about products, customers, recommendations, governance, and outcomes.

## Practical usage
Use this document when designing schemas, APIs, feature specs, and architecture artifacts so entity boundaries stay consistent.

## Core entities

### Product
A sellable catalog entity with canonical attributes such as category, fabric, color, pattern, fit, season, occasion, style tags, price tier, imagery, and RTW or CM-specific fields.

### Look
An internal grouping of compatible products that can be curated, generated, ranked, and delivered as a customer-facing outfit.

### Outfit
The customer-facing presentation of a complete look recommendation.

### Recommendation request
A request made by a consuming surface using available identifiers and context such as customer ID, session ID, product ID, surface, location, weather, or occasion hints.

### Recommendation set
The result of a recommendation request, containing one or more recommendation types, ranked products or looks, recommendation set ID, trace ID, and supporting metadata.

### Recommendation item
A specific recommended product or look within a recommendation set, with type, rank, rationale context, and applicable merchandising or experiment metadata.

### Customer identity
The canonical customer representation created from one or more source-system identities, with confidence and provenance.

### Style profile
The usable customer profile for recommendation logic, including inferred preferences, purchase affinities, fit tendencies, occasion signals, and suppression cues.

### Context snapshot
The normalized environmental and session state used in a recommendation decision, such as country, location, weather, season, holiday, occasion signal, and channel or surface context.

### Merchandising rule
A governed rule that can pin, boost, suppress, exclude, or otherwise constrain recommendation behavior.

### Curated look
A merchandiser- or stylist-authored look that serves as an input candidate for recommendation logic.

### Campaign
A governed business construct that applies time-bound or audience-bound recommendation priorities or presentation rules.

### Experiment
A controlled test context used to compare recommendation strategies, ranking behavior, or presentation variants.

### Telemetry event
A recorded outcome such as impression, click, add-to-cart, purchase, dismiss, save, or override tied to recommendation and trace context.

## Entity relationships
- A **product** can belong to many **looks**.
- A **look** can be delivered as an **outfit** in one or more **recommendation sets**.
- A **recommendation request** may use a **customer identity**, **style profile**, **anchor product**, and **context snapshot**.
- A **recommendation set** contains many **recommendation items**.
- **Merchandising rules**, **campaigns**, and **experiments** can influence a recommendation set.
- **Telemetry events** link delivered recommendation sets to downstream outcomes.

## Modeling boundaries
- Keep customer identity separate from style profile so uncertainty and consent can be managed explicitly.
- Keep curated look management separate from recommendation delivery so governance remains clear.
- Treat recommendation set IDs and trace IDs as first-class entities for observability and auditability.
