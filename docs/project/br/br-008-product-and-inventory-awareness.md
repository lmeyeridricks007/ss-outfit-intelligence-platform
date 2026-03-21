# BR-008: Product and inventory awareness

## Metadata

- **Board Item ID:** BR-008
- **Issue:** #82
- **Stage:** workflow:br
- **Parent Item:** none
- **Trigger:** issue-created automation
- **Phase:** Phase 1
- **Approval Mode:** Not recorded in source docs
- **Primary Output:** `docs/project/br/br-008-product-and-inventory-awareness.md`
- **Upstream Sources:**
  - `docs/project/business-requirements.md`
  - `docs/project/architecture-overview.md`
  - `docs/project/standards.md`
  - `docs/project/roadmap.md`
  - `docs/project/data-standards.md`
  - `docs/project/product-overview.md`
- **Downstream Consumers:** feature breakdown, architecture, and implementation artifacts for catalog normalization, delivery API, recommendation engine, merchandising rules, and channel integrations

## Requirement summary

The platform must use product and inventory data as first-class recommendation inputs so every output remains:

- stylistically coherent
- currently assortable and purchasable
- appropriate for the target surface and journey
- safe for merchandising and operational teams to activate

This requirement applies to complete-look outfit recommendations, cross-sell, upsell, style bundle, occasion-based, contextual, and personal recommendations across ecommerce, email, and clienteling surfaces.

## Business problem

Recommendation quality fails when the engine ranks items that look relevant but cannot actually be sold, fulfilled, or trusted in context. For SuitSupply, that risk is amplified because recommendation outputs must preserve styling integrity across multiple categories and distinguish RTW from CM workflows.

Without product and inventory awareness, the platform may:

- recommend products that are unavailable in the shopper's assortment or region
- assemble outfits that are visually inconsistent because key styling attributes are missing or unreliable
- suggest RTW items or CM options without enough compatibility detail to complete the look credibly
- return products whose imagery or metadata is too incomplete for the consuming surface
- create operational churn for merchandising and clienteling teams who must override invalid outputs

## Business outcome

The platform should make recommendation outputs operationally trustworthy by ensuring:

1. recommended products can be shown with enough descriptive and visual quality for the surface
2. recommended products are eligible for the shopper's assortment, market, and recommendation context
3. inventory-aware constraints prevent clearly non-purchasable results from reaching the final set
4. RTW and CM recommendation logic use the correct product data for their different decision states
5. ranking optimization never bypasses hard compatibility, eligibility, or safety constraints

## Scope

### In scope

- Canonical product identity and source mappings used by recommendation logic
- Product attributes needed for compatibility, retrieval, filtering, ranking, and response shaping
- Assortment and market eligibility needed to determine whether an item can be recommended
- RTW and CM product fields needed to keep look composition coherent
- Inventory and availability constraints needed to keep outputs purchasable
- Imagery and visual asset expectations needed for customer-facing and internal surfaces
- Freshness and provenance expectations for recommendation-critical product and inventory data
- Hard versus soft decisioning rules for recommendation assembly

### Out of scope

- Inventory planning, allocation optimization, or demand forecasting
- Detailed source-system implementation design
- Final API schema design for every surface
- Channel UI behavior beyond the product and inventory data expectations those surfaces require
- Full merchandising authoring workflow design

## Primary users and consumers

### Customer-facing users

- online shoppers browsing anchor products on PDP
- customers adding products to cart and considering complementary items
- customers exploring occasion-led or inspiration-led outfit recommendations
- returning customers receiving contextual or personal recommendation sets

### Internal users

- merchandisers who need confidence that recommendation outputs reflect current assortment constraints
- clienteling and store teams who need recommendation outputs that are operationally realistic
- analytics and product teams who need traceable data inputs when diagnosing recommendation quality

### Consuming surfaces

- PDP
- cart
- homepage and web personalization surfaces
- style inspiration pages
- email and CRM payloads
- in-store clienteling interfaces

## Requirement details

### 1. Canonical product identity is mandatory

Recommendation logic must not rely on channel-local or source-local product identifiers alone.

The platform must maintain:

- a stable canonical product ID
- source-system identifier mappings for each upstream product source
- product-level provenance so downstream teams can diagnose which source supplied recommendation-critical fields
- recommendation traceability back to product IDs included in the final set

This is required to keep retrieval, filtering, ranking, telemetry, and analytics aligned across channels.

### 2. Product attributes must support recommendation coherence

The normalized product model must carry enough information to decide whether products belong in the same look and whether they should be displayed on a given surface.

#### Recommendation-critical descriptive attributes

