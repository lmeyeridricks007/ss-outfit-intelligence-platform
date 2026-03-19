# Sub-Feature: Variant Assignment (A/B and Experimentation)

**Parent feature:** F24 — A/B and experimentation (`docs/features/ab-and-experimentation.md`)  
**BR(s):** BR-10  
**Capability:** Assign request to experiment variant (strategy, layout, rule set); pass experiment_id and variant to F11 and F17.

---

## 1. Purpose

**Assign** each recommendation request to an **experiment variant** (e.g. strategy A vs B, or layout 1 vs 2). Pass experiment_id and variant_id in request and response so F17 can attribute outcomes by variant. Support A/B and optional multi-armed bandit. See parent F24.

## 2. Core Concept

**Assignment service or middleware:** On request (session_id or customer_id), determine experiment (from F20 or config) → assign variant (deterministic hash or random) → add experiment_id, variant to request context → F11 passes to F9 and response; F12 events include experiment_id/variant. See parent §2.

## 3. User Problems Solved

- **Optimization:** Compare strategy/layout performance. **Attribution:** Revenue per variant in F17. See parent §4.

## 4.–24. Trigger through Testing

Request-time. Inputs: session/customer, placement. Outputs: experiment_id, variant. Integrations: F11, F20 (config), F12, F17. See parent F24 full spec.

---

**Status:** Placeholder. Parent: `docs/features/ab-and-experimentation.md`.
