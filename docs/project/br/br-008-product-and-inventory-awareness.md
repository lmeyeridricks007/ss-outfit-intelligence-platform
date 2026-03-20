# BR-008: Product and inventory awareness

## Metadata

| Field | Value |
|---|---|
| BR ID | BR-008 |
| Title | Product and inventory awareness |
| Stage | workflow:br |
| Trigger | Issue-created automation for GitHub issue #57 |
| Source artifacts | `docs/project/business-requirements.md` (BR-8), `docs/project/product-overview.md`, `docs/project/roadmap.md`, `docs/project/standards.md` |
| Output | `docs/project/br/br-008-product-and-inventory-awareness.md` |
| Parent item | None |
| Downstream stage | Feature breakdown for purchasable recommendation flows |

## 1. Problem statement

The platform must recommend outfits that customers can realistically purchase, not just products that are stylistically similar. Today BR-8 exists only as a high-level statement, which is not specific enough for downstream feature work to decide which product inputs, inventory constraints, assortment rules, and freshness expectations are required for operationally valid recommendations.

For ecommerce customers, stylists, and merchandisers, a recommendation loses value when it includes an unavailable size, a product that is not sellable in the active country or channel, or a combination that is technically available but outside the relevant assortment. This requirement defines the business inputs and boundaries needed so complete-look, cross-sell, and upsell recommendations remain coherent, relevant, and purchasable.

## 2. Target users and consuming surfaces

### Primary users
- Ecommerce customers on PDP and cart surfaces who expect outfit recommendations they can add to cart immediately.
- Returning customers whose recommendations must reflect both style relevance and current product availability.
- Merchandisers who need recommendation logic to respect assortment strategy, exclusions, and channel priorities.

### Secondary users
- In-store stylists and clienteling teams when inventory-aware recommendations are extended to store-assisted journeys.
- Product, analytics, and optimization teams responsible for recommendation quality and business performance.

### Recommendation types in scope
- Outfit recommendations
- Cross-sell recommendations
- Upsell recommendations
- Contextual recommendations where assortment or availability changes by country, season, or channel

### Surface and channel emphasis
- Phase 1 emphasis: ecommerce PDP and cart for RTW anchor-product journeys
- Later expansion: homepage, email, style inspiration, and clienteling surfaces after foundational purchasability is reliable

## 3. Business value

This requirement supports the following business outcomes:
- Preserve customer trust by reducing recommendation impressions that cannot convert into a purchasable outfit.
- Improve conversion, add-to-cart rate, and attachment by prioritizing available complementary items.
- Protect brand integrity by ensuring recommended outfits remain stylistically coherent and operationally valid.
- Reduce manual merchandising intervention caused by stock, assortment, or eligibility mismatches.
- Provide a dependable foundation for later personalization and multi-channel rollout in the roadmap.

## 4. Scope boundaries

### In scope
- Defining the product, assortment, and inventory inputs required to judge recommendation eligibility.
- Defining operational boundaries for when an item, size, or outfit can be surfaced as purchasable.
- Defining freshness expectations for catalog, assortment, and inventory inputs by business criticality.
- Defining success measures for purchasable recommendation quality on initial digital surfaces.
- Covering RTW-first recommendation flows, with explicit notes for later CM extension.

### Out of scope
- Inventory planning, demand forecasting, replenishment, or allocation optimization.
- Replacing upstream commerce, OMS, POS, or inventory systems of record.
- Detailed technical design for ingestion pipelines, APIs, storage, or ranking implementation.
- Full CM configuration logic beyond the business requirements needed to flag later dependencies.
- Channel-specific UX design for how inventory messages appear on each surface.

## 5. Required business inputs

### 5.1 Product and catalog inputs

The recommendation platform must ingest or receive the following product inputs so it can build complete outfits that are both coherent and sellable:

