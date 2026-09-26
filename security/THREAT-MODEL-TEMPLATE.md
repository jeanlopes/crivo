# Threat model — <product>

Copy to `spec/security/threat-model.md` (protected, P06). The human owns and approves it; the agent may draft it at `proposals/spec/security/threat-model.md.proposed` and reads it before any security-triggering change (P11). Keep it short enough to be re-read: its value is being current, not being long.

**Status:** draft | approved · **Approved by:** <human> · **Date:** <yyyy-mm-dd> · **P11 level:** 2 · **ASVS target:** L2

## 1. What we protect

| Asset | Classification (SEC-073) | Where it lives | Worst realistic outcome if exposed |
|---|---|---|---|
| User accounts and sessions | personal | `users`, session store | account takeover at scale |
| <domain data> | personal / sensitive | | |
| Integration tokens held for customers | secret | | pivot into customers' other systems (SEC-054) |
| Availability of <core flow> | — | | revenue, trust |

## 2. Who attacks, and what they can already do

| Actor | Starting position |
|---|---|
| Anonymous internet user / bot | Can reach every public route; can send unlimited requests from many IPs |
| Authenticated user | Valid session in one tenant |
| Malicious tenant | Owns a tenant; can invite users; controls its own data and integrations |
| Compromised dependency or third-party script | Runs code in the build or in users' browsers |
| Compromised or manipulated coding agent | Writes code; reads issues and web content (Domain 14) |
| Insider / support staff | Admin tooling (SEC-047) |

## 3. Entry points and trust boundaries

List every way in, with its authentication. This list and `spec/security/public-routes` must agree; the route-manifest test (SEC-035) keeps them honest.

| Entry point | Authn | Boundary crossed | Notes |
|---|---|---|---|
| `GET /` landing from <origin system> redirect | one-time code (SEC-050) | origin system → app | see §4 |
| `/api/**` | session cookie | browser → API | |
| `POST /webhooks/<provider>` | HMAC (SEC-067) | provider → app | |
| Background jobs | service identity | queue → worker | re-check authorization (SEC-065) |

## 4. Critical flows

For each flow that moves identity or money across a boundary, a short sequence and the controls on each step. The sign-in handoff that brings users in already authenticated is always one of them — start from the worked scenario at the end of `security/ATTACKS.md`.

## 5. Domain verdicts

One row per catalogue domain. `applies` names how the controls are verified here; `not-applicable` carries one line; `exception` points at `spec/security/exceptions.yaml`. A per-SPEC *Security* section repeats this table for the triggered domains only, at control granularity.

| Domain | Verdict | Verified by | Notes |
|---|---|---|---|
| 1 Input and injection | applies | sast, fuzz, abuse | |
| 2 Browser and client side | applies | headers, sast, abuse | |
| 3 Authentication | applies | abuse, test | delegated to <IdP>? |
| 4 Sessions and SSO | applies | abuse, test | handoff flow §4 |
| 5 Authorization and tenancy | applies | abuse (authz matrix), config (RLS) | |
| 6 Data, crypto, privacy | applies | | LGPD controller: <entity> |
| 7 Availability, abuse, bots | applies | config, abuse | edge provider: <name> |
| 8 Supply chain | applies | sca, ci, sbom | |
| 9 Configuration and infrastructure | applies | iac, config | |
| 10 Files and uploads | not-applicable | — | no upload feature (revisit when one is added) |
| 11 Business logic | applies | abuse, property | |
| 12 Detection and response | applies | config, test | |
| 13 AI and LLM | not-applicable | — | |
| 14 Agent-built code | applies | suppressions, config | |

## 6. Controls verified by evidence (`config`)

Controls that live outside the code, each with a link to the thing that shows them — an IaC resource, a configuration file, a dated record. The `security` layer checks that each link resolves; a human checks, quarterly, that it is still true.

| Control | Evidence | Last verified |
|---|---|---|
| SEC-080 edge DDoS protection, origin locked to edge | `infra/edge.tf#origin_allowlist` | <date> |
| SEC-089 budget caps and alerts | `infra/billing.tf` | <date> |
| SEC-116 SPF/DKIM/DMARC `p=reject` | `infra/dns.tf` | <date> |
| SEC-135 incident runbook | `docs/runbooks/incident.md`, last exercise <date> | <date> |
| SEC-138 external pentest | report <ref> | <date> |

## 7. Open risks

Accepted risks and known gaps, each with an owner and a revisit trigger — the security counterpart of the P10 violation ledger. Entries with an expiry belong in `spec/security/exceptions.yaml`.

---

## Per-SPEC section (copy into the SPEC's *Security* section)

```
## Security (P11)
Triggers fired: 1 (new route), 5 (redirect handling)
Domains: 2, 4, 5

| Control | Verdict | Verified by |
|---|---|---|
| SEC-027 | applies | abuse: SECURITY-EXAMPLE "Landing does not redirect off-site" |
| SEC-050 | applies | abuse: "Used handoff code is rejected", "Expired…", "Other audience…" |
| SEC-058 | applies | authz-matrix rows `invoice:*` |
| SEC-023 | not-applicable | page not embeddable; frame-ancestors 'none' unchanged |

Abuse cases (malicious user / malicious tenant / bot):
- …
```
