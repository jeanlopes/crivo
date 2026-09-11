# Axis 1 — Boundaries: where to cut and what it costs

Module boundaries, aggregate boundaries, service boundaries, team boundaries. The four are the same decision at different scales.

---

### AP-018 · A boundary is a coupling decision, and coupling has three dimensions: strength, distance, and volatility
`BCSD`

Maintenance pain is the product of the three. Strong coupling is acceptable only at short distance; at long distance, only contract.

### AP-019 · Never combine high integration strength with high distance
`BCSD` · collides: AP-043

Sharing an internal model between services owned by different teams is the most expensive combination there is — and it is exactly what badly cut microservices produce.

### AP-020 · Classify integration strength before discussing the mechanism
`BCSD`

Intrusive (access to internals), functional (duplicated business rule), model (shared model), contract (published interface only). The choice of protocol does not change the degree of coupling.

### AP-021 · Volatility decides where decoupling is worth paying for
`BCSD`

Decoupling from what never changes is pure cost. Coupling to what changes every week is compound debt.

### AP-022 · Cut by subdomain first, by service second
`LDDD` · collides: AP-029, AP-073

Identify core, supporting, and generic before drawing any technical boundary: they have completely different design, staffing, and build-versus-buy requirements.

### AP-023 · Invest design complexity where there is competitive advantage
`LDDD` · collides: AP-014

Domain model in the core. Transaction script or active record in supporting. Buy the generic — implementing authentication differentiates nobody.

### AP-024 · A bounded context is a model and language boundary, not a table boundary
`LDDD`

Inside it, a term means one thing only. The same noun in two contexts is almost always two distinct concepts that share a name by accident.

### AP-025 · Choose the relationship pattern between contexts explicitly
`LDDD` · collides: AP-076

Partnership, shared kernel, conformist, anti-corruption layer, open-host service, separate ways. A relationship not chosen is conformist by omission — you inherit the other model without having decided to.

### AP-026 · Use an anti-corruption layer whenever the foreign model is legacy, unstable, or third-party
`LDDD`

The cost of translating at the border is fixed; the cost of letting someone else's model leak in grows with time.

### AP-027 · The aggregate is the boundary of transactional consistency
`LDDD` · collides: AP-035

One transaction, one aggregate. If a rule requires updating two aggregates atomically, either the boundary is wrong or the rule is eventual.

### AP-028 · Keep aggregates small and reference others by identity
`LDDD` · collides: AP-007

A large aggregate is lock contention disguised as cohesion.

### AP-029 · Cut teams along cognitive-load fracture lines, and the software will follow
`TT` · collides: AP-022

Conway's law operates either way; the only choice is whether you design the organisation on purpose or let chance design the architecture.

### AP-030 · A team's cognitive load is the real size limit of its domain
`TT`

If the team cannot hold the mental model of what it owns, the boundary is too large — no matter how many people you add.

### AP-031 · Treat the team boundary as an API
`TT`

Code, versioning, documentation, practices, and interaction mode are part of the team's contract, not internal details.

---

## Mechanisms that touch this axis

| Principle | Layer | Coverage |
|---|---|---|
| AP-018 – AP-021 | `structure` | Partial — the dependency graph shows distance and the arch rules show declared strength; volatility comes from churn in `scoring`. |
| AP-024, AP-025, AP-026 | `structure` | Only if the project encodes its contexts as architecture rules. Unencoded contexts are invisible. |
| AP-027, AP-028 | `structure`, `e2e` | Project-defined arch rule for the one-aggregate-per-transaction constraint; `e2e` with real dependencies exposes violations under load. |

Team boundaries (AP-029 – AP-031) have no mechanism inside a repository. They reach the gauntlet only as the ADR's ownership section (P10) and as `CODEOWNERS` (P06).
