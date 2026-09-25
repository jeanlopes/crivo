# EVIDENCE — <change title>

Generated from **one fresh run**. All numbers below come from that run and nothing else.

| | |
|---|---|
| Commit | `<sha>` · tree `<tree-hash>` |
| Entry command | `crivo run --evidence` |
| SPEC | `spec/<name>.md` · approved by <human> on <date> |
| Confidence index | touched modules: <before> → <after> · repo: <before> → <after> <(uncalibrated)> |

## Layers

| Layer | Kind | Result | Metric | Threshold |
|---|---|---|---|---|
| types | gate | pass | — | — |
| lint | gate | pass | suppressions: 0 | 0 |
| unit | gate | pass | 184/184 ×3, flaky 0.00 | — |
| coverage | gradient | pass | changed-line 0.97 | ≥ 0.90 |
| structure | gate | pass | max cc 8 · arch viol. 0 | ≤10 · 0 |
| architecture | gate | pass | ADR-0007 · 7/7 axes · 0 expired | complete · 0 |
| mutation | gradient | pass | 0.91 (41/45) · +3 by trajectory | ≥ 0.85 |
| property | gradient | pass | 6/6 invariants | ≥ 0.80 |
| traced | gradient | pass | 12/12 goldens match | 1.0 |
| comments | gate | pass | — | — |
| docs | gate | pass | — | — |
| e2e | gate | pass | 9/9 scenarios · real DB | — |
| security | gate | pass | level 2 · 0 crit/high · 0 overdue | 0 · 0 |
| adversary | gradient | pass | 0 unresolved | 0 |

## Security (P11)
Triggers fired: 1 (new route), 5 (redirect handling) · Domains: 2, 4, 5 · Threat-model delta: approved

| Check | Result | Detail |
|---|---|---|
| sast | pass | 0 errors · rules: registry + `security/semgrep` (20) |
| secrets | pass | 0 |
| sca | pass | 0 crit/high · 0 KEV · 2 medium → #311, #312 · new deps: 0 |
| sbom | pass | `.crivo/results/sbom.cdx.json` · 412 components |
| iac · ci | pass | 0 · 0 (all actions SHA-pinned) |
| headers | pass | CSP strict · HSTS · CORS probe clean · no source maps |
| dast · fuzz | pass | ZAP baseline 0 FAIL · 1 840 generated requests, 0 5xx |
| abuse | pass | 9/9 `@security` scenarios · authz matrix 48/48 cells · public routes 3 = manifest |
| suppressions | pass | 0 unreferenced |

Control coverage (applicable controls with a passing mechanism): 71/74 · verified only by `config` evidence: 12 · only by `adversary`: 3
Open exceptions: 0 · Findings past deadline: **0**

## Surviving mutants
| Mutant | Location | Classification |
|---|---|---|
| M07 `>=` → `>` | itinerary.py:88 | equivalent — boundary excluded by INV-012 |

## Architecture decisions
| ADR | Status | Axes | Violations recorded |
|---|---|---|---|
| ADR-0007 | accepted | 7/7 | AP-007 — revisit: write throughput > 200/s |

Violation ledger: <n> open · <n> due within 90 days · **0 expired**

## Golden trajectories
- created: `traced/golden/test_reject_overlap.<hash>.jsonl` — **awaiting approval**
- updated: none · diverged: none

## Adversarial findings
| # | Severity | Control | Location | Attack | Status |
|---|---|---|---|---|---|
| — | | | | | |

## Spec → test mapping
3/3 scenarios mapped.

## Reproduce
```
git checkout <sha> && crivo run --evidence
```
