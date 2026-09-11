# Rules registry

The place where long explanations live so that code comments can be one line (P07).

## Entry format — `rules/RULE-nnn.md`
```yaml
---
id: RULE-017
title: Legs on the same day must not overlap
status: active | deprecated
origin: "#412"            # issue, ADR, conversation link
adr: ADR-0007
invariants: [INV-012]
sites:                    # every enforcement point in code; checked by the comments layer
  - src/domain/itinerary.py:88
  - src/api/legs.py:41
related: [RULE-023]
---
```
Body: the full explanation, edge cases, why the rule exists, what would break without it. Length is not constrained here — this is where the essay goes.

## Checks (`comments` layer)
- Every `RULE-` referenced in code exists in the registry.
- Every `adr:` and every `ADR-` referenced in code resolves in `decisions/` (P10, `architecture` layer).
- Every `sites` entry contains a `RULE-nnn` comment.
- Registry coverage = rules with all sites marked / rules total (navigability gradient).
- A rule referenced from ≥ 5 files is flagged `dispersed` — a candidate for extraction into a module.

## Ownership
Protected path (P06). The agent proposes new rules via `proposals/rules/RULE-nnn.md.proposed`; a human moves them in.
