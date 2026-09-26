# Attacks — the attacker's index

The catalogue is organised by what to build. This page is organised by what an attacker does. Each row names the attack, the controls that stop it, and how the gauntlet or a reviewer finds the gap. The adversary pass (`REVIEW.md`) walks this table.

Test column shorthand: **sast** / **sca** / **headers** / **dast** / **fuzz** — `security` layer checks; **abuse** — an `@security` scenario the human writes; **review** — only the adversary pass or a pentest finds it.

## Injection

| Attack | Stopped by | How it is found |
|---|---|---|
| SQL injection (classic, blind, time-based, second-order) | SEC-001, SEC-008 | sast (`crivo.sec-001.*` + registry); fuzz; abuse: `' OR '1'='1` and `pg_sleep` on every filter and sort; dast active scan |
| NoSQL operator injection (`{"$ne": null}`) | SEC-002 | sast; test with object-typed values in string fields |
| OS command injection | SEC-003 | sast (`crivo.sec-003.*`) |
| Code and server-side template injection | SEC-004 | sast; review of user-editable templates |
| Insecure deserialization | SEC-005 | sast (`crivo.sec-005.*`) |
| Path traversal, zip slip | SEC-006, SEC-124 | sast; test with `../`, encoded separators, crafted archive |
| XML external entities | SEC-007 | sast |
| Mass assignment (`"role":"admin"` in the body) | SEC-009, SEC-060 | abuse: extra privileged fields in every write request are ignored or rejected |
| Prototype pollution | SEC-010 | sast; sca (vulnerable merge libraries) |
| Header, CRLF, email-header and log injection | SEC-011 | sast; fuzz |
| Regular-expression denial of service | SEC-012 | sast; fuzz with long pathological strings |
| Server-side request forgery | SEC-013, SEC-109 | sast; abuse: `http://169.254.169.254/`, `http://localhost`, a redirecting URL, a DNS name resolving to 10.0.0.1 |
| Spreadsheet formula injection in exports | SEC-017 | test |

## Browser and client side

| Attack | Stopped by | How it is found |
|---|---|---|
| Stored and reflected cross-site scripting | SEC-014, SEC-016, SEC-018, SEC-020 | sast (`crivo.sec-016.*`); abuse: `<img src=x onerror=…>` in every rich-text field, asserted not to execute in the e2e browser; dast |
| DOM-based XSS | SEC-019, SEC-020 | sast; headers (Trusted Types in CSP) |
| Cross-site request forgery, login CSRF | SEC-025, SEC-026 | abuse: a state-changing request from a foreign origin without the token fails; headers (SameSite) |
| Clickjacking | SEC-023 | headers |
| CORS misconfiguration (reflected origin, `null`, `*` with credentials, suffix matching) | SEC-024 | headers (`Origin: https://crivo-probe.invalid` and `null`); sast (`crivo.sec-024.*`) |
| Open redirect | SEC-027 | sast (`crivo.sec-027.*`); abuse: `?next=//evil.example`, `?next=/\evil.example`, `?next=https://evil.example` |
| Malicious `postMessage` | SEC-028 | sast (`crivo.sec-028.*`) |
| Formjacking / Magecart / hijacked CDN script | SEC-029, SEC-020 | sast (`crivo.sec-029.*` on templates); headers (CSP) |
| Token theft from `localStorage` after any XSS | SEC-030 | review; sast for `localStorage.setItem` of token-like names |
| Secrets, internal endpoints and source maps in the bundle | SEC-031 | secrets; headers (`.map` probe) |
| Web cache deception and poisoning | SEC-032 | headers (`Cache-Control` on authenticated pages); dast |
| Cross-site leaks, reverse tabnabbing | SEC-033 | headers |
| Framework middleware bypass, server-action exposure | SEC-034 | sca (framework CVEs); test: every server action and route checks auth itself |

## Authentication and sessions