| Input area | Required business inputs | Why the requirement exists |
|---|---|---|
| Canonical product identity | Stable product, variant, and SKU identifiers with source-system mapping | Recommendations and telemetry must reference the same purchasable item across systems. |
| Product hierarchy | Category, subcategory, collection, and anchor-product role | Outfit logic depends on knowing what can anchor a look and what can complete it. |
| Style attributes | Color, pattern, fabric, material, fit, silhouette, formality, occasion, season, and style tags | Complete-look recommendations must remain stylistically coherent. |
| Commercial attributes | Price tier, premium level, lifecycle status, launch or exit status | Upsell and assortment decisions must reflect current commercial reality. |
| Variant structure | Size, length, fit variant, colorway, and other purchasable dimensions | Recommendations must point to variants customers can actually buy, not only parent products. |
| Merchandising eligibility | Inclusion or exclusion flags, campaign participation, brand-safety restrictions, substitution eligibility | Merchandising teams must be able to govern what is eligible for recommendation. |
| Channel and region eligibility | Country, channel, and market-specific sellability and assortment flags | A product can be valid in one market or channel and invalid in another. |
| Visual and descriptive assets | Imagery, naming, and customer-facing descriptors | Customers need enough context to trust and act on the recommended outfit. |

### 5.2 Inventory and assortment inputs

The recommendation platform must apply inventory-aware and assortment-aware constraints before outputting recommendations:

| Input area | Required business inputs | Why the requirement exists |
|---|---|---|
| Sellable availability | Whether the product or variant is currently sellable for the active surface, channel, and country | A recommended item must be buyable in the current journey. |
| Size availability | Size-level or variant-level availability where the surface expects direct add-to-cart behavior | A parent product is not sufficient if the relevant size is unavailable. |
| Assortment relevance | Country, region, store, or channel assortment membership | Recommendations must not surface products outside the active assortment. |
| Inventory state qualifiers | In stock, low stock, backorder, preorder, reserved, or unavailable states when those states affect customer purchaseability | Ranking and fallback behavior must distinguish between truly sellable and effectively unavailable items. |
| Reservation or hold effects | Exclusions caused by pending allocation, reservation, or other temporary non-sellable states when exposed by upstream systems | Recommendation quality should not degrade because nominal stock is not actually available to sell. |
| Fulfillment constraints | Surface-relevant fulfillment restrictions when they materially affect purchaseability | Operationally invalid items should not be promoted as easy additions to an outfit. |
| Store availability inputs | Store or appointment-level availability only when the consuming channel needs it and the upstream data is trusted | Clienteling and store-assisted flows may need a different definition of purchasable than ecommerce. |

### 5.3 Ranking and assembly implications

Product and inventory awareness must affect both recommendation eligibility and ranking:
- Hard constraints must remove non-sellable or out-of-assortment candidates before final ranking.
- Low-confidence availability states should reduce rank or trigger fallback rules instead of being treated as normal inventory.
- A recommendation set should prefer outfit completeness with purchasable components over a theoretically stronger style match that cannot be bought.
- Upsell logic must not promote a premium alternative if it is outside the active assortment or materially unavailable.
- Recommendation assembly should preserve at least one viable path to a purchasable outfit even when some ideal components are excluded.

## 6. Operational boundaries for purchasable recommendations

The platform must operate within the following business boundaries:

1. **Purchaseability beats optional relevance signals.** If a product is not sellable for the active surface, it must not appear as a customer-actionable recommendation.
2. **Eligibility is surface-specific.** PDP and cart recommendations require stricter availability handling than inspiration-only surfaces because they sit closer to add-to-cart behavior.
3. **Assortment is a hard boundary.** The platform must not recommend products that are outside the active country, channel, or store assortment even if they are stylistically compatible.
4. **Variant awareness is required where direct purchase is expected.** For surfaces that support direct add-to-cart or rapid product selection, parent-level availability is insufficient.
5. **Fallback is better than false confidence.** When required inventory or assortment inputs are stale, missing, or contradictory, the platform should fall back to safer recommendation behavior rather than present a likely unpurchasable outfit.
6. **Recommendation quality is judged at the outfit level.** A set is not operationally valid if one or more required outfit components repeatedly fail purchaseability checks.
7. **Inventory awareness is not fulfillment optimization.** The platform may use inventory status to filter or rank recommendations, but it does not own allocation, sourcing, or promise-date decisions.
8. **Governance remains explicit.** Merchandising rules, exclusions, and campaign priorities can further restrict recommendation eligibility even when inventory is available.

## 7. RTW and CM considerations

### RTW
- RTW is the Phase 1 focus and must support immediate ecommerce purchaseability on PDP and cart.
- RTW recommendation logic must rely on variant-aware availability and active assortment constraints.

