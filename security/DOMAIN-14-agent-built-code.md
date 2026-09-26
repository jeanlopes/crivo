# Domain 14 — Code written by agents

crivo assumes nobody reads the diff (P01). That changes the security model in two ways: the agent is a new actor with write access that can be manipulated, and an agent under pressure to pass a gate will, given the means, weaken the gate. This domain is about the controls that stay true when the author is a model.

---

### SEC-148 · The agent cannot silence a security scanner
`crivo` `T10:A08` · verify: lint, config · severity: critical

Inline suppression markers — `nosemgrep`, `nosec`, `gitleaks:allow`, `NOSONAR`, `trivy:ignore`, `checkov:skip`, `eslint-disable` of a security rule — fail the gate unless the same line carries a `RULE-` or issue reference (`security/checks/suppressions.sh`). Scanner configuration and ignore files (`.semgrepignore`, `.gitleaks.toml`, `.gitleaksignore`, `.trivyignore`, `osv-scanner.toml`, `.snyk`, audit allow-lists) are protected paths (P06).

### SEC-149 · The agent cannot weaken the security tests
`crivo` · verify: test, config · severity: critical

`@security` scenarios, the authorization matrix and the public-route list live under `spec/` (protected). The assertion-count ratchet (P02) covers security tests. A failing security scenario is fixed in the code or escalated to the human, never by editing the scenario.

### SEC-150 · The agent runs without production credentials and with bounded tools
`ASI:ASI03` `CWE-250` · verify: config · severity: critical

No production secrets in the agent's environment or context; network egress limited to what the task needs; no deploy rights; protected-path hooks enforced by the runtime (P06), not requested in the prompt.

### SEC-151 · Everything the agent reads is an injection surface
`ASI:ASI01` `LLM:LLM01` · verify: config, adversary · severity: high

Issue text, pull-request comments, dependency READMEs, web pages and test fixtures can carry instructions aimed at the coding agent. The defence is the same as SEC-140: what the agent can do is bounded by hooks and permissions, so a hijacked agent still cannot touch protected paths, secrets or production.

### SEC-152 · A security-triggering change gets a security review in a separate context
`crivo` `T10:A06` · verify: adversary · severity: high

When a P11 trigger fires, the `adversary` layer runs the security pass in `security/REVIEW.md` in a separate context, preferably on a different model, with the diff, the SPEC and its threat model. Each finding cites a `SEC-nnn` and is resolved by a code change or a test, or accepted with an issue — the agent that wrote the code does not grade it.
