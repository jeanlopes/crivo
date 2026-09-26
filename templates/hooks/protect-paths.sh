#!/usr/bin/env bash
# Claude Code PreToolUse hook (P06). Reads the tool call JSON on stdin,
# exits 2 (block) if the target path is protected. Also usable as a git pre-commit check.
set -euo pipefail
PROTECTED_REGEX='^(spec/|gauntlet/|traced/golden/|rules/|principles/|decisions/|security/|scoring/|\.github/workflows/|AGENTS\.md$|CLAUDE\.md$|CODEOWNERS$|\.pre-commit-config\.yaml$|(.*/)?(\.semgrepignore|\.gitleaks\.toml|\.gitleaksignore|\.trivyignore[^/]*|osv-scanner\.toml|\.snyk|\.nsprc|audit-ci\.json[^/]*|deny\.toml|zap-rules\.tsv)$)'

if [[ -t 0 ]]; then
  # git pre-commit mode: check staged files
  bad=$(git diff --cached --name-only | grep -E "$PROTECTED_REGEX" || true)
  if [[ -n "$bad" && "${CRIVO_HUMAN:-0}" != "1" ]]; then
    echo "crivo P06: protected paths staged:"; echo "$bad"
    echo "Set CRIVO_HUMAN=1 to commit as a human."; exit 1
  fi
  exit 0
fi

input=$(cat)
path=$(echo "$input" | python3 -c 'import sys,json; d=json.load(sys.stdin); ti=d.get("tool_input",{}); print(ti.get("file_path") or ti.get("path") or ti.get("notebook_path") or "")' 2>/dev/null || true)
rel=${path#"${CLAUDE_PROJECT_DIR:-$PWD}/"}
if [[ -n "$rel" && "$rel" =~ $PROTECTED_REGEX ]]; then
  echo "crivo P06: '$rel' is a protected path. Write a proposal to proposals/$rel.proposed instead." >&2
  exit 2
fi
exit 0
