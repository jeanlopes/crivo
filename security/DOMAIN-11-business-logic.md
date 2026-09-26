# Domain 11 — Business logic

Logic flaws use the application exactly as built, in an order or at a speed nobody imagined. No scanner knows that a coupon should apply once. The only defence that scales is to write the abuse down in the SPEC — which is why SEC-130 is the root of this domain.

---

### SEC-126 · Make critical operations atomic and idempotent
`ASVS:V2` `CWE-362` `CWE-367` · verify: test, abuse · severity: high

Race conditions spend a balance twice, redeem a single-use coupon ten times, or exceed a plan limit by sending requests in parallel. Use transactions with the right isolation, row locks or conditional updates (`UPDATE … WHERE balance >= amount`), unique constraints, and idempotency keys on payment-like operations. Test: the `@security` scenario sends the same request 20 times concurrently and asserts the effect happened once.

### SEC-127 · Enforce workflow order on the server
`ASVS:V2` `CWE-841` · verify: abuse · severity: high

Checkout, onboarding, approval, KYC and multi-step forms keep their state server-side; a request for step 4 without a completed step 3 is rejected; completed steps cannot be replayed.

### SEC-128 · Validate business values, not only their types
`ASVS:V2` `CWE-20` `CWE-190` · verify: property · severity: high

Negative quantities, zero or negative prices, integer overflow, currency rounding, dates in the past, and totals recomputed from the server's own catalogue. These are invariants (`INV-nnn`) and get property tests.

### SEC-129 · Limit abuse of free tiers, trials, referrals and invitations
`ASVS:V2` `API:API6` `OAT:OAT-019` · verify: abuse, adversary · severity: medium

Multi-accounting for repeated trials, self-referral, invitation features used to send spam from your domain, and free storage used as malware hosting. Rate-limit, require verification, and cap what an unverified account can do.

### SEC-130 · Write abuse cases in the SPEC
`ASVS:V2` `T10:A06` · verify: abuse · severity: high

For every feature the SPEC answers three questions — how would a malicious user, a malicious tenant, and a bot misuse this? — and each answer becomes an `@security` Gherkin scenario (template: `spec/features/SECURITY-EXAMPLE.feature`). Insecure Design (A06) is the category of flaws that no amount of correct implementation fixes; abuse cases are how design gets tested.
