# Origin

On 22 July 2026 a developer wrote that he could not feel comfortable letting an agent edit his files: if he was responsible for the code, he needed to understand it. Robert C. Martin replied the next morning that he started coding in the late 1960s, that his current strategy is to not read any code his agents write because that is the only way to realize their productivity, and that instead he surrounds them with extreme constraints — unit tests, Gherkin tests, QA procedures, quality metrics, mutation testing, coverage, and many more — so that he ends up with high confidence in code that has run the gauntlet of all of them.

Follow-ups added detail: cyclomatic complexity thresholds, module size limits, dependency-structure analysis, and a Clojure mutation tester he had Claude write because none existed for his stack. Grady Booch pushed back that metrics cannot see what an experienced engineer sees on sight.

## What crivo takes from it
- Trust moves from reading to instruments. The instruments must be forgery-proof (P06) or the move is theatre.
- Mutation testing is the load-bearing piece. Coverage measures execution; mutation measures verification. Without it, agent-written tests can be green by construction.
- Structure metrics are for the agent's benefit, not the human's aesthetics.

## What crivo adds
- The gauntlet verifies conformance to a spec; it cannot prove the spec complete. The human's job moved to spec-writing. Say so explicitly (P01, Limits).
- Booch is partially right about intent. Answer with a separate adversarial reviewer and security tooling, and be honest that this is probabilistic.
- A confidence number without calibration against escaped defects is decoration. Build the calibration table from day one (P04).
- Characterization at the state level — traced tests — gives agents a root-cause pointer instead of a stack trace, and kills mutants tests cannot (P05).
- Comments and docs are what the human reads instead of code; they need their own gauntlet (P07, P08).

## A phrase worth keeping
Nothing on Martin's list lives in a prompt. That is the whole design principle: policy in a prompt is a suggestion; policy in CI is a law.