At minimum, recommendation-ready product data must support:

- category and subcategory
- fabric
- color and color family
- pattern
- fit and silhouette
- season
- occasion
- style tags
- price tier
- brand or collection constraints where relevant
- RTW and CM classification

These attributes are required because the platform generates complete-look and compatibility-driven recommendations, not simple item similarity.

#### Recommendation-critical merchandising attributes

The platform must also support fields that determine whether a product may be recommended at all, including:

- assortment eligibility
- region or market eligibility
- channel or surface eligibility where product activation differs by consumer
- lifecycle state such as active, suppressed, discontinued, or future
- override or governance flags that affect recommendation eligibility

### 3. Assortment eligibility is a hard constraint

A product must not appear in the final recommendation set when it is not eligible for the shopper's relevant assortment context.

Assortment-aware filtering must consider, where applicable:

- market or country
- region or store context
- selling channel
- campaign or collection restrictions
- launch timing or product activation state
- any explicit merchandising suppression

Eligibility is a hard gate, not a ranking preference.

### 4. Inventory awareness is required for operational validity

Inventory data must influence final recommendation assembly so outputs stay purchasable and credible.

The platform must support inventory-aware constraints such as:

- in stock versus out of stock state
- low inventory or limited availability status
- preorder or future-availability state where allowed
- sellable versus unsellable inventory distinctions
- fulfillment or operational restrictions that make a product non-viable for recommendation

Inventory handling must distinguish:

- **hard exclusions:** clearly unavailable or unsellable items that should not be shown
- **soft ranking signals:** lower-confidence or low-stock items that may still appear if policy allows and the surface can tolerate them

### 5. RTW and CM fields must remain distinct

RTW and CM recommendation workflows share some product foundations, but they do not use the same data in the same way.

#### RTW requirements

RTW recommendation logic must support immediate sellable-product decisions, including:

- size-independent product compatibility signals
- current availability and assortment state
- styling fields that help assemble coherent outfits around anchor products
- imagery suitable for customer-facing surfaces

#### CM requirements

CM recommendation logic must additionally support configuration-aware decisions, including:

- fabric and palette relationships
- style detail compatibility
- premium option and upsell context
- fields that reflect whether a CM suggestion remains credible given current garment choices

CM recommendation outputs must not flatten configuration-specific logic into generic product similarity.

### 6. Imagery inputs are required for recommendation delivery quality

Recommendation outputs need imagery inputs that are good enough for the target surface, not only textual metadata.

The platform must support:

- primary image references for each recommendable product
- image variants or crops appropriate for relevant surfaces where available
- enough visual consistency to support outfit assembly and customer trust
- fallback handling when imagery is missing, incomplete, or unsuitable

Customer-facing surfaces should suppress or deprioritize items that lack minimum viable imagery for that surface. Internal tools may expose lower-quality items for operational awareness if clearly labeled.

### 7. Product and inventory data must support multiple decision stages

The same data is not used identically at every stage of recommendation generation.

#### Candidate generation

Product attributes should help retrieve compatible candidates, related categories, and viable substitutes.

#### Eligibility filtering

Assortment, lifecycle, governance, and hard inventory constraints must remove invalid candidates before final ranking.

#### Ranking

Ranking may use attribute similarity, style coherence, price laddering, inventory confidence, and context relevance, but only after hard constraints are applied.

#### Response shaping

Final payload assembly must confirm the product has enough title, imagery, and descriptive context for the destination surface.

### 8. Surface requirements differ and must be explicit

Different surfaces tolerate different levels of product and inventory uncertainty.

#### PDP and cart

These surfaces require the highest operational confidence because they are closest to purchase intent. Recommendation sets should strongly prefer immediately purchasable, fully assortable products with dependable imagery and current inventory state.

#### Homepage and inspiration surfaces

These surfaces may tolerate broader exploratory coverage, but they still must respect hard assortment and suppression rules.

#### Email and CRM payloads

These surfaces require stronger sensitivity to freshness lag because content may be rendered or opened after payload generation. Downstream work must define whether inventory is checked at payload generation time, open time, or both.

#### Clienteling

Internal surfaces may expose richer operational context, such as confidence, availability caveats, or alternative suggestions, but must still avoid clearly invalid recommendations.

### 9. Data freshness and provenance must be visible

Product and inventory awareness only works if downstream teams can tell how current the underlying data is.

The platform must preserve:

- freshness metadata for recommendation-critical product and inventory records
- source provenance for product, inventory, and imagery inputs
- enough trace context to diagnose invalid recommendations caused by stale or conflicting data

Freshness expectations will differ by surface, but the platform must not treat freshness as implicit.

