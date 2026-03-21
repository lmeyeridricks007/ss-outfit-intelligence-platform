# Feature: Open decisions

**Upstream traceability:** `docs/project/business-requirements.md` (BR-001 through BR-012); `docs/project/vision.md`; `docs/project/goals.md`; `docs/project/problem-statement.md`; `docs/project/personas.md`; `docs/project/product-overview.md`; `docs/project/roadmap.md`; `docs/project/architecture-overview.md`; `docs/project/standards.md`; `docs/project/review-rubrics.md`; `docs/project/agent-operating-model.md`; `docs/features/README.md`; `docs/features/feature-spec-index.md`; all feature deep-dives under `docs/features/*.md`.

---

## 1. Purpose

Define the portfolio-level feature that captures unresolved product, governance, analytics, privacy, and architecture choices discovered during the feature deep-dive stage so downstream architecture and implementation work does not silently invent missing decisions.

This file is the canonical cross-feature decision register for the feature stage. It exists to make uncertainty explicit, traceable, and actionable.

## 2. Core Concept

Feature deep-dives should be implementation-oriented, but they should not pretend that every strategic or cross-cutting choice is already settled. `open-decisions.md` is the shared mechanism that:

1. consolidates cross-feature gaps into one decision portfolio
2. gives each decision a stable ID
3. records why the decision matters and who should own it
4. helps architecture, planning, and governance work resolve decisions in the right stage
5. prevents repeated or conflicting local assumptions across feature specs

The goal is not to create a generic parking lot. The goal is to preserve implementation readiness while clearly separating:

- what is already canonical product truth
- what is still unresolved but known
- what must be resolved before later stages can safely claim final contracts or rollout readiness

## 3. Why This Feature Exists

The project standards and operating model require downstream artifacts to record missing decisions rather than invent them. That matters especially for this portfolio because the product spans:

- ecommerce, email, and clienteling channels
- RTW and CM modes
- curated, rule-based, and AI-ranked recommendation sources
- inventory, identity, consent, experimentation, and explainability concerns

Without a shared open-decision feature:

- each feature spec would hide or duplicate the same unresolved questions
- architecture could freeze contracts that contradict feature-stage assumptions
- implementation-planning teams would guess at precedence, freshness, or privacy policy
- review artifacts would not be able to distinguish acceptable uncertainty from missing depth

## 4. User / Business Problems Solved

| User / stakeholder | Problem | How this feature helps |
| --- | --- | --- |
| Product leadership | Strategic or scope decisions get rediscovered in many docs | Provides one place to see unresolved product choices and their phase impact |
| Architecture | Contract and subsystem work can start from incomplete or conflicting assumptions | Makes critical unresolved contract, latency, data, and ownership questions explicit before architecture hardens them |
| Implementation planning | Teams cannot tell which questions are true blockers vs later-phase decisions | Adds decision owners, downstream impact, and recommended resolution timing |
| Merchandising / governance | Policy questions become scattered across recommendation, governance, and explainability docs | Consolidates cross-cutting governance choices with clear references |
| Privacy / legal / security | Consent, retention, and trace-depth choices can be buried inside adjacent features | Keeps sensitive policy decisions visible and auditable |
| Reviewers | Hard to judge whether a feature is incomplete or simply waiting on a portfolio-level choice | Isolates acceptable unresolved items so feature reviews can focus on actual depth and correctness |

## 5. Scope

This feature covers the portfolio-level handling of unresolved decisions discovered in `docs/features/*.md`. It includes:

- the canonical decision register
- decision taxonomy and lifecycle semantics
- resolution ownership expectations
- phase and stage guidance for when decisions should be resolved
- update rules for reconciling decisions back into canonical `docs/project/` or BR documents

This feature does **not** directly resolve the decisions themselves. It also does **not** replace board workflow, human approval, or architecture artifacts.

**Assumptions:**

- The current set of feature deep-dives is broad enough that most high-value unresolved items are already represented.
- Decision IDs must remain stable once referenced from feature specs or review artifacts.
- The repository may later formalize board-level or project-operations handling for some decisions, but the feature layer still needs a canonical register now.

