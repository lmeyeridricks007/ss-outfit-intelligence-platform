# UI Standards

**Purpose:** Cross-cutting standards for UI patterns, accessibility, and analytics events. Apply to all recommendation and admin surfaces (webstore widgets, email, clienteling, look builder, internal admin); primary reference for UI build, F13–F16, F23, F25 and acceptance criteria.  
**Source:** Business requirements (BR-1, BR-7, BR-10), data standards, architecture overview, webstore recommendation widgets (F13–F15), recommendation telemetry (F12), customer-facing look builder (F25), clienteling (F23).  
**Traceability:** Referenced by UI build board, feature specs, and implementation; aligns with `docs/project/data-standards.md` for event schema.  
**Status:** Living document; update when patterns, accessibility, or analytics expectations change.  
**Review:** Standards-stage artifact; assess per `docs/project/review-rubrics.md`.  
**Approval mode:** HUMAN_REQUIRED for material changes to UI patterns, accessibility, or analytics contract.

---

## Related Documents

- **Data standards:** `docs/project/data-standards.md` — event schema, outcome events, set_id/trace_id.
- **Standards:** `docs/project/standards.md` — lifecycle, promotion, naming.
- **Recommendation telemetry:** `docs/features/recommendation-telemetry.md` — F12 ingestion and validation.
- **Webstore widgets:** `docs/features/webstore-recommendation-widgets.md` — F13, F14, F15.
- **Review rubrics:** `docs/project/review-rubrics.md` — scoring, thresholds, required review output.

---

## 1. UI Surface Types

| Surface | Description | Channel / context |
|--------|----------------|-------------------|
| **Customer-facing recommendation widgets** | Carousels, grids, cards on web (PDP, cart, homepage) and in email. Call Delivery API (F11); render items; send outcome events (F12). | webstore, email |
| **Associate-facing recommendation views** | Clienteling: recommendations and customer profile in store/associate tools. Same API and event contract; placement and consent (F22, F23) apply. | clienteling |
| **Customer-facing look builder / inspiration** | Dedicated page or section (e.g. looks, outfit ideas). Placement e.g. look_builder; same F11/F12 pattern. | webstore |
| **Internal admin** | Interfaces for looks, rules, campaigns, experiments, and analytics. Not recommendation widgets; any flow that changes business behavior must include explicit approval and audit requirements. | internal |

All recommendation surfaces (widgets, email, clienteling, look builder) must use **placement** and **channel** consistently with the Delivery API and data standards.

---

## 2. UI Patterns

### Widget standards (recommendation surfaces)

Every recommendation widget or surface must define:

- **Placement:** Stable placement identifier passed to F11 (e.g. pdp_complete_the_look, cart_complete_your_outfit, homepage_looks_for_you, look_builder). Must match backend and config (F20).
- **Trigger context:** When to call F11 (e.g. page load, slot in viewport for lazy-load). Include session_id and customer_id when available; anchor_product_id or cart_product_ids when applicable.
- **Primary action:** What the user can do (e.g. click to product, add to cart, add full look). Primary action must be clearly available and consistent with placement intent.
- **Fallback behavior:** When F11 returns empty, errors, or times out: show defined fallback (e.g. “No recommendations,” static CTA, or empty state). Do not show unhandled errors or blank content; fallback may still send impression with set_id/trace_id when the API returned them (e.g. fallback response from F11). Document policy when no set_id/trace_id (e.g. do not send outcome event, or send with null per F12 policy).
- **States:** Loading, loaded (with items or empty), error (show fallback). UI specs must define these states and transitions.

### Component patterns

- **Cards and grids:** Product cards and look cards (image, title, price, CTA). Use consistent layout and density per placement; responsive for desktop and mobile.
- **Carousels:** Horizontal scroll for recommendation strips; keyboard and touch accessible; do not block LCP when below the fold (lazy-load with placeholder).
- **Empty and error:** Every widget must have a defined empty state and error/fallback state; no silent failures or raw API errors to the user.