### 10. Fallback behavior is required

The platform must degrade gracefully when product, inventory, or imagery data is incomplete.

Fallback behavior should include:

- substitute with another eligible product in the same compatibility slot
- reduce recommendation set size rather than show clearly invalid items
- fall back from a richer recommendation type to a simpler but valid one
- expose operational trace context so teams can identify why the set degraded

The system should prefer a smaller valid recommendation set over a larger incoherent or non-purchasable one.

## Data expectation matrix

| Data domain | Why it matters | Minimum expectation | Hard gate or ranking signal |
| --- | --- | --- | --- |
| Canonical product ID and source mappings | Stable cross-system recommendation logic and telemetry | Present for every recommendable product | Hard gate |
| Category, fabric, color, pattern, fit, season, occasion, style tags | Look coherence and compatibility | Present and normalized for recommendation-critical categories | Primarily ranking and compatibility, may become hard gate where required |
| Assortment eligibility | Prevent non-sellable market/channel outputs | Present by market, channel, or applicable selling context | Hard gate |
| Lifecycle and suppression state | Avoid discontinued or governed-off products | Present and current | Hard gate |
| RTW and CM classification and fields | Use correct recommendation logic for each mode | Present for affected products | Hard gate |
| Inventory availability status | Keep outputs purchasable | Present with freshness metadata | Hard gate for clearly unavailable items; ranking signal for softer scarcity states |
| Imagery references | Support customer trust and surface rendering | Present for customer-facing recommendation candidates | Hard gate for surfaces that require imagery |
| Freshness and provenance | Diagnose stale or conflicting outputs | Present for recommendation-critical entities | Operational hard requirement |

## Business rules

1. Hard compatibility, assortment, governance, and availability constraints take precedence over ranking optimization.
2. Recommendation sets must not rely on manual cleanup as the normal operating model.
3. Customer-facing recommendations must prefer products with enough imagery and descriptive completeness to support confident purchase decisions.
4. When data is incomplete, the system should narrow or simplify outputs before it shows invalid items.
5. RTW and CM logic may share common infrastructure, but downstream design must preserve their domain differences.

## Phase guidance

### Phase 1 expectation

Phase 1 should prioritize:

- RTW anchor-product flows on PDP and cart
- high-confidence product attribute normalization
- explicit assortment and inventory eligibility handling
- enough imagery quality to support initial customer-facing surfaces
- traceability that allows teams to debug invalid recommendations quickly

### Later-phase extension

Later phases should expand:

- broader context- and personalization-aware ranking on top of the same product and inventory foundation
- stronger clienteling and email handling for freshness-sensitive outputs
- deeper CM configuration-aware recommendation logic
- improved substitution and graceful degradation strategies

## Success measures

This business requirement is satisfied when downstream work can support:

- recommendation sets that remain stylistically coherent across outfit components
- recommendation sets that avoid clearly unavailable, suppressed, or non-assortable products
- high coverage of recommendation-ready products with required attributes and imagery
- visible traceability for which product and inventory inputs shaped a recommendation set
- lower operational override burden caused by invalid product or availability suggestions

## Dependencies

- reliable upstream catalog and inventory feeds
- explicit canonical product identity mapping
- governance over recommendation-critical product attributes
- defined source-of-truth ownership for assortment and availability fields
- surface-specific decisions on acceptable freshness lag, especially for email and CRM

## Assumptions

- Recommendation quality depends on normalized product and inventory data more than on ranking sophistication alone in Phase 1.
- Product availability and assortment constraints materially affect recommendation trust and conversion.
- Some freshness profiles will be mixed, but the platform can still operate if freshness is visible and downstream surfaces define acceptable tolerance.
- Merchandising and operational teams need to understand why a product was included, excluded, or substituted.

## Missing decisions and open questions

- Which systems are the initial source of truth for assortment eligibility, inventory state, and imagery references?
- What freshness SLA is required by surface for PDP, cart, homepage, email, and clienteling?
- Which inventory states are hard exclusions versus soft ranking signals in each market?
- How should email and CRM payloads handle inventory drift between generation and open time?
- What minimum imagery quality threshold is required for each customer-facing surface?
- Which CM fields are mandatory in the first recommendation-capable release versus later sophistication?

## Exit criteria mapping

This BR is complete when downstream teams can use it to define product and inventory data contracts that keep recommendation outputs:

- coherent as outfits rather than disconnected products
- purchasable within the relevant assortment and availability context
- operationally valid for merchandising, ecommerce, and clienteling use
- traceable enough to diagnose stale, missing, or conflicting data inputs
