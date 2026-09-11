# Axis 5 — Teams and operation: who operates it and who decides

Teams, ownership, operation, platform.

---

### AP-073 · The architecture you can sustain is limited by the team structure you have
`TT` · collides: AP-022

The inverse Conway manoeuvre — changing the organisation to obtain the desired architecture — is a lever of architecture, not of HR.

### AP-074 · Use four team types and only those: stream-aligned, enabling, complicated-subsystem, and platform
`TT`

Any team that does not fit is a symptom of a badly drawn boundary.

### AP-075 · Most teams should be stream-aligned, with end-to-end ownership
`TT`

The other three types exist to reduce those teams' cognitive load, not to create handoff stages.

### AP-076 · Choose and declare the interaction mode: collaboration, X-as-a-service, or facilitation
`TT` · collides: AP-025

Collaboration is expensive and must be temporary and aimed at discovery; a permanent regime of collaboration is an undefined boundary.

### AP-077 · A platform is a product, with internal customers who are allowed to refuse it
`TT` · collides: AP-016

A platform adopted by mandate hides its own usability defects until it is too late.

### AP-078 · Long-lived teams are a precondition of ownership
`TT`

A team dissolved at the end of every project accumulates no mental model — and the cost reappears as system complexity.

### AP-079 · Transparency is a production requirement
`RI`

A system that cannot report what it is doing cannot be operated, only restarted. Instrumentation is not added afterwards.

### AP-080 · Design for the operator, not only for the user
`RI` `DDIA` · collides: AP-010

Configuration, actionable logs, health endpoints, and graceful shutdown are first-class functionality.

### AP-081 · Write the log for whoever will be woken at three in the morning
`RI` · collides: AP-011

A message with no identifier context, no suggested action, and no correct severity is noise that delays diagnosis.

### AP-082 · Maintainability is one of the three base requirements, alongside reliability and scalability
`DDIA`

Operability, simplicity, and evolvability are its three faces — and most of the cost of software is there, not in construction.

---

## Mechanisms that touch this axis

| Principle | Layer | Coverage |
|---|---|---|
| AP-079, AP-080, AP-081 | `architecture` | Check `operability_declared`: a change that adds an integration point or a background process without declaring its health signal, its log identifiers, and its shutdown behaviour in the ADR. Declaration is checked; quality is not. |
| AP-082 | `scoring` | The navigability index N is one operational reading of this principle. It measures legibility for the next agent, not for the on-call engineer. |

AP-073 – AP-078 are organisational facts. No repository can verify them. They appear in the ADR because a boundary decision that ignores who will own it is not a decision, it is a wish — and `CODEOWNERS` (P06) is where the answer becomes mechanical.
