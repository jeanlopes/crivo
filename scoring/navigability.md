# Navigability index N

How legible the repository is to a cold agent. Separate from the confidence index by design: a false comment does not make the code wrong; it makes the *next* agent more likely to make it wrong.

## Gradients (from `comments` and `docs` layers)
| Gradient | Weight |
|---|---|
| 1 − lexical redundancy rate | 0.20 |
| comment length compliance | 0.15 |
| 1 − stale-suspect rate | 0.15 |
| registry coverage (rules with all sites marked) | 0.25 |
| docs header coverage (required files) | 0.15 |
| 1 − doc-stale-suspect rate | 0.10 |

Same weighted geometric mean as C. Reported alongside C in EVIDENCE. Gates from P07/P08 zero **C**, not N — a dead reference is a defect.
