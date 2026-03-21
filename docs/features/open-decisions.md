# Feature portfolio open decisions

## Purpose

Consolidate cross-cutting open decisions from `docs/features/*.md` so architecture and planning work can resolve them without re-reading every feature spec to discover repeated gaps.

## How to use this file

- Treat this as the portfolio-level decision register for the feature stage.
- If a decision is resolved in architecture or by product/governance review, update the originating feature spec and this register together.
- If a decision remains intentionally deferred, keep the owner and downstream impact current so later stages do not guess.

## Decision register

| Decision ID | Topic | Originating feature(s) | Primary upstream source | Owner | Why it matters downstream |
| --- | --- | --- | --- | --- | --- |
| DEC-001 | Delivery transport and versioning model (`REST` vs `GraphQL`, URL vs header versioning) | `shared-contracts-and-delivery-api.md` | `docs/project/architecture-overview.md`, BR-003 | Architecture | Determines consumer integration pattern, schema governance, and compatibility testing strategy. |
| DEC-002 | Phase 1 latency and availability targets for interactive ecommerce recommendation requests | `shared-contracts-and-delivery-api.md`, `ecommerce-surface-experiences.md` | `docs/project/architecture-overview.md`, `docs/project/roadmap.md` | Architecture | Needed for cache design, timeout behavior, and frontend rendering fallbacks. |
| DEC-003 | Canonical delivery contract outline freeze: required resources, required fields, and error taxonomy | `shared-contracts-and-delivery-api.md` | BR-003, BR-010, BR-011 | Architecture + API owners | Prevents surface-specific drift across web, email, and clienteling consumers. |
| DEC-004 | Homepage / inspiration / occasion-led placement timing beyond PDP and cart (Phase 1.5 vs Phase 2) | `ecommerce-surface-experiences.md`, `context-engine-and-personalization.md` | `docs/project/roadmap.md`, BR-003, BR-001 | Product | Affects scope boundaries and which surfaces architecture must support first. |
| DEC-005 | Customer-facing copy conventions distinguishing outfit, cross-sell, upsell, and style-bundle modules | `ecommerce-surface-experiences.md` | BR-001, BR-002 | Product + Design | Keeps recommendation types clear in UX and avoids flattening complete-look intent. |
| DEC-006 | Server-side impression fallback policy when client analytics are blocked or degraded | `ecommerce-surface-experiences.md`, `analytics-and-experimentation.md` | BR-010, `docs/project/data-standards.md` | Analytics + Web platform | Needed for telemetry completeness and comparable experiment analysis. |
| DEC-007 | Attribution windows, experiment stickiness policy, and experimentation platform ownership | `analytics-and-experimentation.md` | BR-010, `docs/project/architecture-overview.md` | Analytics + Architecture | Shapes event joins, reporting validity, and experiment SDK integration choices. |
| DEC-008 | Campaign vs personalization/context precedence on homepage, occasion, email, and clienteling surfaces | `recommendation-decisioning-and-ranking.md`, `merchandising-governance-and-operator-controls.md`, `context-engine-and-personalization.md`, `channel-expansion-email-and-clienteling.md` | BR-005, BR-007, BR-009 | Product + Merchandising governance | Critical to avoid inconsistent ranking behavior across channels. |
| DEC-009 | Weather provider, holiday-calendar ownership, and geo-consent handling by market | `context-engine-and-personalization.md` | BR-007, `docs/project/roadmap.md` | Product + Architecture + Legal | Affects provider integrations, privacy behavior, and context confidence. |
| DEC-010 | Email freshness threshold and regeneration policy before send | `channel-expansion-email-and-clienteling.md`, `shared-contracts-and-delivery-api.md` | BR-003 | Marketing + Architecture | Determines batch orchestration, suppression behavior, and stale-content risk. |
| DEC-011 | Clienteling platform and operator explanation depth for first rollout | `channel-expansion-email-and-clienteling.md`, `explainability-and-auditability.md` | BR-003, BR-011 | Product + Clienteling ops | Defines auth model, UX detail, and rollout dependency sequencing. |
| DEC-012 | CM digital self-service scope vs stylist-assisted scope in early phases | `rtw-and-cm-mode-support.md` | BR-004, `docs/project/business-requirements.md` | Product | Controls Phase 4 boundaries and prevents premature self-service CM assumptions. |
| DEC-013 | FEAT ID policy for this repository stage (`FEAT-###` assignment now vs later board-driven assignment) | `feature-spec-index.md`, `README.md` | `docs/project/standards.md` | Project operations | Needed for stable cross-stage references if architecture/planning artifacts require feature IDs. |

## Notes

- These are not blockers for keeping `docs/features/` as the feature-stage source of truth, but they should be resolved or explicitly deferred before downstream architecture and implementation artifacts claim final contracts.
- When a decision affects canonical product truth, update `docs/project/` or the relevant BR doc first, then reconcile the feature specs.
