# P04 — Confidence index

**Status:** normative · **Enforced by:** `scoring/calc/crivo_score.py` reading gauntlet artifacts

## Statement

The repository MUST report a confidence index **C ∈ [0, 100]** per module and aggregated. C is an **ordinal index until calibrated** (see `scoring/calibration/`). Documentation MUST NOT describe C as a probability before calibration data exists.

## Formula

For a module, given gradient layer results gᵢ ∈ [0, 1] with weights wᵢ (Σwᵢ = 1):

```
C_module = 0                       if any gate failed
C_module = 100 · Π gᵢ^wᵢ            otherwise   (weighted geometric mean)
```

Multiplicative, not additive: confidence is weakest-link. A gradient at 0.3 cannot be compensated by others at 1.0.

## Aggregation

```
C_repo = Σ (C_module · r_module) / Σ r_module
r_module = blast_radius · (1 + churn_30d)
```

`blast_radius` = number of modules transitively depending on this one (from the `structure` layer's dependency graph). `churn_30d` = normalized commit count in the last 30 days. A stable leaf module weighs little; a hot core module weighs a lot.

## Default gradients and weights

| Gradient | Weight | Source layer |
|---|---|---|
| changed-line coverage | 0.15 | `coverage` |
| mutation score (diff scope) | 0.30 | `mutation` |
| spec→test mapping (fraction of scenarios with ≥1 linked test) | 0.15 | `unit` + `spec/` |
| invariants with property tests | 0.10 | `property` |
| trajectory match | 0.10 | `traced` |
| 1 − flaky rate | 0.10 | `unit` (randomized, repeated) |
| 1 − unresolved adversarial findings (normalized) | 0.10 | `adversary` |

`llm-eval` (P09), when present, enters as its **lower Wilson bound** with weight 0.15, rescaling the others.

Comments and docs gradients (P07, P08) do **not** enter C. They enter a separate **navigability index N** (`scoring/navigability.md`), because a false comment does not make code incorrect — it makes the next agent more likely to err. Only P07/P08 *gates* (dead references, commented-out code, `false` comments, contradicted docs) affect C, by zeroing it.

## Calibration

`scoring/calibration/escapes.csv` MUST be maintained: every defect found after the gauntlet passed, with module, date, category, and the module's C at that commit. Weights SHOULD be re-fit against this table quarterly. `scoring/calibration/planted/` holds a dataset of planted defects used to measure gauntlet **recall** by category. Until `escapes.csv` has ≥ 30 rows, C is reported with the suffix `(uncalibrated)`.