### CM
- CM remains part of the long-term product requirement, but full configuration-aware purchaseability is not part of the first-release boundary for this BR.
- CM flows will need later extension for fabric, configuration, appointment, and premium-option compatibility before availability can be judged reliably.
- Until CM-specific availability logic is defined, this BR should be interpreted as establishing the shared product-and-assortment foundation that CM features will inherit.

## 8. Freshness expectations

Freshness expectations must be explicit because recommendation quality depends on both styling data and operational data. The platform should use business-critical freshness tiers rather than treat every upstream input the same.

| Freshness tier | Inputs covered | Business expectation | Consequence if stale |
|---|---|---|---|
| Tier 1 - Near-real-time or equivalent operational freshness | Sellable availability, size-level availability, reservation-sensitive states, channel eligibility exceptions | Inputs that determine whether a customer can buy now must be refreshed at the highest cadence used by the active surface, especially PDP and cart. | Stale data risks surfacing unpurchasable recommendations and directly harms conversion and trust. |
| Tier 2 - Intra-day freshness | Assortment membership, regional eligibility, pricing state when it affects recommendation validity, campaign-level eligibility changes | These inputs must update within the same trading day and on material changes that affect recommendation safety or relevance. | Stale data causes out-of-market, out-of-campaign, or commercially misaligned recommendations. |
| Tier 3 - Daily or publish-driven freshness | Longer-lived product attributes, imagery, copy, style tags, hierarchy, and other catalog metadata | These inputs must stay synchronized with catalog publishing so outfit logic reflects the current assortment and product story. | Stale data weakens outfit coherence and explainability even when items remain sellable. |

Additional freshness rules:
- Higher-risk surfaces should use stricter freshness enforcement than slower-moving or inspiration-led surfaces.
- If freshness falls below the minimum safe threshold for purchaseability inputs, the platform should degrade gracefully by reducing candidate eligibility or omitting the affected recommendation block.
- Recommendation telemetry must preserve enough trace context to diagnose whether poor outcomes were caused by stale catalog data, stale inventory data, or business-rule exclusions.

## 9. Success measures

Success for this requirement is measured by whether recommendations remain both coherent and purchasable:

| Measure | Why it matters |
|---|---|
| Purchasable recommendation rate | Percentage of recommendation impressions whose surfaced items remain sellable for the active surface when customers interact with them. |
| Out-of-stock exposure rate | Measures how often recommendations present items that cannot actually be purchased. |
| Assortment compliance rate | Confirms recommendations stay within the intended country, channel, and store assortment boundaries. |
| Complete-outfit purchasability rate | Measures how often a recommended outfit contains enough purchasable components to support the intended look. |
| Recommendation add-to-cart rate | Indicates whether inventory-aware recommendations improve actionability, not just clicks. |
| Attachment rate for recommendation-influenced orders | Validates that purchasable complementary products increase basket building. |
| Manual override or suppression rate due to bad availability | Highlights operational pain caused by poor product or inventory awareness. |
| Freshness compliance by input tier | Confirms the platform meets the expected cadence for business-critical catalog and inventory inputs. |

Numeric targets are a downstream decision and should be set once baseline instrumentation exists for the first rollout surfaces.

## 10. Open decisions

- Missing decision: Which upstream system is the first trusted system of record for ecommerce inventory, store inventory, and assortment eligibility?
- Missing decision: Which surfaces beyond PDP and cart are in the first release scope for strict purchaseability handling?
- Missing decision: Should backorder and preorder states count as purchasable for all surfaces, or only for selected channels and markets?
- Missing decision: What minimum safe freshness threshold should trigger fallback behavior on each surface?
- Missing decision: How should substitutions work when the ideal complementary item is unavailable but a close alternative exists?
- Missing decision: When clienteling is introduced, should store-level inventory be treated as required or optional evidence for recommendation eligibility?
- Missing decision: What CM-specific availability inputs are required before CM recommendations can be treated as purchasable instead of inspirational?

## 11. Approval and downstream notes

- Approval mode for this autonomous issue run is handled without waiting for a human "Mark as ready" step.
- This BR is ready to fan out into feature work focused on catalog eligibility, inventory freshness, assortment enforcement, and purchaseability-aware fallback behavior.
- Downstream work should preserve the distinction between curated, rule-based, and AI-ranked recommendation sources while applying the same purchaseability boundaries to all of them.
