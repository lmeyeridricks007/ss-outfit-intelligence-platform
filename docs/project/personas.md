# Personas

## Purpose
Define the key users and internal stakeholders whose needs shape the platform.

## Practical usage
Use these personas when deriving workflows, acceptance criteria, and channel priorities.

## Source
- GitHub issue #37: Master product spec: AI Outfit Intelligence Platform (SuitSupply Recommendation Engine)

## Primary personas

### Persona P1: Digital outfit shopper
| Dimension | Details |
| --- | --- |
| Role | Customer browsing suits, jackets, shirts, shoes, and accessories online. |
| Goals | Build a complete outfit, avoid style mistakes, and buy with confidence. |
| Pain points | Knows the main item they want but not what matches it; generic related products create noise. |
| Behaviors | Starts from a PDP, category page, or look inspiration page; compares a few options before committing. |
| Decision-making context | Needs confidence quickly and expects a curated, brand-aligned answer. |
| Success looks like | Can move from one anchor product to a cohesive purchasable outfit in one session. |

### Persona P2: Returning style-profile customer
| Dimension | Details |
| --- | --- |
| Role | Existing customer with prior purchases, browsing history, or loyalty/account signals. |
| Goals | Receive recommendations that complement owned wardrobe items and match personal taste. |
| Pain points | Repeats the same discovery work every visit; existing recommendations do not reflect prior purchases. |
| Behaviors | Returns through direct traffic, email, or seasonal shopping moments. |
| Decision-making context | Expects the brand to remember fit, color tendencies, occasion patterns, and prior ownership. |
| Success looks like | Sees recommendations that feel incremental, personal, and relevant to their wardrobe. |

### Persona P3: Occasion-driven shopper
| Dimension | Details |
| --- | --- |
| Role | Customer shopping for a defined event such as a wedding, interview, business meeting, or travel need. |
| Goals | Receive outfit guidance that matches the occasion and removes uncertainty. |
| Pain points | Occasion needs are not explicit in standard product discovery; compatibility across categories is hard. |
| Behaviors | Searches broadly, reads styling content, and often needs more hand-holding than routine shoppers. |
| Decision-making context | Balances formality, climate, season, and budget while trying not to make a styling error. |
| Success looks like | Finds a suitable complete look without needing external research or in-store help. |

## Secondary personas

### Persona S1: In-store stylist or clienteling associate
- Goal: Start from strong look suggestions, then tailor them for the customer.
- Pain points: Manual outfit assembly is time-consuming and not always connected to digital history.
- Success: The clienteling interface exposes recommendations that are editable, explainable, and inventory-aware.

### Persona S2: Merchandiser
- Goal: Encode curated looks, compatibility rules, seasonality, and campaign priorities.
- Pain points: Styling knowledge is hard to operationalize consistently across channels.
- Success: Can author or override recommendation logic without engineering changes and can measure impact.

### Persona S3: Marketing manager
- Goal: Activate recommendation sets in email and personalization programs.
- Pain points: Channel-specific one-off logic creates inconsistent targeting and weak reuse.
- Success: Can pull governed recommendation sets into campaigns with clear attribution and segmentation.

### Persona S4: Product, analytics, and optimization lead
- Goal: Understand recommendation performance and improve it through experimentation.
- Pain points: Insufficient telemetry, fragmented systems, and unclear source-of-truth metrics.
- Success: Can trace recommendation performance by surface, audience, algorithm source, and outcome event.

## Persona implications for the platform
- Customer-facing recommendations must support both anchor-product flows and occasion-led flows.
- Personalization should incorporate prior purchases and browsing, but never depend on those signals being present.
- Internal users need editable controls, traceability, and measurement rather than a black-box engine.
- Assisted-selling users need near-real-time recommendations with clear fallback behavior.
