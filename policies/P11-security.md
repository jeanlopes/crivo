# P11 — Security

**Status:** normative · **Enforced by:** `security` layer (`gauntlet/layers.yaml`), `adversary` layer security pass, `security/check.sh`, `security/checks/`, protected paths (P06)

## Statement

A conforming project MUST run the `security` layer at its declared level, MUST keep a threat model and abuse scenarios for every change that fires a security trigger, and MUST NOT carry a security finding past its deadline without a recorded, expiring exception.

The standard against which agent work is judged is the controls catalogue in [`security/`](../security/README.md): 152 controls, `SEC-001` – `SEC-152`, in fourteen domains, each mapped to OWASP ASVS 5.0, the OWASP Top 10 (2025), CWE and the other references in [`security/SOURCES.md`](../security/SOURCES.md), and each naming the mechanism that verifies it.

## Why security is a separate policy

P01 removes the human from the diff. For most defects the gauntlet compensates with tests the agent must write and mutants it must kill. Security defects are different in two ways that make the compensation insufficient on its own:

1. **The failing case is not in the spec.** Tests check what the SPEC asks for. A vulnerability is almost always behaviour the SPEC never mentioned — the second tenant, the replayed code, the thousandth request. P11 makes the human write those cases down (abuse scenarios, authorization matrix), because nothing else will.
2. **The cost is asymmetric and external.** A logic bug hurts the feature; a vulnerability hurts the users whose data leaves. That justifies gates that block on findings the author disagrees with, and deadlines that do not wait for the next change.

## Adoption levels

The level is declared in `layers.yaml: security.level` (protected, P06). The levels follow ASVS: level 1 is the minimum for anything on the internet; level 2 is the default for a SaaS that holds personal data.

| Level | Checks the `security` layer runs | Additional records |
|---|---|---|
| 1 | `sast`, `secrets`, `sca`, `suppressions`, `catalogue`, `headers` | — |
| 2 | level 1 + `sbom`, `iac`, `ci`, `dast`, `fuzz`, `abuse` | project threat model, authorization matrix, public-route list; adversary security pass on trigger |
| 3 | level 2 + active DAST on schedule, full-history secret scan per PR | yearly external pentest recorded (SEC-138), incident exercise recorded (SEC-135) |

A project that processes personal data (LGPD art. 5 I) MUST NOT declare a level below 2.

## Security triggers

A change is security-relevant when the `security` layer observes any trigger below. Triggers are computed from the diff, so the agent cannot declare itself exempt.

1. A route, server action, GraphQL operation, websocket handler, webhook or queue consumer is added or its signature changes.
2. A file matching `security.sensitive_paths` changes (defaults: authentication, session, token, password, MFA, OAuth, permission, policy, tenant, RLS, crypto).
3. A new sink appears: raw query, shell, template compilation, deserialization, file-system path from input, outbound URL fetch, raw HTML — detected by the `sink_inventory` rules.
4. A dependency is added or upgraded, a lockfile changes, or a third-party script or stylesheet is referenced.
5. CORS, CSP, cookie, header, redirect or CSRF configuration changes.
6. A persistent field classified `personal` or `sensitive` is added, or a new export or upload path appears.
7. Infrastructure, container or CI definitions change.
8. A non-deterministic component or one of its tools changes (P09).

A project MAY add triggers. A project MUST NOT remove triggers 1–6.

## What a triggered change MUST carry

- **Threat-model delta.** The SPEC's *Security* section names the triggered domains and, for each, a verdict on every control of that domain: `applies` (with the mechanism that verifies it here), `not-applicable` (with one line of justification), or `exception` (with an entry in the exception register). A domain left without verdicts fails — the same gate on the record that P10 applies to architecture.
- **Abuse scenarios.** At least one `@security` Gherkin scenario per triggered domain among 1–5, 7, 10 and 11, tagged with the `SEC-nnn` it exercises (template: [`spec/features/SECURITY-EXAMPLE.feature`](../spec/features/SECURITY-EXAMPLE.feature)). They run in the `e2e` layer against real dependencies.
- **Authorization matrix cells.** A new route or resource adds its rows to `spec/security/authz-matrix`; every cell, allow and deny, has a test (SEC-062).
- **Public-route list.** A route reachable without authentication appears in `spec/security/public-routes` with a reason; the route-manifest test fails on any route that is neither authenticated nor listed (SEC-035).
- **Adversary security pass.** The `adversary` layer runs the protocol in [`security/REVIEW.md`](../security/REVIEW.md) in a separate context, and every finding is resolved or accepted as P03 requires.

`spec/security/` is under `spec/**` and therefore protected (P06): the human approves the threat model and the matrix; the agent reads them.

## The checks

Each check realizes one or more of the `verify:` mechanisms the catalogue uses. Reference commands per stack are in `gauntlet/adapters/`.