## 6. In Scope

- Cross-feature unresolved decisions discovered during feature deep-dives
- Stable decision IDs (`DEC-###`)
- Mapping from decisions to originating feature specs
- Owner and downstream-impact visibility
- Recommended resolution stage and phase framing
- Rules for reconciling resolved decisions into canonical docs
- Review and audit guidance for acceptable feature-stage uncertainty

## 7. Out of Scope

- Final architectural solutions for the listed decisions
- Board-state changes, approvals, or promotion claims
- Issue fan-out into implementation tickets
- Detailed program-management workflows outside repository artifacts
- Runtime software for decision tracking beyond what future stages may choose to build

## 8. Main User Personas

| Persona / role | Why they use this feature |
| --- | --- |
| Product lead | Validate which unresolved choices affect roadmap, phase boundaries, or customer-facing behavior |
| Architect | Identify decisions that must be settled before freezing contracts, integrations, or service boundaries |
| Implementation planner | Separate architecture-stage unknowns from later optimization or expansion questions |
| Merchandising / governance operator | Understand which controls, approval semantics, and precedence rules are still not canonical |
| Analytics / privacy / legal stakeholders | Find unresolved measurement, retention, consent, and explanation-policy items in one place |
| Feature reviewer | Confirm that open questions are explicit rather than hidden as gaps in a feature deep-dive |

## 9. Main User Journeys

### Journey 1: Feature author discovers a repeated unresolved question

1. A feature deep-dive identifies a missing decision that affects more than one module or downstream artifact.
2. The feature doc references an existing `DEC-###` if one already exists, or the portfolio adds a new decision ID.
3. The open-decision record captures topic, source, owner, and downstream impact.
4. Other features reference the same decision instead of inventing local variants.

### Journey 2: Architecture team scopes its next stage

1. Architecture reviews `feature-spec-index.md` and this file together.
2. The team identifies decisions that must be resolved before finalizing contracts, ownership, or phase commitments.
3. Resolved decisions are written back into `docs/project/` or BR artifacts first when they change canonical product truth.
4. The affected feature specs and this register are reconciled together.

### Journey 3: Reviewer evaluates whether a feature doc is promotable

1. Reviewer sees explicit open decisions referenced from a feature spec.
2. Reviewer checks whether those decisions are already tracked here with stable IDs.
3. If yes, the reviewer can focus on feature depth rather than penalizing appropriate uncertainty.
4. If not, the reviewer identifies the gap as a missing artifact-quality issue rather than acceptable deferral.

### Journey 4: Governance or legal stakeholder resolves a policy decision

1. A decision involving privacy, retention, role access, or consent is reviewed by the proper owner.
2. Canonical policy text is updated in `docs/project/` or a BR artifact.
3. The corresponding feature specs are updated to align with the new canonical truth.
4. The open-decision entry is revised to show that the portfolio-level uncertainty is no longer active.

## 10. Triggering Events / Inputs

| Trigger | Typical input | Expected action |
| --- | --- | --- |
| New feature deep-dive created or refined | Missing decision discovered in one or more feature docs | Add or reference a decision entry with stable ID |
| Review pass identifies hidden uncertainty | Review artifact cites a decision gap | Create or tighten the decision record and link it from the affected feature |
| Architecture needs to freeze a contract | Delivery, ownership, schema, latency, or provider choice requires resolution | Use this register to identify upstream truth and update targets |
| Product or governance clarification arrives | Decision resolved in comments, policy docs, or BR updates | Update canonical docs first, then reconcile this file and affected features |
| Roadmap or phase boundary changes | Resolution timing or scope changes | Reassess the priority framing and downstream impact notes |

## 11. States / Lifecycle

This artifact does not manage board workflow state, but each portfolio decision follows a conceptual lifecycle:

