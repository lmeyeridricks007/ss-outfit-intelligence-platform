# Feature: Explainability and auditability

**Upstream traceability:** `docs/project/business-requirements.md` (BR-011); `docs/project/br/br-011-explainability-and-auditability.md`, `br-009-merchandising-governance.md`, `br-010-analytics-and-experimentation.md`, `br-012-identity-and-profile-foundation.md`; `docs/project/goals.md`; `docs/project/personas.md`; `docs/project/product-overview.md`; `docs/project/roadmap.md`; `docs/project/architecture-overview.md`; `docs/project/data-standards.md`; `docs/project/glossary.md`; `docs/features/open-decisions.md` (DEC-011, DEC-025, DEC-026, DEC-027, DEC-028, DEC-029).

---

## 1. Purpose

Define the shared explainability and auditability capability that lets authorized internal operators reconstruct:

- why a **recommendation set** was produced
- which curated, rule-based, **AI-ranked**, campaign, and override inputs shaped it
- whether the set came from a normal, degraded, or emergency path
- what recommendation-affecting controls changed over time
- how to investigate recommendation issues without depending on scattered engineering-only logs

This feature exists to operationalize BR-011 at feature-spec depth. It is not a generic debug-log subsystem. It is the governed operator-facing trace and audit layer that keeps recommendation delivery trustworthy across ecommerce, email, clienteling, governance tooling, and later optimization workflows.

## 2. Core Concept

Explainability and auditability is a layered evidence model built around a request-scoped **trace ID** and one or more **recommendation set IDs**. Each trace preserves enough information to answer the business questions from BR-011 without exposing sensitive customer reasoning too broadly.

The core layers are:

1. **Request trace** - what triggered the recommendation and on which surface
2. **Input-state trace** - which product, context, identity-confidence, and eligibility inputs were available
3. **Source provenance trace** - whether outputs came from curated, rule-based, **AI-ranked**, or fallback logic
4. **Governance trace** - which rules, campaigns, suppressions, pins, or overrides affected the result
5. **Experiment trace** - whether a treatment, holdout, or variant changed the behavior
6. **Assembly / ranking trace** - how the final set was composed and whether degradation occurred
7. **Audit linkage** - which configuration versions and historical changes were active at the time

The feature is therefore a shared reconstruction layer across:

- recommendation delivery
- merchandising governance
- analytics and experimentation
- support and operations troubleshooting
- privacy-safe operator review

## 3. Why This Feature Exists

The platform vision depends on blending curated taste, business rules, context, identity, and AI ranking into one governed recommendation stack. That blend only works operationally if teams can understand recommendation behavior after the fact.

Without this feature:

- merchandisers cannot tell whether a surprising result came from curation, campaign logic, rule precedence, or model ranking
- support teams cannot investigate "why did I see this?" complaints quickly
- analysts cannot separate experiment impact from governance changes
- engineers become the bottleneck for routine incident diagnosis
- privacy and governance stakeholders cannot verify that explanation depth is bounded appropriately

`docs/project/goals.md` and `docs/project/vision.md` treat explainability, auditability, and operator trust as foundational operating requirements, not post-launch nice-to-haves. Phase 1 ecommerce quality and later channel expansion both depend on these capabilities arriving early enough to keep recommendation behavior trustworthy.

## 4. User / Business Problems Solved

| User / stakeholder | Problem to solve | What this feature enables |
| --- | --- | --- |
| S2 merchandiser | Recommendation behavior changes but root cause is unclear | Trace summaries showing curated, rule, campaign, and override influence |
| S4 product / analytics / optimization | Experiment lift is hard to interpret because governance changes are invisible | Shared trace + analytics linkage with experiment and governance context |
| S1 stylist / clienteling associate | Needs confidence in recommendation behavior during assisted selling | Role-appropriate explanation summaries and cross-channel trace review |
| Support / operations | Customer complaint or empty-result incident requires engineering log forensics | Searchable trace viewer and guided troubleshooting path |
| Privacy / compliance reviewers | Internal explanation depth may expose too much customer reasoning | Role-based redaction, bounded explanation layers, access audit trail |
| Engineering | Multiple tools expose inconsistent answers for the same recommendation set | One canonical trace schema and retrieval model across subsystems |

## 5. Scope

This feature covers the implementation-oriented requirements for:

- request and recommendation trace capture
- recommendation source provenance and governance provenance
- linkage from recommendation delivery to analytics, experiments, and audit history
- role-aware operator explanation views
- trace and audit lookup APIs
- searchable read models for incident, merchandising, and optimization workflows
- access controls, masking, and trace-view meta-audit

