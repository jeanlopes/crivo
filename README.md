# crivo

**Don't read the code. Make it pass the sieve.**

*Crivo* is Portuguese for *sieve*. "Passar pelo crivo" — to pass through the sieve — is what Brazilians say when something has survived rigorous scrutiny. This repository is a set of enforceable policies, a layered gauntlet, and reference tooling for trusting code written by AI agents that no human will ever read line by line.

## The four principles

1. **Reading agent code slows you down.** The productivity of agents is only realizable if the human stops reviewing diffs. Trust has to be carried by something else. → [P01](policies/P01-no-read.md)
2. **Extreme constraints.** The agent is surrounded by machine-enforced gates: types, lint, tests, structural metrics, mutation testing, property tests, traced trajectories, real execution, security scans, adversarial review. → [P02](policies/P02-constraints.md)
3. **The gauntlet.** Constraints run as an ordered, fail-fast pipeline. Nothing in a prompt counts; only what runs in CI, hooks, or file permissions counts. → [P03](policies/P03-gauntlet.md)
4. **A calibrated confidence index.** The repository reports a number — per module, aggregated by blast radius — that says how much the gauntlet lets you trust it, and that number is calibrated against defects that actually escaped. → [P04](policies/P04-confidence.md)

## What the human reads instead of code

| Before the agent writes code | After the gauntlet passes |
|---|---|
| The [SPEC](spec/SPEC-TEMPLATE.md): a test plan and Gherkin scenarios | The [EVIDENCE](evidence/EVIDENCE-TEMPLATE.md) report from one clean run |
| The [rules registry](rules/REGISTRY.md) entries the change touches | The confidence index delta |
| The [ADR](decisions/ADR-TEMPLATE.md), when the change is architecturally significant | The violation ledger, and any revisit trigger that came due |
| The [threat model](security/THREAT-MODEL-TEMPLATE.md), authorization matrix and abuse scenarios, when the change is security-relevant | Security findings, overdue vulnerabilities, control coverage |
| — | Golden trajectory diffs, when a traced test diverged |
| — | Adversarial reviewer findings |

Everything in the left column is human-owned and agent-read-only ([P06](policies/P06-protected-paths.md)). Everything in the right column is produced by machines the agent cannot edit.

## Security

Security is where not reading the code is most dangerous, so it gets its own policy ([P11](policies/P11-security.md)) and its own corpus ([security/](security/README.md)): 152 controls in fourteen domains — injection, browser, authentication, sessions and SSO, authorization and tenancy, data and privacy (LGPD), availability and bots, supply chain, infrastructure, files, business logic, detection and response, AI components, and code written by agents — de-duplicated from OWASP ASVS 5.0, the OWASP Top 10 (2025), the API Security Top 10, the 2025 CWE Top 25 and the other standards in [SOURCES](security/SOURCES.md), and grounded in [real incidents](security/CASES.md). Each control names the mechanism that verifies it; the `security` layer runs the mechanical ones (SAST with crivo's own rules, secrets, dependency audit and release-age policy, SBOM, IaC and CI analysis, header and CORS probes, DAST, API fuzzing), the human writes the abuse scenarios and authorization matrix that no scanner can infer, and the adversary runs a [security review protocol](security/REVIEW.md) walking the [attacker's index](security/ATTACKS.md).

## Original contributions

Most of this repository is curation. Two things are not:

- **Traced tests** ([P05](policies/P05-traced-tests.md), [traced/](traced/)) — characterization testing lifted from outputs to internal state. A test run records a *trajectory* of *frames* (scoped variable trees at function boundaries). An approved trajectory becomes a *golden*; a later run that differs reports the *first divergence* — the exact frame and variable where state left the rails. Trajectories also kill mutants that ordinary tests miss.
- **Comments as pointers** ([P07](policies/P07-comments.md), [rules/](rules/)) — long explanations live in a rules registry with stable IDs; code comments are one line plus an ID. This makes hidden, distributed business rules discoverable by agents and makes comment quality measurable.

## Repository map

```
policies/     P01–P11, normative (RFC 2119), each pointing to its enforcement mechanism
gauntlet/     layers.yaml (declarative pipeline) + per-stack adapters
spec/         SPEC template and Gherkin features — human-owned
evidence/     EVIDENCE report template
scoring/      confidence index: formula, reference calculator, calibration protocol
traced/       trajectory format, normalization rules, MCP debugger server design
rules/        rules registry format and template
principles/   90 architecture principles, AP-001–AP-090, by axis of decision
decisions/    ADR registry and template — the record P10 gates
security/     152 security controls, SEC-001–SEC-152, by domain; attacks index, cases, review protocol, semgrep rules, checks — P11
comments/     banned phrases, judge output schema
templates/    AGENTS.md, CI workflow, protected-path hooks, CODEOWNERS
rationale/    why — essays, not policy
```

## Quick start

1. Copy `templates/AGENTS.md` to your project root (or `CLAUDE.md`).
2. Copy `templates/hooks/` and `templates/CODEOWNERS`, adjust paths. **Do this first** — without protected paths nothing else is real.
3. Copy `gauntlet/layers.yaml` and the adapter for your stack; fill in commands. Copy `security/`, set the P11 level, and write `spec/security/threat-model.md` from the template.
4. Write your first `spec/features/*.feature`. Approve it. Let the agent go. If the change fires a significance trigger ([P10](policies/P10-architecture-decisions.md)), approve the ADR too.
5. Read `evidence/EVIDENCE.md` when it comes back. Not the diff.

## Status

Skeleton. Policies are drafted; reference tooling under `scoring/calc/` and `traced/mcp-server/` is specification plus minimal implementation. Adapters for Python and TypeScript are filled; Rust and .NET list the tool matrix only.

## Origin

Robert C. Martin, July 2026, replying to a developer who said he needed to understand any code he was responsible for: he no longer reads code written by his agents; he surrounds them with extreme constraints instead — unit tests, Gherkin, QA procedures, quality metrics, mutation testing, coverage — and trusts what survives the gauntlet. See [rationale/00-origin.md](rationale/00-origin.md) for what that gets right and what it leaves out.

## License

MIT.
