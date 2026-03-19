# UI Standards

## Purpose

Define shared expectations for presenting recommendation outputs across customer-facing and internal interfaces.

## UI consistency principles

- recommendation modules should emphasize complete-look usefulness, not only item similarity
- outfit and bundle presentations should make cross-category relationships understandable at a glance
- UI language should be consistent across surfaces for recommendation type and item role
- recommendations should feel integrated into the shopping journey rather than bolted-on add-ons

## Presentation expectations

Each recommendation module should make it clear:

- what type of recommendation is being shown
- which item or occasion the recommendation is responding to
- which products belong together when an outfit or bundle is displayed
- whether an item is unavailable, unavailable in-region, or otherwise not currently actionable

Where helpful, surfaces may show lightweight recommendation context such as occasion or seasonal framing, but should avoid exposing sensitive personalization reasoning.

## State and feedback patterns

Every recommendation surface should define and consistently handle:

- loading state
- empty state
- fallback state when personalization or context is unavailable
- error or degraded state
- unavailable or unsellable item state

Users should receive a coherent experience even when recommendation quality inputs are partial.

## Accessibility expectations

- recommendation modules must meet baseline accessibility expectations for keyboard use, semantics, focus order, and readable content structure
- outfit or bundle groupings should be understandable without relying only on color or visual position
- dynamic updates to recommendation modules should be implemented accessibly

## Shared component expectations

- reusable recommendation card and outfit grouping patterns should be preferred across web surfaces
- clienteling and admin interfaces may vary in layout, but should keep terminology and core interaction patterns consistent
- design-system integration should be favored over bespoke per-surface implementations when possible

## Analytics and telemetry expectations

UI implementations must emit consistent telemetry for:

- module impression
- item impression where needed
- click or selection
- add-to-cart
- save or dismiss when applicable
- downstream conversion linkage where supported

Telemetry should carry recommendation set identifiers and relevant surface metadata.

## Trust and governance expectations

- customer-facing modules should not imply certainty or personalization depth that the platform cannot support
- internal users should have enough context to understand when output is curated, rule-based, or AI-ranked if that distinction affects their workflow
- suppression, exclusion, and unavailable-item handling must be respected at render time
