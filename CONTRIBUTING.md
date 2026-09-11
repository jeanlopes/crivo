# Contributing

- Policies are normative. Every MUST/SHOULD in `policies/` MUST name the mechanism that enforces it (CI layer, hook, file permission). A rule with no mechanism goes to `rationale/`, not `policies/`.
- Keywords MUST, MUST NOT, SHOULD, SHOULD NOT, MAY follow RFC 2119.
- Changes to `gauntlet/layers.yaml` thresholds require a note in `scoring/calibration/CHANGELOG.md` — thresholds are calibration parameters, not style.
- This repository is itself subject to its own comment policy (P07). Run `comments/check.sh` before opening a PR.
