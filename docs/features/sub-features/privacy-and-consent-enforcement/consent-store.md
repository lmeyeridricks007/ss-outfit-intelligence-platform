# Sub-Feature: Consent Store (Privacy and Consent Enforcement)

**Parent feature:** F22 — Privacy and consent enforcement (`docs/features/privacy-and-consent-enforcement.md`)  
**BR(s):** BR-12  
**Capability:** Store and serve consent state (customer_id, use_case, region → allowed) for F4, F7, F23.

---

## 1. Purpose

**Store** consent state: (customer_id, use_case, region) → allowed (boolean). **Serve** to F4 (resolve consent_ok), F7 (empty profile when not allowed), F23 (hide profile when not allowed). No override; legal defines policy. See parent F22.

## 2. Core Concept

**Key-value store** or table: customer_id, use_case, region → allowed. **Check API:** GET consent?customer_id=...&use_case=...&region=... → allowed. Default when no record per policy (strict = false). See parent §2, §10.

## 3. User Problems Solved

- **Compliance:** Opt-out respected. **Single source** for consent. See parent §4.

## 4.–24. Trigger through Testing

Request-time check; update on preference center or support. Integrations: F4, F7, F23. See parent F22 full spec.

---

**Status:** Placeholder. Parent: `docs/features/privacy-and-consent-enforcement.md`.
