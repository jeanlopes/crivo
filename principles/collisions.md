# Known collisions

The principles contradict each other on purpose. A corpus in which every rule agrees with every other rule is a corpus of empty rules.

This file does not resolve the collisions. It names them, so that an ADR that lands on one of these pairs is recognisably landing on a known problem rather than discovering it alone. The resolution belongs in the ADR, in the concrete context — and the reason for the side you chose is the part that will matter in three years.

The catalogue is not exhaustive. A collision you find that is not here is a proposal to add (`proposals/principles/`).

---

## Depth against decomposition

| | |
|---|---|
| **AP-007** Make modules deep | **AP-028** Keep aggregates small |
| **AP-007** Make modules deep | **AP-014** Make modules somewhat generic |
| **AP-008** Distrust proliferating small classes | **AP-052** Compartmentalise with bulkheads |

Depth argues for fewer, larger units. Aggregate size, bulkheads, and generic interfaces each argue for more, smaller ones, for reasons that have nothing to do with each other: lock contention, blast radius, and reuse. The usual resolution is that they operate at different scales — but the usual resolution is a claim to be defended, not a default.

## Hiding against showing

| | |
|---|---|
| **AP-010** Pull complexity downward | **AP-080** Design for the operator |
| **AP-010** Pull complexity downward | **AP-090** Decide latency and cost per user path |
| **AP-011** Define errors out of existence | **AP-049** Timeout on everything |
| **AP-011** Define errors out of existence | **AP-050** Fail fast |
| **AP-011** Define errors out of existence | **AP-081** Write the log for the on-call engineer |

The strongest collision in the corpus. Pulling complexity down means the caller does not see it; designing for the operator means someone has to. An error defined out of existence is also a signal that no longer reaches anyone.

The distinction that usually resolves it: hide the *mechanism*, expose the *cost and the state*. An interface that hides a remote call's retry policy is deep; one that hides the fact that it is remote at all is a fallacy of distributed computing with a nice name.

## Investment against generality

| | |
|---|---|
| **AP-014** Make modules somewhat generic | **AP-023** Invest design complexity in the core |

Generality is an investment paid everywhere; AP-023 says to concentrate investment where there is competitive advantage. In supporting and generic subdomains, "somewhat generic" is the speculative generalisation AP-014 itself warns about.

## Consistency against change

| | |
|---|---|
| **AP-016** Consistency is unknown-unknown reduction | **AP-069** Refactor when domain understanding changes |
| **AP-016** Consistency is unknown-unknown reduction | **AP-072** Strangle, do not rewrite |
| **AP-016** Consistency is unknown-unknown reduction | **AP-077** A platform can be refused |

Every one of the three introduces a second convention that coexists with the first — a new model, a strangled frontier, a platform a team opted out of. Consistency says a mediocre convention applied uniformly beats the best one applied halfway; the other three each produce exactly a convention applied halfway, and are right anyway.

What makes the difference is whether the second convention has a declared end date. A strangler with no contraction step (AP-067) is the collision resolved in the worst direction.

## Strategy against incrementality

| | |
|---|---|
| **AP-005** Program strategically | **AP-072** Strangle, do not rewrite |
| **AP-004** Complexity is incremental | **AP-063** Compatibility in two directions |
| **AP-004** Complexity is incremental | **AP-065** Separate deployment from release |

Compatibility shims and feature flags are, individually, always justified, and in aggregate are exactly the accumulation AP-004 describes. "There is no such thing as just this once" collides with two mechanisms whose entire value is that they let you do it just this once, safely.

The contraction step (AP-067) and flag expiry are the same answer to both.

## Consistency of state against boundaries

| | |
|---|---|
| **AP-027** One transaction, one aggregate | **AP-035** Linearizability where there is no substitute |
| **AP-032** Declare the system of record | **AP-046** Event log as the source of truth |
| **AP-019** Never combine high strength with high distance | **AP-043** Concentrate decisions in a consistent core |

AP-043 asks for a small core shared by everyone; AP-019 says that a model shared across a team boundary is the most expensive coupling there is. The consistent core is the exception, and it is an exception precisely because its contract is tiny and almost never changes — which is AP-021 doing the arbitration.

## Resilience against simplicity

| | |
|---|---|
| **AP-052** Compartmentalise with bulkheads | **AP-058** Distrust unbalanced capacities |
| **AP-061** Measure latency at a high percentile | **AP-087** Guardrails have their own latency |

Bulkheads deliberately strand capacity: a pool reserved for one traffic class is idle while another class queues. That is unbalanced capacity bought on purpose, which is why AP-058 cannot be applied mechanically.

## Organisation against domain

| | |
|---|---|
| **AP-022** Cut by subdomain first | **AP-029** Cut teams along cognitive-load lines |
| **AP-022** Cut by subdomain first | **AP-073** Architecture is limited by team structure |
| **AP-025** Choose the context relationship pattern | **AP-076** Declare the interaction mode |

The domain says where the boundary belongs; Conway says where it will end up. The inverse manoeuvre (AP-073) is the claim that you can move the second to meet the first, and it is true over quarters, not sprints. An ADR that draws a boundary no team can own has decided nothing.

Note also that AP-025 and AP-076 are the same decision named twice, from two books — one from the model's side, one from the team's side. They collide when the answers differ: a partnership between contexts whose teams interact as X-as-a-service is a contradiction that will be resolved by whichever side is cheaper, not by whichever is right.

## The AI premise-breaks

| | |
|---|---|
| **AP-063** Compatibility in two directions | **AP-083** The model is versioned by a third party |
| **AP-012** No information leakage between modules | **AP-086** RAG is context construction |
| **AP-010** Pull complexity downward | **AP-090** Latency and cost per user path |

AP-063 assumes you control when the new version appears. Under AP-083 you do not, so forward compatibility stops being a rollout property and becomes a continuous property — which is what the P09 ratchet exists to detect.

AP-086 is information leakage as a design goal: a retrieval layer that constructs context is, by construction, holding knowledge about the consumer's domain. The usual resolution is that the leaked thing is the *query*, not the *model* — and that resolution needs to be written down, because the drift from one to the other is invisible.
