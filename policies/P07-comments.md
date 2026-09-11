# P07 — Comments

**Status:** normative · **Enforced by:** `comments` layer (deterministic checks) + comment judge (inferential, scheduled)

## Model

A comment is a **pointer, not an essay**. Long explanations live in the rules registry (`rules/`), ADRs, or linked docs. The comment carries one line and an ID. This makes hidden, distributed rules discoverable and makes prolixity structurally impossible.

## Taxonomy

Every comment MUST fall into exactly one class:

| Class | Where | Rule |
|---|---|---|
| **API** (docstring, rustdoc, XML doc, JSDoc) | exported/public symbols only | 1-line summary; contract (params, return, errors, preconditions); no narrative; ≤ 12 lines, above that requires a `RULE-` reference |
| **Rule** (`RULE-nnn`) | each enforcement site of a non-local rule | 1–2 lines + ID resolving in `rules/` |
| **Reference** (`#412`, `ADR-0007`, URL) | where a decision is non-obvious | 1 line; must resolve (closed issues are valid) |
| **Marker** (`SAFETY:`, `PERF:`, `HACK:`) | technically non-obvious code | 1–3 lines; `HACK` requires an issue |
| **TODO / FIXME** | anywhere | requires an issue reference |
| **Narration** ("// increment the counter") | — | MUST NOT exist |
| **Commented-out code** | — | MUST NOT exist |
| **Inline** (same line as code) | constant tables only | MUST NOT exist elsewhere |

API comments MUST NOT exist on non-exported symbols unless they carry a `RULE-` reference. Documenting private helpers is noise.

## History belongs in git

Comments MUST NOT narrate how code evolved. `git log`, ADRs and issues are the logbook. A comment carries at most one reference into that history.

## Deterministic gates (`comments` layer)

- Commented-out code (detected by parsing comment content as source).
- `TODO`/`FIXME`/`HACK` without issue reference.
- Dead reference: nonexistent issue, `RULE-` not in registry, 404 URL, missing doc path.
- Inline comment outside constant tables.
- Markdown syntax inside code comments (headings, bullets, bold) — signature of uncurated generated text.
- Any phrase in `comments/banned-phrases.txt`.
- Docstring on non-exported symbol without `RULE-`.
- Comment judged `truth: false` (see below).

## Deterministic gradients (navigability index N)

- **Lexical redundancy**: Jaccard similarity between comment tokens and identifiers in the following statement(s); ≥ 0.6 flagged.
- **Length compliance**: fraction of comments within their class cap.
- **Staleness suspicion**: via `git blame`, comment whose anchored block changed in ≥ 2 commits since the comment last changed. Feeds the judge; not a failure by itself.
- **Registry coverage**: fraction of registry rules with all declared enforcement sites marked.
- **Density** (comment lines / code lines per file): alert only, never a gate. > 0.3 outside public-API modules is a narration signal.

## Inferential audit (comment judge)

No deterministic check verifies "this comment is still true". A separate read-only agent, clean context, receives each comment with its anchored code and emits `comments/judge-output.schema.json`:

- `truth`: `true` / `partial` / `false`
- `value`: `why` (says what code cannot show) / `what` (restates code) / `none`
- `action`: `keep` / `fix-comment` / `fix-code` / `delete`

`false` is a gate. `what` on trivial code is `delete`. The judge **proposes** patches via PR; it never edits directly. That PR is one of the things the human reads — reviewing a comment is reviewing prose.

## Cadence

| When | Scope |
|---|---|
| Every PR | comments in the diff |
| Weekly | all `stale-suspect` comments |
| Quarterly | random 10 % sample of the repository |
