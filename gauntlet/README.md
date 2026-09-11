# gauntlet

`layers.yaml` is the single declarative source of the pipeline. Adapters under `adapters/<stack>/` bind each layer to concrete commands. CI (`templates/ci.yml`) is generated from these; nothing about the pipeline should live only in CI YAML.

Rules: layers run in declared order; the first failing gate halts; each layer writes a machine-readable result to `.crivo/results/<layer>.json` so `scoring/calc/` can read it without parsing logs.
