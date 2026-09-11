# Trajectory format

## Files
```
traced/golden/<test_id>.<content-hash8>.jsonl     the golden
traced/golden/<test_id>.schema.yaml              path classification (see normalize.md)
.crivo/trajectories/<test_id>.jsonl               current run (not committed)
```
JSONL: one **frame** per line, ordered by `seq`. One file per test. Git LFS above 2 MB. The content-hash suffix detects out-of-process edits.

## Frame
```json
{"seq":41,"event":"exit","fn":"Itinerary.add_leg","file":"domain/itinerary.py","line":88,
 "args":{"leg":{"from":"FRA","to":"MUC","start":"<ts:1>","end":"<ts:2>"}},
 "locals":{"conflicts":[{"leg_id":"<id:1>","overlap_min":120}]},
 "ret":{"type":"Rejected","reason":"time_conflict"},
 "self_delta":{"legs.len":[1,1]},
 "depth":3,"thread":"<thr:1>"}
```

| Field | `contract` | `full` | Notes |
|---|---|---|---|
| `seq` | ✓ | ✓ | monotonic per trajectory |
| `event` | `enter` / `exit` / `raise` | + `line` | |
| `fn`, `file`, `line` | ✓ | ✓ | `line` is the boundary line at `contract` |
| `args` | on `enter` | ✓ | normalized |
| `locals` | on `exit`, only names listed in schema `observe`/`assert` | all | |
| `ret` | on `exit` | ✓ | |
| `exc` | on `raise` | ✓ | type + normalized message |
| `self_delta` | on `exit` | ✓ | `{path: [before, after]}` for mutated fields |
| `depth`, `thread` | ✓ | ✓ | thread is a placeholder |

## Header line
Line 0 is a header frame: `{"seq":0,"event":"header","test_id":..., "granularity":"contract","tracer":"py-sys-monitoring/0.1","schema":"<hash>","created":"<iso>"}`.

## Comparison output
```json
{"test_id":"test_reject_overlap","match":false,
 "first_divergence":{"seq":41,"fn":"Itinerary.add_leg","path":"locals.conflicts[0].overlap_min",
                     "expected":120,"actual":60,"class":"assert"},
 "observe_diffs":3,"ignored":12}
```
`first_divergence` is the payoff: the agent receives the exact frame and variable where state left the rails, not a stack trace.
