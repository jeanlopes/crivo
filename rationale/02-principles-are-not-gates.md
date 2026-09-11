# Principles are not gates

Why the ninety principles in `principles/` are a registry and not a policy, and why P10 gates the record instead of the decision.

## The temptation

crivo's whole design principle is that policy in a prompt is a suggestion and policy in CI is a law (`00-origin.md`). Given a corpus of ninety architecture principles, the obvious move is to make them law: write them as MUST, put them in `policies/`, and let the adversary layer enforce them.

That move would break the repository. CONTRIBUTING says a rule with no mechanism goes to `rationale/`, and there is no mechanism for "make modules deep". There is no threshold for depth, no counter for information leakage, no linter for temporal decomposition. A MUST with no mechanism is the exact thing crivo exists to refuse — a constraint that lives in prose and is honoured when convenient.

The second reason is worse than the first. A principle applied without its argument is a reflex, and reflexes are what a corpus like this most easily produces in an agent. "Modules must be deep" enforced mechanically gives you one 400-line module where five would have been right, and it gives it to you with a green pipeline.

## What is actually checkable

Not the decision. The deliberation.

An agent cannot be gated on choosing well. It can be gated on having weighed the thing it was supposed to weigh, on citing principles that exist, on naming which ones it broke, and on saying when someone should look again. All four are syntactic. None of them is a judgement about architecture.

This is a narrower claim than it looks, and the honesty matters: a filled-in axis traversal proves that seven sections contain text. An agent can produce plausible text for all seven. What the gate buys is not correctness — it is that the *absence* of deliberation becomes visible, and that the violations become a list someone can read. The `adversary` layer sees the ADR alongside the diff for exactly the part the gate cannot reach.

## The collision is the point

The corpus contradicts itself on purpose, and the contradictions are catalogued rather than resolved (`principles/collisions.md`). A reader who wants a checklist finds this frustrating; it is the most useful property the corpus has.

"Pull complexity downward" and "design for the operator" are both true, and in a given module one of them has to lose. A corpus that resolved the collision in advance would be deciding, in a repository it has never seen, something that depends entirely on which of the two costs is larger there. What the corpus can do is guarantee that whoever decides knows they are on a known fault line, and writes down which side they picked.

A rule that never conflicts with another rule is almost always empty. The ones in this corpus that look conflict-free — AP-017, AP-055, AP-066 — are either measurements rather than trade-offs, or they are conflict-free only because nobody has written the principle they collide with yet.

## Why the violation is the valuable part

An ADR that lists what it respects is a formality. An ADR that lists what it broke, why, and under what condition the reason expires is the only artifact that lets a future reader distinguish between a decision that was wrong and a decision that stopped being right.

The failure mode of recorded violations is not that they are wrong. It is that nobody comes back. Which is why the `revisit` trigger is mandatory, why an expired trigger is a gate failure, and why the contraction step of an expand-and-contract migration is a ledger entry rather than a line in a plan. Design debt with no creditor is indistinguishable from design.

## What the distillation lost

Each of the ninety entries is one or two sentences standing in for a chapter. The reduction is deliberate — an agent cannot be handed eight books — but it should be named: the entry is a pointer, not the content, in exactly the sense P07 means it. `APOSD`'s argument for deep modules runs forty pages and most of it is about what happens when you get it wrong. AP-007 carries none of that.

This makes the corpus a reasonable checklist and an unreasonable authority. It is also why the source sigil on every entry is mandatory and why the registry says, in the first screen, that it is not a substitute for reading the source. Somebody on the team has to have read the forty pages. The corpus tells you which forty.

## The relationship to P01

P01 says the human stops reading code and reads the SPEC and the EVIDENCE instead. P10 adds a third thing to that list, and it is the one that is hardest to automate: the ADR.

That is a cost, and it belongs in the open. The number of ADRs a system needs is bounded by its significance triggers, not by its commit count, so the cost is bounded too — but on a change that fires a trigger, the human is reading prose the agent wrote about a decision the agent proposes to make. That is the highest-leverage prose in the repository and it deserves the same scrutiny the comment judge's PRs get (P07). Reviewing a decision is reviewing prose. It is still much cheaper than reviewing the diff.
