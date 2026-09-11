# llm adapter (P09)

Reference bindings:

- **Python**: [Inspect](https://inspect.ai-safety-institute.org.uk/) — dataset / solver / scorer separation, multi-epoch runs, agent trajectories as first-class objects.
- **TypeScript**: [promptfoo](https://www.promptfoo.dev/) — CI-friendly, `--repeat` for multi-run.

Requirements this adapter must satisfy (from P09): golden dataset under `spec/llm/` (protected); N runs per sample; Wilson lower bound as the layer metric; per-sample ratchet history in `.crivo/llm-history.jsonl`; judge model ≠ model under test; judge meta-eval reported in EVIDENCE.
