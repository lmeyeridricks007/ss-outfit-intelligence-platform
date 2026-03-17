# Industry Standards & Best Practices: Recommendation & Personalization

**Document purpose:** Capture industry norms and provider approaches for recommendation engines, personalization, and outfit-level intelligence so the AI Outfit Intelligence Platform aligns with established practice while supporting SuitSupply’s outfit-first differentiation.

**Terminology (project convention):** In this project, **look** denotes the product grouping (e.g. a curated set of SKUs); **outfit** denotes the customer-facing complete-look concept. See `docs/.cursor/rules/recommendation-domain-language.mdc`.

**References:** Provider documentation (e.g. Dynamic Yield), event/API best practices (e.g. Amazon Personalize, Algolia), and fashion/apparel recommendation research. Project-specific standards remain in `api-standards.md`, `data-standards.md`, and the recommendation-domain-language rule.

**Status:** Living document; update when adopting new provider references or when project standards change.

---

## 1. Industry Standards Overview

### 1.1 What the industry optimizes for

- **Relevance:** Recommendations match user intent, context, and (where available) history.
- **Merchandising control:** Brands can pin, exclude, and constrain algorithm output without replacing the engine.
- **Measurability:** Impressions, clicks, add-to-cart, and purchase are tracked with clear attribution to recommendation and placement.
- **Channel coverage:** Same logic and data can power web, app, email, and in-store/assisted selling where feasible.
- **Testing:** A/B tests and multi-armed bandits allow comparison of strategies, layouts, and rules.

### 1.2 Common recommendation patterns

| Pattern | Description | Typical use |
|--------|-------------|-------------|
| **Similar items** | Items close in attributes or embedding space | “More like this” |
| **Frequently bought together** | Co-purchase / co-occurrence | Cross-sell, basket building |
| **Viewed together** | Same-session co-views | Discovery, cross-sell |
| **Complete the look (CTL)** | Complementary items to form an outfit/set | PDP, cart, post-purchase |
| **Personalized / collaborative filtering** | User–item affinity from behavior | “For you” |
| **Popular / trending** | Weighted engagement (views, cart, purchase) | Cold start, category pages |
| **Next-best action** | Sequence or deep-learning next-purchase prediction | Homepage, email, retargeting |
| **Upsell** | Higher-value or premium alternatives to the viewed/purchased item | PDP, cart, post-purchase |
| **Style bundles** | Curated or AI-generated outfit/theme bundles (e.g. “Wedding guest”, “Summer linen”) | Homepage, landing, email |

### 1.3 Complete-the-look as a standard

**Complete the Look (CTL)** is an established pattern in ecommerce and fashion:

- **Anchor item:** The product being viewed or in cart.
- **Complementary set:** Items from defined categories (e.g. shirt, tie, shoes for a suit) chosen for style, color, occasion, and compatibility.
- **Signals used:** Bought-also-bought, viewed-also-viewed, top sellers in category, similarity (attribute or visual), and explicit compatibility rules.
- **Placement:** Typically PDP, cart, and post-purchase. Leading implementations use ML across attributes (color, pattern, material, occasion) and sometimes visual embeddings.

Outfit intelligence extends CTL by treating the **full look** as the unit of recommendation (outfit-level) and by combining rules, curation, and AI rather than only item-to-item similarity.

---

## 2. Provider Approaches: Dynamic Yield

Dynamic Yield is a widely used personalization and recommendation platform. The following summarizes how they approach recommendations, merchandising, and delivery—useful as a reference for our platform’s design and terminology.

### 2.1 Core philosophy

- **Full merchandising control** over content and product recommendations: adapt layout by context, combine multiple strategies in one widget, and test layout, design, strategy, location, and headers.
- **Machine learning** to personalize the experience from observed data (behavioral and catalog).
- **Self-training deep learning** option: predict next product from co-occurrence and sequence of historical and real-time interactions.

### 2.2 Recommendation strategies (representative list)

- **Automatic:** Strategy chosen by page type and best practices.
- **Affinity-based:** Most relevant products by all tracked engagements (up to ~2 years + current session).
- **Purchased together:** Online and/or offline with viewed product or cart.
- **Viewed together:** Same-session co-views.
- **Recently viewed / recently purchased:** Recency-ordered lists.
- **Most popular:** Weighted interactions (purchase, add-to-cart, view), recency-weighted.
- **Most popular in category:** Popularity scoped to category context.
- **Similar items:** Similarity to current item + popularity.
- **Personalized (collaborative filtering):** Cross-user behavior similarity.
- **Deep learning:** Next-product prediction from interaction sequences.
- **Fallback strategies:** When primary strategy returns fewer items than slots.

