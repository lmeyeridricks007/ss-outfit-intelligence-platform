# Problem Statement

## Artifact metadata
- **Upstream source:** GitHub issue #37 master product description.
- **Bootstrap stage:** Bootstrap project documentation.
- **Next downstream use:** Problem framing for later BR and feature-breakdown artifacts.
- **Key assumption:** The central unsolved customer need is complete-outfit construction, not only product discovery.
- **Missing decisions:** Shared rollout and identity questions are tracked in `business-requirements.md`, `roadmap.md`, and `architecture-overview.md`.

## Current problem
SuitSupply customers often know the first item they want to explore, but not the full outfit they should build around it. A shopper may land on a navy suit, linen jacket, or winter tailoring page and still have unanswered questions about the right shirt, tie, shoe, belt, outerwear, or accessory combination for the setting.

Current ecommerce recommendation patterns are not enough for this behavior. Similar products, popularity lists, and frequently-bought-together modules do not reliably account for:
- style compatibility across categories;
- occasion and dress-code intent;
- season, weather, and local market context;
- differences between RTW and CM journeys;
- the customer's past purchases and style profile;
- merchandising priorities and curated looks.

## Who experiences the problem
### Customers
- New shoppers who need inspiration and confidence to build a polished look.
- Returning customers who expect recommendations to reflect prior purchases and preferences.
- Occasion-led shoppers who care about the situation first, not the individual product first.

### Internal teams
- In-store stylists who want a stronger starting point for assisted selling.
- Merchandisers who need structured control over looks and rule-based overrides.
- Marketing teams that need relevant multi-item recommendations for outbound campaigns.
- Product and analytics teams that need measurable recommendation behavior across channels.

## Why current alternatives are insufficient
Current alternatives optimize around co-occurrence or product similarity, not outfit construction. They tend to:
- over-recommend near substitutes instead of complements;
- ignore nuance in color, pattern, fabric, and formalwear compatibility;
- treat channels independently instead of sharing intelligence across ecommerce, email, and clienteling;
- provide limited operator control and limited feedback loops for learning.

## Why now
The business already has the styling knowledge and merchandising intent needed to create differentiated outfit recommendations. The missing piece is a consistent data-driven platform that can operationalize that knowledge across channels while learning from customer behavior.

This is timely because:
- customers expect more personalized digital shopping assistance;
- SuitSupply already spans online and assisted-selling channels that can benefit from a shared intelligence layer;
- the business has clear commercial upside in conversion, AOV, and retention;
- AI ranking and graph-based recommendation approaches can now be blended with business rules at practical scale.

## Consequences of not solving it
If the problem remains unsolved:
- customers continue to hesitate or purchase incomplete outfits;
- recommendation surfaces stay generic and easier for competitors to match;
- internal teams keep relying on fragmented manual workflows;
- personalization performance in email and clienteling remains inconsistent;
- product and analytics teams lack the telemetry needed to improve recommendation quality systematically.