This feature does **not** require final model interpretability techniques, legal discovery tooling, or final infrastructure vendor decisions. It defines the minimum business-semantic evidence that downstream architecture and implementation must preserve.

**Tracked open decisions:** `DEC-011`, `DEC-025`, `DEC-026`, `DEC-027`, `DEC-028`, and `DEC-029` in `docs/features/open-decisions.md`.

## 6. In Scope

- Recommendation-set trace capture for ecommerce, later email, and later clienteling flows
- Summary explanation views for operators, merchandisers, analysts, and support
- Drill-down trace detail for request, input, source, governance, and degradation context
- Historical audit linkage for rules, campaigns, curated looks, suppressions, pins, and overrides
- Search and lookup by `traceId`, `recommendationSetId`, time window, placement, campaign, rule, and controlled customer lookup paths
- Privacy-safe display rules based on role and need
- Meta-audit of trace access and sensitive drill-down usage
- Integration with analytics, governance, and identity-confidence state

## 7. Out of Scope

- Per-score model-interpretability tooling such as SHAP for every ranking feature
- End-customer legal disclosure flows
- Final statistical or causal analysis framework for interpreting performance changes
- Full ediscovery, legal hold workflow design, or litigation export platform
- Final dashboard styling and final admin-console layout
- Any approval or state automation that bypasses governance rules defined elsewhere

## 8. Main User Personas

- **S2: Merchandiser** - primary operator for understanding campaign, rule, curated, suppression, and override effects
- **S4: Product / analytics / optimization team member** - needs trace reconstruction for experiment interpretation and regression analysis
- **S1: Stylist / clienteling associate** - needs a bounded, trustworthy explanation layer in assisted-selling contexts
- **Support / operations** - needs a fast lookup and evidence path for complaints, empty states, and recommendation defects
- **Privacy / governance reviewers** - need bounded explanation depth, access control, and audit history
- **Engineers** - consume deeper structured trace data for unresolved or severe incidents

## 9. Main User Journeys

### Journey A: Support investigates a customer complaint
1. Support receives a complaint that a recommendation looked irrelevant.
2. Support searches by `traceId`, time window, or customer-safe request context.
3. The trace summary shows recommendation type, placement, dominant source mix, and whether the result was degraded or override-driven.
4. Support opens governance and input tabs to see campaign, suppression, identity-confidence, and fallback context.
5. Support routes the issue to merchandising or engineering with concrete evidence instead of anecdotal screenshots.

### Journey B: Merchandiser investigates a recommendation shift
1. A merchandiser notices that a placement is surfacing different products than expected.
2. They inspect recent traces and compare active recommendation sets before and after a campaign or rule change.
3. Audit linkage reveals the specific control versions and effective windows that changed.
4. They determine whether the shift was expected governed behavior, a stale curated-look issue, or an unintended override side effect.

### Journey C: Analyst interprets an experiment result
1. Experiment reporting shows a performance change on a recommendation surface.
2. Analyst drills from aggregate metrics into representative traces.
3. Trace detail shows whether the experiment altered source mix, ordering logic, or fallback path behavior.
4. Governance annotations reveal whether an overlapping campaign or emergency suppression affected the same period.
5. Analyst separates treatment effect from governance noise.

### Journey D: Stylist reviews a clienteling recommendation
1. A stylist retrieves a recommendation set for a known customer.
2. The system provides a summary explanation appropriate for assisted selling.
3. Sensitive underlying profile reasoning remains abstracted or masked based on role.
4. If needed, a deeper support or engineering path is available without exposing the stylist to raw sensitive inputs.

## 10. Triggering Events / Inputs

Explainability and auditability is triggered by:

- completion of a recommendation request in the shared delivery path
- candidate generation, filtering, or ranking completion events
- governance changes such as campaigns, suppressions, overrides, or curated-look updates
- experiment assignment and treatment context
- identity-confidence and profile-use decisions from the identity foundation
- delivery degradation, timeout, or fallback behavior
- operator access to trace views or sensitive trace detail

Primary inputs include:

- request metadata such as channel, surface, placement, anchor product, and mode
- product and inventory eligibility state
- context features such as market, occasion, season, and session state
- identity-confidence and consent-safe personalization state
- rule IDs, campaign IDs, override IDs, and governance snapshot versions
- experiment and variant identifiers
- final recommendation set composition and ordering metadata

