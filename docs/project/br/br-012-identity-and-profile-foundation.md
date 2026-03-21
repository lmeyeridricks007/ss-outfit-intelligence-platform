# BR-012: Identity and profile foundation

## Metadata

- **Board Item ID:** BR-012
- **Issue:** #86
- **Stage:** workflow:br
- **Trigger:** issue-created automation
- **Parent Item:** none
- **Source Artifacts:** `docs/project/business-requirements.md`, `docs/project/goals.md`, `docs/project/architecture-overview.md`, `docs/project/roadmap.md`, `docs/project/data-standards.md`, `docs/project/product-overview.md`, `docs/project/personas.md`
- **Output Artifact:** `docs/project/br/br-012-identity-and-profile-foundation.md`
- **Next Stage:** feature breakdown on the features board, feature ID TBD during downstream fan-out
- **Approval Mode:** AUTO_APPROVE_ALLOWED

## Problem statement

The platform needs a shared identity and profile foundation so personalization and activation behave consistently across ecommerce, email, and clienteling channels. Today, customer understanding can fragment across source systems, sessions, and channels, which creates duplicate profiles, inconsistent recommendations, weak measurement, and unreliable activation. SuitSupply needs a business requirement for how customer identity should be resolved, how profile data should behave, and how cross-channel recommendation experiences should stay coherent without assuming one source-system identifier is globally reliable.

This matters because the product vision depends on recommendations that adapt to returning customers, context, and prior purchases across multiple surfaces. Without stable customer IDs, explicit source-system mappings, and visible identity confidence, the platform cannot safely support personal recommendations, channel reuse, analytics attribution, or operational trust. The foundation must support both anonymous and known journeys, preserve privacy and consent boundaries, and let downstream features use the same customer understanding rather than rebuilding identity logic per channel.

## Target users

### Primary customer personas

- **Style-aware returning customer:** expects recommendations to improve across repeat visits, repeat purchases, and multiple channels.
- **Occasion-led online shopper:** may begin anonymously, then authenticate or convert later, requiring the platform to connect current intent with profile history when permitted.
- **Custom Made customer:** needs recommendations that respect higher-consideration journeys, possible store assistance, and configuration-aware history where that data is approved for use.

### Internal personas

- **In-store stylist / clienteling associate:** needs trustworthy customer context and profile-backed recommendation starting points during live interactions.
- **Marketing and CRM manager:** needs reusable, segment-aware recommendation inputs that stay aligned with onsite and store experiences.
- **Product, analytics, and optimization lead:** needs consistent IDs, identity confidence, and profile traceability to measure recommendation impact correctly.
- **Merchandiser / look curator:** needs confidence that personalization is applied on top of governed look, rule, and campaign controls instead of conflicting with them.

## Business value

- Enables personal recommendations that feel progressively smarter across homepage, PDP, cart, email, and clienteling surfaces.
- Reduces inconsistent customer treatment caused by duplicate or conflicting source-system identities.
- Improves recommendation trust by making identity confidence, profile recency, and consent boundaries explicit.
- Supports reusable activation so marketing, ecommerce, and in-store teams can act on the same customer understanding.
- Improves analytics quality because recommendation exposures and outcomes can be attributed to stable canonical customer identities or explicitly anonymous journeys.
- Creates the minimum identity and profile foundation needed for Phase 1 recommendation delivery and Phase 2 cross-channel personalization expansion.

## Recommendation and channel mapping

### Recommendation types affected

- **Personal recommendations:** directly depend on stable customer identity and permitted profile attributes.
- **Contextual recommendations:** benefit from linking current session context to known customer context when confidence and consent allow it.
- **Outfit, cross-sell, and upsell recommendations:** should use the same identity and profile foundation when tailoring outputs for returning customers.
- **Style bundles and occasion-based recommendations:** should be reusable across channels without each channel inventing separate customer identity rules.

### Consuming surfaces affected

- **Homepage and web personalization surfaces**
- **Product detail page**
- **Cart**
- **Email and lifecycle campaigns**
- **In-store clienteling interfaces**
- **Future API consumers and admin or operational tooling**

### Recommendation source implications

- **Curated sources** remain governed by merchandising, but customer identity determines which curated looks or campaigns are eligible.
- **Rule-based sources** depend on identity-aware eligibility, suppressions, and preference handling.
- **AI-ranked sources** depend on trustworthy customer history and profile recency so ranking does not optimize on the wrong customer representation.

## Scope boundaries

### In scope

