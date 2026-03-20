# Business requirements: BR-003 Multi-surface delivery

**BR ID:** BR-003  
**Parent item:** None  
**Stage:** workflow:br  
**Trigger:** issue-created automation for GitHub issue #52  
**Source artifacts:** `docs/project/business-requirements.md` (BR-3), `docs/project/product-overview.md`, `docs/project/roadmap.md`, `docs/project/goals.md`  
**Planned output:** `docs/project/br/br-003-multi-surface-delivery.md`

## Problem statement

SuitSupply needs one recommendation capability that can serve multiple customer and internal surfaces without fragmenting styling logic, business controls, or measurement. Today, the product direction clearly expects recommendations to appear across ecommerce, email, clienteling, and future API-driven consumers, but those surfaces have different decision moments, latency expectations, identity confidence, and presentation needs. If each surface receives separately defined recommendation behavior, the business will recreate the same outfit logic multiple times, create inconsistent customer experiences, and make merchandising governance harder to scale.

This requirement exists to define the shared business expectations for a multi-surface delivery model: ecommerce must validate commercial value early, shared delivery contracts must start early enough that later channels reuse the same recommendation outputs, and deeper multi-channel activation should expand in Phase 3 once governance, telemetry, and contract stability are reliable.

## Target users

### Primary users
- Ecommerce shoppers on product detail pages, cart, homepage, and style-discovery surfaces who need complete-look recommendations that are relevant to the current journey.
- Returning customers whose recommendations should remain coherent across sessions and touchpoints.
- Occasion-led shoppers who may begin on digital browsing surfaces and later continue through email or stylist-assisted journeys.

### Secondary users
- Lifecycle and campaign marketers who need reusable recommendation outputs for email programs.
- In-store stylists and clienteling teams who need recommendation sets that can support assisted selling and follow-up outreach.
- Merchandisers who need consistent curation, rule application, campaign controls, and eligibility behavior across every consuming surface.
- Internal product teams or future API consumers, such as mobile or partner experiences, that need governed recommendation outputs without recreating recommendation logic.

## Business value

Multi-surface delivery matters because it:
- increases conversion and attachment by making complete-look recommendations available at more high-intent moments;
- increases reuse of curated looks, compatibility rules, and ranking outputs instead of rebuilding them per channel;
- improves campaign and clienteling effectiveness by letting email and in-store workflows use the same recommendation decisioning foundation as ecommerce;
- preserves brand consistency because merchandising controls, exclusions, and campaign priorities apply across surfaces rather than only inside one channel;
- reduces operational fragmentation by establishing one delivery contract, one telemetry model, and one set of shared expectations for future consumers.

## Recommendation and channel mapping

### Recommendation types in scope
- Outfit recommendations
- Cross-sell recommendations
- Upsell recommendations
- Style bundles
- Occasion-based recommendations
- Contextual recommendations
- Personal recommendations

### Consuming surfaces in scope
- Ecommerce PDP
- Ecommerce cart
- Ecommerce homepage and personalization surfaces
- Style inspiration and look-builder experiences
- Email campaigns and lifecycle messages
- In-store clienteling interfaces
- Future API-first consumers such as mobile, partner, or other internal surfaces

### Recommendation sources expected across surfaces
- Curated looks approved or authored by merchandising teams
- Rule-based compatibility and eligibility logic
- AI-ranked ordering and personalization where the surface has sufficient context and permitted data

## Scope boundaries

### In scope
- Define the business requirements for a shared recommendation delivery model that serves ecommerce, email, clienteling, and future API consumers.
- Specify what must be common across surfaces, including recommendation identity, traceability, eligibility behavior, telemetry expectations, and merchandising controls.
- Define where surfaces can differ, such as rendering, layout, cadence, latency tolerance, and identity confidence.
- Establish rollout sequencing expectations so early ecommerce delivery builds reusable contracts for later channel expansion.
- Capture both customer-facing and internal-user needs for multi-surface activation.

### Out of scope
- Channel-specific UI designs, templates, or component specifications.
- Detailed API schema or implementation architecture.
- ESP, POS, or clienteling tool replacement.
- Final prioritization of every downstream consumer beyond the stated rollout guidance.
- Surface-specific experimentation plans or operational playbooks beyond the business requirement level.

