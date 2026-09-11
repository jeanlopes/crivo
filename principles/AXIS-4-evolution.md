# Axis 4 — Evolution: how the system changes without stopping

Change, versioning, schema, deployment.

---

### AP-063 · Design for compatibility in two directions: backward and forward
`DDIA` · collides: AP-004, AP-083

During any rollout, old and new versions run simultaneously. New code reads old data; old code has to tolerate new data without breaking.

### AP-064 · Schema evolution is an architecture decision, not a migration task
`DDIA`

Choose a format with explicit evolution, and never remove or reuse field identifiers.

### AP-065 · Separate deployment from release
`RI` · collides: AP-004

Code in production switched off by a flag makes the decision to expose a feature reversible in seconds rather than in a build cycle.

### AP-066 · Deployment has to be routine and boring
`RI`

If a deployment is an event, frequency drops, batch size grows, and risk per deployment grows with it — the opposite of the intent.

### AP-067 · Expand and contract: add the new, migrate, and only then remove the old
`DDIA` `RI`

Never in one step. The contraction step is frequently forgotten and becomes permanent debt.

### AP-068 · Version the contract, not the implementation
`RI` `BCSD`

Consumers depend on the published contract; anything else they can observe becomes a de facto contract, whether you want it to or not.

### AP-069 · Refactor the design when the understanding of the domain changes, not when the code annoys you
`LDDD` · collides: AP-016

In DDD, model change follows language change — when the business starts speaking differently, the model is already behind.

### AP-070 · Re-evaluate context boundaries periodically
`LDDD`

A subdomain changes category: what was core becomes generic when the market commoditises it, and the design investment has to migrate with it.

### AP-071 · Prefer rebuildable derived data over incrementally maintained derived data
`DDIA`

Being able to reprocess from scratch is what makes pipeline evolution safe.

### AP-072 · Do not rewrite; strangle
`RI` `LDDD` · collides: AP-005, AP-016

Incremental replacement with an explicit frontier preserves the option to stop halfway — a full rewrite does not.

---

## Mechanisms that touch this axis

| Principle | Layer | Coverage |
|---|---|---|
| AP-063, AP-064, AP-068 | `architecture` | Check `contract_compat`: a removed or renumbered field identifier, or a removed published operation, without a superseding ADR. See P10. |
| AP-067 | `architecture` | The debt ledger tracks the contraction step as an open entry with a revisit trigger. A contraction that never arrives is visible, which is the entire point. |
| AP-070 | `schedule.quarterly` | `architecture_boundary_review` — the review is scheduled; its outcome is an ADR. |
| AP-071 | — | No mechanism. |

AP-065 and AP-066 are properties of the delivery pipeline, outside what this repository verifies about a change. They belong in the ADR's operability section.