- A **stable canonical customer ID** that is independent of any one commerce, CRM, loyalty, marketing, or store-system identifier.
- Explicit **source-system identifier mappings** from channel or system IDs to the canonical customer identity.
- Business rules for **identity resolution confidence**, including when a profile is considered high-confidence, low-confidence, or unresolved.
- Support for **anonymous-to-known journey progression**, including preserving session continuity where policy and matching rules permit.
- A shared **customer profile capability** that aggregates permitted history, preferences, and recent signals for recommendation use.
- Profile expectations for **source provenance, recency, freshness visibility, and consent or suppression state**.
- Cross-channel consistency requirements for **homepage, PDP, cart, email, and clienteling** consumers.
- Business expectations for **fallback behavior** when the customer is anonymous, low-confidence, newly resolved, or missing important profile data.
- Applicability across **RTW and CM** journeys, including explicit acknowledgement that CM signals may require additional governance before broad use.
- Requirements for **traceability** so downstream recommendation decisions can identify which customer identity and profile context influenced activation.

### Out of scope

- Detailed technical design for identity graph implementation, storage design, API contracts, or matching algorithms.
- Replacement of existing commerce, CRM, loyalty, ESP, POS, or clienteling systems.
- Legal or policy approval decisions beyond documenting that consent, regional privacy, and sensitive-signal rules must be enforced.
- Building every downstream personalization feature, activation workflow, or surface-specific UX in this BR.
- Defining exact numeric thresholds, SLAs, or confidence formulas where the organization has not yet made those decisions.

## RTW and CM considerations

- **RTW:** identity and profile foundation should first support high-frequency digital journeys where anchor-product and repeat-purchase signals are strongest.
- **CM:** the same canonical identity model should apply, but profile use may need stricter governance because appointment history, stylist notes, and in-progress configuration context can be more sensitive and operationally complex.
- Identity requirements must not assume RTW and CM share identical signal quality, freshness, or activation paths. The platform should support both while allowing later-phase CM-specific governance and compatibility expansion.

## Detailed business requirements

### 1. Canonical identity requirements

- The platform must maintain a **canonical customer identity** separate from channel-specific or source-system identifiers.
- The platform must preserve **many-to-one source mappings** so customer records from commerce, CRM, loyalty, email, and store systems can be linked without losing provenance.
- The platform must not assume an email address, account ID, cookie, loyalty ID, or any single source identifier is globally authoritative on its own.
- The platform must support a distinct **anonymous session identity** that can be linked to a canonical customer identity when later evidence permits.
- The platform must support **identity conflict handling** so ambiguous matches do not silently overwrite or merge customer understanding.

### 2. Identity confidence requirements

- Every merged or linked customer identity used for personalization or activation must carry an **identity resolution confidence** or equivalent confidence state.
- Recommendation consumers must be able to distinguish between **known-high-confidence**, **known-low-confidence**, and **anonymous or unresolved** customer states.
- Low-confidence identity states must degrade safely by reducing reliance on persistent personal history instead of pretending the profile is fully trusted.
- Identity confidence must remain visible enough for analytics, operations, and downstream rules to understand when personalization was based on a partial or uncertain match.

### 3. Customer profile behavior requirements

- The platform must provide a shared **customer profile capability** for recommendation use across digital, marketing, and internal channels.
- The profile must aggregate permitted inputs such as purchase history, browsing behavior, engagement, loyalty or account context, and approved store-related signals.
- The profile must preserve **recency and source provenance** so downstream consumers can distinguish stable long-term preferences from recent short-term intent.
- The profile must indicate **consent, suppression, or regional-use constraints** relevant to recommendation activation.
- The profile must distinguish **persistent profile traits** from **session or journey-local signals** so current intent can be balanced against history.
- The profile must tolerate partial data and still support recommendation delivery, rather than failing when only minimal customer context is available.

### 4. Cross-channel consistency requirements

- The same canonical customer identity should support consistent recommendation behavior across **homepage, PDP, cart, email, and clienteling** surfaces when those channels have access to the same permitted inputs.
- Cross-channel consistency means the platform should apply the same customer understanding for preference, suppression, exclusion, and eligibility logic even when presentation differs by surface.
- Channels may shape recommendation payloads differently, but they must not redefine the underlying customer identity or profile semantics independently.
- Customer actions and new signals captured in one channel should become available to other eligible channels within an agreed freshness model rather than remaining permanently siloed.
- Where one channel lacks sufficient context or consent, the platform must fall back gracefully without contradicting higher-confidence treatment on other channels.