1. **Observed** - a real unresolved question appears in one or more feature specs
2. **Registered** - the decision receives a stable `DEC-###` ID with source and owner
3. **Triaged** - the team identifies why it matters and which stage should resolve it
4. **Resolved upstream** - canonical product, BR, governance, or architecture truth is updated
5. **Reconciled downstream** - affected feature specs and review artifacts are brought back into alignment
6. **Historical / superseded** - if a decision is replaced by a newer framing, keep an auditable trail rather than reusing the ID for a different meaning

Current repository behavior is intentionally simple: the register stores active portfolio decisions and their context, while review and audit artifacts explain whether the uncertainty is acceptable at the feature stage.

## 12. Business Rules

1. Do not invent missing business or architecture decisions in downstream artifacts when the decision is known to be unresolved.
2. If the same unresolved question appears in multiple feature docs, prefer one shared `DEC-###` rather than duplicated local notes.
3. Keep decision IDs stable once they are referenced in feature docs, reviews, audits, or downstream planning artifacts.
4. When a decision changes canonical product truth, update `docs/project/` or the relevant BR document before reconciling feature docs.
5. A decision may remain open at the feature stage if the feature doc is otherwise concrete and the downstream impact is explicit.
6. A decision is blocking if unresolved ambiguity would make architecture or implementation planning unsafe.
7. Decision records must name an owner or owning function even if a specific person is not known.
8. Cross-cutting privacy, consent, retention, and role-access decisions must never be hidden inside non-governance features.
9. Do not use this file to imply that a decision is approved, finalized, or implemented without matching canonical evidence.

## 13. Configuration Model

Each decision record should be interpretable through the following logical attributes:

| Attribute | Meaning |
| --- | --- |
| Decision ID | Stable cross-reference key used by feature docs and reviews |
| Topic | Short description of the unresolved choice |
| Originating feature(s) | Where the decision first surfaced or currently matters |
| Primary upstream source | Canonical sources that constrain the decision |
| Owner | Function primarily responsible for resolution |
| Why it matters downstream | Consequence if later stages guess |

Recommended derived attributes for future stages, even if not yet stored as explicit columns:

- decision type: product, architecture, governance, analytics, privacy, operations
- recommended resolution stage: feature follow-up, architecture, implementation planning, governance approval
- roadmap urgency: Phase 1 critical, later-phase critical, or expansion-only
- canonical update target: `docs/project/`, `docs/project/br/`, architecture, or implementation plan

## 14. Data Model

The current markdown table is the source of truth, but the logical decision-record schema is:

```text
decisionId
topic
originatingFeatures[]
primaryUpstreamSources[]
owner
downstreamImpact
```

Recommended future extensions if the repository later formalizes this artifact into stronger board or machine-readable handling:

```text
status
decisionType
recommendedResolutionStage
roadmapUrgency
canonicalUpdateTarget
resolvedByArtifact
resolvedAt
supersedes[]
```

## 15. Read Model / Projection Needs

Downstream users need more than the raw register table. They need to answer:

- which decisions affect Phase 1 ecommerce launch quality
- which decisions block architecture contract hardening
- which decisions are policy/governance items vs technical design items
- which feature specs are affected by a single decision
- which canonical documents must be updated when a decision resolves

This file therefore includes derived views below to support architecture and planning without forcing re-analysis of every feature deep-dive.

## 16. APIs / Contracts

This is a documentation-stage feature, so its primary contract is an **artifact contract**, not a runtime API.

Expected contract for feature docs referencing open decisions:

1. Reference the relevant `DEC-###` IDs explicitly.
2. Do not create conflicting local wording that changes the meaning of an existing decision.
3. Point to this file when uncertainty is portfolio-level rather than feature-local.
4. Update both the feature doc and this file when a decision meaning changes materially.

Example reference contract inside a feature spec:

```markdown
**Tracked open decisions:** `DEC-006`, `DEC-007`
```

Expected contract for downstream resolution artifacts:

1. Resolve canonical truth in the right source layer first.
2. Note which `DEC-###` entries are being resolved.
3. Reconcile impacted feature docs, reviews, and plans after the canonical update.

## 17. Events / Async Flows

