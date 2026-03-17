#!/usr/bin/env bash
# Create GitHub issues for each Phase 1–5 feature.
# Requires: gh CLI installed and authenticated (gh auth login).
# Usage: ./scripts/create-feature-issues.sh [--dry-run] [--create-labels]
# Labels: phase-1, phase-2, phase-3, phase-4, phase-5, feature (use --create-labels to create if missing).

set -e
REPO="${GITHUB_REPO:-lmeyeridricks007/ss-outfit-intelligence-platform}"
BASE_URL="https://github.com/${REPO}/blob/main"
DRY_RUN=""
CREATE_LABELS=""
for arg in "$@"; do
  [[ "$arg" == "--dry-run" ]] && DRY_RUN="echo"
  [[ "$arg" == "--create-labels" ]] && CREATE_LABELS=1
done

ensure_labels() {
  if [[ -z "$CREATE_LABELS" ]] || [[ -n "$DRY_RUN" ]]; then return; fi
  gh label create feature   --repo "$REPO" --color "EDEDED" --description "Product feature" 2>/dev/null || true
  gh label create phase-1   --repo "$REPO" --color "0E8A16" --description "Data and graph foundation" 2>/dev/null || true
  gh label create phase-2   --repo "$REPO" --color "1D76DB" --description "PDP + Delivery API" 2>/dev/null || true
  gh label create phase-3   --repo "$REPO" --color "FBCA04" --description "Cart + email + analytics" 2>/dev/null || true
  gh label create phase-4   --repo "$REPO" --color "FEF2C0" --description "Clienteling + merchandising UI" 2>/dev/null || true
  gh label create phase-5   --repo "$REPO" --color "D93F0B" --description "Optimization + look builder" 2>/dev/null || true
}

create_issue() {
  local phase=$1
  local fid=$2
  local title=$3
  local desc=$4
  local brs=$5
  local spec=$6
  local bodyfile
  bodyfile=$(mktemp)
  cat <<BODY > "$bodyfile"
**Phase:** ${phase}
**Feature ID:** ${fid}
**BR(s):** ${brs}

**Description:** ${desc}

**Docs:**
- Feature list: [docs/project/feature-list.md](${BASE_URL}/docs/project/feature-list.md)
- Business requirements: [docs/project/business-requirements.md](${BASE_URL}/docs/project/business-requirements.md)
- Roadmap: [docs/project/roadmap.md](${BASE_URL}/docs/project/roadmap.md)
- Feature spec: [${fid} spec](${BASE_URL}/${spec})
BODY
  if [[ -n "$DRY_RUN" ]]; then
    echo "Would create: $title (labels: ${phase}, feature)"
  else
    gh issue create --repo "$REPO" --title "$title" --body-file "$bodyfile" --label "${phase}" --label "feature"
  fi
  rm -f "$bodyfile"
}

# Phase 1
ensure_labels

create_issue "phase-1" "F1" "[F1] Catalog and inventory ingestion" \
  "Ingest and sync product catalog, inventory, and metadata from PIM, Shopify, OMS, DAM, Custom Made so the graph and engine use current assortment." \
  "BR-2" "docs/features/catalog-and-inventory-ingestion.md"
create_issue "phase-1" "F2" "[F2] Behavioral event ingestion" \
  "Ingest behavioral events (view, add-to-cart, purchase, store visits, appointments, email engagement) for profile building and attribution." \
  "BR-2" "docs/features/behavioral-event-ingestion.md"
create_issue "phase-1" "F3" "[F3] Context data ingestion" \
  "Ingest weather, location, season, and calendar context for occasion- and environment-aware recommendations." \
  "BR-2" "docs/features/context-data-ingestion.md"
create_issue "phase-1" "F4" "[F4] Identity resolution" \
  "Merge anonymous, logged-in, POS, and email identities into a stable customer view with consent; canonical customer ID for profile and API." \
  "BR-2, BR-12" "docs/features/identity-resolution.md"
create_issue "phase-1" "F5" "[F5] Product graph" \
  "Model product relationships (e.g. suit → shirt → tie → shoes) and compatibility/substitution by style, fabric, occasion." \
  "BR-4" "docs/features/product-graph.md"
create_issue "phase-1" "F6" "[F6] Outfit graph and look store" \
  "Store and manage curated looks and compatibility rules; configurable by merchandising (file/config or minimal admin in Phase 1)." \
  "BR-4, BR-6" "docs/features/outfit-graph-and-look-store.md"

# Phase 2
create_issue "phase-2" "F7" "[F7] Customer profile service" \
  "Build and maintain style profile (preferences, affinity, segmentation, intent) from orders, browsing, store visits, stated interests; consumed by engine." \
  "BR-3" "docs/features/customer-profile-service.md"
create_issue "phase-2" "F8" "[F8] Context engine" \
  "Supply weather, season, location, occasion, channel/placement, and inventory context to the recommendation engine." \
  "BR-5" "docs/features/context-engine.md"