### 5. Personalization and activation requirements

- Personal recommendations must only use profile attributes and history that are permitted by region, consent state, and company policy.
- Identity and profile foundation must support **activation reuse** so email, onsite personalization, and clienteling flows can consume the same customer understanding.
- The platform must support **suppression and exclusion logic** so prior purchases, ineligible products, or policy-restricted signals do not create contradictory recommendations across channels.
- The profile foundation must support both **returning-customer personalization** and **anonymous-session fallback** within the same product experience.
- Downstream recommendation logic must be able to combine profile inputs with curated, rule-based, and AI-ranked sources without bypassing merchandising governance.

### 6. Measurement and operational requirements

- Recommendation telemetry must be able to reference the canonical customer ID when known, or an anonymous session ID when not.
- Identity and profile usage must be traceable enough that analytics can understand which profile state influenced a recommendation set.
- Operators must be able to identify when poor recommendation performance may be caused by identity gaps, stale profile data, or low-confidence matches.
- The identity and profile foundation must support phased rollout, starting with a narrower high-confidence use case before broadening to richer cross-channel activation.

## Success metrics

### Business and product outcomes

- Personal recommendations for returning customers feel more consistent across homepage, PDP, cart, email, and clienteling workflows.
- Internal teams can reuse the same customer understanding across activation channels rather than maintaining channel-specific personalization logic.
- Recommendation quality for returning customers measurably improves relative to anonymous-only behavior, with exact uplift targets **TBD** downstream.

### Operational and data outcomes

- Recommendation events can be attributed to either a canonical customer ID or an anonymous session ID with minimal ambiguity.
- Identity confidence coverage is visible for recommendation-influenced sessions and campaigns.
- Duplicate or conflicting customer representations that affect recommendation behavior trend downward, with baseline and target **TBD**.
- Profile freshness, provenance, and consent visibility are available to downstream consumers and operators.
- Cross-channel suppressions and preference handling behave consistently enough to avoid contradictory activations, with exact consistency thresholds **TBD**.

## Constraints and guardrails

- The platform must respect privacy, consent, and regional policy boundaries before profile data is used for recommendations or activation.
- Sensitive signals such as stylist notes, appointment data, or high-touch store interactions must not be broadly activated without explicit governance.
- The platform must preserve merchandising control and hard compatibility rules even when identity-driven personalization is available.
- This BR must remain business-focused; technical implementation choices are for downstream architecture and planning work.

## Phase guidance

### Phase 1 foundation

- Establish canonical customer IDs, source mappings, anonymous-session handling, and a basic profile capability for high-confidence digital recommendation use cases.
- Support enough profile behavior to improve returning-customer experiences on early surfaces such as PDP and cart.
- Make identity confidence, recency, and consent constraints visible from the start.

### Phase 2 expansion

- Expand cross-channel identity resolution across ecommerce, email, loyalty, and broader customer history.
- Increase profile richness for personal and contextual recommendations.
- Improve cross-channel consistency for activation and measurement.

### Later-phase considerations

- Expand CM, store appointment, and stylist-assisted profile use only after governance, sensitivity rules, and operational controls are strong enough.
- Avoid broad rollout of low-confidence or opaque identity logic before the Phase 1 and Phase 2 foundations are trusted.

## Open decisions

- **Missing decision:** Which source systems are authoritative enough to initiate canonical identity creation in the first release?
- **Missing decision:** What confidence thresholds or business states should distinguish safe personalization from fallback treatment?
- **Missing decision:** Which profile attributes are allowed for each consuming channel, especially email and clienteling?
- **Missing decision:** What freshness expectations apply by surface for profile updates and cross-channel propagation?
- **Missing decision:** Which CM and store-originated signals are approved for early use, and which require later governance review?
- **Missing decision:** What merge and unmerge operating model is required when source-system identities conflict?
- **Missing decision:** What customer-facing explanation, if any, is acceptable when recommendations are profile-influenced?

## Approval and milestone notes

- **Trigger:** issue-created automation from GitHub issue #86.
- **Approval mode:** `AUTO_APPROVE_ALLOWED` as recorded on `boards/business-requirements.md`.
- **Autonomous run note:** this artifact is intended to be completed, committed, and pushed without waiting for human approval.
- **Downstream note:** feature breakdown should fan this BR into work for canonical identity management, profile behavior, consent-aware activation, cross-channel consistency rules, and identity observability.
