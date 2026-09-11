# P10 — Architecture decisions

**Status:** normative · **Enforced by:** `architecture` layer; `principles/` and `decisions/` (protected paths, P06)

## Statement

An architecturally significant change MUST carry an accepted ADR in `decisions/`. The ADR MUST traverse all seven sections of [`principles/`](../principles/README.md) — the five axes of decision, bracketed by the invariant layer (axis 0) and the premise-breaker (axis 6) — and record, for each one, the principles the decision respects and the principles it **consciously violates, with the reason and a revisit trigger**.

The gate is on the **record**, not on the decision. No layer decides whether an architecture is good. The layers decide whether the reasoning that produced it exists, is complete, cites principles that resolve, and comes back when it said it would.

## The principles are not gates

Most of the ninety principles in `principles/` are not mechanically decidable. Stating them as MUST would make this repository's own constitution false: *a rule with no mechanism goes to `rationale/`, not `policies/`* (CONTRIBUTING).

So the corpus is normative in a narrower sense that is worth being precise about:

- A principle MUST be **considered** on a significant change. Consideration is evidenced by the ADR's axis traversal, which is checkable.
- A principle MAY be violated. Violation without a recorded reason MUST NOT pass.
- A principle MUST NOT be cited to reject a change on its own. `AP-008` is not an argument; an ADR that weighs `AP-008` against `AP-052` for this system is.

The three principles that do become gates here do so by being about the record itself:

| Principle | How it becomes checkable |
|---|---|
| **AP-006** Design it twice | The ADR MUST record at least one rejected alternative with the reason for rejection. An empty alternatives section fails. |
| **AP-062** Write the degradation mode into the spec | A change that adds an integration point MUST carry a degradation scenario in `spec/features/`. Missing scenario fails. |
| **AP-067** Expand and contract | A migration ADR MUST carry the contraction step as a ledger entry with a revisit trigger. A contraction that never arrives becomes visible instead of permanent. |

## Architectural significance

A change is significant when the `architecture` layer observes any trigger below. Triggers are computed from the diff and from the `structure` layer's dependency graph, so the agent cannot decide it is exempt.

1. A new dependency edge crossing a declared context or layer boundary.
2. A new external integration point: remote call target, queue, scheduler, datastore.
3. A change to a published contract: API schema, event schema, or the schema of a shared store.
4. A change to the system of record for an entity, or a new persistent store.
5. A change to a transactional-consistency boundary — aggregate membership, transaction scope.
6. Introducing, removing, or re-routing a non-deterministic component (P09).
7. A change to a resilience policy: timeout, retry, circuit breaker, bulkhead, back pressure, load shedding.
8. Creation or deletion of a top-level module or package.
9. A change to a module whose blast radius exceeds `architecture.blast_radius_trigger` (default 10 dependents).
10. A new third-party runtime dependency under a `docs.required_dirs` path.

A project MAY add triggers. A project MUST NOT remove triggers 1–7 — `layers.yaml` is a protected path (P06), so removal requires a human.

## What an ADR MUST contain

Format and frontmatter: [`decisions/REGISTRY.md`](../decisions/REGISTRY.md). Template: [`decisions/ADR-TEMPLATE.md`](../decisions/ADR-TEMPLATE.md).

- **Context** — the forces, including the ones that lost.
- **Decision** — one paragraph a new agent can act on.
- **Alternatives** — at least one, rejected, with the reason (AP-006).
- **Axis traversal** — all seven sections, each with a verdict. `not-applicable` is a valid verdict and MUST carry one line of justification; an axis left blank is not.
- **Violations** — each with `principle`, `reason`, `revisit`.
- **Consequences** — what becomes harder, not only what becomes possible.
- **Operability** — health signal, log identifiers, shutdown behaviour, for any change that adds a process or an integration point (AP-079 – AP-081).

## The violation ledger

Every `violations` entry across accepted ADRs is one row of the ledger. The ledger is **derived data** and MUST be rebuildable from `decisions/` alone — crivo applying AP-032 and AP-071 to itself. The `architecture` layer emits it to `.crivo/results/architecture.json`; EVIDENCE renders it.

`revisit` MUST be one of: an ISO date, an issue reference, or a named condition (`"when the itinerary service moves to its own store"`). Prose with no trigger is not a revisit.

