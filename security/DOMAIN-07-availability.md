# Domain 7 — Availability, abuse and bots

Taking a SaaS down no longer needs a botnet the size of Mirai. One expensive endpoint without a limit, one regex, one export that loads a table into memory, or one signup form that sends SMS is enough. Volumetric attacks are absorbed at the edge; everything else is absorbed by limits written in the code — and those, the gauntlet can check.

The resilience principles in `principles/AXIS-3-failure.md` (AP-049 timeouts, AP-051 circuit breakers, AP-052 bulkheads, AP-054 unbounded resources) are the architecture view of the same problem; this domain adds the adversary.

---

### SEC-080 · Put the application behind an edge with DDoS protection and hide the origin
`ASVS:V13` `CWE-400` · verify: config, iac · severity: high

A CDN or edge proxy absorbs layer 3/4 floods and filters layer 7 floods; the origin accepts connections only from the edge (firewall allow-list or authenticated origin pulls), so attackers cannot bypass it by finding the origin's IP. In 2018 GitHub took a 1.35 Tbps memcached amplification attack; in 2023 the HTTP/2 "Rapid Reset" technique (CVE-2023-44487) produced record request rates against major providers using modest botnets.

### SEC-081 · Rate-limit every endpoint by identity and by source, harder on expensive and sensitive routes
`ASVS:V2` `ASVS:V4` `CWE-770` `CWE-799` `API:API4` · verify: abuse, config · severity: high

Budgets per user, per API key, per IP/ASN, and per route class: login, signup, reset, OTP, search, export, file upload, AI calls and anything that sends email or SMS get the strictest ones. Answer with 429 and `Retry-After`. In 2024 an attacker pulled 49 million customer records from a Dell partner portal at thousands of requests per minute for weeks. Test: an `@security` scenario exceeds the budget and receives 429.

### SEC-082 · Limit consumption per tenant
`ASVS:V2` `CWE-770` `API:API4` `AP-052` · verify: abuse, test · severity: medium

Quotas and concurrency limits per customer, so one tenant — hostile, compromised, or just a runaway integration — cannot exhaust capacity shared by everyone else.

### SEC-083 · Cap the size and shape of every input
`ASVS:V4` `ASVS:V5` `CWE-400` `CWE-409` · verify: test, fuzz · severity: high

Request body, header and URL length; JSON nesting depth and array length; multipart part count; file size (SEC-120); decompressed size (a 10 KB gzip body can inflate to gigabytes). Enforce at the edge and again in the application.

### SEC-084 · Put a timeout on everything
`ASVS:V15` `CWE-400` `AP-049` · verify: lint, config · severity: high

Inbound requests, outbound calls (lint rule `no_unbounded_call`), database statements (`statement_timeout`), locks, and idle client connections — slow clients that hold connections open (Slowloris) are dropped by the edge or server configuration.

### SEC-085 · Paginate every list and bound every query
`ASVS:V4` `CWE-770` `AP-054` · verify: lint, test · severity: high

Server-enforced maximum page size; no endpoint that returns "all"; large exports run as background jobs (SEC-087). Lint rule `no_unbounded_resource`.

### SEC-086 · Bound GraphQL query cost
`ASVS:V4` `CWE-770` `API:API4` · verify: test · severity: high

Depth and complexity limits, caps on aliases and batched operations, persisted or allow-listed queries in production, introspection disabled in production. One nested GraphQL query can request millions of objects.

### SEC-087 · Move expensive work to queues with back pressure
`ASVS:V15` `CWE-400` `AP-054` · verify: adversary · severity: medium

Reports, imports, media processing, AI calls, bulk email: enqueue, return immediately, process with bounded workers and per-tenant concurrency. The request path stays cheap, so an attacker cannot turn request volume directly into CPU exhaustion.

### SEC-088 · Detect and manage automated abuse of business flows
`ASVS:V2` `CWE-799` `API:API6` `OAT:OAT-019` `OAT:OAT-011` · verify: config, abuse · severity: high

The OWASP Automated Threats catalogue names what bots do to a SaaS: credential stuffing (OAT-008), account creation (OAT-019), scraping (OAT-011), spamming (OAT-017), card testing (OAT-001), denial of inventory (OAT-021). Use bot scoring at the edge and invisible challenges (Turnstile, reCAPTCHA, hCaptcha) on signup, login, reset, contact and invitation forms, and watch for the behavioural signature, not just the volume.

### SEC-089 · Cap the bill, not just the traffic
`ASVS:V2` `CWE-400` `LLM:LLM10` · verify: config · severity: high

Hard budget limits and alerts on autoscaling, serverless invocations, egress, SMS and email sending, LLM tokens and paid third-party APIs. "Denial of wallet" does not take the service down; it makes you take it down.

### SEC-090 · Block SMS and email pumping
`ASVS:V2` `CWE-799` `OAT:OAT-017` · verify: abuse, config · severity: medium

Any form that sends a message to an arbitrary number or address is a toll-fraud and spam relay: rate-limit per destination and per source, restrict SMS to the countries you serve, block premium-rate ranges, and require a challenge before sending.

### SEC-091 · Degrade on purpose under attack
`ASVS:V15` `CWE-400` `AP-051` · verify: adversary · severity: medium

Load shedding, circuit breakers, feature kill switches, a static "under maintenance" fallback served from the edge, and a runbook that says who flips which switch. Degradation modes are written in the SPEC (AP-062), so they are tested like features.

### SEC-092 · Know your breaking point before an attacker finds it
`CWE-400` · verify: test · severity: medium

Load-test before launch and after architecture changes: find the request rate at which latency and error rate break, and verify that rate limits, autoscaling limits and alerts fire below it.

### SEC-093 · Make enumeration and bulk harvesting expensive
`ASVS:V8` `CWE-200` `OAT:OAT-011` · verify: abuse · severity: medium

No sequential public identifiers; caps on how many records one identity can read per time window; alerts on harvesting patterns (many distinct IDs, sorted walks, lookup endpoints hit with lists). Scraping through a "find friends by phone" feature exposed data of 533 million Facebook users.
