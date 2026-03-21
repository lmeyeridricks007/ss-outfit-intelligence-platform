# Feature specification index

Cross-reference for major platform capabilities, priorities, dependencies, artifact filenames, and upstream BR mapping. Priorities reflect `docs/project/roadmap.md` emphasis (P0 foundational for delivery, P1 Phase 1 ecommerce RTW, P2 expansion, P3 channel/operator scale, P4 CM/advanced).

| Feature / module | Short description | Priority | Dependencies (features or capabilities) | File | Upstream BR mapping |
| --- | --- | --- | --- | --- | --- |
| Shared contracts and delivery API | Versioned, API-first recommendation delivery: typed **recommendation sets**, trace metadata, degraded states, multi-surface consumers. | P0 | Catalog readiness; identity optional for anonymous Phase 1 | `shared-contracts-and-delivery-api.md` | BR-003, BR-002, BR-011 (trace fields), BR-010 (telemetry hooks) |
| Catalog and product intelligence | Ingestion, normalization, eligibility, inventory and imagery readiness for recommendation candidates. | P0 | None (foundational data plane) | `catalog-and-product-intelligence.md` | BR-008, BR-004 (mode fields) |
| Complete-look orchestration | Assemble **looks** into customer-facing **outfits** from anchor or occasion entry; grouped semantics and fallbacks. | P1 | Catalog; contracts; governance | `complete-look-orchestration.md` | BR-001, BR-002 (type: outfit), BR-008, BR-005 |
| Recommendation decisioning and ranking | Curated + rule-based + **AI-ranked** blend, candidate generation, precedence, ranking objectives by **recommendation type**. | P1 | Catalog; governance; contracts | `recommendation-decisioning-and-ranking.md` | BR-005, BR-002, BR-001, BR-008 |
| Merchandising governance and operator controls | Rules, campaigns, overrides, curated **looks**, approval boundaries, audit. | P1 | Contracts (rule context in responses); catalog | `merchandising-governance-and-operator-controls.md` | BR-009, BR-011, BR-005 |
| Analytics and experimentation | Impression→outcome telemetry, experiments, reporting dimensions, guardrails. | P1 | Contracts (IDs); surface instrumentation | `analytics-and-experimentation.md` | BR-010, BR-003, BR-002, data standards |
| Explainability and auditability | Trace layers, provenance, operator troubleshooting, privacy-safe explanation bounds. | P1 | Contracts; governance versioning | `explainability-and-auditability.md` | BR-011, BR-009, BR-010 |
| Customer signal ingestion | Orders, browse, cart, search, email, store, stylist notes—freshness, provenance, consent boundaries. | P2 | Identity (for cross-session); analytics pipeline | `customer-signal-ingestion.md` | BR-006, BR-012, BR-010 |
| Identity and style profile | Canonical customer ID, mappings, confidence, **style profile** for ranking/suppression. | P2 | Signal ingestion; contracts (customer state) | `identity-and-style-profile.md` | BR-012, BR-006, BR-011 |
| Context engine and personalization | Weather, season, market, holiday, session and occasion context; ties to contextual/personal types. | P2 | Contracts; identity (personal); catalog | `context-engine-and-personalization.md` | BR-007, BR-002 (contextual, occasion-based, personal), BR-006 |
| Ecommerce surface experiences | PDP, cart, expanded web placements: UX, modules, states, integration to delivery API. | P1 / P2 | Shared contracts; complete-look; analytics | `ecommerce-surface-experiences.md` | BR-003, BR-001, BR-002, BR-010 |
| Channel expansion: email and clienteling | Outbound and assisted-selling consumption of shared contracts, freshness, role boundaries. | P3 | Identity; signals; governance; analytics | `channel-expansion-email-and-clienteling.md` | BR-003, BR-006, BR-012, BR-011, BR-009 |
| RTW and CM mode support | Mode-specific journeys, compatibility depth, phased CM depth vs RTW-first delivery. | P1 (RTW) / P4 (CM depth) | Catalog mode fields; governance; clienteling for CM | `rtw-and-cm-mode-support.md` | BR-004, BR-008, BR-001, BR-005 |

## Notes

- **P0** items are prerequisites for safe Phase 1 ecommerce launch quality (valid products + consistent delivery contract + measurement).
- **Recommendation types** (outfit, cross-sell, upsell, style bundle, occasion-based, contextual, personal) are defined in BR-002 and `docs/project/glossary.md`.
- For orchestration dependencies, see `docs/project/architecture-overview.md`.
- Feature IDs are **not assigned yet** in this repository stage. If downstream boards or architecture artifacts require `FEAT-###` identifiers, assign them once in the board or project-operations layer and update this index plus `open-decisions.md` decision `DEC-013`.
- Cross-cutting unresolved items are consolidated in `open-decisions.md` rather than repeated only in each feature file.