## 11. States / Lifecycle

### Trace lifecycle
`captured -> validated -> enriched -> indexed -> queryable -> retained -> expired`

- **captured:** delivery or orchestration emits raw trace envelope
- **validated:** required identifiers, enums, and minimal context are checked
- **enriched:** governance, experiment, identity-confidence, and catalog version references are attached
- **indexed:** search projections and lookup keys created
- **queryable:** trace available to authorized operator tooling
- **retained / expired:** lifecycle managed under retention and privacy policy

### Governance audit lifecycle
`draft change -> approved -> activated -> superseded or expired -> archived`

Trace linkage must preserve which governance versions were active at request time even after controls are superseded later.

### Access-review lifecycle
`requested -> granted by role -> viewed -> logged -> reviewed if sensitive`

Sensitive trace access is itself auditable. This feature must not only explain recommendation behavior; it must also log who viewed deeper explanation detail.

## 12. Business Rules

- **Every meaningful recommendation set must be traceable.** No production recommendation response on supported surfaces should be emitted without a `traceId` and `recommendationSetId`.
- **Source families must remain distinguishable.** Summaries and drilldowns must distinguish curated, rule-based, **AI-ranked**, and fallback behavior rather than flattening them into one opaque "score."
- **Low-confidence identity is analytically and operationally meaningful.** BR-012 identity confidence and bounded personalization states must be visible in the trace at an appropriate abstraction level.
- **Governance actions are first-class evidence.** Rules, campaigns, suppressions, pins, exclusions, and overrides must appear in the trace and link to historical audit state.
- **Degraded and emergency paths must be explicit.** Partial data, timeouts, emergency suppressions, and fallback outputs cannot masquerade as normal delivery.
- **Explanation depth is role-bound.** Summary views may be broad; deeper trace details must be restricted and masked by role, purpose, and region.
- **Trace access must itself be logged.** Viewing sensitive trace detail is a meta-audited action.
- **Customer-facing explanation, if introduced later, must be materially shallower than internal explanation.**
- **Trace reconstruction must not depend on mutable current state alone.** Versioned references are required so historical requests remain interpretable after later governance changes.
- **Routine investigation should not require direct log spelunking.** Raw system logs may remain available for engineering, but the product must expose an operator-grade review path first.

## 13. Configuration Model

The feature requires configuration for:

- trace schema version
- role-based detail levels by persona and region
- redaction and masking rules for identity, profile, stylist-note, and audit fields
- searchable lookup keys allowed to each role
- retention windows by environment, region, and trace class (`summary`, `detail`, `access-log`)
- legal hold or incident-preservation exceptions
- thresholds for trace write failure alerts or index lag
- export policies for SIEM, warehouse, or incident systems
- customer-facing explanation templates if that capability is later enabled under `DEC-025`

All such configuration must be versioned so investigators can tell which masking and explanation rules were in force at the time of access or delivery.

## 14. Data Model

### Core entities

| Entity | Purpose | Required core fields |
| --- | --- | --- |
| `RecommendationTrace` | Canonical request-level evidence envelope | `traceId`, `recommendationSetIds[]`, `requestTs`, `channel`, `surface`, `placement`, `recommendationTypes[]`, `anchorProductId`, `lookId`, `market`, `mode`, `identityState`, `degradedFlags[]`, `schemaVersion` |
| `TraceInputSnapshot` | Summary of what the system knew at decision time | `traceId`, `catalogVersionId`, `inventorySnapshotRef`, `contextSummary`, `profileUsageLevel`, `identityConfidence`, `consentState`, `eligibleSourceSummaries[]` |
| `TraceSourceProvenance` | How candidates entered the set | `traceId`, `sourceKind`, `sourceRefId`, `candidateCount`, `selectedCount`, `fallbackFlag`, `notes` |
| `TraceGovernanceContext` | Governance controls that affected the result | `traceId`, `governanceSnapshotId`, `ruleIds[]`, `campaignIds[]`, `overrideIds[]`, `suppressionIds[]`, `pinIds[]`, `emergencyFlag` |
| `TraceExperimentContext` | Experiment visibility | `traceId`, `experimentId`, `variantId`, `holdoutFlag`, `assignmentKey` |
| `TraceAssemblySummary` | Final set composition and ordering explanation | `traceId`, `setId`, `sourceMix`, `assemblyReason`, `filterStages[]`, `fallbackReason`, `itemSummaries[]` |
| `TraceAccessLog` | Meta-audit for viewing trace detail | `accessLogId`, `traceId`, `viewerRole`, `viewerId`, `viewedAt`, `viewLevel`, `reasonCode`, `regionPolicy` |

