# Domain 8 — Software supply chain

Most of the code running in a JavaScript SaaS was written by strangers and arrives through `npm install`. Software Supply Chain Failures entered the OWASP Top 10 (2025) at third place. The attacks are no longer only old CVEs in unpatched libraries (Equifax, Log4Shell); they are maintainers phished and packages republished with malware that runs at install time or in your users' browsers.

---

### SEC-094 · Commit lockfiles and install only from them
`ASVS:V15` `CWE-1357` `T10:A03` `SLSA` · verify: sca, ci · severity: high

`npm ci`, `pnpm install --frozen-lockfile`, `uv sync --locked`, `pip install --require-hashes`, `cargo build --locked`. CI fails when the lockfile is missing or out of date. Without a lockfile every build can pull a version nobody reviewed.

### SEC-095 · Scan dependencies on every change and every day, with a remediation deadline
`ASVS:V15` `CWE-1395` `T10:A03` · verify: sca · severity: critical

Every PR and a daily scheduled run on the default branch query OSV/GitHub advisories for the whole lockfile, transitive dependencies included. Critical and high findings, and anything listed in CISA's Known Exploited Vulnerabilities catalogue, fail the gate. Findings that appear on the default branch between changes get a deadline (P11). Equifax (2017) was breached through an Apache Struts flaw two months after the fix was published; Log4Shell (2021) was a one-line lookup in a logging library almost everyone had transitively.

### SEC-096 · Wait before adopting a freshly published version
`CWE-1357` `T10:A03` · verify: sca · severity: high

A minimum release age (default 7 days) for new versions, except for fixes of known vulnerabilities — Renovate `minimumReleaseAge`, Dependabot `cooldown`, pnpm `minimumReleaseAge`. In September 2025 a phished maintainer's account published malicious versions of `chalk`, `debug` and other packages with billions of weekly downloads, carrying a browser-side crypto-wallet drainer; the same month the self-replicating "Shai-Hulud" worm stole npm and GitHub tokens from developers' machines and republished itself into hundreds of packages. Both were caught within hours to days — a cooldown would have skipped them.

### SEC-097 · Disable install-time scripts by default
`CWE-829` `T10:A03` · verify: sca, ci · severity: high

`npm config set ignore-scripts true` (or `.npmrc`), pnpm's allow-list of packages permitted to build; allow the few packages that genuinely need a build step by name. Install scripts run with the developer's or the CI runner's credentials — that is how the 2025 worms spread.

### SEC-098 · Vet every new dependency before it enters the lockfile
`ASVS:V15` `CWE-1357` `T10:A03` · verify: sca, adversary · severity: high

Does the package exist, and is it the one you meant (typosquatting; "slopsquatting" — names that AI assistants hallucinate and attackers then register)? Who maintains it, how old is it, how many people use it, does it publish with provenance, what does its licence allow, and does it pull in a large tree? Prefer the standard library and fewer, larger, well-maintained dependencies. A new runtime dependency is already a P10 significance trigger; P11 adds the security review.

### SEC-099 · Produce an SBOM for every build
`ASVS:V15` `T10:A03` `SLSA` · verify: sbom · severity: medium

CycloneDX or SPDX, generated in CI and stored with the build artefact, so "are we affected by CVE-X?" becomes a query across releases instead of an investigation. During Log4Shell the organisations with an SBOM answered in minutes.

### SEC-100 · Pin CI actions by commit SHA and base images by digest
`CWE-829` `T10:A03` `SLSA` · verify: ci, iac · severity: high

Tags move. In March 2025 the tags of the popular `tj-actions/changed-files` GitHub Action were repointed to a malicious commit that printed CI secrets into public logs (CVE-2025-30066). Pin `uses:` to a full 40-character SHA with the version in a comment, and `FROM` to `image@sha256:…`; let a bot propose updates.

### SEC-101 · Give CI the least privilege and never run untrusted code with secrets
`CWE-94` `CWE-250` `T10:A03` · verify: ci · severity: critical

Workflow-level `permissions: contents: read`, elevated per job only where needed; OIDC federation to the cloud instead of long-lived keys; no secrets exposed to pull requests from forks; never check out and run a fork's code under `pull_request_target` or `workflow_run`; never interpolate `${{ github.event.* }}` text (titles, branch names, comments) directly into `run:` scripts — pass it through an environment variable. Static analysis of workflows (zizmor, actionlint) catches most of these.

### SEC-102 · Verify everything the build downloads
`CWE-494` `T10:A08` · verify: ci, sast · severity: high

No `curl … | bash`. Download, check a pinned checksum or signature, then execute. In 2021 a modified Codecov uploader script exfiltrated environment variables — cloud keys and tokens — from thousands of customers' CI runs.

### SEC-103 · Protect the path from commit to production
`CWE-345` `T10:A08` `SLSA` · verify: ci, config · severity: high

Branch protection with required reviews on protected paths (P06); phishing-resistant MFA on GitHub, registry and cloud accounts; package publishing through trusted publishing (OIDC) with provenance attestations rather than long-lived tokens; build provenance for deployable artefacts. The xz-utils backdoor (2024, CVE-2024-3094) was planted by a contributor who spent two years earning maintainer trust — the controls that matter are the ones that do not depend on trusting any single person.

### SEC-104 · Run only supported versions of runtimes, frameworks and base images
`ASVS:V15` `CWE-1104` `T10:A03` · verify: sca, iac · severity: high

End-of-life components no longer receive security fixes, so every future CVE in them is permanent. EOL dates are tracked, and a component inside its last six months of support is a finding.

### SEC-105 · Remove what you do not use
`ASVS:V15` `CWE-1104` · verify: sca · severity: low

Unused dependencies (knip, depcheck, deptry), dead feature flags, and orphaned endpoints are attack surface with no benefit.

### SEC-106 · Treat responses from third-party APIs as untrusted input
`ASVS:V4` `CWE-20` `API:API10` · verify: adversary · severity: medium

Validate their schema, bound their size, time them out, and never follow their redirects or render their HTML blindly. A compromised or spoofed provider is an injection source like any user.