create_issue "phase-2" "F9" "[F9] Recommendation engine core" \
  "Multiple strategies (curated, rule-based, collaborative filtering, co-occurrence, similarity, popularity); hybrid ranking; context-aware filtering; fallbacks." \
  "BR-5, BR-1" "docs/features/recommendation-engine-core.md"
create_issue "phase-2" "F10" "[F10] Merchandising rules engine" \
  "Apply pin, include, exclude, inventory, category/price constraints; rules take precedence over raw algorithm output." \
  "BR-6" "docs/features/merchandising-rules-engine.md"
create_issue "phase-2" "F11" "[F11] Delivery API" \
  "Single logical API: request (customer/session, context, product, placement, channel), response (set ID, trace ID, ranked items/looks, reason/source hints); fallback when insufficient results." \
  "BR-7" "docs/features/delivery-api.md"
create_issue "phase-2" "F12" "[F12] Recommendation telemetry" \
  "Capture outcome events (impression, click, add-to-cart, purchase, dismiss) with recommendation set ID and trace ID for analytics and attribution." \
  "BR-10" "docs/features/recommendation-telemetry.md"

# Phase 3
create_issue "phase-3" "F13" "[F13] PDP recommendation widgets" \
  "Surface complete-the-look, styled with, and you may also like on product detail page; widgets call Delivery API and send outcome events." \
  "BR-1, BR-7" "docs/features/webstore-recommendation-widgets.md"
create_issue "phase-3" "F14" "[F14] Cart recommendation widgets" \
  "Surface complete your outfit on cart; widgets call Delivery API and send outcome events." \
  "BR-1, BR-7" "docs/features/webstore-recommendation-widgets.md"
create_issue "phase-3" "F15" "[F15] Homepage and landing recommendation widgets" \
  "Surface looks for you, trending outfits, and inspiration on homepage and landing pages; call Delivery API and send outcome events." \
  "BR-1, BR-7" "docs/features/webstore-recommendation-widgets.md"
create_issue "phase-3" "F16" "[F16] Email and CRM recommendation payloads" \
  "Provide recommendation content for email/CRM campaigns (e.g. Customer.io); respect audience, region, availability; open-time or batch as designed." \
  "BR-8" "docs/features/email-crm-recommendation-payloads.md"
create_issue "phase-3" "F17" "[F17] Core analytics and reporting" \
  "Report core recommendation metrics (CTR, add-to-cart, conversion, revenue attribution, AOV) in agreed tool/dashboard; attribution model applied." \
  "BR-10" "docs/features/core-analytics-and-reporting.md"

# Phase 4
create_issue "phase-4" "F18" "[F18] Admin: look editor" \
  "Let merchandising create and edit curated looks and publish (or submit for approval) without engineering; role-based access." \
  "BR-11, BR-6" "docs/features/admin-look-editor.md"
create_issue "phase-4" "F19" "[F19] Admin: rule builder" \
  "Let merchandising define and edit pin, exclude, include, category, price, inventory rules with targeting and scheduling." \
  "BR-11, BR-6" "docs/features/admin-rule-builder.md"
create_issue "phase-4" "F20" "[F20] Admin: placement and campaign config" \
  "Let merchandising and CRM configure where recommendations appear, which strategy applies, and campaign/placement settings; preview." \
  "BR-11" "docs/features/admin-placement-and-campaign-config.md"
create_issue "phase-4" "F21" "[F21] Approval workflows and audit" \
  "Require human or governed approval for high-visibility changes; audit log for critical actions (rule change, look publish, suppression) with identity and timestamp." \
  "BR-12, BR-6" "docs/features/approval-workflows-and-audit.md"
create_issue "phase-4" "F22" "[F22] Privacy and consent enforcement" \
  "Scope customer data use to permitted use cases and regions; respect consent and opt-out; no unapproved bulk overrides." \
  "BR-12" "docs/features/privacy-and-consent-enforcement.md"
create_issue "phase-4" "F23" "[F23] In-store clienteling integration" \
  "Associate-facing surface (app or tablet) calls Delivery API with customer ID, store/region, optional appointment context; recommendations and (where permitted) style profile visible." \
  "BR-9" "docs/features/clienteling-integration.md"

# Phase 5
create_issue "phase-5" "F24" "[F24] A/B and experimentation" \
  "Support A/B and multi-armed bandit (where configured) for strategies, layouts, and rules; primary metric and sample size defined; results in reporting." \
  "BR-10" "docs/features/ab-and-experimentation.md"
create_issue "phase-5" "F25" "[F25] Customer-facing look builder" \
  "Let customers browse and explore curated looks as a dedicated surface; recommendations delivered via same Delivery API; placement and metrics tracked." \
  "BR-1, BR-7" "docs/features/customer-facing-look-builder.md"
create_issue "phase-5" "F26" "[F26] Performance and personalization tuning" \
  "Improve profile coverage and personal recommendation lift; tune graph coverage and strategy mix using analytics; document roadmap for further refinement." \
  "BR-10, BR-3, BR-4" "docs/features/performance-and-personalization-tuning.md"

echo "Done. 26 feature issues created. Use --create-labels if you need to create phase-1..phase-5 and 'feature' labels."