Although this is a docs artifact, it still participates in important asynchronous repository flows:

### Flow A: Feature discovery to portfolio registration

1. Feature deep-dive identifies unresolved cross-cutting question.
2. Feature doc adds or references `DEC-###`.
3. This register updates the portfolio-level record.
4. Review artifact confirms uncertainty is explicit rather than hidden.

### Flow B: Architecture resolution

1. Architecture identifies a decision that must be frozen.
2. Canonical product or architecture artifact resolves the question.
3. Feature docs update to remove or narrow the uncertainty.
4. This register is reconciled so downstream teams do not continue treating the decision as open.

### Flow C: Governance or policy resolution

1. Legal, privacy, or governance review clarifies policy.
2. Policy source of truth updates.
3. Related feature docs, this register, and relevant review notes are updated together.

## 18. UI / UX Design

For the documentation surface itself, the register should optimize for fast scanning and safe handoff:

- stable IDs for cross-linking
- one concise row per decision
- enough context to understand impact without re-reading every feature file
- clear grouping and priority framing for architecture and planning teams
- explicit notes where resolution must happen in canonical docs first

This is intentionally a markdown-first UX because the repository currently uses docs as the authoritative stage artifact.

## 19. Main Screens / Components

The effective components of this feature are:

1. **Purpose and operating guidance** - explains how to use the register
2. **Decision register** - canonical list of active portfolio decisions
3. **Priority views** - shows what needs earlier resolution vs later
4. **Owner matrix** - clarifies who should resolve which classes of decisions
5. **Rules for reconciliation** - explains how to update canonical docs and downstream feature specs safely

If the repo later creates a dedicated board or dashboard view for open decisions, it should preserve these same components.

## 20. Permissions / Security Rules

- Product, architecture, governance, privacy, analytics, and operations stakeholders may all contribute decision context, but canonical resolution must follow the correct source-of-truth layer.
- Decisions touching customer data, explanation depth, access permissions, or retention must be treated as governance-sensitive.
- This register must not leak private customer data or operational secrets; it records policy questions, not sensitive case data.
- Review artifacts may reference decisions, but they must not present unresolved policy as final approval.

## 21. Notifications / Alerts / Side Effects

When important decisions remain unresolved, the side effects are usually documentation or planning related:

- feature reviews may call out that downstream work is conditionally ready
- architecture work may need to stop short of final contract claims
- implementation plans may need explicit dependency notes or milestone gates
- governance-sensitive features may require human review before policy assumptions change

The artifact itself does not send notifications, but it should make these side effects visible enough for review comments, PR descriptions, and follow-up planning.

## 22. Integrations / Dependencies

This feature depends on and integrates with:

- all feature deep-dives under `docs/features/`
- `docs/features/feature-spec-index.md` for feature inventory and dependency context
- `docs/features/README.md` for portfolio navigation
- canonical docs under `docs/project/`
- BR artifacts under `docs/project/br/`
- review and audit artifacts under `docs/features/deep-dives/reviews/` and `docs/features/audits/`

It is especially coupled to:

- shared contracts and delivery API decisions
- governance and approval semantics
- analytics and telemetry policy
- privacy, identity, and traceability boundaries

## 23. Edge Cases / Failure Cases

- A feature introduces a new unresolved item but does not register it here, creating hidden uncertainty.
- Two feature docs describe the same unresolved question differently, causing duplicate or conflicting decisions.
- A decision is resolved in an architecture or BR artifact but this file is not updated, leaving stale uncertainty.
- A decision touches multiple owners and no one is clearly accountable.
- A decision is treated as architecture-only when it actually changes canonical product or governance policy.
- A later-stage artifact silently resolves a decision without updating upstream truth, creating drift.
- A stable `DEC-###` ID gets reused for a different meaning, breaking review traceability.

## 24. Non-Functional Requirements

- **Clarity:** every decision entry must be understandable without deep repo archaeology
- **Traceability:** every decision must point back to source features and upstream product truth
- **Stability:** decision IDs should remain durable across review cycles
- **Maintainability:** the register should stay concise enough to scan even as the portfolio grows
- **Auditability:** review and audit artifacts must be able to reference decisions unambiguously
- **Stage safety:** the artifact must support downstream planning without overstating certainty

