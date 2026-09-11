# principles — architecture principles registry

Normative text is in [`policies/P10-architecture-decisions.md`](../policies/P10-architecture-decisions.md). This directory is the corpus that policy points at.

Ninety principles distilled from eight works, organised by the five axes of decision — bracketed by an invariant layer that holds regardless of axis, and by the premise-breaker that invalidates parts of all five. Every principle has a stable ID (`AP-nnn`) so that ADRs, rules registry entries, and code comments can cite it in one line (P07). Compiled 2026-09-11.

## How to read this

Each entry is a rule in imperative form, followed by the reason that sustains it and the source. The rules are **rewritten, not extracted**: the idea of the work in operational form, not its text.

A distilled rule loses the argument that justifies it — which is exactly what allows it to be applied with judgement instead of by reflex. Use this as a decision checklist and as the starting point of an ADR, not as a substitute for reading the source.

## The principles are not gates

No layer of the gauntlet checks whether a change respects `AP-007`. Most of these principles are not mechanically decidable, and a repository whose constitution says *"a rule with no mechanism goes to `rationale/`, not `policies/`"* (CONTRIBUTING) would be lying to itself if it pretended otherwise.

What is mechanised is the **record**: P10 gates the ADR, not the decision. The traversal of the axes, the citation of the principles a decision respects, and above all the citation of the ones it **consciously violates, with the reason** — those are checkable, and the `architecture` layer checks them. See [`rationale/02-principles-are-not-gates.md`](../rationale/02-principles-are-not-gates.md).

A subset does have an existing mechanism. P10 lists which principle each layer already covers.

## The rules collide with each other on purpose

"Pull complexity downward" (AP-010) collides with "design for the operator" (AP-080). "Invest design complexity in the core" (AP-023) collides with "make modules somewhat more generic" (AP-014). The corpus does not resolve the collision — the ADR resolves it, in the concrete context.

A rule that never conflicts with another is probably empty. Known collisions are catalogued in [`collisions.md`](collisions.md); the inline `collides:` marker on an entry points there.

## Axes

| File | Axis | Range | Question it answers |
|---|---|---|---|
| [AXIS-0-complexity.md](AXIS-0-complexity.md) | 0 · Invariant layer | AP-001 – AP-017 | What makes any system hard to change |
| [AXIS-1-boundaries.md](AXIS-1-boundaries.md) | 1 · Boundaries | AP-018 – AP-031 | Where to cut and what the cut costs |
| [AXIS-2-state.md](AXIS-2-state.md) | 2 · State | AP-032 – AP-047 | Where the truth lives and under which consistency |
| [AXIS-3-failure.md](AXIS-3-failure.md) | 3 · Failure | AP-048 – AP-062 | What breaks and how it degrades |
| [AXIS-4-evolution.md](AXIS-4-evolution.md) | 4 · Evolution | AP-063 – AP-072 | How the system changes without stopping |
| [AXIS-5-teams.md](AXIS-5-teams.md) | 5 · Teams and operation | AP-073 – AP-082 | Who operates it and who decides |
| [AXIS-6-ai.md](AXIS-6-ai.md) | 6 · AI as premise-breaker | AP-083 – AP-090 | Which assumptions of axes 0–5 stop holding |

Axis 6 is not one more axis. It is the context that breaks premises of the earlier ones rather than only changing their constants.

## Entry format

```
### AP-007 · Make modules deep: small interface, large functionality
`APOSD` · collides: AP-014, AP-028

A module is worth the ratio between what it resolves and what it forces its callers to know.
```

The source sigil is mandatory. The `collides:` marker is present only where a collision is catalogued.

## Sources

| Sigil | Work |
|---|---|
| `APOSD` | Ousterhout — *A Philosophy of Software Design* |
| `DDIA` | Kleppmann — *Designing Data-Intensive Applications* (2nd ed.) |
| `LDDD` | Khononov — *Learning Domain-Driven Design* |
| `BCSD` | Khononov — *Balancing Coupling in Software Design* |
| `RI` | Nygard — *Release It!* |
| `PoDS` | Joshi — *Patterns of Distributed Systems* |
| `TT` | Skelton & Pais — *Team Topologies* |
| `AIE` | Huyen — *AI Engineering* |

## Checks

`principles/check.sh` runs the deterministic part: ID uniqueness and contiguity, mandatory source sigil, resolvable `collides:` targets, and `AP-` references from anywhere in the repository that do not resolve here. The `architecture` layer runs it (`gauntlet/layers.yaml`).

## Ownership

Protected path (P06). The agent reads this directory; it does not write to it. New principles arrive by `proposals/principles/AP-nnn.proposed`, and a human moves them in — the corpus is the standard against which agent work is judged, so an agent that could edit it could lower it.
