# Sub-Feature: Coverage Metrics (Performance and Personalization Tuning)

**Parent feature:** F26 — Performance and personalization tuning (`docs/features/performance-and-personalization-tuning.md`)  
**BR(s):** BR-10, BR-3, BR-4  
**Capability:** Define and report profile coverage (% logged-in/identified with non-empty profile) and personalization lift for tuning.

---

## 1. Purpose

**Metrics** for tuning: **profile coverage** (% of identified users with non-empty style profile after N interactions); **personalization lift** (conversion or AOV lift for users with profile vs without). Informs F7, F4, F9 tuning and roadmap. See parent F26.

## 2. Core Concept

**Coverage metric:** Count identified users with profile vs total identified; or % with non-empty after N events. **Lift:** Compare conversion/AOV in cohort with profile vs without (from F17 attribution and profile presence). May be dashboard or report; process and doc focus in F26. See parent §2.

## 3. User Problems Solved

- **Improve coverage** (identity, profile build). **Prove personalization value** (lift). See parent §4.

## 4.–24. Trigger through Testing

Scheduled report or dashboard read. Inputs: F7 profile stats, F17 attribution. Outputs: coverage %, lift %. See parent F26 full spec.

---

**Status:** Placeholder. Parent: `docs/features/performance-and-personalization-tuning.md`.
