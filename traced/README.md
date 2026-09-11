# traced — golden trajectories

Normative: `policies/P05-traced-tests.md`. Here: format, normalization, and the MCP debugger server design.

- `format.md` — trajectory / frame layout
- `normalize.md` — canonicalization rules and the golden schema (`assert` / `observe` / `ignore`)
- `schema/frame.schema.json` — JSON Schema for one frame
- `golden/` — approved trajectories (protected, P06); created per project, not here
- `mcp-server/` — design of the MCP server exposing tracers and DAP
