# Axis 3 — Failure: what breaks and how it degrades

Stability under failure, under load, and under success.

---

### AP-048 · Every integration is a point of failure, and integrations are the number one cause of outages
`RI`

Each external call is a place where your process can be brought down by something outside your control.

### AP-049 · Timeout on everything. No exceptions
`RI` · collides: AP-011

A call without a timeout is a thread leak waiting to happen, and that is how remote slowness becomes local unavailability.

### AP-050 · Fail fast rather than failing slow
`RI` · collides: AP-011

A slow response is worse than an error: it consumes resources on both sides and propagates the queue upstream.

### AP-051 · Use a circuit breaker to turn repeated failure into immediate failure
`RI`

The breaker exists to give the remote system a chance to recover and your system a chance to degrade in a way you chose.

### AP-052 · Compartmentalise with bulkheads
`RI` · collides: AP-008, AP-058

Pools, queues, and instances separated by traffic class guarantee that the failure of one part does not consume the capacity of all.

### AP-053 · Design against chain reactions and cascading failures
`RI`

A chain reaction is horizontal (one instance dying overloads its siblings); a cascade is vertical (one layer's failure brings down the layer above). Two distinct modes requiring distinct defences.

### AP-054 · Assume every unbounded resource will be exhausted
`RI`

An unlimited query result, an uncapped queue, a cache without expiry: all of them work in testing and die at real volume.

### AP-055 · Steady state is a requirement, not hygiene
`RI`

Every datum that accumulates needs an automatic purge mechanism. Recurring human intervention is a design defect.

### AP-056 · Apply back pressure instead of accepting work you cannot execute
`RI`

A system that accepts everything and queues indefinitely fails later and worse. Refusing is a legitimate response.

### AP-057 · Shed load before degrading for everyone
`RI`

Rejecting a fraction of the traffic preserves the service for the majority; the alternative is uniform unavailability.

### AP-058 · Distrust unbalanced capacities between layers
`RI` · collides: AP-052

A front end sized for ten times the back end's capacity is a weapon pointed inward.

### AP-059 · Treat your own users as a traffic threat
`RI`

A promotion, a mass email, and automatic retries produce a self-inflicted denial of service with stopwatch precision.

### AP-060 · Add jitter to every retry and every scheduled task
`RI`

Accidental synchrony between clients forms a dogpile at the instant of recovery — the worst possible moment.

### AP-061 · Measure latency at a high percentile, never by the mean
`DDIA` · collides: AP-087

The mean hides the tail, and the tail is what the user remembers. In a composed request, the tail dominates the result.

### AP-062 · Write the degradation mode into the specification, alongside the normal behaviour
`RI`

"What this system does when dependency X is down" is a functional requirement, and if nobody decided, the default answer is "it falls over".

---

## Mechanisms that touch this axis

| Principle | Layer | Coverage |
|---|---|---|
| AP-049 | `lint` | Rule `no-unbounded-call` (P10, proposed rules) — a remote call with no timeout argument and no enclosing deadline. |
| AP-054 | `lint` | Rule `no-unbounded-resource` — unlimited query, uncapped queue, cache without TTL. Syntactic; a computed limit of infinity passes. |
| AP-060 | `lint` | Rule `retry-requires-jitter` — a retry policy with a fixed or purely exponential delay. |
| AP-061 | `e2e` | Reports percentiles where the project defines a latency budget. Nothing gates on it by default. |
| AP-062 | `unit` + `spec/` | The degradation scenario is a Gherkin scenario like any other, so `spec_to_test_mapping` covers it — **if it was written**. Whether it was written is what P10 asks of the ADR. |

AP-051 – AP-053 and AP-056 – AP-058 are architectural shapes. No layer sees them. The ADR is the only record.