## 25. Analytics / Auditability Requirements

Even as a documentation feature, this artifact should support portfolio governance and audit questions such as:

- how many open decisions remain in Phase 1-critical areas
- which owners have the heaviest unresolved-decision burden
- which features depend on the same unresolved choice
- whether feature reviews are isolating uncertainty consistently
- whether resolved decisions are being reconciled back into canonical docs

Review and audit artifacts should explicitly call out whether open decisions remain appropriate for the current stage or have become blockers.

## 26. Testing Requirements

Validation for this feature should include:

1. every `DEC-###` referenced from feature docs resolves to a real entry here
2. decision IDs remain unique and stable
3. origin feature names and filenames remain current
4. owner and downstream-impact notes are present for each decision
5. README and feature-index guidance still match the role of this file
6. review and audit artifacts interpret open decisions as explicit uncertainty rather than hidden gaps

## 27. Recommended Architecture

At the repository level, treat this feature as a **portfolio decision registry** owned by the feature stage but consumed heavily by architecture and implementation planning.

Recommended operating model:

- feature docs remain the primary source for feature-local behavior
- `open-decisions.md` remains the portfolio source for cross-cutting unresolved choices
- canonical product or BR docs remain the source of truth for resolved product policy
- architecture docs become the source of truth for resolved technical design choices

This keeps the register small enough to remain useful while still preserving stage-to-stage traceability.

## 28. Recommended Technical Design

1. Keep the register in markdown with stable `DEC-###` IDs.
2. Reference decision IDs from feature docs instead of copying full unresolved-question prose repeatedly.
3. Preserve concise row-level phrasing, then add richer categorization and priority views around the table.
4. When a decision resolves, update the canonical source first, then reconcile:
   - `docs/features/open-decisions.md`
   - affected feature deep-dives
   - any review or audit artifact whose conclusion materially depends on that decision
5. Avoid automatic deletion of resolved history unless a stronger archival pattern exists; stable traceability matters more than keeping the file artificially short.

## 29. Suggested Implementation Phasing

### Phase 0 / feature-stage baseline

- maintain the shared decision register
- keep IDs stable and referenced from feature specs
- isolate uncertainty so feature reviews can still judge implementation readiness accurately

### Architecture stage

- resolve contract, latency, provider, source-of-truth, and precedence decisions that affect shared design
- write resolved truth into canonical product or architecture docs

### Implementation-planning stage

- translate unresolved-but-now-bounded decisions into milestone dependencies, rollout gates, and acceptance criteria

### Build and QA stages

- treat this file primarily as traceability evidence
- ensure implemented behavior follows resolved canonical truth rather than stale feature-stage assumptions

## 30. Summary

`open-decisions.md` is the feature-stage portfolio mechanism that keeps uncertainty visible, owned, and safe. It allows the repository to produce concrete feature deep-dives without pretending that every cross-cutting decision is already final. Used correctly, it improves architecture readiness, review rigor, and cross-module consistency by making unresolved questions explicit instead of letting downstream teams guess.

---

## Decision portfolio summary

### Decision categories represented

| Category | Representative decisions | Why the category matters |
| --- | --- | --- |
| Shared contract and delivery shape | `DEC-001`, `DEC-002`, `DEC-003` | Determines how every consuming surface integrates with the recommendation platform |
| Surface and channel scope | `DEC-004`, `DEC-010`, `DEC-011` | Controls what launches when and which channels can safely consume shared logic |
| UX and customer-facing semantics | `DEC-005`, `DEC-018`, `DEC-019`, `DEC-025` | Protects recommendation meaning, copy boundaries, and degraded-state honesty |
| Experimentation and telemetry | `DEC-006`, `DEC-007` | Needed for trustworthy measurement and optimization |
| Context, identity, and privacy | `DEC-009`, `DEC-021` through `DEC-033` | Governs consent, profile use, retention, explanation depth, and trace visibility |
| Catalog, readiness, and inventory policy | `DEC-014` through `DEC-017` | Defines what products qualify for recommendation and how degraded supply truth is handled |
| Governance and operator controls | `DEC-008`, `DEC-034`, `DEC-035`, `DEC-036` | Defines precedence, approvals, emergency controls, and curated-ordering policy |

