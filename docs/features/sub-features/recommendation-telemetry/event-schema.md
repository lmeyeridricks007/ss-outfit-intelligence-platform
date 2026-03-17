# Sub-Feature: Event Schema (Recommendation Telemetry)

**Parent feature:** F12 — Recommendation telemetry (`docs/features/recommendation-telemetry.md`)  
**BR(s):** BR-10  
**Capability:** Canonical schema and validation for recommendation outcome events (impression, click, add-to-cart, purchase, dismiss).

---

## 1. Purpose

Define and enforce **canonical schema** for recommendation outcome events so F17 (analytics) and attribution can rely on consistent fields (event_name, set_id, trace_id, channel, placement). See parent F12.

## 2. Core Concept

**Event schema** (and validator): required fields (event_name, timestamp, recommendation_set_id, trace_id, channel, placement; optional customer_id/session_id, item id, action). Channels (F13–F15, F23, F16) send events to pipeline that validates and routes to F17. See parent §2.

## 3. User Problems Solved

- **Attribution:** set_id and trace_id on every outcome. **Consistency:** Same shape across web, email, clienteling. See parent §4.

## 4.–24. Trigger through Testing

Request/event-time. Inputs: event payload. Outputs: validated event to stream/store. Schema in data-standards. No UI for schema itself. Integrations: channels → F12 pipeline → F17. See parent F12 full spec.

---

**Status:** Placeholder. Parent: `docs/features/recommendation-telemetry.md`.
