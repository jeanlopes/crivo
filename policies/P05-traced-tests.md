# P05 — Traced tests

**Status:** normative · **Enforced by:** `traced` layer; golden files under `traced/golden/` (protected, P06)

## Vocabulary

| Term | Meaning |
|---|---|
| **Trajectory** | The ordered sequence of state snapshots from one test execution, end to end. |
| **Frame** | One point in a trajectory: a scope, at an instant, with its variable tree. |
| **Golden** | An approved, stored trajectory that serves as oracle. |
| **First divergence** | The earliest frame at which a run's trajectory differs from its golden. |

## Statement

A traced test MUST record a trajectory while the test runs and compare it against its golden. The comparison result is the `trajectory_match` gradient. A divergence in an `assert`-class path is a gate failure; the `traced` layer MUST report the first divergence (frame `seq`, function, variable path, expected, actual).

## What traced tests are for — and not

Traced tests are **characterization tests**: they detect *change*, not *correctness*. They MUST be positioned where change is the enemy — the REFACTOR step and regression — and MUST NOT be the primary correctness oracle. Correctness is Gherkin, property tests and mutation (P02).

## Capture granularity

- `contract` (default, produces goldens): entry and exit of public functions — arguments, return value, delta of mutated fields on `self`/`this`.
- `full` (diagnostic only): every frame, every local. Enabled on demand when `diff` reports a divergence. `full` trajectories MUST NOT be committed.

## Capture mechanism

Recording MUST use in-process tracing where available (Python `sys.monitoring`, Node `inspector`, .NET `EventPipe`/`DiagnosticSource`, Rust `tracing` subscriber). Stepping through a debugger over DAP to record a trajectory is NOT permitted — each step is an RPC round-trip and end-to-end flows become minutes. DAP **logpoints** MAY be used as a recording fallback. DAP stepping, breakpoints and expression evaluation are for the agent's **investigation** after a divergence (`traced/mcp-server/`).

## Golden lifecycle

1. A golden is created only from a run in which every earlier gauntlet layer passed.
2. The agent proposes the golden; the human approves it (approval-testing model). Approval is the human reading *values*, which is easier than reading logic.
3. Golden files are protected paths (P06). The agent MUST NOT edit them; it MAY propose replacements via a marked PR.
4. Every golden carries a schema classifying paths as `assert`, `observe`, or `ignore` (`traced/normalize.md`).

## Normalization

Raw frames MUST pass through `traced/normalize.md` before comparison: placeholder substitution for ids, timestamps, addresses; stable ordering of unordered collections; numeric epsilon; depth cap. Without this the false-positive rate approaches 100 % within days.

## Mutation synergy

The `mutation` layer SHOULD use trajectories as a secondary oracle: a mutant that corrupts intermediate state without changing test outputs survives ordinary tests but diverges from the golden. Kills obtained this way MUST be reported separately (`mutation_kills_by_trajectory`) so the mutation score remains honest about what tests alone caught.

## Format

`traced/format.md`, `traced/schema/frame.schema.json`. JSONL, one frame per line, one file per test, content-hash suffix, Git LFS above 2 MB.
