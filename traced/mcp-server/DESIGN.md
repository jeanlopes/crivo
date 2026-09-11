# crivo-trace MCP server — design

One MCP server, two tool groups, several backends.

## Group A — recording (used inside the gauntlet)
| Tool | Purpose |
|---|---|
| `record(test_id, granularity)` | run the test under the in-process tracer, emit `.crivo/trajectories/<test_id>.jsonl` |
| `normalize(test_id)` | apply `normalize.md` rules and the golden schema |
| `diff(test_id)` | compare with golden; return `first_divergence` |
| `propose_golden(test_id)` | write a `.proposed` golden + schema for human approval (P06) |

Backends (fast, no RPC per step):
- Python — `sys.monitoring` (3.12+), fallback `sys.settrace`
- Node/TS — `inspector` module, `Debugger` domain with logpoints; `async_hooks` for async continuity
- .NET — `EventPipe` / `DiagnosticSource` with a method-boundary instrumentation profile
- Rust — `tracing` subscriber; entry/exit spans instrumented via `#[instrument]` on public fns

## Group B — investigation (used by the agent after a divergence)
Speaks the Debug Adapter Protocol to: `debugpy`, `js-debug`, `lldb-dap` / CodeLLDB, `netcoredbg`.

| Tool | Purpose |
|---|---|
| `launch(test_id, stop_at_seq)` | start under DAP, run to the frame just before `first_divergence` |
| `stack()`, `scopes(frame)`, `variables(scope)` | inspect |
| `evaluate(expr)` | ask questions of live state |
| `step_over/into/out`, `continue` | move |
| `logpoint(file, line, expr)` | non-stopping capture (recording fallback) |

The `stop_at_seq` bridge is the key integration: the divergence gives a frame number; the server translates it into a conditional breakpoint (`fn` entered N times) so the agent lands exactly where state went wrong.

## Constraints
- Group B is read-only with respect to source; it cannot edit files.
- Recording via Group B stepping is disallowed by P05 — performance, not principle.
- Trajectories may contain data; the server applies the secret detector before writing anything.

## Status
Specification. Python backend is the first implementation target.
