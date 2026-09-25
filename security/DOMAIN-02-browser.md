# Domain 2 — Browser and client side

The browser runs code from your origin with your users' cookies. Anything that lets an attacker add code to that origin, frame it, read from it cross-origin, or send requests as it, is an account takeover waiting for a victim to click a link.

---

### SEC-018 · Sanitize user-supplied HTML and Markdown with a maintained sanitizer
`ASVS:V1` `ASVS:V3` `CWE-79` `T10:A05` · verify: sast, test · severity: high

Rich text, comments, bios and Markdown rendered to HTML pass through DOMPurify (or the platform equivalent) with an allow-list of tags and attributes. Links and images accept only `https:` and relative URLs — `javascript:`, `data:` and `vbscript:` in `href`/`src` are the classic Markdown XSS. Test: an `@security` scenario stores `<img src=x onerror=alert(1)>` and `[x](javascript:alert(1))` and asserts that neither executes in the e2e browser.

### SEC-019 · Keep attacker-controlled data out of DOM sinks
`ASVS:V3` `CWE-79` · verify: sast, headers · severity: high

`location`, `location.hash`, `document.referrer`, `postMessage` data, `localStorage` and URL parameters must not flow into `innerHTML`, `document.write`, `eval`, `setTimeout(string)`, `script.src` or `iframe.srcdoc`. Where browsers support it, enforce Trusted Types with CSP (`require-trusted-types-for 'script'`) so the sink refuses plain strings.

### SEC-020 · Ship a strict Content-Security-Policy
`ASVS:V3` `CWE-79` `CWE-1021` · verify: headers, dast · severity: high

Nonce- or hash-based `script-src` with `'strict-dynamic'`; no `'unsafe-inline'` or `'unsafe-eval'` for scripts; `object-src 'none'`; `base-uri 'none'`; `frame-ancestors` set (SEC-023); a `report-to`/`report-uri` endpoint that someone reads. Roll out with `Content-Security-Policy-Report-Only` first. CSP is the net under every XSS that SEC-016 and SEC-018 miss.

### SEC-021 · Enforce HTTPS with HSTS
`ASVS:V12` `CWE-319` · verify: headers · severity: high

`Strict-Transport-Security: max-age=31536000; includeSubDomains` on every HTTPS response; add `preload` once every subdomain serves HTTPS. Plain HTTP only redirects.

### SEC-022 · Send the baseline security headers on every response
`ASVS:V3` `ASVS:V13` `CWE-16` · verify: headers · severity: medium

`X-Content-Type-Options: nosniff`; an explicit `Content-Type` with charset; `Referrer-Policy: strict-origin-when-cross-origin` (or `no-referrer` on pages that may carry a code in the URL, SEC-050); a minimal `Permissions-Policy`; no `Server`/`X-Powered-By` version banners.

### SEC-023 · Control who can frame the app
`ASVS:V3` `CWE-1021` · verify: headers · severity: medium

`Content-Security-Policy: frame-ancestors 'none'` (plus `X-Frame-Options: DENY` for old browsers). An app that must be embedded by a partner lists the partner origins explicitly — never `*`. Clickjacking turns one click on a decoy page into "delete account" or "grant access".

### SEC-024 · Configure CORS with an explicit origin allow-list
`ASVS:V3` `ASVS:V4` `CWE-942` · verify: headers, sast, abuse · severity: high

Never reflect the request's `Origin`; never combine `*` with credentials; never allow the `null` origin; match the full origin (scheme, host, port) — not a suffix or a regex that `evil-batuvia.com` also satisfies. Send `Vary: Origin`. Test: a request with `Origin: https://evil.example` receives no `Access-Control-Allow-Origin` echo.

### SEC-025 · Protect every state-changing request against CSRF
`ASVS:V3` `CWE-352` · verify: test, dast, abuse · severity: high

