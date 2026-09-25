# What the gauntlet cannot see

An honest inventory, to be kept current.

1. **Spec gaps.** A missing scenario is invisible to every layer. Track as `spec-gap` in `scoring/calibration/escapes.csv`; it is the metric of the human.
2. **Intent.** A permissive security check the test expects. Mitigated, not solved, by `adversary` and `security` — and by the part of P11 that is written by the human: the authorization matrix and the abuse scenarios. A tenant boundary nobody wrote down is still a spec gap.
3. **Equivalent mutants.** Inflate survivors; require human classification. Cap the effort: 85–90 % mutation score is real, 100 % is theatre.
4. **Emergent behavior under real load and real data.** E2E with real dependencies helps; production observability is outside this repository's scope and should not be pretended otherwise.
5. **The judge's blind spots.** Comment/doc judges are LLMs; their agreement with humans is measured (P09 meta-eval), never assumed.