### Recommended resolution priority view

This is a feature-stage guidance view derived from `docs/project/roadmap.md` and the current portfolio, not a board-state change.

| Priority bucket | Decision IDs | Why these should resolve earlier |
| --- | --- | --- |
| Architecture-contract critical | `DEC-001`, `DEC-003`, `DEC-014`, `DEC-018`, `DEC-019`, `DEC-034` | These shape shared contracts, eligibility semantics, grouped-output truth, or governance boundaries that architecture cannot safely harden by guesswork. |
| Phase 1 launch-quality critical | `DEC-002`, `DEC-005`, `DEC-006`, `DEC-015`, `DEC-016`, `DEC-020`, `DEC-035`, `DEC-036` | These affect interactive ecommerce quality, telemetry validity, inventory safety, outfit coherence, or emergency-governance behavior for early rollout. |
| Later-phase expansion critical | `DEC-004`, `DEC-009`, `DEC-010`, `DEC-011`, `DEC-012`, `DEC-021` through `DEC-033` | Important for personalization, cross-channel expansion, clienteling, and deeper governance, but not all must block early architecture for Phase 1 RTW foundations. |
| Repository-operations hygiene | `DEC-013` | Important for cross-stage traceability and stable feature references, but lower product-risk than customer- or contract-facing decisions. |

### Owner emphasis view

| Owner group | Representative decisions |
| --- | --- |
| Architecture | `DEC-001`, `DEC-002`, `DEC-003`, `DEC-014`, `DEC-024` |
| Product | `DEC-004`, `DEC-005`, `DEC-012`, `DEC-018`, `DEC-020` |
| Product + governance / merchandising | `DEC-008`, `DEC-015`, `DEC-034`, `DEC-035`, `DEC-036` |
| Analytics | `DEC-006`, `DEC-007`, `DEC-032` |
| Legal / privacy / security | `DEC-009`, `DEC-021`, `DEC-024`, `DEC-026`, `DEC-027`, `DEC-028`, `DEC-030`, `DEC-031` |