They support **mixed strategies** (e.g. different algorithm per slot) and **shuffle** for diversity.

### 2.3 Merchandising rules and control

- **Pin:** Force specific products in specific slots (placement over relevance).
- **Whitelist (include):** Only a subset of products may appear in a widget or slot.
- **Blacklist (exclude):** Products that must not be recommended in a widget or slot.
- **Dynamic lists:** Pin/whitelist/blacklist by product attribute conditions (e.g. price, category).
- **Real-time filters:** Filter results using session data (e.g. price band, visitor selection).
- **Custom filtering rules:** Arbitrary rules to restrict results.
- **Prioritization:** Conflict resolution when rules contradict.
- **Targeting:** Rules can be scoped to users, pages, and context.
- **Scheduling:** Rules can be time-bound.

This aligns with our need for merchandising override, approval, and audit (see `docs/project/business-requirements.md` BR-6, BR-12).

### 2.4 Targeting and context

- **Time-based:** When experiences are live.
- **Affinity-based:** High interest in a product property (e.g. color, category).
- **New user / first session:** First-time visitors.
- **Session behavior:** Page views, URL, time on site, etc.
- **Audience-based:** Segments from the same or another site.
- **Traffic source:** Referrer/channel.
- **Technology:** Device, browser, OS, resolution.
- **Location:** Geographic.
- **Weather:** Current or forecast at user location.
- **Product engagement / social proof:** Views and purchases on the product.
- **Custom evaluators:** Custom logic for when to show an experience.

Supports **context-aware** and **placement-aware** recommendations (weather, season, location) as in our vision.

### 2.5 Testing and optimization

- **A/B tests:** Different algorithms, layouts, rules, headers, placement.
- **Multi-armed bandit:** Automated traffic allocation toward better-performing variations.
- **Primary and secondary metrics:** e.g. CTR, page views, purchases, revenue, AOV, custom events.
- **Probability to be best:** Bayesian-style “probability this variation wins” for a chosen metric.
- **Audience breakdowns:** Performance by segment.
- **Custom detailed reports:** Direct and assisted impact of recommendations; configurable attribution windows.
- **Outlier filtering:** Limit skew from rare events.

### 2.6 Channels and delivery

- **Web and mobile web:** Widgets anywhere on site.
- **Mobile app:** In-app recommendations.
- **Email:** Recommendations (including open-time rendering for freshness), triggered emails.
- **Push notifications:** Schedule or event-triggered.
- **Ads:** Dynamic recommendation-driven creative.
- **Landing pages:** Personalized recommendation blocks.

**API control:** Raw recommendation results for server- or client-side custom rendering and integration with external systems.

### 2.7 Data and integrations

- **Product feed:** Full catalog with metadata; large feeds (millions of SKUs).
- **Delta feed API:** Incremental catalog updates.
- **Multi-feeds:** Combine multiple sources.
- **Multi-language:** Multiple values per item (e.g. names, descriptions) by language.

### 2.8 Takeaways for our platform

- Treat **pin / include / exclude** and **rule prioritization and targeting** as first-class merchandising capabilities.
- Support **multiple strategies per placement** and **fallbacks** when a strategy returns insufficient items.
- Use **targeting** (audience, context, weather, location) to scope when and where recommendations apply.
- Provide **recommendation-level reporting** (CTR, add-to-cart, conversion, revenue, AOV) with **attribution** and **audience breakdowns**.
- Expose a **recommendation API** for web, email, clienteling, and other channels so logic is centralized and consistent.

---

## 3. Other Provider and Ecosystem Practices

### 3.1 Event ingestion and real-time behavior

**Industry norm:** Record user–item interactions as they happen and send them to the recommendation/personalization system in near real time.

- **High-value events:** Purchase, add-to-cart, product detail view.
- **Medium value:** Search, category view, cart view.
- **Negative signal:** Remove-from-cart (where applicable).

**Common requirements:**

- Stable **user/session identifier**.
- **Timestamp** and **event type** (consistent naming).
- **Item/product ID** (and optionally category, placement).
- **Request/recommendation ID** when the event is a direct response to a recommendation (for attribution).

Platforms such as **Amazon Personalize** and **Algolia** document event schemas (e.g. `PutEvents`, Insights API) and stress completeness and consistency for model quality. Our `data-standards.md` and recommendation telemetry (impression, click, add-to-cart, purchase, dismiss) align with this.

### 3.2 API and delivery

