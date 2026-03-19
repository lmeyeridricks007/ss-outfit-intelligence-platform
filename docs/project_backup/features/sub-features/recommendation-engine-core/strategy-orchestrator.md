# Sub-Feature: Strategy Orchestrator (Recommendation Engine Core)

**Parent feature:** F9 — Recommendation engine core (`docs/features/recommendation-engine-core.md`)  
**BR(s):** BR-5, BR-1  
**Capability:** Orchestrate strategies (curated, similarity, popularity), merge and rank candidates, apply fallback.

---

## 1. Purpose

**Orchestrate** recommendation strategies: run primary strategy (and optional mix), merge candidates, apply F10 (rules) and context filter, rank, then **fallback** if result size &lt; limit. Returns ranked list to F11. See parent F9.

## 2. Core Concept

**Orchestrator** receives (customer_id, profile, context, placement, anchor, limit) → fetches candidates from F5, F6, strategies → merge → F10 rules (pin, exclude, boost) → context filter → rank → if size &lt; limit, run fallback strategy → return items + metadata (fallback_used). See parent §2, §16.

## 3. User Problems Solved

- **Multiple strategies:** Curated + similarity + popularity. **No empty response:** Fallback fills. See parent §4.

## 4.–10. Trigger through Data Model

Request-time from F11. Inputs: profile, context, placement, anchor, limit. Outputs: ranked_items, fallback_used. Transient; no persistence. See parent §10–14.

## 11. API Endpoints

Internal POST /engine/recommend (called by F11). See parent §16.

## 12.–14. Events, Integrations

None emitted. Reads F5, F6, F7, F8, F10. See parent §17, §22.

## 15.–24. UI through Testing

No UI. Errors: F5/F6 down → use cache or fallback. Cold start: empty profile → non-personal strategies. See parent §23–26.

---

**Status:** Placeholder. Parent: `docs/features/recommendation-engine-core.md`.
