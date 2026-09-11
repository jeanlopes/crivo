# Decisions registry

Architecture decision records. The place where the reasoning behind a boundary lives, so that code comments can be one line and an ID (P07) and so that the reasoning survives the people who had it.

Normative text: [`policies/P10-architecture-decisions.md`](../policies/P10-architecture-decisions.md). The principles an ADR traverses: [`principles/`](../principles/README.md).

## Entry format — `decisions/ADR-nnnn-slug.md`

```yaml
---
id: ADR-0007
title: Itinerary legs stay in one aggregate
status: proposed | accepted | superseded
date: 2026-09-11
deciders: [<human>]
supersedes:
superseded_by:
modules:                  # code this decision governs; checked against docs: headers (P08)
  - src/domain/itinerary.py
rules: [RULE-017]         # registry entries this decision produced
invariants: [INV-012]
axes:                     # verdict per section of principles/
  0-complexity:   { respects: [AP-007], violates: [] }
  1-boundaries:   { respects: [AP-027, AP-028], violates: [AP-007] }
  2-state:        { respects: [AP-032], violates: [] }
  3-failure:      { respects: [AP-049], violates: [] }
  4-evolution:    { respects: [AP-068], violates: [] }
  5-teams:        { respects: [AP-030], violates: [] }
  6-ai:           { not-applicable: "no model in this path" }
violations:
  - principle: AP-007
    reason: "Depth loses to lock contention here: the aggregate is written on every booking."
    revisit: "when write throughput on legs exceeds 200/s"
---
```

Body sections, all mandatory: `Context`, `Decision`, `Alternatives`, `Axis traversal`, `Consequences`, `Operability`. See `ADR-TEMPLATE.md`.

## Checks (`architecture` layer)

- Every `ADR-` referenced from code, `rules/`, or `docs/` exists here.
- Every `AP-` cited in `axes` or `violations` resolves in `principles/`.
- Every section of `axes` is present; `not-applicable` carries a justification.
- `Alternatives` is non-empty (AP-006).
- Every `violations` entry has `reason` and a valid `revisit`.
- A `revisit` trigger that has passed while `status: accepted` is a gate failure.
- `status: superseded` requires `superseded_by`; the supersession chain is acyclic.
- ADR coverage = modules under `docs.required_dirs` with a resolving `adr:` header / total (navigability gradient).

## Numbering

Four digits, allocated in order, never reused. A rejected proposal keeps its number and stays in the directory with `status: superseded` and a `superseded_by` pointing at what was decided instead — the rejected branch is the part a future reader needs most.

## The ledger

The violation ledger is derived data, rebuilt from every accepted ADR on each run and written to `.crivo/results/architecture.json`. It is never hand-maintained: a hand-maintained ledger diverges from the ADRs and then the ADRs stop being the source of truth (AP-032).

## Ownership

Protected path (P06). The agent proposes at `proposals/decisions/ADR-nnnn.proposed`; a human moves it in. The approval is the point — an ADR the agent can accept on its own records nothing that anyone agreed to.
