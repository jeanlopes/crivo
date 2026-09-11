"""crivo confidence & navigability index — reference calculator.

docs: scoring/confidence.md, scoring/navigability.md
Reads .crivo/results/*.json and scoring/weights.yaml; writes .crivo/score.json.
"""
from __future__ import annotations

import json
import math
import sys
from pathlib import Path

import yaml

EPS = 1e-6


def geometric(gradients: dict[str, float], weights: dict[str, float]) -> float:
    present = {k: w for k, w in weights.items() if k in gradients}
    if not present:
        return 0.0
    total = sum(present.values())
    acc = 0.0
    for key, w in present.items():
        acc += (w / total) * math.log(max(gradients[key], EPS))
    return 100.0 * math.exp(acc)


def load_results(results_dir: Path) -> dict[str, dict]:
    return {p.stem: json.loads(p.read_text()) for p in results_dir.glob("*.json")}


def module_scores(results: dict[str, dict], weights: dict) -> dict[str, dict]:
    """Per-module C. Layers report `modules: {path: {status, metric}}`; layers
    without module granularity apply repo-wide."""
    modules: dict[str, dict] = {}
    paths = set()
    for r in results.values():
        paths.update(r.get("modules", {}).keys())
    for path in paths:
        gates_ok = True
        grads: dict[str, float] = {}
        for layer, r in results.items():
            entry = r.get("modules", {}).get(path, r)
            if r.get("kind") == "gate" and entry.get("status") == "fail":
                gates_ok = False
            if r.get("kind") == "gradient" and entry.get("metric") is not None:
                grads[r.get("weight_key", layer)] = float(entry["metric"])
        for emitted in ("flaky_inverse", "spec_to_test", "adversary_inverse"):
            v = results.get("unit", {}).get("emits", {}).get(emitted)
            if v is not None:
                grads[emitted] = float(v)
        c = 0.0 if not gates_ok else geometric(grads, weights["confidence"])
        modules[path] = {"C": round(c, 1), "gates": "pass" if gates_ok else "fail", "gradients": grads}
    return modules


def aggregate(modules: dict[str, dict], structure: dict) -> float:
    graph = structure.get("emits", {}).get("dependency_graph", {})
    churn = structure.get("emits", {}).get("churn_30d", {})
    num = den = 0.0
    for path, m in modules.items():
        blast = float(graph.get(path, {}).get("dependents", 0)) + 1.0
        r = blast * (1.0 + float(churn.get(path, 0.0)))
        m["r"] = round(r, 2)
        num += m["C"] * r
        den += r
    return round(num / den, 1) if den else 0.0


def main(root: str = ".") -> int:
    rootp = Path(root)
    weights = yaml.safe_load((rootp / "scoring/weights.yaml").read_text())
    results = load_results(rootp / ".crivo/results")
    modules = module_scores(results, weights)
    repo = aggregate(modules, results.get("structure", {}))
    escapes = rootp / "scoring/calibration/escapes.csv"
    calibrated = escapes.exists() and sum(1 for _ in escapes.open()) - 1 >= 30
    out = {"repo": repo, "calibrated": calibrated, "modules": modules}
    (rootp / ".crivo/score.json").write_text(json.dumps(out, indent=2))
    print(f"C_repo = {repo}{'' if calibrated else ' (uncalibrated)'}")
    return 0


if __name__ == "__main__":
    sys.exit(main(*sys.argv[1:]))
