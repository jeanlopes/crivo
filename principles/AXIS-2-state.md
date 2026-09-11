# Axis 2 — State: where the truth lives and under which consistency

State, replication, transaction, ordering.

---

### AP-032 · Declare the system of record before any other data decision
`DDIA` · collides: AP-046

Everything else is derived data, and derived data can be rebuilt. Confusing the two is the origin of most irreparable inconsistencies.

### AP-033 · Choose the replication model by the write pattern, not the read pattern
`DDIA`

Single-leader, multi-leader, and leaderless differ in how they resolve write conflicts — which is the hard problem.

### AP-034 · Name the guarantee the user needs, not the one the database offers
`DDIA`

Read-after-write, monotonic reads, consistent prefix: distinct guarantees with distinct costs. "Eventual consistency" is not a requirement, it is the absence of one.

### AP-035 · Linearizability is expensive and rarely necessary — but where it is, there is no substitute
`DDIA` · collides: AP-027

Leader election, uniqueness constraints, and distributed locks require real consensus. For everything else, negotiate.

### AP-036 · Know the isolation level you are actually using and the anomalies it lets through
`DDIA`

Lost update, write skew, and phantoms are not laboratory cases; they are what produces a negative balance in production. Snapshot isolation is not serializable.

### AP-037 · Never use a wall clock to order events across machines
`DDIA` `PoDS`

Clocks drift, jump, and run backwards. Use logical counters, versions, or fencing tokens.

### AP-038 · Protect resources with a fencing token, not with possession of a lease
`DDIA` `PoDS`

A node may have lost its lease without knowing it yet — GC pauses last longer than anyone assumes. The resource has to reject the stale write.

### AP-039 · Make every receiver idempotent
`PoDS` `DDIA`

On an asynchronous network there is no "delivered exactly once"; there is "applied once because the application is idempotent".

### AP-040 · Write to the log before mutating state
`PoDS`

A write-ahead log is the mechanism that turns a mid-operation crash into deterministic recovery. Segment it and define the watermark that truncates it.

### AP-041 · Use a quorum to decide, a generation to break ties, and a high-water mark to know what is committed
`PoDS`

Without a generation counter, a resurrected old leader corrupts the log; without a watermark, replicas expose uncommitted writes.

### AP-042 · Detect failure by heartbeat, but never confuse detection with truth
`PoDS`

A failure detector on an asynchronous network is always wrong in some scenario; design what happens when it is wrong.

### AP-043 · Concentrate decisions in a small consistent core and keep the data volume outside it
`PoDS` · collides: AP-019

Metadata, membership, and configuration in the replicated core; application data partitioned outside.

### AP-044 · Partition by access key and plan rebalancing from day zero
`DDIA` `PoDS`

A fixed number of partitions larger than the number of nodes avoids the full reorganisation nobody wants to run in production. A hot spot is a key-modelling problem, not a capacity problem.

### AP-045 · Separate transactional load from analytical load
`DDIA`

Opposite access patterns do not coexist in the same store without one of them paying for it.

### AP-046 · Treat the event log as the source of truth when the history of "how it got here" has business value
`LDDD` `DDIA` · collides: AP-032

Event sourcing pays for itself in audit, retroaction, and new read models — and only in those cases.

### AP-047 · If you adopt CQRS, accept that the read model is stale, and design the interface for that
`LDDD`

Hiding the lag from the user produces a perception bug that no log explains.

---

## Mechanisms that touch this axis

| Principle | Layer | Coverage |
|---|---|---|
| AP-037 | `lint` | Rule `no-walltime-ordering` (P10, proposed rules). Catches the syntactic form, not the intent. |
| AP-039 | `property` | Only if the project states idempotence as an `INV-nnn` in `spec/invariants.md`. |
| AP-036, AP-044, AP-047 | `e2e` | Real dependencies expose the anomaly; nothing declares which anomaly was accepted. That is the ADR's job. |

The rest of this axis is a design decision with no syntactic footprint. It reaches the gauntlet only through the ADR (P10) and through the invariants the SPEC declares.
