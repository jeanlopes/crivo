#!/usr/bin/env bash
# Deterministic checks for the principles registry (P10). Exit 1 on any finding.
# Usage: principles/check.sh [repo-root]
set -euo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
DIR="$ROOT/principles"
status=0

axes=$(find "$DIR" -maxdepth 1 -name 'AXIS-*.md' | sort)
if [[ -z "$axes" ]]; then echo "NO AXIS FILES under $DIR"; exit 1; fi

# 1-4: ids contiguous and unique, source sigil present, collides targets resolve and are symmetric
# shellcheck disable=SC2086
awk '
  FNR == 1 { file = FILENAME; sub(/.*\//, "", file) }
  /^### AP-[0-9]{3} / {
    id = substr($2, 1, 6)
    if (id in seen) { printf "DUPLICATE ID %s (%s and %s)\n", id, seen[id], file; bad = 1 }
    seen[id] = file
    order[++n] = id
    line[id] = FNR
    expect_sigil = 1
    next
  }
  expect_sigil {
    expect_sigil = 0
    if ($0 !~ /^`[A-Za-z]+`( `[A-Za-z]+`)*/) {
      printf "MISSING SOURCE SIGIL %s (%s:%d)\n", order[n], file, FNR; bad = 1
    }
    if ($0 ~ /collides:/) {
      tail = $0; sub(/.*collides: */, "", tail); gsub(/ /, "", tail)
      c = split(tail, targets, ",")
      for (i = 1; i <= c; i++) collides[order[n] SUBSEP targets[i]] = 1
      for (i = 1; i <= c; i++) refs[order[n]] = refs[order[n]] targets[i] ","
    }
  }
  END {
    for (i = 1; i <= n; i++) {
      want = sprintf("AP-%03d", i)
      if (order[i] != want) { printf "ID NOT CONTIGUOUS: expected %s, found %s\n", want, order[i]; bad = 1 }
    }
    for (pair in collides) {
      split(pair, p, SUBSEP)
      if (!(p[2] in seen)) { printf "DEAD COLLISION TARGET %s -> %s\n", p[1], p[2]; bad = 1; continue }
      if (!((p[2] SUBSEP p[1]) in collides)) { printf "ASYMMETRIC COLLISION %s -> %s (not declared back)\n", p[1], p[2]; bad = 1 }
    }
    exit bad ? 1 : 0
  }
' $axes || status=1

# 5: every AP- reference elsewhere in the repository resolves in the registry
declared=$(grep -hoE '^### AP-[0-9]{3}' $axes | grep -oE 'AP-[0-9]{3}' | sort -u)
referenced=$(grep -rhoE 'AP-[0-9]{3}' "$ROOT" \
  --exclude-dir=.git --exclude-dir=.crivo --exclude='AXIS-*.md' 2>/dev/null | sort -u || true)
dead=$(comm -13 <(echo "$declared") <(echo "$referenced") || true)
if [[ -n "$dead" ]]; then echo "DEAD PRINCIPLE REFERENCE"; echo "$dead"; status=1; fi

exit $status