| Attack | Stopped by | How it is found |
|---|---|---|
| Unauthenticated endpoint | SEC-035 | abuse: route-manifest test against `spec/security/public-routes` |
| Credential stuffing, password spraying, brute force | SEC-038, SEC-039, SEC-040, SEC-088 | abuse: repeated failures produce 429 or a challenge |
| Account enumeration | SEC-041 | abuse: identical response and timing for existing and unknown accounts |
| Password-reset poisoning and takeover | SEC-042 | abuse: reset with a second email, with a forged `Host` header, reuse of a used link |
| MFA fatigue, SIM swap, real-time phishing | SEC-039 | review; config |
| Account pre-hijacking, trust in unverified email | SEC-044 | test |
| Brute force of one-time codes and magic links | SEC-045 | abuse |
| Session fixation | SEC-048 | test: session ID changes at login |
| Session hijacking (stolen cookie, infostealer) | SEC-026, SEC-030, SEC-049, SEC-055 | headers; test: logout invalidates server-side |
| Token leakage through URL, `Referer`, logs | SEC-050, SEC-022, SEC-056 | sast (`crivo.sec-050.*`); headers (`Referrer-Policy`); abuse on the handoff flow (below) |
| JWT forgery (`alg: none`, key confusion, missing audience) | SEC-051 | sast (`crivo.sec-051.*`); test with forged tokens |
| OAuth code or token theft (loose `redirect_uri`, missing `state` or PKCE) | SEC-053, SEC-027 | test; review |
| Abuse of stolen integration tokens | SEC-054 | review; config |
| Compromise of internal admin or support tools | SEC-047, SEC-119 | config; review |

## Authorization

| Attack | Stopped by | How it is found |
|---|---|---|
| IDOR / broken object-level authorization | SEC-058, SEC-061, SEC-062 | abuse: the authorization matrix runs every object route as another user and another tenant |
| Privilege escalation through admin functions | SEC-059, SEC-062 | abuse: matrix deny cells |
| Cross-tenant data access | SEC-061, SEC-062, SEC-144 | abuse; test with RLS enabled and a missing application filter |
| Excessive data exposure in responses | SEC-060, SEC-074 | test: response schemas are explicit; review |
| Client-side trust (price, role, current-user tampering) | SEC-063, SEC-128 | abuse: tampered values are recomputed or rejected |
| Authorization skipped in jobs, websockets, exports | SEC-065 | review; test |
| Forged or replayed webhooks | SEC-067 | test: unsigned, badly signed and replayed events are rejected |
| Leaked signed URL reused | SEC-066 | test: expiry |

## Availability, abuse and bots

| Attack | Stopped by | How it is found |
|---|---|---|
| Volumetric DDoS (layer 3/4, amplification) | SEC-080 | config (edge in front, origin not reachable directly) |
| Layer-7 floods, HTTP/2 Rapid Reset | SEC-080, SEC-081, SEC-118 | config; abuse: rate limit returns 429 |
| Slow-connection attacks (Slowloris) | SEC-084 | config |
| Expensive-endpoint abuse (search, export, report) | SEC-081, SEC-085, SEC-086, SEC-087 | lint (`no_unbounded_resource`, `no_unbounded_call`); abuse |
| Payload bombs (huge body, deep JSON, zip bomb) | SEC-083, SEC-124 | fuzz; test |
| Noisy or hostile tenant | SEC-082 | abuse |
| Denial of wallet (autoscaling, SMS, LLM tokens) | SEC-089, SEC-090, SEC-145 | config (budget caps and alerts) |
| Bots: scraping, fake sign-ups, spam, card testing, scalping | SEC-088, SEC-093, SEC-129 | config (bot management); abuse on sign-up and contact forms |
| Race conditions (double spend, limit overrun) | SEC-126 | abuse: 20 concurrent identical requests take effect once |

## Supply chain

| Attack | Stopped by | How it is found |
|---|---|---|
| Known vulnerability in a JavaScript or Python library | SEC-095, SEC-104, SEC-099 | sca per PR and nightly; KEV blocks |
| Malicious new version of a legitimate package | SEC-096, SEC-097, SEC-094 | sca (release-age and install-script policy; lockfile) |
| Typosquatting and hallucinated package names | SEC-098 | sca; review of every new dependency |
| Compromised GitHub Action or base image | SEC-100, SEC-101 | ci (zizmor: unpinned actions, dangerous triggers, template injection) |
| Tampered build-time download | SEC-102 | ci; sast |
| Malicious maintainer or contributor | SEC-103 | config (branch protection, provenance) |