### Example canonical trace fragment

```json
{
  "traceId": "trace_01JPF4MX6V9HAF9Q3SXN9Q4G2Z",
  "recommendationSetIds": ["recset_01JPF4MX8A2YV93F5K1M3H7T9W"],
  "requestTs": "2026-03-21T15:08:12Z",
  "channel": "web",
  "surface": "pdp",
  "placement": "complete_the_look_primary",
  "recommendationTypes": ["outfit"],
  "anchorProductId": "prod_12345",
  "market": "NL",
  "mode": "RTW",
  "identityState": {
    "customerState": "anonymous",
    "identityConfidence": "unknown",
    "profileUsageLevel": "session_only"
  },
  "sourceProvenance": [
    {
      "sourceKind": "curated",
      "sourceRefId": "look_789",
      "candidateCount": 1,
      "selectedCount": 1
    },
    {
      "sourceKind": "ai_ranked",
      "sourceRefId": "ranker_v3",
      "candidateCount": 24,
      "selectedCount": 4
    }
  ],
  "governanceContext": {
    "governanceSnapshotId": "govsnap_556",
    "ruleIds": ["rule_inventory_guard", "rule_formalwear_compatibility"],
    "campaignIds": ["camp_spring_wedding"],
    "overrideIds": [],
    "suppressionIds": ["supp_out_of_stock"],
    "emergencyFlag": false
  },
  "assemblySummary": {
    "sourceMix": "curated_plus_ai_ranked",
    "assemblyReason": "complete-look from curated seed with governed completion",
    "fallbackReason": null
  },
  "degradedFlags": []
}
```

### Data-model notes

- Traces must preserve references to versioned state rather than duplicating every mutable object inline
- large candidate lists may be summarized with pointers to deeper engineering-only blobs, but summary-level business evidence cannot be dropped
- identity and profile details must be abstracted enough to support privacy-safe views

## 15. Read Model / Projection Needs

This feature requires read models for at least:

- **Trace lookup index** by `traceId`, `recommendationSetId`, time window, channel, surface, placement, and market
- **Governance-linked view** by campaign, rule, suppression, override, and governance snapshot
- **Customer-safe support lookup** with controlled access patterns for known-customer investigations
- **Experiment-linked view** for comparing traces and treatments during performance investigation
- **Degradation / incident view** for incomplete traces, fallback paths, and trace-write failures
- **Access-audit view** for who viewed which trace detail and at what sensitivity level

Read models should optimize for investigation speed. Operators should be able to move from symptom -> trace summary -> deeper evidence without querying raw stores directly.

## 16. APIs / Contracts

This feature needs internal, role-aware contracts for both retrieval and meta-audit.

### Required contract capabilities

- lookup by `traceId`
- lookup by `recommendationSetId`
- search by time window, placement, campaign, or governance identifier
- retrieve summary-only vs full-detail representations based on role
- emit trace-view access logs automatically
- link from analytics or governance tools into a canonical trace drilldown

### Example internal interfaces

- `GET /traces/{traceId}`
- `GET /recommendation-sets/{recommendationSetId}/trace`
- `POST /trace-search`
- `GET /governance-snapshots/{snapshotId}/traces`
- `POST /trace-access-log`

Wire format and transport remain architecture work, but the semantic contract must preserve:

- role-scoped representations
- stable identifiers
- governance and experiment linkage
- degraded-state indicators
- privacy-safe explanation summary fields

## 17. Events / Async Flows

### Flow A: Normal recommendation trace capture
1. Shared delivery path assembles a recommendation response.
2. Delivery layer assigns or propagates `traceId` and `recommendationSetId`.
3. Orchestration emits a trace envelope with request, source, governance, and assembly context.
4. Validation and enrichment attach experiment, identity-confidence, and governance snapshot references.
5. Trace becomes queryable in the lookup index and available to analytics and support tools.

### Flow B: Governance change linkage
1. Merchandiser publishes a campaign, override, or suppression.
2. Governance subsystem emits a new version or snapshot.
3. Future traces reference that snapshot ID.
4. Audit viewers can compare behavior before and after the change without reconstructing history from mutable current state.

### Flow C: Trace access meta-audit
1. Operator opens a trace summary or detail view.
2. Access layer resolves allowed detail level from role and region policy.
3. The view action is logged with trace ID, role, viewer, and sensitivity level.
4. Sensitive access logs remain queryable for governance review.

