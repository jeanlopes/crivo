# SPEC — <change title>

**Status:** draft | approved · **Approved by:** <human> · **Date:** <yyyy-mm-dd>
**Rules touched:** RULE-xxx, RULE-yyy · **ADR:** ADR-xxxx (if a design decision)

## Intent
One paragraph. What changes for the user or the system, and why now.

## Out of scope
Explicit list. The agent MUST NOT touch these. Ambiguity here is the #1 source of "passed the gauntlet, still wrong".

## Scenarios
Gherkin, in `features/<name>.feature`. Listed here by title with the test ID that will cover each:

| Scenario | Test ID |
|---|---|
| Leg overlapping an existing leg is rejected | `test_itinerary_reject_overlap` |

## Invariants
Properties that must hold for all inputs. Each gets a property test.

- INV-012: `add_leg` never increases `legs` by more than 1.
- INV-013: `Itinerary.total_duration == sum(leg.duration)` after any sequence of operations.

## Traced tests
Which tests record a golden trajectory at `contract` granularity, and which paths are `assert` vs `observe` (P05).

## Non-deterministic components (P09)
None | dataset `spec/llm/<name>.jsonl`, N=5, k=4, scorer: <schema|judge>.

## Acceptance
All gauntlet layers pass; EVIDENCE produced from a fresh run; confidence index for touched modules ≥ <value>.

## Questions the agent must ask before starting
The agent MUST stop and ask if any of these are unclear rather than pick the easiest interpretation:
- <list>
