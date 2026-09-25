# Calibration changelog

| Date | Change | Escapes (n) | Rationale |
|---|---|---|---|
| 2026-09-11 | Initial default weights | 0 | Priors from P04; uncalibrated |
| 2026-09-11 | N: added `adr_coverage` 0.15; renormalised the other six | 0 | P10. Prior, not a fit — no escape data distinguishes a missing ADR from a missing doc header. Taken proportionally from the five comment/doc gradients, leaving `registry_coverage` dominant. |
| 2026-09-25 | `security` layer thresholds (P11): block on critical/high and CISA KEV; `dependency_min_age_days` 7; remediation 7/30/90 days; exceptions ≤ 90 days. No weight change — `security` stays a gate; `control_coverage` is reported in EVIDENCE, not weighted | 0 | Priors from P11 and industry practice (OWASP, CISA KEV guidance). Revisit once `security` escapes exist to fit against. |
