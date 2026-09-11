# P03 — The gauntlet

**Status:** normative · **Enforced by:** CI pipeline generated from `gauntlet/layers.yaml`; `templates/ci.yml`

## Statement

Layers MUST run in the order declared in `layers.yaml`. The pipeline MUST halt at the first failing gate. Cheap layers run first; expensive layers run last. No layer MAY be skipped by the agent.

## Canonical order

```
types → lint → unit → coverage → structure → architecture → mutation → property → traced → comments → docs → e2e → security → llm-eval → adversary
```

## The EVIDENCE report

After the final layer passes, the pipeline MUST produce `evidence/EVIDENCE.md` from **one fresh run** on the final commit. All numbers in the report MUST come from that run. The report MUST include:

- Commit SHA and tree hash.
- The single entry command that reproduces the run.
- Per-layer result, metric value, threshold.
- Surviving mutants with a one-line classification each (`equivalent` / `accepted-risk:#issue` / `unresolved`). `unresolved` > 0 is a gate failure.
- Golden trajectories created, updated, or diverged.
- Architecture decisions in the change, and the violation ledger with any expired revisit trigger (P10).
- Adversarial findings, each `resolved` / `accepted:#issue` / `unresolved`. `unresolved` > 0 is a gate failure.
- The confidence index before and after.

The EVIDENCE report is what the human reads (P01).

## The adversary layer

- Runs in a **separate agent context** with no access to the author's reasoning or conversation.
- Receives: the SPEC, the diff, the rules registry entries referenced, read-only repository access.
- MUST NOT be the same model instance that produced the change. SHOULD be a different model.
- Emits structured findings (`severity`, `location`, `claim`, `evidence`). Prose-only findings are rejected.
- Its findings are the only place where "intent" is checked. Treat its output as probabilistic (P01, Limits).

## Anti-gaming

The agent MUST stop and ask when the SPEC is ambiguous rather than choose the interpretation easiest to pass. Detected patterns that are automatic failures:

- Tests that exercise code without asserting on it (caught by `mutation`).
- Hardcoded outputs matching test fixtures (caught by `property` and `traced`).
- Broad `catch`/`except` swallowing errors (caught by `lint` rule `no-swallow`).
- Threshold, config, or spec edits (caught by P06 hooks).