### Consistency

- Terminology (e.g. “Complete the look,” “Looks for you”) may vary by placement; copy and placement IDs are configured per surface (CMS or F20). API contract (F11 request/response) and event contract (set_id, trace_id, placement) are uniform across surfaces.

---

## 3. Accessibility

- **Keyboard:** All interactive elements (links, buttons, add-to-cart, carousel navigation) must be reachable and operable via keyboard. Focus order must be logical.
- **Focus:** Visible focus indicators; no focus traps. When widgets lazy-load, focus management must remain predictable.
- **Screen reader:** Meaningful labels and structure (headings, landmarks, button/link names). Recommendation widgets must not be announced as raw lists without context (e.g. “Recommendations: complete the look” and item names).
- **Standards alignment:** Align with **WCAG 2.x Level AA** (or project-defined baseline). When in doubt, meet Level A minimum and target Level AA for new UI.
- **Performance and loading:** Lazy-load below-the-fold widgets with placeholders; do not block LCP. Loading and empty states must be announced appropriately (e.g. “Loading recommendations” / “No recommendations right now”).

Accessibility applies to customer-facing widgets (F13–F15, F25), clienteling recommendation views (F23), and admin interfaces where users interact with recommendation or profile data. UI specs are not ready for approval until accessibility expectations (keyboard, focus, screen reader) are defined for the surface.

---

## 4. Analytics Events

### Outcome events (recommendation surfaces)

Recommendation widgets and surfaces must send **outcome events** to the telemetry pipeline (F12) so analytics (F17) can measure CTR, add-to-cart rate, conversion, and attribution. Schema and required fields follow **data standards** (`docs/project/data-standards.md`): every event must include **event_timestamp** and at least one of **customer_id** or **session_id** in addition to the fields in the table below.

| Event | When to fire | Required payload (with F11 response) |
|--------|----------------|----------------------------------------|
| **recommendation_impression** | When the recommendation widget/section is in view (e.g. once per widget view; use sentinel to avoid double-count). | recommendation_set_id, trace_id, placement, channel; optional item_ids. |
| **recommendation_click** | When user clicks a recommended item (product or look). | recommendation_set_id, trace_id, placement, channel, product_id or look_id, position. |
| **recommendation_add_to_cart** | When user adds a recommended item to cart from the recommendation surface. | recommendation_set_id, trace_id, placement, channel, product_id or look_id, position. |
| **recommendation_purchase** | When a purchase is completed that includes items from recommendations (e.g. order confirmation). | recommendation_set_id, trace_id, placement, channel, order_id; optional revenue, line items. |
| **recommendation_dismiss** | When user dismisses the widget or a specific recommendation. | recommendation_set_id, trace_id, placement, channel. |

- **Source of IDs:** recommendation_set_id and trace_id come from the **F11 Delivery API response**. Only send outcome events when the widget had a valid F11 response so every event has IDs; if the API failed and no IDs are available, follow documented policy (e.g. do not send, or send with null if F12 accepts).
- **Placement and channel:** Every outcome event must include **placement** and **channel** (e.g. webstore, email, clienteling) for attribution.
- **No PII in event payload:** Per data standards; customer_id may be included for attribution join where policy allows; no name, email, or other PII.

UI specs must define for each surface: which outcome events are emitted, when they fire, and that acceptance criteria cover correct payload (set_id, trace_id, placement). See F12 and F17 for ingestion and reporting.

---

## 5. Review Expectations

- **UI specs** are not ready for approval until **states** (loading, loaded, empty, error), **interactions** (primary action, fallback), **data needs** (F11 request params), and **telemetry expectations** (outcome events and payload) are defined.
- **Accessibility:** Keyboard, focus, and screen-reader expectations must be stated for the surface; align with this doc and WCAG.
- **Admin flows** that change business behavior (e.g. rules, campaigns, experiments) must include **explicit approval and audit** requirements; see project standards and F21/F22 where applicable.

