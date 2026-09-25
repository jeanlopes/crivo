# Domain 3 — Authentication

Who is this? Most account takeovers today do not break cryptography; they replay leaked passwords, phish a second factor, abuse a reset flow, or find the one route nobody put behind the login.

---

### SEC-035 · Authenticate every route by default; public routes are an explicit, reviewed list
`ASVS:V8` `CWE-306` `T10:A07` · verify: test, abuse · severity: critical

A route-manifest test enumerates every registered route (HTTP, server actions, websockets, GraphQL operations) and fails if a route has neither the authentication middleware nor an entry in `spec/security/public-routes` with a reason. Optus (2022, ~10 million customers) and Peloton (2021) exposed personal data through API endpoints that simply did not ask who was calling.

### SEC-036 · Prefer delegated identity and passkeys over home-grown passwords
`ASVS:V6` `NIST:800-63B-4` · verify: adversary · severity: medium

An OIDC provider or a maintained auth library carries a decade of fixes you would otherwise rediscover as incidents. Passkeys (WebAuthn) are phishing-resistant by construction. Writing password handling from scratch is an ADR-worthy decision (P10).

### SEC-037 · Hash passwords with a slow, salted, memory-hard function
`ASVS:V6` `CWE-916` `T10:A04` · verify: sast, test · severity: critical

Argon2id (or scrypt; bcrypt with cost ≥ 12 as a legacy option), unique salt per password, parameters recorded with the hash so they can be raised. Never a fast hash (SHA-*, MD5), never reversible encryption.

### SEC-038 · Follow NIST SP 800-63B-4 for password rules
`ASVS:V6` `CWE-521` `NIST:800-63B-4` · verify: test · severity: high

Minimum 15 characters when the password is the only factor (8 when it is one factor of MFA); accept at least 64; allow paste, spaces and all Unicode; no composition rules; no periodic forced rotation; reject passwords found in breach corpora (k-anonymity range queries let you check without sending the password).

### SEC-039 · Offer MFA to everyone and require phishing-resistant MFA for privileged users
`ASVS:V6` `CWE-308` `NIST:800-63B-4` · verify: test, config · severity: high

Passkeys/WebAuthn first, TOTP second, SMS last. Push approvals use number matching (Uber, 2022: an attacker spammed push prompts until an employee accepted). Snowflake customers (2024) and 23andMe (2023, ~14 000 accounts → data of ~6.9 million people) were breached with stolen or reused passwords on accounts without MFA.

### SEC-040 · Throttle authentication per account and per source, and detect stuffing across accounts
`ASVS:V6` `CWE-307` `OAT:OAT-007` `OAT:OAT-008` · verify: abuse, test · severity: high

Progressive delays and challenges after failures; lockout that slows the attacker without letting anyone lock a victim out forever; alerting when one source tries many accounts or many sources try one. Test: 20 wrong passwords in an `@security` scenario produce 429 or a challenge, and a correct password after the window still works.

### SEC-041 · Give the same answer, in the same time, whether the account exists or not
`ASVS:V6` `CWE-203` `CWE-204` · verify: abuse, test · severity: medium

Login, registration, password reset and invitation flows. "Email already registered" and a faster response for unknown users both let an attacker build a target list. Twitter (2022, 5.4 million accounts), Trello (2024) and Authy (2024, 33 million phone numbers) all leaked account existence through lookup endpoints.

### SEC-042 · Make password reset single-use, short-lived, and bound to the address on file
`ASVS:V6` `CWE-640` · verify: abuse, test · severity: critical

High-entropy token, stored hashed, valid for minutes, invalidated on use and on password change. Sent only to the verified address already on the account — never to an address taken from the request (GitLab CVE-2023-7028 sent reset links to an attacker-supplied second email). The link is built from a configured base URL, never from the `Host` header. Reset ends all other sessions.

### SEC-043 · Re-authenticate before sensitive actions
`ASVS:V6` `CWE-306` · verify: abuse · severity: high

Changing email, password or MFA; exporting data; deleting the account; adding payment methods or API keys; granting access to others. A stolen session should not be enough to make the theft permanent.

### SEC-044 · Trust an email only after the user proves they control it
`ASVS:V6` `CWE-287` · verify: test, adversary · severity: high

Account linking, "sign in with provider" and domain-based organisation membership are account-takeover paths when an unverified email is trusted. Check the identity provider's `email_verified` claim; do not let an unverified local signup pre-claim an address that later signs in through SSO (account pre-hijacking).

### SEC-045 · Make magic links and one-time codes single-use, short-lived and attempt-capped
`ASVS:V6` `CWE-640` `CWE-330` · verify: test, abuse · severity: high

Bound to the browser that requested them where possible, expiring in minutes, invalidated after use, with a hard cap on guesses per code (a 6-digit code without a cap falls to a script).

### SEC-046 · Scope, hash and make rotatable every API key and service credential
`ASVS:V6` `CWE-798` · verify: secrets, adversary · severity: high

Keys carry a recognizable prefix so secret scanners detect leaks, are stored as hashes, are scoped per tenant and per permission, show a last-used date, and can be revoked without redeploying.

### SEC-047 · Put internal admin and support tools behind stronger controls than the product
`ASVS:V8` `CWE-269` · verify: config, adversary · severity: critical

SSO with phishing-resistant MFA, network restriction, just-in-time elevation, full audit log, and impersonation that is logged and visible to the impersonated user. The 2020 Twitter compromise of high-profile accounts ran entirely through internal support tooling.
