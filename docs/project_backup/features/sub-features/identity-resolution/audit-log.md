# Sub-Feature: Audit Log (Identity Resolution)

**Parent feature:** F4 — Identity Resolution (`docs/features/identity-resolution.md`)  
**BR(s):** BR-12  
**Capability:** Append-only audit log for identity link and consent-related actions (link, unlink, merge) for governance and compliance.

---

## 1. Purpose

Record **every material identity operation** (link added, link unlinked, customer merge) with **timestamp**, **actor** (system or user id), **customer_id**, and **action type**—**no PII**—so compliance and support can audit who did what and when. Required for BR-12 (governance and safety).

## 2. Core Concept

An **append-only audit log** that:
- Receives events from link-management (add, unlink, merge) and optionally consent updates.
- Stores: action, customer_id(s), source_system/source_id (anonymized/hashed if needed), timestamp, actor, optional reason_code.
- Is read-only for downstream (no update/delete). Retention and export per policy.

## 3. User Problems Solved

- **Compliance:** Demonstrate identity and consent handling for regulators and audits.
- **Support:** Trace merge or unlink to resolve customer disputes.
- **Security:** Detect anomalous bulk link or unlink actions.

## 4. Trigger Conditions

- **Event-driven:** Every link add, unlink, merge (and optionally consent withdrawal) writes one or more audit records. Triggered by link-management or F22.

## 5. Inputs

- **Action:** link_added \| link_unlinked \| customer_merged \| consent_updated (optional).
- **customer_id** (one or two for merge).
- **source_system, source_id** (hashed or redacted); optional.
- **actor:** system \| service name \| user_id (admin); no customer PII.
- **timestamp:** event time (server-generated if not trusted).
- **metadata:** optional reason_code, use_case.

## 6. Outputs

- **Audit record ID** (optional) and 201/200. No business response; write is fire-and-forget or synchronous per policy.

## 7. Workflow / Lifecycle

1. Link-management (or F22) performs add/merge/unlink.
2. After successful write to link table, call audit-log: append record with action, customer_id(s), actor, timestamp, no PII.
3. Store append-only (no update/delete). Retention and archival per policy (e.g. 7 years).

## 8. Business Rules

- **No PII:** Do not store name, email, or raw identifiers in audit log; customer_id and hashed/source_system only as needed.
- **Append-only:** No updates or deletes to audit records.
- **Integrity:** Optional checksum or signing for critical compliance; per policy.
- **Retention:** Define in policy; archive or purge after retention period.

## 9. Configuration Model

- **Retention period:** Days/years; archive to cold storage after.
- **Fields to include:** action, customer_id, actor, timestamp; exclude list for PII.
- **Optional:** Export format and schedule for compliance.

## 10. Data Model

- **audit_log:** id (PK), action (enum), customer_id_primary, customer_id_secondary (for merge), source_system, source_id_hashed (optional), actor, timestamp, metadata (JSON). Append-only table or log stream.

## 11. API Endpoints

- **Internal write:** POST /identity/audit (or in-process writer) with body { action, customer_id, ... }. No public API.
- **Read (admin):** GET /identity/audit?customer_id=...&from=...&to=... → list of records (paginated). Role-protected; no PII in response.

## 12. Events Produced

- None required. Optional: AuditRecordWritten for downstream analytics (anonymized).

## 13. Events Consumed

- **From link-management:** After add/merge/unlink, push audit record. May be synchronous call or async event (audit consumer subscribes to IdentityLinkAdded, etc.).

## 14. Integrations

- **Callers:** link-management (primary), optionally F22 for consent_updated.
- **Consumers:** Admin audit viewer, compliance export, SIEM (optional).

## 15. UI Components

- **Audit log viewer:** Table or list with filters (customer_id, action, date range); no PII displayed. Optional export CSV.

## 16. UI Screens

- **Governance / Identity:** “Identity audit log” screen: filters, paginated table, export button. Role: compliance, support (read-only).

## 17. Permissions & Security

- **Write:** Only identity service (link-management) or F22; no external write.
- **Read:** Only authorized roles (compliance, support, admin); audit access logged.
- **Data:** No PII; customer_id and action only; source_id hashed if stored.

## 18. Error Handling

- **Audit write failure:** Log and alert; optionally block link-management write (fail closed) or allow and retry audit (fail open). Policy must define; recommend retry and alert.
- **Read failure:** 503; retry. Pagination to avoid large result sets.

## 19. Edge Cases

- **High volume:** Batching or async write to avoid blocking link operations; ensure ordering or accept eventual consistency.
- **Duplicate events:** Idempotent by (action, customer_id, timestamp, actor) or accept duplicates and dedupe in export.

## 20. Performance Considerations

- **Write:** Async or batched to avoid adding latency to link-management. Append-only writes are fast.
- **Read:** Index on customer_id, timestamp for admin queries. Partition by date if very high volume.

## 21. Observability

- **Metrics:** Audit records per second; write errors; read latency.
- **Alerts:** Audit write failure; unusual spike in merge or unlink.

## 22. Example Scenarios

- **Link added:** action=link_added, customer_id=c1, source_system=auth, source_id_hashed=abc, actor=auth-service, timestamp=...
- **Merge:** action=customer_merged, customer_id_primary=c1, customer_id_secondary=c2, actor=merge-job, timestamp=...
- **Unlink:** action=link_unlinked, customer_id=c1, source_system=auth, actor=consent-service, metadata={ "use_case": "recommendations" }.

## 23. Implementation Notes

- **Backend:** Audit log writer (library or service); append-only store (table, Kafka, or S3). Optional admin read API.
- **Database:** audit_log table or equivalent; partition by month/year.
- **Jobs:** Optional retention job to archive or purge old records.
- **External APIs:** None.
- **Frontend:** Audit log viewer (admin UI); optional export.

## 24. Testing Requirements

- **Unit:** Record shape; no PII in generated record.
- **Integration:** Link add → audit record present; merge → two customer_ids in record. Read API returns only non-PII.
- **Retention:** Optional test that old records are archived or purged per config.
