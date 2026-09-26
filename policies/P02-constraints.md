# P02 — Extreme constraints

**Status:** normative · **Enforced by:** `gauntlet/layers.yaml`

## Statement

Every constraint on agent-produced code MUST be expressed as a layer in `gauntlet/layers.yaml` with a machine-checkable outcome. Constraints that exist only in prompts, AGENTS.md prose, or review comments are advisory and MUST NOT be counted toward the confidence index.

## Two kinds of constraint

- **Gate** — binary. Failure halts the gauntlet and sets the confidence index to zero for the change.
- **Gradient** — continuous in [0, 1]. Enters the confidence index (P04). MAY have a `min` threshold, in which case falling below it is also a halt.

## Mandatory layers

A conforming project MUST run, in this order: `types`, `lint`, `unit`, `coverage`, `structure`, `mutation`, `e2e`, `security` (at the P11 level the project declares). It SHOULD run `property`, `traced`, `comments`, `docs`, `adversary`. Projects with LLM components MUST run `llm-eval` (P09).

## Rules for all layers

- Suppressions (`#[allow]`, `# noqa`, `# type: ignore`, `eslint-disable`, `#pragma warning disable`, `@ts-ignore`) MUST be zero unless each carries a `RULE-` or issue reference (P07). Enforced by `lint`. The same rule applies to security-scanner suppressions (`nosemgrep`, `nosec`, `gitleaks:allow`, …); enforced by the `security` layer (P11, SEC-148).
- Skipped, pending, or expected-failure tests MUST reference an open issue. Enforced by `unit`.
- No test file MAY be deleted or have assertions removed without SPEC amendment. Enforced by `unit` (assertion-count ratchet) and P06.
- Thresholds MUST NOT be lowered by the agent. Enforced by P06 — `layers.yaml` is a protected path.
- Coverage is measured on **changed lines**, not globally. Enforced by `coverage`.
- Mutation testing runs on the diff by default and on the full repo on a schedule. Enforced by `mutation`.

## Structural thresholds (defaults, tunable per project in `layers.yaml`)

| Metric | Default |
|---|---|
| Cyclomatic complexity per function | ≤ 10 |
| Cognitive complexity per function | ≤ 15 |
| Function length | ≤ 40 lines |
| Module length | ≤ 400 lines |
| Architecture rule violations | 0 |
| Duplication | ≤ 3 % |
| Distance from main sequence (D) per package | ≤ 0.3 |

Rationale for structural gates: tangled code slows agents and makes them fail at untangling their own mess. Structure is prophylaxis for the agent, not aesthetics for the human.
