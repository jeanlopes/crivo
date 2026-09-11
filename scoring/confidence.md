# Confidence index — reference

Normative text is in `policies/P04-confidence.md`. This file is the implementation reference for `calc/crivo_score.py`.

## Inputs
`.crivo/results/<layer>.json` for every layer, plus `.crivo/results/structure.json#dependency_graph` and `git log` for churn.

## Per-module computation
1. If any gate layer reports `fail` for the module → `C = 0`.
2. Collect gradients `g_i` from `weights.yaml`. Missing optional gradients are dropped and weights renormalized.
3. `C = 100 · exp(Σ w_i · ln(max(g_i, ε)))`, ε = 1e-6 so a true zero still collapses the product.

## Aggregation
`r = blast_radius · (1 + churn_30d_normalized)`; `C_repo = Σ C_m r_m / Σ r_m`.

## Output
`.crivo/score.json`:
```json
{"repo": 82.4, "calibrated": false,
 "modules": {"src/domain/itinerary.py": {"C": 91.2, "r": 14.0, "gradients": {...}, "gates": "pass"}}}
```

## Related
- `navigability.md` — the second index (comments and docs).
- `calibration/` — escapes table, planted defects, weight re-fitting.
