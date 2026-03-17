# Sub-Feature: Rule Evaluation (Merchandising Rules Engine)

**Parent feature:** F10 — Merchandising rules engine (`docs/features/merchandising-rules-engine.md`)  
**BR(s):** BR-6  
**Capability:** Evaluate pin, exclude, include, category, price, inventory rules on candidate list for a request.

---

## 1. Purpose

**Evaluate** merchandising rules (pin, exclude, include, boost, category/price/inventory constraints) against a **candidate list** and **placement/campaign** context. Returns reordered and filtered list; rules take precedence over raw algorithm output. See parent F10.

## 2. Core Concept

**Rule engine** receives (candidates, placement, campaign_id, context) → loads applicable rules from store (F19/F20) → applies pin first, then exclude, include, boost, constraints → returns ordered list. See parent §2.

## 3. User Problems Solved

- **Merchandising control:** Pin items, exclude out-of-stock, boost category. **Governance:** Rules approved (F21). See parent §4.

## 4.–10. Trigger through Data Model

Request-time from F9. Inputs: candidates, placement, campaign. Outputs: reordered/filtered list. Rules from rule store. See parent §10–14.

## 11. API Endpoints

Internal (F9 calls). See parent §16.

## 12.–14. Events, Integrations

None. Reads F6 (looks), rule store (F19). See parent §17, §22.

## 15.–24. UI through Testing

Rule builder UI in F19. Permissions, errors, implementation (rule store, evaluator), testing. See parent §18–26.

---

**Status:** Placeholder. Parent: `docs/features/merchandising-rules-engine.md`.