Session cookies with `SameSite=Lax` or `Strict`, plus a synchronizer or double-submit token, or server-side verification of `Origin`/`Sec-Fetch-Site`. `GET` never changes state. CSRF is third in the 2025 CWE Top 25. Login and logout forms need protection too (login CSRF signs the victim into the attacker's account).

### SEC-026 · Set every cookie flag deliberately
`ASVS:V3` `ASVS:V7` `CWE-614` `CWE-1004` · verify: headers, sast · severity: high

Session cookies: `Secure`, `HttpOnly`, `SameSite`, a `__Host-` name prefix, `Path=/`, no `Domain` attribute (a `Domain=` cookie is readable and overwritable by every subdomain, including a taken-over one, SEC-115).

### SEC-027 · Redirect only to allow-listed destinations
`ASVS:V3` `CWE-601` · verify: sast, test, abuse · severity: high

`?next=`, `?returnTo=`, `?redirect_uri=` accept relative paths that start with a single `/` (not `//` or `/\`), or origins from a registered list. An open redirect on the app that users arrive at from a partner is the phishing link that looks legitimate and, combined with OAuth or a login handoff, the path that delivers codes and tokens to an attacker (SEC-050, SEC-053).

### SEC-028 · Check the origin of every postMessage
`ASVS:V3` `CWE-345` · verify: sast · severity: high

Receivers compare `event.origin` against an exact allow-list before reading `event.data`; senders pass an explicit `targetOrigin`, never `"*"`.

### SEC-029 · Control every third-party script that runs on your origin
`ASVS:V3` `CWE-829` `CWE-353` `PCI:6.4.3` `PCI:11.6.1` · verify: sast, headers · severity: high

Self-host third-party JavaScript where possible; otherwise pin it with Subresource Integrity (`integrity=` + `crossorigin`) and restrict it with CSP. Keep an inventory of each script and why it is there. British Airways (2018) lost ~400 000 cards to 22 modified lines in one of its own scripts; in 2024 the new owner of the `polyfill.io` domain served malicious code to more than 100 000 sites that loaded it from a CDN.

### SEC-030 · Keep session tokens out of JavaScript-readable storage
`ASVS:V3` `ASVS:V7` `CWE-922` · verify: sast, adversary · severity: high

`localStorage`, `sessionStorage`, IndexedDB and non-`HttpOnly` cookies are read by any XSS and by any compromised dependency (SEC-029, SEC-098). Keep the session in an `HttpOnly` cookie; single-page apps that need tokens for third-party APIs use a backend-for-frontend.

### SEC-031 · Treat the frontend bundle as public
`ASVS:V13` `ASVS:V14` `CWE-200` `CWE-540` · verify: secrets, headers · severity: critical

Nothing in client code is secret: not API keys with write scopes, not service-role keys (a Supabase `service_role` or a Firebase admin credential in the bundle bypasses every rule), not internal hostnames or hidden admin routes. Production does not serve source maps publicly. Only keys designed to be public — publishable, anon, restricted by rules (SEC-061) — may ship.

### SEC-032 · Keep authenticated responses out of shared caches
`ASVS:V14` `CWE-524` · verify: headers, dast · severity: high

`Cache-Control: no-store` (or `private`) on anything personalized. Configure CDN cache keys on every input that changes the response and do not cache by path extension alone: web cache deception makes the CDN store a victim's `/account/profile.css` for the attacker to fetch.

### SEC-033 · Isolate sensitive pages from cross-origin leaks
`ASVS:V3` `CWE-203` · verify: headers · severity: low

`Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Resource-Policy: same-origin` on authenticated pages and APIs reduce XS-Leaks (cross-site inference of state through timing, frame counts and error events) and cut the `window.opener` link. Links that open other sites use `rel="noopener noreferrer"`.

### SEC-034 · Treat framework server functions, middleware and server components as public endpoints
`ASVS:V4` `ASVS:V8` `CWE-285` `T10:A01` · verify: test, sca, adversary · severity: critical

Every server action, API route and server component that reads data performs its own authentication and authorization check — middleware is not the only gate. In 2025 an `x-middleware-subrequest` header let requests skip Next.js middleware entirely (CVE-2025-29927), and a flaw in React Server Components gave unauthenticated remote code execution (CVE-2025-55182). Keep the framework patched within the SLA (SEC-095).
