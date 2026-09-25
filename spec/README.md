# spec — human-owned

Protected path (P06). The agent reads this directory; it does not write to it.

- `SPEC-TEMPLATE.md` — the plan the human approves before any code exists.
- `features/` — Gherkin scenarios. Each scenario MUST map to at least one automated test (`unit` layer emits `spec_to_test_mapping`).
- `invariants.md` — properties tagged `INV-nnn`, each to be covered by a property test (`property` layer).
- `llm/` — golden datasets for P09, when applicable.
- `security/` — P11: `threat-model.md`, `authz-matrix`, `public-routes`, `exceptions.yaml`. Abuse scenarios live in `features/`, tagged `@security` and `@SEC-nnn` (example: `features/SECURITY-EXAMPLE.feature`).
