# Normalization

Raw frames are never compared. They pass through these rules first; the golden stores the normalized form.

## Placeholder substitution
Values matching a detector are replaced by a stable, per-trajectory sequential placeholder so identity is preserved without the literal value.

| Detector | Placeholder |
|---|---|
| UUID, ULID, snowflake, DB autoincrement (declared per project) | `<id:n>` |
| ISO timestamps, epoch seconds/millis | `<ts:n>` |
| Memory addresses, object identities, hashes of unstable inputs | `<addr:n>` |
| Thread / task / coroutine ids | `<thr:n>` |
| Randomness (declared seed sources) | `<rand:n>` |
| Secrets (detected by gitleaks patterns) | `<secret>` — never stored |

## Ordering
Sets, dicts/maps with unstable iteration order, and query results without `ORDER BY` are sorted by a canonical key before serialization.

## Numerics
Floats compared with relative epsilon (default `1e-9`), configurable per path.

## Depth and size
Trees truncated at depth 6 and 200 children per node by default; truncation is recorded as `"…":{"truncated":n}` so a truncated golden never silently matches.

## Golden schema (`<test_id>.schema.yaml`)
Every path is one of three classes. Unlisted paths default to `observe`.

```yaml
assert:
  - "ret.type"
  - "ret.reason"
  - "locals.conflicts[*].overlap_min"
  - "self_delta.legs.len"
observe:
  - "args.leg"
ignore:
  - "locals.debug_*"
  - "**.cache_hits"
```

- `assert` — divergence fails the `traced` layer.
- `observe` — recorded and shown in the diff; never fails.
- `ignore` — dropped before storage.

The schema is human-approved with the golden (P05). The agent proposes it; a human deciding which values matter is the review — of values, not code.
