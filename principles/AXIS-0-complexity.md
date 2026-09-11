# Axis 0 — Invariant layer: complexity

**Half-life: decades.** These principles do not depend on platform, language, or era. When a decision on any other axis contradicts one of them, the burden of proof is on the decision.

---

### AP-001 · Treat complexity as the central obstacle, not as a symptom of something else
`APOSD`

Everything that makes a system hard to understand or modify is complexity. There are only two responses available: eliminate it, or encapsulate it.

### AP-002 · Diagnose complexity by three symptoms: change amplification, cognitive load, and unknown-unknowns
`APOSD`

The third is the worst: it is when the developer has no way of knowing what they need to know.

### AP-003 · Attack the two root causes: dependencies and obscurity
`APOSD`

A dependency is when one change forces another. Obscurity is when the information required is not visible.

### AP-004 · Complexity is incremental, and that is how it wins
`APOSD` · collides: AP-063, AP-065

No single decision ruins a system; their sum does. Therefore there is no such thing as "just this once".

### AP-005 · Program strategically, not tactically
`APOSD` · collides: AP-072

The goal of the work is not to make it work, it is to produce a design that keeps allowing work. Reserve a fixed, constant percentage of effort for structural investment instead of episodic refactoring campaigns.

### AP-006 · Design it twice
`APOSD`

Before implementing, produce a second design radically different from the first and compare them. The cost is one hour and the return pays for itself within the module's first year.

### AP-007 · Make modules deep: small interface, large functionality
`APOSD` · collides: AP-014, AP-028

A module is worth the ratio between what it resolves and what it forces its callers to know.

### AP-008 · Distrust proliferating small classes (classitis)
`APOSD` · collides: AP-052

Many shallow modules add up to more interface than they hide implementation; the sum of the parts becomes more complex than the whole.

### AP-009 · Pass-through methods are a design defect, not a style
`APOSD`

A layer that only forwards has no abstraction of its own. Different layers must have different abstractions.

### AP-010 · Pull complexity downward
`APOSD` · collides: AP-080, AP-090

Between complicating a module's implementation and complicating its interface, complicate the implementation: the interface is paid for by every caller, the implementation by one author.

### AP-011 · Define errors out of existence wherever possible
`APOSD` · collides: AP-049, AP-050, AP-081

The best way to handle an exception is to redefine the semantics so that the condition stops being exceptional. Every propagated exception is complexity multiplied by every call path.

### AP-012 · Allow no information leakage between modules
`APOSD` · collides: AP-086

If two modules must change together because they share a piece of design knowledge, that knowledge belongs to exactly one of them.

### AP-013 · Avoid temporal decomposition
`APOSD`

Organising modules by the order in which operations happen scatters the same knowledge across several steps. Organise by knowledge, not by chronology.

### AP-014 · Make modules somewhat more generic than the immediate need requires
`APOSD` · collides: AP-007, AP-023

A generic interface with a specific use tends to be deeper and simpler than a specialised interface. *Somewhat* — speculative generalisation is the opposite error.

### AP-015 · Comments are part of the design, and what they describe is what the code cannot say
`APOSD`

A comment that repeats the code is noise; a comment that documents the abstraction is the abstraction. Write them first, as a design tool.

### AP-016 · Consistency is unknown-unknown reduction
`APOSD` · collides: AP-069, AP-072, AP-077

Conventions let a reader infer the behaviour of code they have never read. A mediocre convention applied uniformly is worth more than the best convention applied halfway.

### AP-017 · Optimise for the critical path, measured — never by intuition
`APOSD`

Design the critical path so that it does the minimum necessary, and optimise only what the profiler points at.

---

## Mechanisms that touch this axis

| Principle | Layer | Coverage |
|---|---|---|
| AP-007, AP-008, AP-009 | `structure` | Partial — module and function size, distance from the main sequence. Depth is not measured; interface-to-functionality ratio has no metric here. |
| AP-012 | `structure` | Partial — architecture rules catch declared dependencies, not shared design knowledge. |
| AP-015 | `comments` (P07) | Full for the deterministic part; the judge covers truth. |
| AP-016 | `comments`, `lint` | Partial — conventions that a linter can express. |

Everything else on this axis reaches the gauntlet only through the ADR (P10).
