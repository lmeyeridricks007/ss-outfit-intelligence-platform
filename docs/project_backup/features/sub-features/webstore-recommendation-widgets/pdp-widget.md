# Sub-Feature: PDP Widget (Webstore Recommendation Widgets)

**Parent feature:** F13–F15 — Webstore recommendation widgets (`docs/features/webstore-recommendation-widgets.md`)  
**BR(s):** BR-1, BR-7  
**Capability:** PDP placement widget: complete-the-look, styled-with, you-may-also-like; calls F11 and sends outcome events.

---

## 1. Purpose

**UI component** on product detail page that calls Delivery API (F11) with placement (e.g. pdp_complete_the_look), session_id, anchor_product_id, and renders returned items; on impression/click/add-to-cart sends events to F12 with set_id and trace_id. See parent F13.

## 2. Core Concept

**Widget:** Mounts on PDP; GET/POST to F11 (via BFF or server-side to hide API key); renders carousel/grid; on view sends recommendation_impression; on click sends recommendation_click; on add-to-cart sends recommendation_add_to_cart. All events include set_id, trace_id from F11 response. See parent §2, §16.

## 3. User Problems Solved

- **Complete-the-look on PDP:** Increases AOV. **Attribution:** F12 receives events. See parent §4.

## 4.–24. Trigger through Testing

Page load or slot in view. Inputs: placement, session_id, anchor_product_id, limit. Outputs: rendered items; events to F12. Upstream F11; session from webstore. Permissions: no API key on client. User not logged in: session_id only. See parent full spec.

---

**Status:** Placeholder. Parent: `docs/features/webstore-recommendation-widgets.md`.
