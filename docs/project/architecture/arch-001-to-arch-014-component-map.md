# Architecture component map (ARCH-001 to ARCH-014)

This map links each architecture item to implementation-oriented component boundaries used across the platform.

| ARCH ID | Parent feature | Primary components | Primary interfaces |
| --- | --- | --- | --- |
| ARCH-001 | FEAT-001 Analytics and experimentation | Telemetry Collector, Event Validator, Attribution Linker, Metrics Semantic Layer, Experiment Assignment Adapter | `POST /analytics/recommendation-events`, attribution stream topics |
| ARCH-002 | FEAT-003 Catalog and product intelligence | Catalog Ingestion Pipeline, Readiness Evaluator, Eligibility Projection Builder, Inventory Freshness Gate | catalog ingest APIs, readiness snapshots |
| ARCH-003 | FEAT-004 Channel expansion - email and clienteling | Channel Delivery Adapter, Freshness Regeneration Orchestrator, Clienteling Access Gateway | batch recommendation APIs, clienteling retrieval APIs |
| ARCH-004 | FEAT-005 Complete-look orchestration | Outfit Template Resolver, Slot Filler, Governance-Aware Assembly Service, Degraded Outfit Controller | internal assemble contracts, grouped outfit payload |
| ARCH-005 | FEAT-006 Context engine and personalization | Context Normalizer, Precedence Resolver, Personalization Eligibility Evaluator, Context Snapshot Service | context snapshot events, personalization envelope |
| ARCH-006 | FEAT-007 Customer signal ingestion | Signal Intake Gateway, Canonical Envelope Normalizer, Consent and Eligibility Gate, Replay and Deletion Processor | signal ingestion topics/APIs, revocation workflows |
| ARCH-007 | FEAT-009 Ecommerce surface experiences | Storefront Recommendation Hook/BFF, Placement Registry, Typed Module Mapper, Telemetry Fallback Bridge | shared delivery API, browser/server telemetry contracts |
| ARCH-008 | FEAT-010 Explainability and auditability | Trace Writer, Trace Search API, Governance Snapshot Linker, Redaction and Access Audit Layer | trace lookup APIs, audit event streams |
| ARCH-009 | FEAT-011 Identity and style profile | Identity Resolution Service, Style Profile Builder, Activation Envelope Evaluator, Conflict Review Queue | identity mapping APIs, profile activation contracts |
| ARCH-010 | FEAT-012 Merchandising governance and operator controls | Rule and Campaign Service, Approval Policy Engine, Snapshot Publisher, Override Timeline Logger | governance APIs, snapshot propagation events |
| ARCH-011 | FEAT-013 Open decisions | Portfolio Decision Registry Service (artifact-level), Decision Reconciliation Workflow, Dependency Impact Tracker | docs-driven decision register and linkage rules |
| ARCH-012 | FEAT-014 Recommendation decisioning and ranking | Decision Mission Resolver, Candidate Enumerator, Policy Gate, Scoring Service, Deterministic Fallback Ranker | internal `decide()` contracts, ranking trace payloads |
| ARCH-013 | FEAT-015 RTW and CM mode support | Mode Resolver, RTW Delivery Path, CM Validation Gate, Mode-Sliced Telemetry Layer | mode-aware delivery/request contexts |
| ARCH-014 | FEAT-016 Shared contracts and delivery API | Delivery Request Normalizer, Contract Version Router, Recommendation Envelope Packager, Snapshot Retrieval API | `POST /recommendations`, batch/snapshot/version endpoints |

## Notes

- Component names are logical responsibilities, not mandatory service boundaries.
- Runtime deployment boundaries are expected to be finalized during implementation planning using these mappings.
