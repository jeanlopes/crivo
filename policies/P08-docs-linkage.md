# P08 — Docs linkage

**Status:** normative · **Enforced by:** `docs` layer + doc judge (scheduled)

## Statement

Documentation and code MUST be linked bidirectionally so that staleness is detectable.

## Code side — file header

```rust
//! docs: docs/domain/itinerary.md#conflicts
//! rules: RULE-017, RULE-023
//! adr: ADR-0007
```

```python
"""
docs: docs/domain/itinerary.md#conflicts
rules: RULE-017, RULE-023
adr: ADR-0007
"""
```

## Doc side — frontmatter

```yaml
---
code: [src/domain/itinerary.rs, src/api/legs.rs]
rules: [RULE-017, RULE-023]
---
```

## When a header is required

A `docs:` header is **MUST** for files in designated directories (`domain/`, `core/`, or as configured in `layers.yaml: docs.required_dirs`) **or** for files exceeding the `structure` layer's complexity/size thresholds by 50 %. Elsewhere it is MAY. This scales with project complexity instead of demanding a doc for `utils/slug.ts`.

## Deterministic gates (`docs` layer)

- Unresolved link on either side.
- Required header missing.
- Doc claim judged `contradicted`.

## Deterministic gradients (navigability index N)

- Orphan docs: docs no code links to (candidates for deletion).
- Freshness: code file with churn in ≥ N commits while linked doc unchanged → `doc-stale-suspect`, routed to the judge.
- Coverage: fraction of required files with resolving headers.

## Doc judge

Same shape as the comment judge (P07). Receives the doc and its linked code; returns each claim as `verified` / `contradicted` / `unverifiable` with location. `contradicted` is a gate. Proposes patches via PR.

## Standard

The rules registry, ADRs and linked docs are what the human reads instead of code (P01). Their quality bar is therefore the highest in the repository, not the lowest.
