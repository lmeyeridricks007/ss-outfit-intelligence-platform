# Personas

## Artifact metadata
- **Upstream source:** GitHub issue #37 master product description.
- **Bootstrap stage:** Bootstrap project documentation.
- **Next downstream use:** Persona coverage for later BR, UI, personalization, and operator-tooling artifacts.
- **Key assumption:** Both external shoppers and internal operators materially shape the product scope.
- **Missing decisions:** No persona-specific bootstrap decisions remain beyond the shared rollout questions tracked in `business-requirements.md` and `roadmap.md`.

## Primary personas

### 1. Outfit-seeking online shopper
**Who they are:** A customer browsing suits, jackets, shirts, shoes, and accessories online who wants help assembling a complete look.

**Goals**
- Find items that work together without second-guessing color or formality.
- Understand what completes the look from a starting product.
- Buy with confidence in one session when possible.

**Pain points**
- Product pages answer "what is this item" better than "what should I wear with it."
- Generic recommendations show alternatives instead of complements.
- The customer must mentally combine color, fabric, season, and occasion across categories.

**Behavior and decision context**
- Often starts from one anchor item such as a suit or jacket.
- Compares options quickly and may abandon if the full look remains unclear.
- Uses context like event type, season, or destination even if it is not explicitly collected.

**Success looks like**
- A recommendation set quickly turns a single product view into a credible full outfit.
- The shopper adds multiple compatible items with minimal uncertainty.

### 2. Returning customer with style history
**Who they are:** A known customer with previous purchases, browsing history, account behavior, and potential loyalty or email engagement signals.

**Goals**
- Receive recommendations that feel informed by prior purchases and personal taste.
- Avoid duplicate or low-fit suggestions.
- Discover new looks that extend the existing wardrobe.

**Pain points**
- Repeated exposure to items already owned or incompatible with prior purchases.
- Lack of recognition of preferred fits, colors, fabrics, or price tier.
- No clear bridge between purchase history and future outfit-building guidance.

**Behavior and decision context**
- Shops intermittently across seasons and occasions.
- May respond to email, retargeting, or clienteling outreach rather than only onsite browsing.
- Expects higher relevance than a first-time visitor.

**Success looks like**
- Recommendations reflect wardrobe continuity, not just session-level popularity.
- The customer feels understood and returns for additional categories over time.

### 3. Occasion-led shopper
**Who they are:** A customer shopping for a specific moment such as a wedding, interview, business trip, or seasonal wardrobe refresh.

**Goals**
- Translate an occasion into a complete, appropriate outfit.
- Balance dress code, climate, and personal style.
- Move from inspiration to purchase quickly.

**Pain points**
- Occasion intent is not captured well by standard product recommendations.
- It is difficult to judge whether a look is suitable for formal, business, travel, or seasonal needs.
- Context such as city, weather, or time of year is rarely reflected in recommendations.

**Behavior and decision context**
- Starts with event intent or a specific climate-driven need.
- May browse inspiration pages before landing on individual products.
- Responds well to curated bundles or look narratives.

**Success looks like**
- The platform suggests a full outfit that fits the event and local context.
- The customer does not need to stitch together advice from multiple places.

## Secondary personas

### 4. In-store stylist or clienteling associate
**Goals**
- Use platform recommendations as a strong starting point for assisted selling.
- Adapt curated or personalized looks during appointments and store visits.
- Understand why a recommendation set was generated at a practical level.

**Pain points**
- Styling guidance may be inconsistent between channels.
- Manual look building is time-consuming and difficult to scale.
- Customer context from ecommerce and store interactions may be fragmented.

**Success looks like**
- Faster preparation for appointments and better attachment selling in store.

### 5. Merchandiser or campaign owner
**Goals**
- Curate looks, define compatibility or exclusion rules, and control campaign presentation.
- Balance brand presentation, inventory realities, and AI-driven ranking.
- Launch seasonal or occasion-focused recommendation strategies quickly.

**Pain points**
- Limited control over how recommendation logic expresses merchandising intent.
- Manual curation does not scale across all surfaces and markets.
- Difficult to measure which curated logic drives commercial impact.

**Success looks like**
- The team can adjust looks and rules without bespoke engineering changes for each campaign.

### 6. Marketing, product, and analytics stakeholders
**Goals**
- Reuse recommendation intelligence in email, personalization, and optimization workflows.
- Measure recommendation quality and downstream commercial impact.
- Run experiments and compare performance across channels.

**Pain points**
- Fragmented data and inconsistent identifiers across channels.
- Limited telemetry linking recommendation impressions to later outcomes.
- Difficulty determining whether performance came from curation, rules, or AI ranking.

**Success looks like**
- Shared recommendation datasets, delivery APIs, and telemetry support confident optimization decisions.