**Ratchet.** A violation whose `revisit` date has passed, or whose named condition the ADR marks as met, while the ADR is still `accepted`, is a gate failure. This is the P09 ratchet applied to design debt: the failure mode of recorded violations is not that they are wrong, it is that nobody ever comes back.

## Deterministic gates (`architecture` layer)

- Significance trigger fired with no ADR in the change.
- Axis traversal incomplete: an axis with no verdict, or `not-applicable` with no justification.
- Empty alternatives section (AP-006).
- A violation with no `reason`, or with no valid `revisit`.
- A violation whose `revisit` trigger has passed while the ADR is `accepted`.
- Dead reference: an `AP-nnn` that does not resolve in `principles/`, or an `ADR-nnnn` referenced from code, `rules/`, or `docs/` that does not resolve in `decisions/`.
- An ADR marked `superseded` with no `superseded_by`, or a cycle in the supersession chain.
- A contract change removing or renumbering a field identifier with no superseding ADR (AP-064, AP-068).
- An integration point added with no degradation scenario in `spec/features/` (AP-062).

Checks that need no repository-specific knowledge run in `principles/check.sh`.

## Deterministic gradients (navigability index N)

- **ADR coverage** — fraction of modules under `docs.required_dirs` whose `adr:` header resolves to an accepted ADR. Weight 0.15 in `scoring/weights.yaml`.

A missing ADR does not make code incorrect; it makes the next agent more likely to make it incorrect. That places it in N, alongside P07 and P08, for the same reason (P04). The P10 **gates** zero C, like every other gate.

## Principles that already have a mechanism

The corpus is not uniformly advisory. These principles reach the gauntlet without passing through an ADR:

| Principle | Layer |
|---|---|
| AP-007, AP-008, AP-009, AP-012 | `structure` (partial — see axis file) |
| AP-015, AP-016 | `comments` (P07) |
| AP-018 – AP-021, AP-024 – AP-028 | `structure` arch rules, where the project encodes its contexts |
| AP-039 | `property`, via `INV-nnn` |
| AP-061 | `e2e` percentile reporting |
| AP-062 | `unit` + `spec/`, via `spec_to_test_mapping` |
| AP-063, AP-064, AP-068 | `architecture` contract-compatibility check |
| AP-083, AP-084, AP-086 – AP-089 | `llm-eval` (P09) |

New lint rules this policy requires, declared in `layers.yaml: lint.rules`:

| Rule | Principle |
|---|---|
| `no-unbounded-call` — remote call with no timeout and no enclosing deadline | AP-049 |
| `no-unbounded-resource` — unlimited query, uncapped queue, cache without TTL | AP-054 |
| `retry-requires-jitter` — retry policy with fixed or purely exponential delay | AP-060 |
| `no-walltime-ordering` — wall-clock comparison used to order cross-process events | AP-037 |

Each is syntactic and each has a known blind spot; they are listed in the axis files next to the principle they partially cover. A project without an adapter for one of these rules MUST record that in its ADR rather than report the principle as covered.

## Cadence

| When | Scope |
|---|---|
| Every PR | Significance triggers, ADR completeness, dead references, expired revisits |
| Quarterly | `architecture_boundary_review` — re-evaluate subdomain categories and context boundaries (AP-070). The outcome is an ADR, including the ADR that says nothing changed. |

## Ownership

`principles/` and `decisions/` are protected paths (P06). The agent reads both; it writes to neither.

The agent proposes an ADR at `proposals/decisions/ADR-nnnn.proposed` and a principle at `proposals/principles/AP-nnn.proposed`. A human moves them in. An ADR drafted by the agent and approved by a human is the intended path — the drafting is cheap, the approval is the point, and it is one more thing the human reads instead of code (P01).

## Limits

- Axis traversal proves deliberation happened, not that it was any good. An agent can fill seven sections with plausible text. The `adversary` layer (P03) receives the ADR along with the diff for exactly this reason, and its findings on the ADR are treated like any other finding.
- The significance triggers are syntactic. A change that alters an architecture without touching any of them exists, and will be found in `escapes.csv` with category `spec-gap`.
- A recorded violation is not an absolved violation. The ledger measures how much design debt was taken on knowingly; nothing measures whether it was worth taking.
