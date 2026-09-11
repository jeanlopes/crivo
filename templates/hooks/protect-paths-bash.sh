#!/usr/bin/env bash
# Blocks shell commands that write into protected paths (P06). Heuristic; the git hook is the backstop.
set -euo pipefail
input=$(cat)
cmd=$(echo "$input" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)
if echo "$cmd" | grep -qE '(>|>>|tee|sed -i|mv |cp |rm |git checkout --|git restore)\s.*(spec/|gauntlet/|traced/golden/|rules/|scoring/|\.github/workflows/|AGENTS\.md|CLAUDE\.md|CODEOWNERS)'; then
  echo "crivo P06: command writes to a protected path." >&2
  exit 2
fi
exit 0