## Surface-specific business needs

### 1. Ecommerce surfaces

Ecommerce is the first proving ground for the shared delivery model because it produces the earliest high-volume commercial signal. The platform must support:
- anchor-product complete-look recommendations on PDP;
- complementary recommendations in cart where attachment and basket-building matter;
- homepage or personalization surfaces once identity and context maturity improve;
- consistent recommendation set composition so a shopper does not see contradictory logic between PDP, cart, and broader web personalization surfaces;
- customer-safe explanations and presentation inputs that allow the ecommerce experience to describe recommendations without exposing sensitive reasoning.

### 2. Email surfaces

Email consumers need recommendation outputs that can be reused in lifecycle and campaign contexts without requiring a separate recommendation system. The platform must support:
- reusable recommendation sets that can be selected for triggered and campaign email use cases;
- freshness rules that account for send timing, assortment availability, and campaign relevance;
- surface-specific identity confidence handling because email recipients may have different levels of recent browsing or session context than live ecommerce experiences;
- campaign-aware merchandising controls so marketers can use recommendation outputs without bypassing brand governance.

### 3. Clienteling surfaces

Clienteling consumers need recommendations that support assisted selling rather than only self-service browsing. The platform must support:
- recommendation sets that stylists can trust during appointments, outreach, and follow-up workflows;
- stronger visibility into why a recommendation set was produced so stylists can adapt the conversation responsibly;
- compatibility with both immediate RTW purchase journeys and longer CM or appointment-led journeys;
- recommendation outputs that remain governed by the same exclusions, brand standards, and campaign priorities used in ecommerce and email.

### 4. Future API consumers

Future consumers must be able to adopt recommendation outputs without redefining core business logic. The platform must support:
- API-first consumption of recommendation sets, recommendation metadata, and traceability fields;
- stable shared expectations for identifiers, recommendation types, and eligibility status;
- channel adaptation on top of a common decisioning contract rather than per-consumer recomputation of styling logic;
- progressive expansion to new consumers only after the shared delivery contract is proven on earlier surfaces.

## Shared delivery expectations

The multi-surface delivery model must preserve the following across all current and future consumers:

1. **Shared recommendation contract:** Every surface must consume a common recommendation concept with stable identifiers for recommendation sets, products, looks, rules, campaigns, and experiments.
2. **Reusable decisioning:** Curated, rule-based, and AI-ranked recommendation logic should be produced once and reused across channels wherever the use case permits.
3. **Surface-aware adaptation:** Surfaces may differ in presentation, invocation timing, and ranking emphasis, but they should not redefine core compatibility or eligibility behavior.
4. **Governance consistency:** Merchandising overrides, exclusions, campaign priorities, and approval rules must apply consistently across ecommerce, email, clienteling, and future consumers.
5. **Telemetry consistency:** Every consuming surface must support measurement of recommendation impression, click or engagement, add-to-cart or equivalent intent, purchase or downstream outcome, dismiss or ignore where relevant, and override context for internal users.
6. **Traceability:** Internal teams must be able to understand which look, rules, ranking inputs, campaign context, and experiment context influenced a recommendation set across all surfaces.
7. **Privacy and consent handling:** Shared delivery must respect regional data permissions and identity confidence differences so each surface only uses permitted customer signals.
8. **Freshness and availability expectations:** Recommendations must remain operationally relevant for the surface cadence, including inventory, assortment, and campaign timing constraints.
9. **Fallback behavior:** When a surface lacks sufficient identity or context, it must still receive governed recommendation outputs rather than breaking or inventing ad hoc logic.

## Rollout sequence

The rollout should follow a phased path that matches the roadmap and the issue note that shared delivery contracts start early while deeper activation expands in Phase 3.

### Phase 1: shared contract foundation plus initial ecommerce validation
- Define the shared recommendation delivery contract early.
- Launch the first delivery loop on high-signal ecommerce surfaces, especially PDP and cart.
- Prove that curated looks, compatibility rules, telemetry, and governance can support reusable outputs.

### Phase 2: broader ecommerce personalization and context enrichment
- Extend the same delivery contract to homepage and other web personalization surfaces.
- Increase personalization, identity resolution, and context usage without breaking cross-surface consistency.
- Use these learnings to harden freshness, traceability, and segmentation expectations before broader activation.