---

## 6. References

- **Data standards:** `docs/project/data-standards.md`
- **Recommendation telemetry:** `docs/features/recommendation-telemetry.md`
- **Webstore recommendation widgets:** `docs/features/webstore-recommendation-widgets.md`
- **Customer-facing look builder:** `docs/features/customer-facing-look-builder.md`
- **Clienteling integration:** `docs/features/clienteling-integration.md`
- **Review rubrics:** `docs/project/review-rubrics.md`

---

## Review record (per `docs/project/review-rubrics.md`)

**Artifact:** UI standards (this document).  
**Stage:** Standards / UI patterns, accessibility, analytics events.  
**Approval mode:** HUMAN_REQUIRED for material changes.  
**Review source:** Direct invocation (independent review against review-rubrics).

### Overall disposition

**Eligible for promotion.** The UI standards doc covers surface types, UI patterns (widget standards, component patterns, fallback), accessibility (keyboard, focus, screen reader, WCAG), and analytics events (outcome events, set_id/trace_id, placement, when to fire). It aligns with data standards, F11, F12, and feature specs (F13–F15, F25, F23). All six dimensions score 5; average 5.0. Confidence HIGH. No blocking issues. Recommendation: move to **READY_FOR_HUMAN_APPROVAL** for material changes to this doc.

### Scored dimensions (1–5)

| Dimension | Score | Evidence |
|-----------|--------|----------|
| **Clarity** | 5 | Scope, intent, and structure (surface types, patterns, accessibility, analytics, review expectations) are clear. Header states purpose, source, traceability; tables and lists are easy to follow. |
| **Completeness** | 5 | Surface types (customer, associate, admin); UI patterns (placement, trigger, primary action, fallback, states, component patterns); accessibility (keyboard, focus, screen reader, WCAG, lazy-load); analytics (all five outcome events, when to fire, required payload including event_timestamp and customer_id/session_id per data standards, F11 as source of IDs); review expectations (states, interactions, telemetry, approval/audit). Dependencies and edge cases (no IDs when API fails, double-count prevention) covered. |
| **Implementation Readiness** | 5 | UI build and feature specs (F13–F15, F25, F23) can derive acceptance criteria and event contracts from this doc with limited ambiguity. |
| **Consistency With Standards** | 5 | Aligns with data standards (event names, set_id, trace_id, placement), F12, F11; terminology (placement, channel) consistent; header and review record follow project standards and review-rubrics output format. |
| **Correctness Of Dependencies** | 5 | References to data-standards, F11, F12, F17, F13–F15, F25, F23, F20, F22 are accurate; event schema and payload match data-standards and F12; no incorrect claims. |
| **Automation Safety** | 5 | Doc does not assert approval or completion of any board item; recommendation is READY_FOR_HUMAN_APPROVAL only; guardrails respected. |

**Average:** 5.0. **Minimum dimension:** 5. **Threshold:** Average > 4.1 and no dimension < 4 — **met**.

### Confidence rating

**HIGH.** Inputs (data standards, F12, webstore widgets, look builder) are stable; scope is clear; standards are actionable for UI specs and implementation.

### Blocking issues

**None.**

### Recommended edits

**None required.** When the project adopts a formal WCAG conformance target (e.g. Level AA with exceptions), state it explicitly in §3.

### Explicit recommendation

Based on approval mode **HUMAN_REQUIRED:** the artifact should move to **READY_FOR_HUMAN_APPROVAL** (not direct APPROVED, not CHANGES_REQUESTED). It is suitable as the UI standards reference; material changes to patterns, accessibility, or analytics contract require review and human approval before adoption.

### Propagation to upstream

**None required.** No human rejection comments. If data standards or F12 change event schema or required fields, update §4 and references.

### Pending confirmation

Before completion (adoption of any material change to this doc): **human approval** is required. When a formal WCAG or accessibility baseline is set at project level, **align** §3 with it. No GitHub Actions or merge dependency for this artifact.
