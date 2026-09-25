# Domain 4 — Sessions, tokens and single sign-on

After login the credential is the session. Stealing it is easier than stealing the password, and a session that arrives through a redirect — the way users reach an app "already logged in" from somewhere else — is the easiest of all to leak.

---

### SEC-048 · Generate sessions with a CSPRNG and rotate them on every privilege change
`ASVS:V7` `CWE-384` `CWE-330` · verify: test · severity: high

At least 128 bits of entropy from a cryptographic generator. Issue a new session identifier at login, logout, MFA completion and role change, so a session fixed by an attacker before login is worthless after it.

### SEC-049 · Expire and revoke sessions on the server
`ASVS:V7` `CWE-613` · verify: test, abuse · severity: high

Idle and absolute timeouts; logout, password change, MFA change and account deletion invalidate server-side state, not just the cookie in one browser. Users can list and revoke their active sessions. Test: a session cookie captured before logout is rejected after it.

### SEC-050 · Never carry long-lived credentials in URLs; hand off logins with a one-time code exchanged server-side
`ASVS:V7` `ASVS:V10` `CWE-598` `T10:A07` · verify: sast, abuse, adversary · severity: critical

Tokens in a query string or fragment leak through `Referer`, browser history, server and proxy logs, analytics tools, screenshots and shared links. When users arrive "already logged in" from another system, the redirect carries a one-time code that is single-use, expires in ≤ 60 seconds, is bound to the target application (audience) and, where possible, to the user agent that requested it. The target exchanges it over a back channel for its own session cookie, then redirects to a clean URL. The page that receives the code sends `Referrer-Policy: no-referrer` and loads no third-party resources. The redirect destination itself is allow-listed (SEC-027). Test: replaying a used code, a code older than 60 s, and a code minted for another audience all fail.

### SEC-051 · Validate every claim of a self-contained token
`ASVS:V9` `CWE-347` `T10:A07` · verify: sast, test · severity: critical

Pin the algorithm (reject `none` and HS/RS confusion); verify signature, `iss`, `aud`, `exp`, `nbf`; fetch keys from a pinned JWKS and cache them; keep lifetimes short. JWT payloads are readable by anyone — no personal data or secrets inside. In 2023 a stolen signing key plus a validation flaw that accepted consumer keys for enterprise tokens let an attacker read government mailboxes at Microsoft (Storm-0558).

### SEC-052 · Rotate refresh tokens and detect reuse
`ASVS:V9` `ASVS:V10` `CWE-613` · verify: test · severity: high

Access tokens live minutes. Each refresh issues a new refresh token and invalidates the old one; presenting an already-used refresh token revokes the whole family, because it means one of the two holders is an attacker.

### SEC-053 · Implement OAuth 2 and OIDC clients by the current best practice
`ASVS:V10` `CWE-352` `CWE-601` · verify: test, abuse · severity: high

Authorization code flow with PKCE for every client; `state` and `nonce` generated and checked; redirect URIs registered and matched exactly; no implicit flow; ID token validated as in SEC-051. OAuth 2.0 Security Best Current Practice (RFC 9700) is the reference.

### SEC-054 · Treat third-party integration tokens as crown jewels
`ASVS:V10` `ASVS:V14` `CWE-522` · verify: adversary, config · severity: high

Tokens your SaaS holds for customers' other systems (CRM, drive, calendar) get the minimum scopes, encryption at rest, per-tenant isolation, revocation and anomaly alerting. In 2025 attackers who stole OAuth tokens from the Salesloft Drift integration exported Salesforce data from hundreds of companies without touching their passwords.

### SEC-055 · Detect stolen sessions
`ASVS:V7` `CWE-294` · verify: config, adversary · severity: medium

Infostealer malware exports cookies straight from browsers; MFA does not help once the cookie is taken (CircleCI, 2023). Bind sessions to device characteristics where the platform allows (device-bound session credentials), re-challenge on abrupt IP/ASN/user-agent changes, and keep privileged sessions short.

### SEC-056 · Keep credentials out of every side channel
`ASVS:V14` `ASVS:V16` `CWE-532` · verify: sast, test · severity: high

Authorization headers, cookies and tokens never reach logs (SEC-132), error trackers, analytics, support tickets or HAR files. Support tooling scrubs uploaded HAR files: in 2023 session tokens in customer-uploaded HAR files let attackers hijack Okta customer sessions.