| Check | Mechanism | Reference tools | Fails when |
|---|---|---|---|
| `sast` | `sast` | Semgrep registry rulesets + [`security/semgrep/`](../security/semgrep/) (rule IDs carry their `SEC-nnn`); Bandit for Python | any finding of severity `ERROR` |
| `secrets` | `secrets` | gitleaks on the change; full history on schedule | any finding. The remedy is revoke and rotate (SEC-071), not a history rewrite |
| `sca` | `sca` | osv-scanner on every lockfile, ecosystem audit, registry signature verification, dependency policy | critical or high; anything in CISA KEV; missing lockfile; a new version younger than `dependency_min_age_days`; install scripts not disabled |
| `sbom` | `sbom` | syft or cdxgen, CycloneDX | SBOM not produced |
| `iac` | `iac` | Trivy config, Checkov | high or critical misconfiguration |
| `ci` | `ci` | zizmor, actionlint | any finding at medium or above; an action not pinned by SHA |
| `headers` | `headers` | [`security/checks/headers.sh`](../security/checks/headers.sh) against the e2e deployment | any `FAIL` line |
| `dast` | `dast` | OWASP ZAP baseline (passive) per PR; active scan on schedule | any alert configured `FAIL` in the project's ZAP rules file |
| `fuzz` | `fuzz` | Schemathesis from the OpenAPI/GraphQL schema | any 5xx, schema violation, or response-time check failure |
| `abuse` | `abuse` | `@security` scenarios in `e2e`; matrix and route-manifest coverage | a triggered domain with no scenario; an untested matrix cell; an unlisted public route |
| `suppressions` | `lint` (SEC-148) | [`security/checks/suppressions.sh`](../security/checks/suppressions.sh) | a scanner suppression without a `RULE-` or issue reference on the same line |
| `catalogue` | — | [`security/check.sh`](../security/check.sh) | malformed control, unknown mechanism, dead `SEC-` reference |

Controls whose mechanism is `test`, `property` or `lint` are verified by the existing layers of the same name. Controls whose mechanism is `config` live outside the code — edge, DNS, cloud accounts, runbooks — and are verified by **presence of evidence**: the threat model links each applicable `config` control to the file, IaC resource or dated record that shows it. The `security` layer checks that the link exists and resolves. It cannot check that a WAF rule holds under attack; P11 does not pretend otherwise.

## Severity, deadlines and exceptions

- **On a change:** critical and high findings block. Medium and low findings are listed in EVIDENCE and MUST each have an issue.
- **On the default branch, between changes:** the scheduled `sca`, `secrets` and `dast` runs find vulnerabilities published after the code merged. Each finding opens an issue with a deadline — critical 7 days, high 30, medium 90 (`remediation_days`). A finding past its deadline fails the `security` layer on every subsequent change until it is resolved. This is the P09/P10 ratchet applied to exposure time.
- **Exceptions.** A finding that cannot be fixed in time is recorded in `spec/security/exceptions.yaml`: `finding`, `control`, `reason`, `compensating_control`, `owner`, `expires` (at most `exception_max_days`, default 90). Expired exceptions fail. The agent MAY propose an exception; only a human can accept it (P06).

## Suppressions and scanner configuration

Every scanner suppression follows P02: zero, unless the same line carries a `RULE-` or issue reference (SEC-148). Scanner configuration and ignore files — `.semgrepignore`, `.gitleaks.toml`, `.gitleaksignore`, `.trivyignore`, `osv-scanner.toml`, `.snyk`, ZAP rules files, audit allow-lists — are protected paths (P06). An agent that can edit a scanner's configuration can make the scanner agree with it.

## Cadence

| When | Scope |
|---|---|
| Every PR | Triggers; the checks of the declared level on the diff; threat-model and abuse-scenario records; adversary security pass on trigger |
| Nightly | `sca` and `secrets` (full history) on the default branch; `fuzz` full; `dast` active scan against staging (level 3) |
| Weekly | `headers` against every production hostname in the inventory (SEC-114) |
| Quarterly | Catalogue review against new OWASP, CWE and CISA publications and new case studies (`security/CASES.md`); expired exceptions; access review of admin tooling (SEC-047) |
| Yearly | External pentest (SEC-138) and incident-response exercise (SEC-135), recorded with dates in the threat model |

## Calibration

Security escapes go in `scoring/calibration/escapes.csv` with category `security` and the violated control in the `issue` field (`SEC-058 #231`). Each escape adds a planted defect under `scoring/calibration/planted/` (for example a missing tenant filter, a reflected CORS origin, a token in a redirect URL) so that gauntlet recall on security defects is measured, not assumed (SEC-139).

## Ownership

`security/` is a protected path (P06), for the same reason as `principles/`: it is the standard the agent's work is measured against. New controls arrive by `proposals/security/SEC-nnn.proposed`. `security/check.sh` enforces ID contiguity, reference format, known mechanisms and resolvable `SEC-` references.

## Limits

- **Specification gaps dominate.** Access control and business-logic flaws are invisible to scanners. The matrix and the abuse scenarios are only as complete as the human who writes them; missing ones surface as `spec-gap` escapes.
- **Patterns, not intent.** SAST finds known shapes. A permissive authorization rule that the tests expect passes every layer; the adversary pass reduces this probabilistically, not certainly (rationale/01).
- **Outside the repository.** Volumetric DDoS absorption, WAF effectiveness, provider account security and human phishing resistance are verified by evidence of configuration, not by execution.
- **Coverage follows the e2e environment.** `headers`, `dast` and `fuzz` see what the e2e deployment exposes. A route that only exists in production is outside their reach — which is why the inventory (SEC-114) and the weekly production header check exist.
- **A clean gauntlet is not a pentest.** It raises the floor; people still find what nobody specified (SEC-138).
