# security — controls catalogue

Normative text is in [`policies/P11-security.md`](../policies/P11-security.md). This directory is the corpus that policy points at, plus the reference tooling that verifies part of it.

One hundred and fifty-two controls, `SEC-001` – `SEC-152`, for web applications and SaaS products — the kind that users reach in a browser, often already signed in through a redirect from somewhere else, and that hold other people's personal data. Compiled 2026-09-25.

## How the catalogue was built

The world does not lack security checklists; it has too many, and they overlap. The catalogue is a **de-duplicated synthesis**:

- **Backbone:** [OWASP ASVS 5.0](https://github.com/OWASP/ASVS) — the most complete verifiable standard for web applications. Every control cites the ASVS chapter it belongs to.
- **Prioritisation:** OWASP Top 10 (2025), OWASP API Security Top 10 (2023), the 2025 CWE Top 25 — they say which controls fail most often in practice; they add few controls of their own.
- **Gaps the backbone covers thinly:** bots and business-flow abuse (OWASP Automated Threats), supply chain (SLSA, OpenSSF, recent npm incidents), AI components (OWASP Top 10 for LLM Applications 2025, OWASP Top 10 for Agentic Applications 2026), privacy law (LGPD), and the one no external standard covers: code written by agents that nobody reads (Domain 14).
- **Evidence:** every domain cites real incidents. The full list, with what each one teaches, is in [`CASES.md`](CASES.md).

Where two sources say the same thing, the catalogue says it once and cites both. The rules are **rewritten, not extracted**: operational form, not the source's text. Use the sources for depth — [`SOURCES.md`](SOURCES.md) says which one to open for what.

## Domains

| File | Domain | Range |
|---|---|---|
| [DOMAIN-01-input.md](DOMAIN-01-input.md) | Input and injection | SEC-001 – SEC-017 |
| [DOMAIN-02-browser.md](DOMAIN-02-browser.md) | Browser and client side | SEC-018 – SEC-034 |
| [DOMAIN-03-authentication.md](DOMAIN-03-authentication.md) | Authentication | SEC-035 – SEC-047 |
| [DOMAIN-04-sessions.md](DOMAIN-04-sessions.md) | Sessions, tokens and single sign-on | SEC-048 – SEC-056 |
| [DOMAIN-05-authorization.md](DOMAIN-05-authorization.md) | Authorization and tenant isolation | SEC-057 – SEC-067 |
| [DOMAIN-06-data.md](DOMAIN-06-data.md) | Data protection, cryptography and privacy | SEC-068 – SEC-079 |
| [DOMAIN-07-availability.md](DOMAIN-07-availability.md) | Availability, abuse and bots | SEC-080 – SEC-093 |
| [DOMAIN-08-supply-chain.md](DOMAIN-08-supply-chain.md) | Software supply chain | SEC-094 – SEC-106 |
| [DOMAIN-09-infrastructure.md](DOMAIN-09-infrastructure.md) | Configuration, infrastructure and cloud | SEC-107 – SEC-119 |
| [DOMAIN-10-files.md](DOMAIN-10-files.md) | Files and uploads | SEC-120 – SEC-125 |
| [DOMAIN-11-business-logic.md](DOMAIN-11-business-logic.md) | Business logic | SEC-126 – SEC-130 |
| [DOMAIN-12-detection-response.md](DOMAIN-12-detection-response.md) | Logging, detection and response | SEC-131 – SEC-139 |
| [DOMAIN-13-ai.md](DOMAIN-13-ai.md) | AI and LLM components | SEC-140 – SEC-147 |
| [DOMAIN-14-agent-built-code.md](DOMAIN-14-agent-built-code.md) | Code written by agents | SEC-148 – SEC-152 |

Views across the domains:

- [`ATTACKS.md`](ATTACKS.md) — the attacker's index: each attack class, the controls that stop it, and how to test for it. Start here when the question is "could someone do X to us?".
- [`CASES.md`](CASES.md) — incidents and what they teach, each linked to the controls that would have prevented it.
- [`REVIEW.md`](REVIEW.md) — the protocol the `adversary` layer follows for a security pass, and [`finding.schema.json`](finding.schema.json), the shape of its output.
- [`THREAT-MODEL-TEMPLATE.md`](THREAT-MODEL-TEMPLATE.md) — the project-level threat model and the per-SPEC security section.

## Entry format

```
### SEC-058 · Check object ownership on every access by identifier
`ASVS:V8` `CWE-639` `API:API1` `T10:A01` · verify: abuse · severity: critical

What the threat is, what the control is, the incident that shows it matters, and — where it is
mechanical — the test that proves it.
```

The tag line is mandatory and machine-checked:

- **References** (at least one): `ASVS:Vn` (ASVS 5.0 chapter), `T10:Ann` (OWASP Top 10 2025), `API:APIn` (API Security Top 10 2023), `CWE-n`, `LLM:LLMnn` (LLM Top 10 2025), `ASI:ASInn` (Agentic Top 10 2026), `OAT:OAT-nnn` (Automated Threats), `NIST:<doc>`, `CIS:n` (CIS Controls v8.1), `PCI:<req>` (PCI DSS 4.0), `LGPD:art.n`, `RFCn`, `SLSA`, `AP-nnn` (a crivo architecture principle), `crivo` (crivo-specific).
- **`verify:`** — the mechanisms that can show the control holds, from the set below.
- **`severity:`** — `critical`, `high`, `medium` or `low`: the typical impact when the control is missing. It sets the default gate for findings mapped to the control.

## Verification mechanisms

| Mechanism | What verifies it | Where |
|---|---|---|
| `sast` | Static analysis: Semgrep registry rules plus the crivo rules in [`semgrep/`](semgrep/) | `security` layer |
| `secrets` | Secret scanning of the change and, on schedule, of the full history | `security` layer |
| `sca` | Dependency vulnerability audit and dependency policy | `security` layer |
| `sbom` | Software bill of materials produced per build | `security` layer |
| `iac` | Infrastructure, container and platform configuration scanning | `security` layer |
| `ci` | CI workflow analysis | `security` layer |
| `headers` | Response headers and browser policy of the running deployment ([`checks/headers.sh`](checks/headers.sh)) | `security` layer, after `e2e` |
| `dast` | Dynamic scanning of the running deployment | `security` layer, after `e2e` |
| `fuzz` | Schema-driven API fuzzing | `security` layer, after `e2e` |
| `abuse` | `@security` Gherkin scenarios, the authorization matrix and the route manifest, written by the human | `e2e` layer; coverage checked by `security` |
| `test` | Unit or integration tests the agent writes | `unit`, `e2e` |
| `property` | Property tests on an `INV-nnn` invariant | `property` |
| `lint` | A lint rule | `lint` |
| `adversary` | Only a reviewer can judge it | `adversary` layer security pass ([`REVIEW.md`](REVIEW.md)) |
| `config` | Lives outside the code; verified by linked evidence in the threat model | `security` layer checks the link resolves |

`adversary` and `config` are the honest labels. A control verified only by them is not mechanically enforced, and the EVIDENCE report says so.

## Reference tooling

- [`check.sh`](check.sh) — catalogue integrity: ID contiguity and uniqueness, tag-line format, known mechanisms and severities, resolvable `SEC-` references across the repository. Run by the `security` layer (`catalogue` check).
- [`checks/suppressions.sh`](checks/suppressions.sh) — SEC-148: scanner suppressions need a `RULE-` or issue reference.
- [`checks/headers.sh`](checks/headers.sh) — SEC-020 – SEC-024, SEC-026, SEC-031, SEC-032, SEC-137 against a URL. Usable today against any deployment: `security/checks/headers.sh https://app.example.com`.
- [`semgrep/`](semgrep/) — twenty rules for JavaScript/TypeScript, JSX, Python and HTML templates, each tagged with the control it enforces, each with a test fixture (`semgrep --test security/semgrep`). They target what the registry rulesets cover weakly or do not map to the catalogue: credentials in URLs (SEC-050), reflected CORS (SEC-024), third-party scripts without SRI (SEC-029), `Math.random` secrets (SEC-070), unverified JWTs (SEC-051), and others. Run them **together with** the registry rulesets, not instead.

## Using it on a project

1. Copy `security/` into the project next to `principles/`; add it to the protected paths (P06).
2. Set `security.level` in the project's `layers.yaml` (level 2 for a SaaS with personal data) and fill the adapter commands.
3. Write `spec/security/threat-model.md` from the template: assets, entry points, trust boundaries, the redirect/handoff flows, and a verdict per domain.
4. Write `spec/security/authz-matrix` and `spec/security/public-routes`. These two files catch more real SaaS breaches than any scanner.
5. Run the gauntlet. Read the security section of EVIDENCE.

For an existing codebase, the first run is an audit: run the `adversary` security pass (`REVIEW.md`) over the whole repository rather than a diff, and triage its findings into issues with the P11 deadlines.

## Ownership

Protected path (P06). The agent reads this directory; it does not write to it. New controls arrive by `proposals/security/SEC-nnn.proposed`, and a human moves them in.