---

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
| DEC-014 | Source-of-truth precedence when PIM, commerce, DAM, and compatibility sources disagree on recommendation-critical fields | `catalog-and-product-intelligence.md` | BR-008, `docs/project/architecture-overview.md`, `docs/project/data-standards.md` | Architecture + Product data owners | Needed so catalog-readiness evaluation can resolve conflicts consistently instead of letting downstream services invent field precedence. |
| DEC-015 | Category- and surface-specific readiness thresholds for attributes, imagery, and compatibility before a product is recommendation-eligible | `catalog-and-product-intelligence.md` | BR-008, `docs/project/roadmap.md` | Product + Merchandising governance | Determines which products qualify for PDP, cart, inspiration, email, and operator-assisted recommendation use, and how degraded states are measured. |
| DEC-016 | Inventory freshness windows and bounded fallback policy by surface (`PDP`, `cart`, homepage, email, clienteling) | `catalog-and-product-intelligence.md`, `ecommerce-surface-experiences.md`, `channel-expansion-email-and-clienteling.md` | BR-008, `docs/project/roadmap.md` | Product + Architecture + Commerce ops | Needed to define when inventory-sensitive recommendation use must suppress, replace, or cautiously degrade candidates instead of serving stale sellability truth. |
| DEC-017 | Minimum CM field groups and compatibility evidence required before customer-facing configuration-aware CM recommendations are allowed | `catalog-and-product-intelligence.md`, `rtw-and-cm-mode-support.md` | BR-004, BR-008 | Product + CM operations + Architecture | Prevents customer-facing CM experiences from overstating compatibility when garment, fabric, palette, or service-availability data is incomplete. |
| DEC-018 | Complete-look composition policy by anchor, surface, and mode: which slots are mandatory versus optional for a credible outfit | `complete-look-orchestration.md` | BR-001, BR-002, `docs/project/roadmap.md` | Product + Merchandising governance | Determines Phase 1 PDP/cart template design, what qualifies as a complete look, and how architecture models required versus optional slot coverage. |
| DEC-019 | Slot substitution versus omission policy, and the minimum acceptable degraded complete-look output before the service must suppress the set entirely | `complete-look-orchestration.md` | BR-001, BR-008, BR-011 | Product + Architecture + Commerce ops | Needed to keep degraded outputs honest, define fallback codes, and avoid turning outfit modules into misleading partial-product lists. |
| DEC-020 | Primary-anchor resolution policy for cart, occasion, and assisted-selling requests with multiple plausible lead items or missions | `complete-look-orchestration.md` | BR-001, BR-002, BR-007 | Product + Architecture | Shapes request normalization, template selection, trace semantics, and how multi-item or mixed-intent flows preserve a single coherent outfit mission. |
| DEC-021 | Signal-family consent matrix and permitted-use policy by region and surface | `customer-signal-ingestion.md` | BR-006, BR-012, `docs/project/data-standards.md` | Product + Legal + Privacy operations | Determines which signal families may be used for session-only, bounded known-customer, or cross-channel personalized activation without inventing local policy shortcuts. |
| DEC-022 | Numeric freshness windows and decay policy by signal family and consuming surface | `customer-signal-ingestion.md` | BR-006, `docs/project/roadmap.md` | Product + Architecture + Analytics | Needed so session intent, durable history, and reviewed operator context degrade consistently across PDP, cart, email, and clienteling instead of each consumer setting its own staleness rules. |
| DEC-023 | Store and stylist signal governance depth, structured taxonomy, and reviewed free-text policy | `customer-signal-ingestion.md`, `channel-expansion-email-and-clienteling.md` | BR-006, BR-003, BR-012 | Product + Clienteling operations + Governance | Decides when operator-entered signals can remain clienteling-only, become structured profile inputs, or stay blocked from customer-facing personalization and analytics-safe summaries. |
| DEC-024 | Raw signal retention, PII minimization, replay strategy, and regional residency model | `customer-signal-ingestion.md` | BR-006, BR-010, `docs/project/data-standards.md`, `docs/project/architecture-overview.md` | Architecture + Security + Legal | Shapes storage-layer design, deletion and revocation propagation, replay safety, regional compliance, and how much raw signal detail can be kept for audit and backfill without violating policy. |
| DEC-025 | Customer-facing explanation scope and copy boundary for ecommerce and clienteling surfaces | `explainability-and-auditability.md`, `channel-expansion-email-and-clienteling.md` | BR-011, BR-003, `docs/project/business-requirements.md` | Product + Legal + Clienteling operations | Needed so downstream UX, API contracts, and policy review distinguish operator-facing explanations from any customer-visible explanation without leaking sensitive reasoning or internal control context. |
| DEC-026 | Trace retention windows, privacy-deletion interaction, and preservation policy by trace class and region | `explainability-and-auditability.md` | BR-011, `docs/project/data-standards.md`, `docs/project/architecture-overview.md` | Architecture + Security + Legal | Determines how long summary traces, deep trace detail, and access-audit records can be retained, how deletion requests affect historical traces, and whether incident or legal-preservation exceptions apply. |
| DEC-027 | Role matrix for summary explanation, deep trace detail, audit-history access, and export permissions | `explainability-and-auditability.md` | BR-011, BR-009, BR-012 | Product + Security + Governance | Controls which personas can see bounded summaries versus sensitive trace detail, and prevents downstream tooling from assuming one universal trace-view permission model. |
| DEC-028 | Acceptable ranking-detail granularity for internal troubleshooting without exposing sensitive feature reasoning | `explainability-and-auditability.md` | BR-011, BR-005, BR-012 | Product + Architecture + Privacy operations | Needed to define how much ranking evidence operators receive, whether summaries stop at source-mix and rule context or include finer ordering rationale, and how to avoid exposing sensitive profile or model detail. |
| DEC-029 | Emergency override and incident-context visibility in operator trace views | `explainability-and-auditability.md`, `merchandising-governance-and-operator-controls.md` | BR-011, BR-009 | Product + Governance + Support operations | Determines how traces distinguish emergency behavior from baseline delivery while keeping sensitive incident-response details visible only to appropriate roles and preserving trustworthy operator troubleshooting. |
| DEC-030 | Identity-confidence thresholds, evidence weighting, and auto-link criteria by source and consuming channel | `identity-and-style-profile.md` | BR-012, BR-006, `docs/project/data-standards.md` | Product + Architecture + Privacy operations | Needed to define when identity can move from unknown to bounded or high confidence, when ambiguous evidence requires review, and how confidently different consumers may activate known-customer behavior. |
| DEC-031 | Allowed style-profile domains by channel, surface, and recommendation purpose | `identity-and-style-profile.md`, `channel-expansion-email-and-clienteling.md` | BR-012, BR-003, BR-006 | Product + Marketing + Clienteling operations + Privacy operations | Determines which profile domains can be used for ecommerce, email, and assisted-selling activation so channels do not invent separate or over-broad customer models. |
| DEC-032 | Ownership, returns, exchanges, and duplicate-suppression windows for wardrobe-aware recommendations | `identity-and-style-profile.md` | BR-012, BR-006, BR-011 | Product + Merchandising governance + Analytics | Needed to decide when owned-item suppressions should hard-block, demote, or expire, and how return or exchange activity should reverse prior ownership assumptions without creating stale suppression behavior. |
| DEC-033 | Operator review workflow and escalation policy for conflicted or sensitive identity cases | `identity-and-style-profile.md`, `channel-expansion-email-and-clienteling.md` | BR-012, BR-011, `docs/project/agent-operating-model.md` | Product + Clienteling operations + Governance | Defines whether ambiguous identity cases require human review before certain activation paths, what operators may resolve manually, and how clienteling or high-value workflows proceed safely when identity remains conflicted. |
| DEC-034 | Approval-role matrix and dual-approval thresholds for merchandising controls by risk class, scope, and mode | `merchandising-governance-and-operator-controls.md` | BR-009, `docs/project/br/br-009-merchandising-governance.md`, `docs/project/agent-operating-model.md` | Product + Governance + Security operations | Needed so feature, architecture, and build work know exactly which changes can self-activate, which require second review, and which premium or CM controls require named approvers rather than inventing local approval policy. |
| DEC-035 | Maximum duration, renewal policy, and post-change review deadline for emergency overrides | `merchandising-governance-and-operator-controls.md` | BR-009, BR-011, `docs/project/roadmap.md` | Product + Governance + Support operations | Determines how long incident-response controls may stay active before auto-expiration or forced review, and prevents temporary suppressions or replacements from quietly becoming baseline behavior. |
| DEC-036 | Default curated ordering policy by surface and mode: fixed order vs reorderable-within-curated-set vs fully governed mix | `merchandising-governance-and-operator-controls.md`, `complete-look-orchestration.md`, `rtw-and-cm-mode-support.md` | BR-009, BR-001, BR-004, BR-005 | Product + Merchandising governance | Required to define how much AI ranking freedom remains once curated looks are active on PDP, cart, homepage, clienteling, RTW, and CM experiences, and to keep operators from assuming different ordering semantics per channel. |

## Notes

- These are not automatic blockers for keeping `docs/features/` as the feature-stage source of truth, but they should be resolved or explicitly deferred before downstream architecture and implementation artifacts claim final contracts or rollout readiness.
- When a decision affects canonical product truth, update `docs/project/` or the relevant BR doc first, then reconcile the feature specs and this register.
- Review artifacts should treat these as explicit uncertainty, not as evidence that the affected feature files are shallow or incomplete by default.
