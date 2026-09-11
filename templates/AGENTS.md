# AGENTS.md — crivo-governed repository

You are working in a repository governed by crivo. The human will not read your code. They will read the SPEC before you start and the EVIDENCE report when you finish. Everything in between is verified by machines you cannot edit.

## Before writing code
1. Read the approved SPEC in `spec/`. If it is not marked `approved`, stop.
2. Read every `rules/RULE-*.md` the SPEC lists. Read `spec/invariants.md`.
3. If anything in the SPEC is ambiguous, **stop and ask**. Do not choose the interpretation that is easiest to pass.

## Protected paths — you cannot write here
`spec/**`, `gauntlet/**`, `traced/golden/**`, `rules/**`, `scoring/**`, `.github/workflows/**`, `AGENTS.md`, `CLAUDE.md`, `CODEOWNERS`, `.pre-commit-config.yaml`.
To propose a change, write `proposals/<path>.proposed` with a one-paragraph justification.

## While writing code
- Every Gherkin scenario in the SPEC maps to at least one test you write. Name tests after scenario IDs.
- Every invariant `INV-nnn` gets a property test tagged with its ID.
- Comments are pointers, not essays: one line plus `RULE-nnn`, `#issue`, or `ADR-nnnn`. No narration. No commented-out code. No docstrings on private symbols. No markdown in comments. See `comments/banned-phrases.txt`.
- Files under `src/domain/` and `src/core/` carry a header linking `docs:`, `rules:`, `adr:`.
- No suppressions (`# noqa`, `# type: ignore`, `eslint-disable`, `#[allow]`, `#pragma warning disable`) without a `RULE-` or issue reference on the same line.
- No `skip`/`xfail`/`todo` tests without an open issue reference.
- Never delete a test or remove an assertion. If a test is wrong, the SPEC is wrong — ask.

## Running the gauntlet
`crivo run` runs all layers in order and halts at the first failure. Run it before declaring done. When it fails:
- `mutation`: each surviving mutant must be classified in your report as `equivalent` or `accepted-risk:#issue`; otherwise write the test that kills it.
- `traced`: read `first_divergence`. Use `crivo-trace launch <test_id> --stop-at-seq N` to inspect state at the exact frame. Do not edit goldens; if the golden is wrong, propose a new one and say why.
- `adversary`: address every finding; `resolved` requires a code change or a test, `accepted` requires an issue.

## Declaring done
`crivo run --evidence` produces `evidence/EVIDENCE.md` from one fresh run. Do not edit it. Do not summarize it. Point the human to it.

## What you must never do
- Lower a threshold, edit a golden, edit a spec, edit this file.
- Hardcode outputs that match fixtures.
- Swallow exceptions broadly.
- Describe the code you wrote as verified because you read it. Reading is not evidence; the gauntlet is.
