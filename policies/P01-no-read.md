# P01 — No-read

**Status:** normative · **Enforced by:** review process, EVIDENCE gate (P03), protected paths (P06)

## Statement

The human MUST NOT review agent-written code by reading function bodies or diffs as the primary means of acceptance. Acceptance MUST be based on artifacts the agent cannot forge: the approved SPEC, the EVIDENCE report, the confidence index, trajectory diffs, and adversarial findings.

## What the human still reads

The human MUST read and approve, before code exists:
- The SPEC (`spec/SPEC-TEMPLATE.md`): test plan, Gherkin scenarios, invariants, out-of-scope list.
- Rules registry entries (`rules/`) that the change creates or modifies.

The human MUST read, after the gauntlet passes:
- The EVIDENCE report (`evidence/EVIDENCE-TEMPLATE.md`).
- Any golden trajectory the run proposes to create or update (P05).
- Any unresolved adversarial finding (P03, layer `adversary`).

The human MAY read public interfaces, module boundaries, and the dependency graph. These are architecture, not code.

## Rationale

The productivity of agents is only realizable if review stops being the bottleneck. Reading removes the bottleneck's benefit while keeping its cost. Trust must be carried by instruments — see `rationale/00-origin.md`.

## Limits (non-negotiable honesty)

- The gauntlet verifies conformance to the SPEC. It cannot prove the SPEC is complete. The human's thinking has moved from reviewing code to writing specs; it has not disappeared.
- Structural metrics do not see intent. A permissive branch in a security check passes complexity, coverage and mutation if the test expects that behavior. The `adversary` and `security` layers reduce this risk probabilistically; they do not eliminate it.
- "Not reading" applies to function bodies. It does not license ignorance of architecture.
