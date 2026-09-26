#!/usr/bin/env bash
# SEC-148 (P11): security-scanner suppressions must carry a RULE- or issue reference on the same line.
# Usage: security/checks/suppressions.sh <path...>   Exit 1 on any finding.
set -euo pipefail
[[ $# -eq 0 ]] && set -- .
status=0

MARKERS='nosemgrep|#[[:space:]]*nosec|gitleaks:allow|NOSONAR|trivy:ignore|checkov:skip|tfsec:ignore|kics-scan[[:space:]]+ignore|eslint-disable[^*]*(security/|no-unsanitized/|react/no-danger)'
REFERENCE='RULE-[0-9]+|#[0-9]+|[A-Z][A-Z0-9]+-[0-9]+'

hits=$(grep -rnIE "$MARKERS" "$@" \
  --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.venv --exclude-dir=vendor --exclude-dir=.crivo 2>/dev/null \
  | grep -vE "$REFERENCE" || true)
if [[ -n "$hits" ]]; then
  echo "SEC-148 SUPPRESSION WITHOUT REFERENCE"; echo "$hits"; status=1
fi

ignores=$(find "$@" \( -name .git -o -name node_modules \) -prune -o -type f \( \
  -name .semgrepignore -o -name .gitleaks.toml -o -name .gitleaksignore -o -name .trivyignore \
  -o -name .trivyignore.yaml -o -name osv-scanner.toml -o -name .snyk -o -name audit-ci.json* \
  -o -name .nsprc -o -name deny.toml \) -print 2>/dev/null || true)
if [[ -n "$ignores" ]]; then
  echo "SEC-148 scanner configuration present (must be listed as protected paths, P06):"; echo "$ignores"
fi

exit $status