### Flow D: Partial or failed trace write
1. Recommendation response is returned to avoid blocking the customer.
2. Trace writer partially succeeds or fails.
3. System records a trace-write anomaly with enough request identity to investigate.
4. Alerting and incident workflows surface the issue because explainability gaps are operationally important.

## 18. UI / UX Design

The UX should be layered rather than flat:

1. **Summary first** - plain-language explanation of recommendation type, source mix, major governance context, and degraded-state status
2. **Structured drilldown** - tabs or sections for request, inputs, governance, experiments, and assembly
3. **Deep evidence** - technical JSON or linked raw details for engineering and advanced investigation roles

### UX principles

- prioritize "what happened?" and "why?" before raw field dumps
- keep recommendation type, placement, and source mix visible in the page chrome
- highlight degraded, emergency, or override-driven behavior clearly
- distinguish facts (`rule applied`) from inference summaries (`AI-ranked within governed bounds`)
- make redaction visible; users should know a field is masked rather than absent accidentally
- support cross-links to analytics dashboards and governance history

## 19. Main Screens / Components

- **Trace viewer** - summary plus role-aware tabs for request, inputs, provenance, and assembly
- **Governance timeline** - campaigns, suppressions, overrides, and rule-version context around a trace
- **Diff viewer** - compare two traces or compare trace context before and after a configuration change
- **Access-review console** - audit who viewed sensitive traces and which detail level was exposed
- **Search / incident workbench** - filter by time window, placement, campaign, degradation flag, or recommendation type
- **Export / share bundle** - controlled internal export for support escalations or engineering handoff

## 20. Permissions / Security Rules

- summary trace access and deep technical access must be separated
- role and regional policy determine which fields are shown, masked, or omitted
- customer identifiers and sensitive profile reasoning must never be broadly exposed in default views
- stylist-note or operator-entered sensitive inputs require stricter access than ordinary recommendation metadata
- every trace-detail view must be logged
- export permissions must be narrower than read permissions
- customer-facing explanation, if later enabled, must use a different contract and template set than internal operator explanation

## 21. Notifications / Alerts / Side Effects

The feature must support alerts for:

- trace write failure or persistent partial-trace rate above threshold
- indexing lag that makes recent traces unavailable for investigation
- unusual spikes in degraded or emergency-path traces
- repeated access to sensitive trace details beyond expected norms

Possible side effects:

- annotate analytics dashboards when trace capture quality is degraded
- open an incident for major trace-capture failures on critical surfaces
- notify governance owners when overrides are heavily represented in traces on a major placement

Alerts must inform operations without blocking customer-facing recommendation delivery unless another policy explicitly requires hard fail behavior.

## 22. Integrations / Dependencies

- **Shared contracts and delivery API** - source of `traceId`, `recommendationSetId`, placement, and response metadata
- **Recommendation decisioning and ranking** - provides source provenance, ranking, filtering, and fallback context
- **Merchandising governance and operator controls** - provides rule, campaign, suppression, and override history
- **Analytics and experimentation** - consumes and links trace IDs for reporting and investigation
- **Identity and style profile** - supplies confidence-aware identity and profile-usage context
- **Ecommerce surface experiences** - primary Phase 1 consuming surface for trace-backed operational investigation
- **Channel expansion: email and clienteling** - later consumers that need cross-channel trace consistency and bounded operator explanation

The explainability subsystem depends on those integrations exposing stable IDs and version references. It cannot reconstruct missing governance or experiment identity after the fact.

## 23. Edge Cases / Failure Cases

- **Partial trace because one subsystem timed out:** mark `incompleteTrace` with reason and preserve what did succeed
- **Recommendation response succeeds but trace write fails:** record a trace-write anomaly and alert because the customer path cannot always block on trace persistence
- **Current governance state differs from historical state:** trace must point to versioned snapshot, not recompute from "now"
- **Same recommendation set viewed by multiple roles:** each role may see different redaction depth, but all views must refer to the same canonical trace
- **Anonymous request later becomes known customer:** trace must preserve what the system knew at request time, not retroactively rewrite certainty
- **Emergency override masks baseline behavior:** trace must explicitly show the override so support does not blame ranking or inventory incorrectly
- **Deletion or privacy requests affect underlying source data:** summary-level historical trace policy remains an open decision under `DEC-026` and must not be guessed away
- **Cross-channel comparison of the same campaign:** traces must stay comparable even if email and ecommerce requests have different latency and exposure semantics