- **Request:** User/session ID, context (page, placement, channel), optional anchor item or cart.
- **Response:** Ranked list of items or sets (e.g. outfits), with identifiers and optional reason/source codes for explainability and analytics.
- **Traceability:** Recommendation set ID and trace ID for attribution and debugging (as in our `api-standards.md`).
- **Latency:** Recommendation APIs are often designed for low latency (e.g. p95 &lt; 200–500 ms) so pages and widgets can render without noticeable delay; define targets per placement and document fallback when SLA is missed.
- **Inventory and availability:** Filter or down-rank out-of-stock or unavailable items in recommendations so that suggested products are shoppable; respect inventory rules in merchandising (see §4.3).

Best practice is to keep **recommendation logic and ranking in one place** and let channels adapt **presentation** (format, layout, copy), not re-implement logic per channel.

### 3.3 Fashion and outfit-specific practice

- **Style compatibility:** Beyond attribute similarity, learning which items “go together” (e.g. co-purchase, co-view, stylist-curated sets) and representing them in a shared embedding or compatibility space.
- **Visual similarity:** Optional use of visual embeddings (e.g. CNN-based) for “looks like this” and visual coherence in outfits.
- **Sequence and structure:** Outfits as sequences (e.g. top → bottom → accessories) or as graphs (suit → shirt → tie → shoes) for compatibility and ordering.
- **Color and occasion:** Explicit handling of color compatibility and occasion (e.g. wedding, business) in rules and models.

These support our **outfit graph**, **style/fabric compatibility rules**, and **occasion-based** recommendations.

### 3.4 Assisted selling and in-store

- **Clienteling:** Associate-facing surfaces consume the same recommendation API with context such as customer ID, store/region, and optional appointment or intent. Recommendations can be scoped to in-store inventory or extended to full catalog for follow-up.
- **RTW vs Custom Made:** Ready-to-wear emphasizes immediate shoppability and stock; Custom Made emphasizes complementary items, fabric coordination, and appointment context. Shared style intelligence with different constraints per journey is a differentiator (see `docs/project/vision.md` and `docs/project/product-overview.md`).

---

## 4. Best Practices by Area

### 4.1 Data and identity

- **Canonical IDs:** Use stable IDs for products, customers, looks, campaigns, and experiments; map source-system IDs explicitly.
- **Identity resolution:** When merging anonymous, logged-in, POS, and email, record **confidence** and respect **consent** and regional rules.
- **Event schema:** Consistent event names, timestamps, user/session, channel/surface, and anchor product/look; recommendation impression and outcome events include recommendation set ID and trace ID.
- **Freshness:** Define SLAs for catalog and behavioral data; near real-time events improve next-session and next-page relevance.

See `docs/project/data-standards.md` and `docs/.cursor/rules/recommendation-domain-language.mdc` for identity and telemetry.

### 4.2 Algorithms and strategies

- **Strategy per placement:** Choose strategy by page type and goal (e.g. PDP: complete the look + similar; cart: cross-sell; homepage: personalized or trending).
- **Fallbacks:** If primary strategy returns too few items, fall back to a safe default (e.g. popular in category, curated look) rather than empty or broken widgets.
- **Cold start (users):** For new users or sparse history, use non-personalized strategies (popular, curated, occasion-based) and transition to personalized as data accumulates.
- **Cold start (products):** For new or low-data items, use attribute-based similarity, category popularity, or merchandising curation until behavioral signals exist.
- **Blend curated and algorithmic:** Support hybrid widgets (e.g. first N slots curated, rest algorithmically filled) and rule-based filtering on top of model output.
- **Inventory and availability:** Exclude or down-rank out-of-stock items in strategy output; apply inventory rules as a filter layer so recommendations are shoppable.

### 4.3 Merchandising control

- **Pin / include / exclude:** Merchandisers should be able to pin items, restrict to a whitelist, or blacklist by product or attribute.
- **Inventory rules:** Exclude or suppress low-stock or out-of-stock items per placement or globally; support minimum-threshold rules so recommendations stay shoppable.
- **Rules are first-class:** Rules have priority, targeting (who/page/context), and optional scheduling; conflicts are resolved by explicit prioritization.
- **Audit:** Critical actions (rule change, look publish, suppression) are logged with identity and timestamp for governance and rollback.
- **Approval:** High-visibility or high-risk changes go through a defined approval path before going live (see `docs/project/business-requirements.md` and `docs/.cursor/rules/approval-and-rework.mdc`).

### 4.4 Delivery and channels

- **Single recommendation API:** One logical API (or a small set by use case) consumed by web, email, clienteling, and future surfaces; channel-specific formatting happens at the consumer.
- **Context in request:** Pass customer/session, placement, channel, anchor product/cart, and optional context (weather, location, region/locale) so the engine can filter and rank appropriately. Include region/locale where recommendations or catalog vary by market.
- **Response contract:** Include request echo, recommendation set ID, type, ranked items/looks, reason/source hints, and trace ID (see `api-standards.md`).

