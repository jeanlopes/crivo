# Axis 6 — AI as premise-breaker

Not one more axis: the context that breaks premises of the earlier ones rather than only changing their constants.

The premises it breaks, explicitly:

- **Axis 3** assumed dependencies fail by being absent or slow. A model dependency fails by being *plausibly wrong* while fully available.
- **Axis 4** assumed a version is a thing you deploy. The model version changes without your deployment.
- **Axis 0** assumed the source of behaviour is readable. A prompt is readable; a weights update is not.
- **P05** assumed a golden trajectory is comparable by equality. Non-deterministic output makes that false.

---

### AP-083 · Treat the model as a non-deterministic external dependency versioned by a third party
`AIE` `RI` · collides: AP-063

It changes without your deployment, without warning, and without a useful changelog. Every integration-point rule of axis 3 applies with more force.

### AP-084 · Build the evaluation before building the product
`AIE`

In an AI system the evaluation is the real bottleneck, not the implementation. Without an eval there is no criterion for knowing whether any change improved anything.

### AP-085 · Climb the adaptation ladder in cost order: prompt, then context and RAG, then fine-tuning
`AIE`

Inverting the order buys permanent complexity to solve a problem that may have been one of instruction.

### AP-086 · RAG is context-construction engineering, not search
`AIE` · collides: AP-012

The quality of the system is decided in the selection and ordering of what enters the window — retrieval is only the first step.

### AP-087 · Guardrails are architecture components, with their own latency, cost, and false-positive rate
`AIE` · collides: AP-061

They must be designed and measured, not bolted on at the end.

### AP-088 · Non-deterministic output breaks the testing premise of axis 4
`AIE`

Equality assertions do not apply; verification becomes statistical, with an acceptable band and regression detection by distribution.

### AP-089 · Close the data loop: production usage feeds the evaluation, which feeds the next adaptation
`AIE`

It is the only source of compounding improvement in a system whose model you do not control.

### AP-090 · Decide latency and cost per user path, not per system
`AIE` · collides: AP-010

Routing between models, caching, and degradation to a smaller model are architecture decisions with a direct effect on experience — and they are the main cost control point.

---

## Mechanisms that touch this axis

This is the axis with the most coverage in crivo, because P09 already exists.

| Principle | Layer | Coverage |
|---|---|---|
| AP-083 | `llm-eval` (P09) | The ratchet detects a silent model change as a per-sample regression. Detection, not prevention. |
| AP-084 | `llm-eval` (P09) | The golden dataset is a protected path and the layer is mandatory where LLM components are declared. |
| AP-085 | `architecture` | ADR-only: the adaptation level chosen and the level rejected, with the reason. |
| AP-086 | `llm-eval` (P09) | Trajectory assertions cover which context entered the window on an agent path. |
| AP-087 | `llm-eval` (P09) | A guardrail is a component under test like any other; its false-positive rate is a sample of the golden dataset. |
| AP-088 | `llm-eval` + `traced` (P09, P05) | This is the premise-break that crivo answers directly: `traced` goldens are for deterministic paths, `llm-eval` distributions for non-deterministic ones. A project that routes a non-deterministic path through `traced` will observe a false-positive rate approaching 100 %. |
| AP-089 | `scoring/calibration` | `escapes.csv` is the data loop for the gauntlet itself. The product's own loop is outside this repository. |
| AP-090 | `architecture` | ADR-only. |
