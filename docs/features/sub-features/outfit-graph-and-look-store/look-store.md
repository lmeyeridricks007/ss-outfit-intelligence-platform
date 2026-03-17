# Sub-Feature: Look Store (Outfit Graph and Look Store)

**Parent feature:** F6 — Outfit graph and look store (`docs/features/outfit-graph-and-look-store.md`)  
**BR(s):** BR-4, BR-6  
**Capability:** Store and serve curated looks (product groupings) and outfit graph for engine and admin.

---

## 1. Purpose

**Store** curated looks (look_id, product_ids, metadata, lifecycle) and **serve** them to F9 (engine) and F18 (admin). Maintains outfit graph (look–product relationships). See parent F6.

## 2. Core Concept

A **look store** (DB or service) with CRUD and query API: get look by id, get looks for placement/category, list for admin. Lifecycle: draft → under_review → approved → published → retired. See parent §2.

## 3. User Problems Solved

- **Curated recommendations:** Engine fetches looks for placement. **Admin:** Create/edit looks (F18). See parent §4.

## 4.–10. Trigger Conditions through Data Model

See parent F6 §10–14. Inputs: look_id, product_ids, metadata, state. Outputs: look records. Data model: look (look_id, product_ids, source, state, placement, …).

## 11. API Endpoints

GET/POST/PUT looks; internal for F9 and F18. See parent §16.

## 12.–14. Events, Integrations

Optional events; upstream F1/F5; downstream F9, F10, F18. See parent §17, §22.

## 15.–24. UI through Testing

Admin UI in F18; permissions; errors; observability; implementation (backend, DB); testing. See parent §18–26.

---

**Status:** Placeholder. Expand per `resolve-api.md` template. Parent: `docs/features/outfit-graph-and-look-store.md`.
