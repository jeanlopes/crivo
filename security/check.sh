#!/usr/bin/env bash
# Deterministic checks for the security controls catalogue (P11). Exit 1 on any finding.
# Usage: security/check.sh [repo-root]
set -euo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
DIR="$ROOT/security"
status=0

domains=$(find "$DIR" -maxdepth 1 -name 'DOMAIN-*.md' | sort)
if [[ -z "$domains" ]]; then echo "NO DOMAIN FILES under $DIR"; exit 1; fi

# 1-5: ids contiguous and unique; tag line present with >=1 known reference,
# a verify: list drawn from the known mechanisms, and a severity
# shellcheck disable=SC2086
awk '
  BEGIN {
    split("sast secrets sca sbom iac ci headers dast fuzz abuse test property lint adversary config", m, " ")
    for (i in m) mech[m[i]] = 1
    split("critical high medium low", s, " ")
    for (i in s) sev[s[i]] = 1
    ref = "^(ASVS:V([1-9]|1[0-7])|CWE-[0-9]+|T10:A(0[1-9]|10)|API:API([1-9]|10)|LLM:LLM(0[1-9]|10)|ASI:ASI(0[1-9]|10)|OAT:OAT-0([01][0-9]|2[01])|NIST:[A-Za-z0-9.-]+|CIS:[0-9]+|PCI:[0-9.]+|LGPD:art\\.[0-9]+|RFC[0-9]+|AP-[0-9]{3}|SLSA|crivo)$"
  }
  FNR == 1 { file = FILENAME; sub(/.*\//, "", file) }
  /^### SEC-[0-9]{3} / {
    id = substr($2, 1, 7)
    if (id in seen) { printf "DUPLICATE ID %s (%s and %s)\n", id, seen[id], file; bad = 1 }
    seen[id] = file
    order[++n] = id
    expect_tags = 1
    next
  }
  expect_tags {
    expect_tags = 0
    where = sprintf("%s (%s:%d)", order[n], file, FNR)
    line = $0
    refs = 0
    while (match(line, /`[^`]+`/)) {
      tok = substr(line, RSTART + 1, RLENGTH - 2)
      line = substr(line, RSTART + RLENGTH)
      if (tok !~ ref) { printf "UNKNOWN REFERENCE %s in %s\n", tok, where; bad = 1 }
      refs++
    }
    if (refs == 0) { printf "MISSING REFERENCES %s\n", where; bad = 1 }
    if ($0 !~ /verify: /) { printf "MISSING VERIFY %s\n", where; bad = 1 }
    else {
      v = $0; sub(/.*verify: */, "", v); sub(/ *·.*/, "", v); gsub(/ /, "", v)
      c = split(v, vs, ",")
      for (i = 1; i <= c; i++) if (!(vs[i] in mech)) { printf "UNKNOWN MECHANISM %s in %s\n", vs[i], where; bad = 1 }
    }
    if ($0 !~ /severity: /) { printf "MISSING SEVERITY %s\n", where; bad = 1 }
    else {
      v = $0; sub(/.*severity: */, "", v); sub(/[^a-z].*/, "", v)
      if (!(v in sev)) { printf "UNKNOWN SEVERITY %s in %s\n", v, where; bad = 1 }
    }
  }
  END {
    for (i = 1; i <= n; i++) {
      want = sprintf("SEC-%03d", i)
      if (order[i] != want) { printf "ID NOT CONTIGUOUS: expected %s, found %s\n", want, order[i]; bad = 1 }
    }
    exit bad ? 1 : 0
  }
' $domains || status=1

# 6: every SEC- reference anywhere in the repository resolves in the catalogue
declared=$(grep -hoE '^### SEC-[0-9]{3}' $domains | grep -oE 'SEC-[0-9]{3}' | sort -u)
referenced=$(grep -rhoE 'SEC-[0-9]{3}' "$ROOT" \
  --exclude-dir=.git --exclude-dir=.crivo 2>/dev/null | sort -u || true)
dead=$(comm -13 <(echo "$declared") <(echo "$referenced") || true)
if [[ -n "$dead" ]]; then echo "DEAD CONTROL REFERENCE"; echo "$dead"; status=1; fi

exit $status
