# P09 — Non-deterministic components

**Status:** normative · **Enforced by:** `llm-eval` layer; `gauntlet/adapters/llm/`

## Statement

Components whose output is not a deterministic function of input (LLM calls, agents, sampling) MUST be evaluated by the pattern

```
golden dataset → system under test → scorer → threshold → gate
```

and MUST NOT be tested with exact-match assertions on free text.

## Rules

1. **The golden dataset is human-owned.** Protected path (P06). The agent MAY propose samples via PR.
2. **Run N times, report a distribution.** `temperature=0` is not determinism. A sample passes if it passes in ≥ k of N runs. The layer metric is the pass rate with a Wilson interval; the confidence index (P04) uses the **lower bound**.
3. **Deterministic scorers first.** Structured output → JSON Schema + exact comparison on the fields that matter. Model-graded scoring only for free text, and only if (a) the judge model differs from the model under test and (b) the judge has its own meta-eval: a human-labeled set on which its agreement is measured and reported.
4. **Ratchet, not just threshold.** Per-sample history is kept. A sample that passed consistently and now fails is a gate failure regardless of the aggregate.
5. **Trajectory assertions for agents.** The sequence of tool calls with normalized arguments is a trajectory (P05). Assert structure — which tools, in what order, with what constraints, and which tools were *not* called — rather than the final prose.
6. **Cost tiering.** Subset on every PR; full dataset nightly.

## Tooling

Provider-agnostic frameworks only. The golden dataset and scorers are assets that must survive a model swap. Reference adapters: `gauntlet/adapters/llm/` (Inspect for Python, promptfoo for TypeScript).

## Meta-evaluation of the gauntlet itself

The same pattern evaluates the gauntlet: dataset = planted defects (`scoring/calibration/planted/`), system under test = the pipeline, scorer = caught or not. The result is gauntlet **recall by defect category**, which is the input that turns the confidence index from a formula into a calibrated instrument (P04).
