---
id: ADR-0000
title: <one line, in the present tense, stating what is decided>
status: proposed
date: <yyyy-mm-dd>
deciders: []
supersedes:
superseded_by:
modules: []
rules: []
invariants: []
axes:
  0-complexity:   { respects: [], violates: [] }
  1-boundaries:   { respects: [], violates: [] }
  2-state:        { respects: [], violates: [] }
  3-failure:      { respects: [], violates: [] }
  4-evolution:    { respects: [], violates: [] }
  5-teams:        { respects: [], violates: [] }
  6-ai:           { respects: [], violates: [] }
violations: []
---

# ADR-0000 — <title>

## Context

The forces in play, including the ones that lost. What is true today that makes this decision necessary now rather than later.

## Decision

One paragraph a new agent can act on without reading the rest of this file.

## Alternatives

At least one, required (AP-006). For each: what it was, and the specific reason it lost. "Worse" is not a reason.

### <alternative> — rejected
<why>

## Axis traversal

One subsection per section of `principles/`. Name the principles that bore on the decision, not every principle in the axis. `not-applicable` is a valid verdict and takes one line of justification.

### 0 · Complexity
Respects: `AP-nnn` — <how>
Violates: —

### 1 · Boundaries
### 2 · State
### 3 · Failure
### 4 · Evolution
### 5 · Teams and operation
### 6 · AI

## Violations

The most valuable part of this record. Each entry mirrors the `violations` frontmatter.

| Principle | Reason | Revisit |
|---|---|---|
| `AP-nnn` | <why this system is the exception> | <ISO date, #issue, or named condition> |

A violation with no revisit trigger is design debt with no creditor. The `architecture` layer rejects it.

## Consequences

What becomes harder. What becomes possible. What the next person will find surprising.

## Operability

Required for any change that adds a process or an integration point (AP-079 – AP-081).

- Health signal:
- Log identifiers carried through this path:
- Shutdown behaviour:
- Degradation when the dependency is down — link the Gherkin scenario (AP-062):
