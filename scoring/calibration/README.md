# Calibration

The confidence index is an opinion with decimals until this directory has data.

## escapes.csv
Every defect discovered **after** the gauntlet passed. One row each.

```
date,commit,module,category,severity,C_at_commit,layer_that_should_have_caught,issue
```
Categories: `logic`, `boundary`, `concurrency`, `integration`, `security`, `data`, `spec-gap`, `perf`.
`spec-gap` is the category the gauntlet cannot catch by construction (P01, Limits); track it anyway — it measures the human.
`security` rows put the violated control first in the `issue` field (`SEC-058 #231`), so recall can be read per catalogue domain (P11, SEC-139).

## planted/
A dataset of planted defects for measuring gauntlet **recall by category** (P09, meta-evaluation). Each entry: a patch that introduces a known defect, its category, and the layer expected to catch it. `crivo calibrate` applies each patch on a branch, runs the gauntlet, records caught/missed.

```
planted/
  P-0001-off-by-one-boundary.patch
  P-0001.yaml     # {category: boundary, expected_layer: mutation, description: ...}
```

Security planted defects (P11) cover the controls with a mechanical check, so that each check's recall is measured rather than assumed: a query built by interpolation (SEC-001, `sast`), a missing tenant filter (SEC-058, `abuse`), a route without authentication (SEC-035, `abuse`), a reflected CORS origin (SEC-024, `headers`), a token in a redirect URL (SEC-050, `sast`), an unpinned action (SEC-100, `ci`), a dependency younger than the release-age threshold (SEC-096, `sca`).

## Re-fitting weights
Quarterly. Fit `weights.yaml` so that C at commit predicts escape probability (logistic regression on `escapes.csv`, gradients as features). Record before/after in `CHANGELOG.md`. Until ≥ 30 escapes exist, weights stay at defaults and C is labeled `(uncalibrated)`.
