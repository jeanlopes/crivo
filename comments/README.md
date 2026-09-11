# comments — enforcement assets for P07

- `banned-phrases.txt` — lexical gate. One pattern per line, case-insensitive, `#` for comments.
- `judge-output.schema.json` — structured output the comment judge must emit.
- `check.sh` — runs the deterministic checks that need no language-specific parser (banned phrases, markdown-in-comments, TODO-without-issue). Language-aware checks (commented-out code, redundancy, docstring-on-private) live in `crivo-checks`.