### 4.5 Analytics and optimization

- **Core metrics:** Impression, click (CTR), add-to-cart, purchase, revenue, AOV; secondary metrics (e.g. dismiss, time in view) where useful.
- **Attribution:** Define model (e.g. last-click, assisted) and attribution window for “revenue from recommendations” and use it consistently in reporting.
- **Placement and strategy breakdown:** Report by placement, strategy, and (where applicable) experiment variant.
- **Testing:** A/B tests or multi-armed bandits for strategy, layout, and rules; primary metric and sample size / run length defined in advance.

### 4.6 Governance and safety

- **Privacy and consent:** Use only data permitted for the use case and region; respect opt-out and consent; do not expose sensitive profile reasoning to customer-facing UI.
- **Brand safety:** Recommendations align with brand and category rules; merchandising can override or suppress.
- **Approval gates:** High-visibility or policy-sensitive changes require human (or governed) approval before production; do not assume auto-approval unless explicitly configured.
- **Diversity and filter bubbles:** Where relevant, avoid over-concentrating recommendations on a narrow set of items or segments; use diversity rules or sampling so discovery and novelty remain possible. Document choices (e.g. business decision to favor best-sellers vs diversity) for governance.

### 4.7 Anti-patterns and what to avoid

- **Duplicate logic per channel:** Do not re-implement recommendation ranking or filtering in each channel; use a single engine and API, with channel-specific presentation only.
- **Recommendations without attribution:** Every recommendation impression and outcome event should carry recommendation set ID and trace ID so performance and revenue can be attributed.
- **Ignoring inventory:** Do not recommend out-of-stock or unavailable items without a clear business exception (e.g. “notify when back”); it degrades trust and conversion.
- **Merchandising bypass:** Do not allow algorithms to override pin/exclude/suppression rules; merchandising rules take precedence over raw model output.
- **No fallback:** Do not show empty or broken widgets when the primary strategy returns too few results; always define a fallback strategy or curated default.

---

## 5. Alignment With Project Standards

| Area | Project standard / rule | Industry / provider practice |
|------|-------------------------|------------------------------|
| Events & identity | `data-standards.md`, recommendation-domain-language | Real-time events, stable IDs, recommendation set/trace ID on outcomes |
| API response | `api-standards.md` | Request echo, set ID, ranked items, reason codes, trace ID |
| Recommendation types | recommendation-domain-language (outfit, cross-sell, upsell, occasion, contextual, personal) | CTL, similar, bought together, personalized, popular; we add outfit-level and occasion |
| Merchandising | BR-6, BR-12, approval-and-rework | Pin, whitelist, blacklist, prioritization, targeting, scheduling (e.g. Dynamic Yield) |
| Channels | BR-7, BR-8, BR-9 | Web, email, app, API; we add clienteling explicitly |
| Testing | BR-10 | A/B and MAB; primary/secondary metrics; attribution |
| Vision / outfit-first | `vision.md`, `product-overview.md` | CTL + outfit-level + occasion; RTW and CM; shared intelligence, different constraints |

---

## 6. References and Further Reading

### Provider and platform

- Dynamic Yield, [Essential Recommendation Capabilities](https://www.dynamicyield.com/blog/essential-recommendation-capabilities/) (strategies, merchandising, targeting, testing, channels).
- Dynamic Yield, [Merchandising Rules](https://www.dynamicyield.com/lesson/merchandising-rules/) (pin, include, exclude, prioritization).
- Dynamic Yield, [Product Recommendation Strategies](https://www.dynamicyield.com/lesson/product-recommendation-strategies/).
- Amazon Personalize, [Recording real-time events](https://docs.aws.amazon.com/personalize/latest/dg/recording-events.html).
- Algolia, [Personalization implementation checklist](https://algolia.com/doc/guides/personalization/classic-personalization/going-to-production/in-depth/implementation-checklist).

### Concepts and patterns

- Complete the look (CTL): anchor item + complementary set; common on PDP, cart, post-purchase.
- Fashion/style compatibility: co-occurrence, embeddings, sequence or graph models; color and occasion as first-class dimensions.

### Project docs

- `docs/project/vision.md` — vision, north star, strategic outcomes, RTW/CM.
- `docs/project/product-overview.md` — channels, recommendation types, inputs, components.
- `docs/project/data-standards.md` — identity, events, privacy.
- `docs/project/api-standards.md` — recommendation API contract and readiness.
- `docs/project/business-requirements.md` — BRs and success metrics.
- `docs/.cursor/rules/recommendation-domain-language.mdc` — types, surfaces, governance, telemetry (look vs outfit).
- `docs/.cursor/rules/approval-and-rework.mdc` — approval mode, milestone gates, human review.