### Phase 3: multi-channel activation for email and clienteling
- Reuse the existing recommendation decisioning foundation for email and clienteling consumers.
- Introduce channel-specific operating patterns, such as campaign timing or stylist-assisted interpretation, while preserving shared governance.
- Confirm that non-ecommerce consumers can use recommendation outputs without engineering-defined channel exceptions becoming the norm.

### Later expansion: future API consumers
- Extend the proven delivery contract to new consumers such as mobile, partner, or other internal applications.
- Only broaden adoption once the contract, telemetry, and governance model are stable enough to support additional surfaces without fragmentation.

## RTW / CM considerations

- **RTW:** Multi-surface delivery should support faster, transaction-oriented journeys where PDP, cart, homepage, and email can act on more immediate inventory and purchase intent.
- **CM:** Clienteling and some follow-up communications may require longer-lived recommendation context, configuration-sensitive compatibility, and stylist interpretation. CM needs should be represented in the shared contract, even if deeper CM activation arrives after the earliest RTW ecommerce rollout.
- The requirement is not to force RTW and CM into identical delivery behavior. The requirement is to ensure both can use the same governed delivery foundation while honoring their different decision horizons and compatibility needs.

## Success metrics

### Business outcomes
- Increased recommendation-influenced conversion on ecommerce launch surfaces.
- Increased attachment rate and average order value where complete-look or complementary recommendations are present.
- Measurable lift in email engagement or downstream commerce outcomes for recommendation-enabled campaigns.
- Improved stylist or clienteling effectiveness, measured through recommendation-assisted outreach or assisted-selling outcomes where feasible.

### Product outcomes
- Reusable recommendation outputs available across ecommerce, email, clienteling, and future API consumers without separate business-rule definitions per surface.
- Consistent recommendation type support and traceability across all adopted surfaces.
- Surface onboarding effort reduced because new consumers adopt the shared delivery contract instead of defining net-new recommendation behavior.

### Operational outcomes
- Stable telemetry coverage across all active surfaces.
- Visible governance adoption, including shared overrides and campaign controls across channels.
- Fewer channel-specific exceptions to compatibility, eligibility, and campaign behavior over time.

## Constraints and assumptions

### Constraints
- Privacy, consent, and regional policy requirements may limit which customer signals are used on each surface.
- Surface latency, cadence, and identity confidence differ, so the shared delivery model must allow controlled adaptation without contract fragmentation.
- Inventory and campaign timing must remain relevant for slower-moving channels such as email.
- Internal users need enough traceability to trust outputs, but customer-facing surfaces should not expose sensitive reasoning.

### Assumptions
- Ecommerce surfaces will continue to be the earliest validation path for recommendation value.
- Email and clienteling adoption should reuse the same recommendation foundation rather than sponsor separate channel-specific recommendation engines.
- Future API consumers will require stable identifiers and traceability from the start, even if they launch later.

## Open decisions

- **Missing decision:** Which non-PDP ecommerce surfaces are mandatory for the first shared-contract release: cart only, or cart plus homepage/personalization?
- **Missing decision:** What freshness windows are acceptable for email recommendations versus live ecommerce responses?
- **Missing decision:** Which clienteling workflows are in the first activation scope: live appointments, follow-up outreach, or both?
- **Missing decision:** Which future API consumers should be treated as the first post-Phase-3 adopter: mobile, partner, or internal tooling?
- **Missing decision:** What minimum traceability detail must be exposed to stylists and marketers versus kept internal-only?

## Approval / milestone-gate notes

- Approval mode is not explicitly recorded elsewhere for this BR item, so the board entry should record `autonomous` for this milestone and note that this artifact was produced by issue-created automation.
- This run should not block on human approval before commit, push, or PR creation.
- Any later human or stage-gate review should focus on whether the rollout sequence and shared delivery expectations are sufficient for feature breakdown and downstream planning.

## Recommended board update

Add or update the `BR-003` row in `boards/business-requirements.md` for issue #52 with:
- status `In Progress` while drafting;
- status `In PR` after push;
- approval mode `autonomous`;
- notes that the artifact captures ecommerce, email, clienteling, and future API consumer needs, with shared delivery contracts beginning early and deeper activation expanding in Phase 3.
