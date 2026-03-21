# Glossary

## Purpose
Define the shared domain language for the AI Outfit Intelligence Platform so requirements, architecture, and delivery artifacts use the same terms.

## Practical usage
Use these definitions when authoring business requirements, feature specs, API contracts, UI artifacts, and review notes.

| Term | Definition |
| --- | --- |
| outfit | The customer-facing complete look recommendation presented as a coherent combination of products across categories. |
| look | The internal grouping of compatible items, curated or generated, that can be ranked and delivered as an outfit. |
| anchor product | The product currently driving a recommendation request, such as a suit, jacket, shirt, or cart line item. |
| recommendation | A ranked suggestion generated for a customer, session, or operator-facing workflow. |
| recommendation set | The full response payload for a request, including one or more recommendation types and ranking metadata. |
| recommendation type | A named output mode such as outfit, cross-sell, upsell, occasion-based, contextual, personal, or style bundle. |
| style bundle | A pre-composed or dynamically assembled group of items intended to be shopped together for a specific style intent. |
| style profile | The customer representation of inferred and explicit preferences, affinity signals, fit tendencies, price sensitivity, and occasion tendencies. |
| merchandising rule | A business-controlled rule that constrains, boosts, pins, excludes, or overrides recommendations. |
| curated look | A look assembled by merchandisers or stylists and made available to recommendation logic as an eligible source. |
| AI-ranked | A recommendation ordering produced by machine learning or statistical ranking models using product, customer, and context features. |
| rule-based | A deterministic decision or filter driven by explicit compatibility or business rules. |
| RTW | Ready-to-Wear products sold from standard catalog inventory and delivered without customer-specific garment construction. |
| CM | Custom Made products or configurations where styling, fabric, and compatibility rules must account for customer-selected garment options. |
| context engine | The subsystem that interprets session and environmental signals such as country, weather, season, and occasion cues. |
| profile service | The subsystem that resolves customer identity and exposes a usable style profile for recommendation decisions. |
| compatibility graph | A maintained representation of which products, attributes, or looks work together and under what conditions. |
| trace ID | A request-level identifier used to connect a delivered recommendation set to downstream telemetry, debugging, and audit records. |
| impression | A telemetry event showing that a recommendation module or item was rendered to a customer or operator. |
| override | A merchandising or operator action that changes a default recommendation outcome or ranking. |