## Configuration and infrastructure

| Attack | Stopped by | How it is found |
|---|---|---|
| Internet-exposed database, cache or admin panel | SEC-108, SEC-119 | iac |
| Public storage bucket, permissive BaaS rules | SEC-110, SEC-061 | iac; test |
| Cloud metadata credential theft | SEC-109, SEC-013 | iac |
| Leaked secret in the repository or a build log | SEC-071, SEC-148 | secrets |
| Debug mode, default credentials, verbose errors | SEC-107, SEC-077 | dast; headers (version banners) |
| Subdomain takeover | SEC-115 | config (DNS inventory) |
| Email spoofing of your domain | SEC-116 | config (DMARC) |
| HTTP request smuggling | SEC-118 | dast; config |

## Files, business logic, AI, detection

| Attack | Stopped by | How it is found |
|---|---|---|
| Web shell or stored XSS through upload (HTML, SVG) | SEC-120, SEC-121, SEC-122 | test; headers on the user-content origin |
| Exploit in an image or document parser | SEC-123 | sca; review |
| Workflow step skipping or replay | SEC-127 | abuse |
| Free-tier, trial and referral abuse | SEC-129 | abuse; review |
| Direct and indirect prompt injection | SEC-140, SEC-142, SEC-147 | llm-eval adversarial set; review |
| Data exfiltration through model output | SEC-141, SEC-143 | test; headers (`img-src`) |
| Cross-tenant retrieval in RAG | SEC-144 | test |
| Intrusion that nobody notices | SEC-131, SEC-133, SEC-134 | test (events emitted); config (alerts routed) |
| Ransomware and backup destruction | SEC-076, SEC-113, SEC-135 | config (restore drill dated) |
| Agent silences a scanner or weakens a security test | SEC-148, SEC-149 | suppressions check; P06 hooks |
| Prompt injection of the coding agent | SEC-150, SEC-151 | config (hooks, no production credentials) |

## Worked scenario — an app users reach already signed in through a redirect

Batuvia and Orpheus open in the browser already signed in, redirected from another system. That single flow concentrates several attack classes, and it is worth threat-modelling on its own:

```
 origin system ──(1) redirect with ?something──▶ app ──(2) exchange──▶ identity/back channel
                                                  │
                                                  └─(3) set session cookie, redirect to clean URL
```

| Step | What goes wrong | Controls |
|---|---|---|
| (1) The redirect URL | A long-lived token in the query or fragment leaks via `Referer` to every third-party resource on the landing page, via browser history, server and proxy logs, analytics and support screenshots. | SEC-050 (one-time, ≤ 60 s, audience-bound code), SEC-022 (`Referrer-Policy: no-referrer` on the landing route), SEC-056 (nothing logs the query string) |
| (1) The origin of the redirect | Anyone can craft a link to the landing route. If the app accepts `?next=` or `?return=` there, it becomes an open redirect that phishing and OAuth attacks reuse. If it accepts a code minted for a different app, one compromised app compromises all. | SEC-027, SEC-053 (`state`), SEC-051 (`aud`) |
| (2) The exchange | Replay of a captured code; a code accepted twice; the exchange done in the browser with a secret that ships in the bundle. | SEC-050 (single-use, server-side exchange), SEC-031 |
| (2) Login CSRF | An attacker sends the victim a link carrying the attacker's own code; the victim works inside the attacker's account and their data lands there. | SEC-025 (bind the code to the browser that requested it where possible; show which account is active) |
| (3) The session | Session fixation; a cookie scoped to the parent domain shared with every subdomain; tokens stored in `localStorage`. | SEC-048, SEC-026 (`__Host-`, no `Domain`), SEC-030 |
| Embedding | If the origin system shows the app in an iframe, framing must be allowed for exactly that origin — which re-opens clickjacking for it. | SEC-023, SEC-026 (`SameSite=None` only if embedding requires it, and then CSRF tokens are mandatory) |

The `@security` scenarios for this flow belong in every project that has it: replay of a used code, an expired code, a code for another audience, a landing URL with a `next` pointing off-site, and the absence of the code in any request the landing page makes afterwards (checked in the e2e browser's network log).
