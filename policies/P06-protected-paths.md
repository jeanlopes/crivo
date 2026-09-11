# P06 — Protected paths

**Status:** normative · **Enforced by:** agent hooks (`templates/hooks/`), `CODEOWNERS`, branch protection

## Statement

The agent MUST NOT create, edit, or delete files under protected paths. Enforcement MUST be mechanical at three levels; a project missing any level is non-conforming:

1. **Agent runtime hook** — rejects the write tool call before it happens (`templates/hooks/claude-code-settings.json`, `templates/hooks/protect-paths.sh`).
2. **Git hook** — `pre-commit` rejects commits touching protected paths unless the committer is on an allow-list.
3. **Repository host** — `CODEOWNERS` + branch protection require human review for protected paths.

## Default protected paths

```
spec/**                    SPEC, Gherkin features, invariants
gauntlet/**                layers.yaml, thresholds, adapters
traced/golden/**           golden trajectories
rules/**                   rules registry
principles/**              architecture principles corpus
decisions/**               architecture decision records
scoring/**                 weights and calibration data
.github/workflows/**       CI definition
AGENTS.md, CLAUDE.md       agent instructions
CODEOWNERS
.pre-commit-config.yaml
```

Projects MAY extend this list. Projects MUST NOT shorten it.

## Why this policy comes first

An agent that struggles to pass a gate will, given the ability, adjust the gate. Every other policy in this repository assumes it cannot. Set this up before anything else.

## Proposing changes to protected paths

The agent MAY propose a change by writing to `proposals/<path>.proposed` with a one-paragraph justification. A human moves it into place. This keeps the door open without giving the agent the key.
