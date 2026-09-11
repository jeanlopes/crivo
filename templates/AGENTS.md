# AGENTS.md — crivo-governed repository

You are working in a repository governed by crivo. The human will not read your code. They will read the SPEC before you start and the EVIDENCE report when you finish. Everything in between is verified by machines you cannot edit.

## Before writing code
1. Read the approved SPEC in `spec/`. If it is not marked `approved`, stop.
2. Read every `rules/RULE-*.md` the SPEC lists. Read `spec/invariants.md`.
3. If anything in the SPEC is ambiguous, **stop and ask**. Do not choose the interpretation that is easiest to pass.
4. If the change crosses a context boundary, adds an integration point, changes a published contract or a consistency boundary, or touches a resilience policy, it needs an ADR. Draft it at `proposals/decisions/ADR-nnnn.proposed`, traverse all seven sections of `principles/`, and **stop for approval before writing code**. Cite `AP-nnn` by ID; do not paraphrase a principle instead of citing it.

## Protected paths — you cannot write here
`spec/**`, `gauntlet/**`, `traced/golden/**`, `rules/**`, `principles/**`, `decisions/**`, `scoring/**`, `.github/workflows/**`, `AGENTS.md`, `CLAUDE.md`, `CODEOWNERS`, `.pre-commit-config.yaml`.
To propose a change, write `proposals/<path>.proposed` with a one-paragraph justification.

## While writing code
- Every Gherkin scenario in the SPEC maps to at least one test you write. Name tests after scenario IDs.
- Every invariant `INV-nnn` gets a property test tagged with its ID.
- Comments are pointers, not essays: one line plus `RULE-nnn`, `#issue`, `ADR-nnnn`, or `AP-nnn`. Every ID must resolve. No narration. No commented-out code. No docstrings on private symbols. No markdown in comments. See `comments/banned-phrases.txt`.
- Files under `src/domain/` and `src/core/` carry a header linking `docs:`, `rules:`, `adr:`.
- No suppressions (`# noqa`, `# type: ignore`, `eslint-disable`, `#[allow]`, `#pragma warning disable`) without a `RULE-` or issue reference on the same line.
- No `skip`/`xfail`/`todo` tests without an open issue reference.
- Never delete a test or remove an assertion. If a test is wrong, the SPEC is wrong — ask.

## Running the gauntlet
`crivo run` runs all layers in order and halts at the first failure. Run it before declaring done. When it fails:
- `mutation`: each surviving mutant must be classified in your report as `equivalent` or `accepted-risk:#issue`; otherwise write the test that kills it.
- `traced`: read `first_divergence`. Use `crivo-trace launch <test_id> --stop-at-seq N` to inspect state at the exact frame. Do not edit goldens; if the golden is wrong, propose a new one and say why.
- `adversary`: address every finding; `resolved` requires a code change or a test, `accepted` requires an issue.
- `architecture`: a significance trigger fired without an ADR is not fixed by removing the trigger. Draft the ADR. An incomplete axis traversal is not fixed by deleting the axis — `not-applicable` plus one line of justification is a valid verdict. A principle you broke goes in `violations` with a reason and a revisit trigger; hiding it is the one failure mode this layer exists to catch.

## Declaring done
`crivo run --evidence` produces `evidence/EVIDENCE.md` from one fresh run. Do not edit it. Do not summarize it. Point the human to it.

## What you must never do
- Lower a threshold, edit a golden, edit a spec, edit a principle, accept your own ADR, edit this file.
- Hardcode outputs that match fixtures.
- Swallow exceptions broadly.
- Describe the code you wrote as verified because you read it. Reading is not evidence; the gauntlet is.