## 24. Non-Functional Requirements

- recent traces should become queryable quickly enough for live support and merchandising operations
- trace capture must be reliable enough that missing-trace incidents are exceptional and actionable
- storage design must support cost-controlled retention without dropping minimum business-semantic evidence
- all sensitive trace fields must be encrypted at rest and protected in transit
- schema evolution must remain backward compatible for historical queryability
- access logging and redaction rules must add minimal friction for routine authorized investigation

## 25. Analytics / Auditability Requirements

This feature is the operational trace backbone for the broader analytics and governance stack.

It must support:

- linkage from trace to impression, click, add-to-cart, purchase, dismiss, and override events
- interpretation of experiment results with visible governance context
- audit review of recommendation-affecting changes by actor, reason, and effective window
- measurement of degraded-path frequency and trace-capture quality
- meta-audit of who viewed sensitive trace detail

Analytics should be able to answer:

- which trace patterns correlate with poor outcomes
- whether governance changes caused the observed recommendation shift
- whether a set's behavior was expected baseline logic, treatment logic, or emergency behavior

## 26. Testing Requirements

- schema contract tests for canonical trace envelopes and retrieval representations
- integration tests across delivery, governance, analytics, and identity providers
- authorization tests for summary vs deep-detail access
- redaction tests by role, region, and sensitive field class
- partial-failure tests for trace-write outages or delayed enrichment
- snapshot-history tests to ensure historical traces remain interpretable after control changes
- search-index tests for lookup by `traceId`, `recommendationSetId`, placement, campaign, and time window
- meta-audit tests to confirm trace access is itself logged correctly

## 27. Recommended Architecture

Recommended logical shape:

`delivery / orchestration -> canonical trace writer -> validation and enrichment -> trace store + search index -> role-aware query facade -> operator tools / analytics drilldown / governance history`

Supporting components:

- append-only canonical trace store
- versioned governance snapshot references
- search-optimized projection index
- role-aware query facade and masking layer
- meta-audit access log

The architecture should prefer append-only evidence plus projections over mutable documents that are continuously rewritten.

## 28. Recommended Technical Design

- define a versioned canonical trace schema early, before surface-specific tooling proliferates
- propagate `traceId` and `recommendationSetId` through all delivery and telemetry paths as first-class fields
- store summary-level business evidence directly in the canonical trace even if large candidate details live elsewhere
- use explicit enums for `sourceKind`, `identityConfidence`, `profileUsageLevel`, `degradedFlags`, and `viewLevel`
- implement masking in the query layer, not as one permanently over-redacted storage format
- keep historical control references immutable so traces remain reconstructable after future changes
- support export bundles for internal investigation without requiring raw database access

## 29. Suggested Implementation Phasing

- **Phase 1:** Ecommerce RTW trace foundation for PDP and cart; canonical trace schema; `traceId` / `recommendationSetId` continuity; rule / campaign / override linkage; summary lookup API; basic meta-audit of trace access
- **Phase 2:** Identity-confidence and richer profile-usage context; tighter analytics drilldown linkage; improved degraded-state reporting
- **Phase 3:** Richer operator UI; cross-channel email and clienteling support; role-tuned summaries for stylists and support
- **Later maturity:** deeper diffing, export, and policy-specific retention / legal-hold workflows after `DEC-025` through `DEC-029` resolve

Phase 1 should lock the canonical trace semantics early even if the richest UI lands later.

## 30. Summary

Explainability and auditability is the platform's governed reconstruction layer for recommendation behavior. The implementation bar for this feature is:

- every meaningful recommendation set has stable trace identity
- curated, rule-based, **AI-ranked**, experiment, and fallback behavior remain distinguishable
- governance changes are historically reviewable
- role-aware summaries exist for non-engineering operators
- deeper evidence is available without exposing sensitive reasoning too broadly
- trace access is itself auditable

The main remaining uncertainties are already isolated to portfolio-level decisions rather than hidden inside the spec:

- `DEC-011` - first-rollout clienteling platform and explanation depth
- `DEC-025` - customer-facing explanation scope and copy boundary
- `DEC-026` - trace retention windows, deletion interaction, and preservation policy
- `DEC-027` - role matrix for summary vs deep trace vs audit access
- `DEC-028` - acceptable ranking-detail granularity for internal troubleshooting
- `DEC-029` - emergency override and incident-context visibility in operator traces
