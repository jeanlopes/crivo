# Policies

| ID | Title | Enforced by |
|---|---|---|
| [P01](P01-no-read.md) | No-read | Review process; EVIDENCE gate |
| [P02](P02-constraints.md) | Extreme constraints | `gauntlet/layers.yaml` |
| [P03](P03-gauntlet.md) | The gauntlet | CI pipeline, fail-fast |
| [P04](P04-confidence.md) | Confidence index | `scoring/calc/` |
| [P05](P05-traced-tests.md) | Traced tests | `traced` layer, golden files |
| [P06](P06-protected-paths.md) | Protected paths | Hooks, CODEOWNERS, branch protection |
| [P07](P07-comments.md) | Comments | `comments` layer, judge |
| [P08](P08-docs-linkage.md) | Docs linkage | `docs` layer, judge |
| [P09](P09-nondeterministic.md) | Non-deterministic components | `llm-eval` layer |

Language: RFC 2119. Every normative statement names its enforcement mechanism. If it cannot, it is not a policy.
