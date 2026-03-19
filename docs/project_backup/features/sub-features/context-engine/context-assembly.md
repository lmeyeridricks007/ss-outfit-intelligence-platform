# Sub-Feature: Context Assembly (Context Engine)

**Parent feature:** F8 — Context engine (`docs/features/context-engine.md`)  
**BR(s):** BR-5  
**Capability:** Assemble context payload (weather, season, occasion, placement) for recommendation request.

---

## 1. Purpose

**Assemble** context payload for a recommendation request: weather, season, occasion, placement, channel, optional inventory. F11 calls this (or in-process) and passes result to F9. See parent F8.

## 2. Core Concept

**Request-time** assembly: given placement, channel, anchor_product_id, region, occasion → fetch weather/season from F3/store, add request params → return context object. No PII. See parent §2.

## 3. User Problems Solved

- **Context-aware filtering:** F9 filters by season, occasion. **Single contract** for context. See parent §4.

## 4.–10. Trigger through Data Model

Request-time. Inputs: placement, channel, anchor, region, occasion. Outputs: context payload (weather, season, occasion, …). Reads from context store (F3). See parent §10–14.

## 11. API Endpoints

POST /context/assemble (internal). See parent §16.

## 12.–14. Events, Integrations

None produced; consumed by F11. Upstream F3; downstream F9 via F11. See parent §17, §22.

## 15.–24. UI through Testing

No UI. Errors: unknown region → default. Performance: cache. Implementation: service + cache. See parent §18–26.

---

**Status:** Placeholder. Parent: `docs/features/context-engine.md`.
