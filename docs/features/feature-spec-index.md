# Feature specification index

Agreed feature specs for AI Outfit Intelligence Platform. Each row maps to a single markdown file under `docs/features/`. Priorities reflect phased delivery in `docs/project/roadmap.md` (P0 = foundation / early phases; P1 = enrichment and broader activation; P2 = platform maturity and expansion).

| Feature name | Short description | Priority | Dependencies | File name |
| --- | --- | --- | --- | --- |
| Catalog and eligibility foundation | Canonical product model, attributes, inventory-aware eligibility, and normalization so recommendations are coherent and purchasable. | P0 | Source catalog/inventory systems; data standards; BR-8 scope from `business-requirements.md` | `catalog-and-eligibility-foundation.md` |
| Customer identity and profile | Identity resolution, canonical customer ID, confidence, profile store, and consent-aware activation across surfaces. | P0 | Event/session identifiers; privacy/consent policy; BR-12 | `customer-identity-and-profile.md` |
| Customer signal activation | Ingestion, classification, freshness tiers, and traceable use of behavioral and profile signals for personalization (bounded by governance). | P1 | Identity and profile; event pipeline; BR-006 | `customer-signal-activation.md` |
| Context engine | Normalize country, region, season, weather, calendars, and session context; precedence, freshness, and traceability for context-aware ranking. | P1 | Catalog/eligibility; delivery request shape; BR-007 | `context-engine.md` |
| Look graph and compatibility | Curated looks, compatibility graph, rule evaluation, RTW vs CM differences, and candidate retrieval inputs to the recommender. | P0 | Catalog foundation; merchandising governance | `look-graph-and-compatibility.md` |
| Recommendation orchestration and types | Candidate generation, rule and eligibility application, curated vs rule-based vs AI-ranked assembly, and typed sets (outfit, cross-sell, upsell, etc.). | P0 | Look graph; catalog; context and signals (as phased) | `recommendation-orchestration-and-types.md` |
| RTW and CM mode orchestration | Mode-specific journeys, configuration state for CM, and orchestration so RTW immediacy and CM consideration are not collapsed. | P1 | Recommendation orchestration; look/compatibility; BR-004 | `rtw-and-cm-mode-orchestration.md` |
| Delivery API and channel adapters | API-first recommendation delivery, stable contracts, and adapters that shape payloads per consumer without forking core logic. | P0 | Orchestration outputs; telemetry IDs; BR-003 | `delivery-api-and-channel-adapters.md` |
| Ecommerce surface activation | PDP, cart, homepage, and web personalization integration patterns, modules, and telemetry for the ecommerce channel. | P0/P1 | Delivery API; UI/standards as applicable | `ecommerce-surface-activation.md` |
| Merchandising governance | Curated looks, rules, campaigns, overrides, approvals, and audit trail so merchandising steers outcomes inside safety bounds. | P1 | Look graph; recommendation orchestration; BR-009 | `merchandising-governance.md` |
| Analytics and experimentation | Impression-to-outcome telemetry, experiments, variant context, and measurement aligned to recommendation set and trace IDs. | P0/P1 | Delivery and event contracts; BR-010 | `analytics-and-experimentation.md` |
| Explainability and auditability | Trace context for why a set was produced: rules, campaigns, experiments, ranking provenance—without unsafe customer-facing leakage. | P1 | Analytics events; governance; BR-011 | `explainability-and-auditability.md` |

## Cross-checks

- Rows for specs **not yet authored** in `docs/features/` should be filled in when those files are added; descriptions and dependencies here should be reconciled with the eventual deep dives.
- **BR-8** has no separate file under `docs/project/br/`; catalog/eligibility traceability relies on `business-requirements.md` and architecture/product docs (see `README.md`).
