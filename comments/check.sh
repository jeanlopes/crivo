#!/usr/bin/env bash
# Language-agnostic deterministic comment checks (P07). Exit 1 on any finding.
# Usage: comments/check.sh <path...>
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
BANNED="$HERE/banned-phrases.txt"
status=0

files=$(grep -rlE '^\s*(#|//|/\*|\*|--)' "$@" --include='*.py' --include='*.ts' --include='*.tsx' --include='*.rs' --include='*.cs' --include='*.js' 2>/dev/null || true)

# 1. banned phrases (only on comment lines)
while IFS= read -r pat; do
  [[ -z "$pat" || "$pat" == \#* ]] && continue
  hits=$(echo "$files" | xargs -r grep -nEi "^\s*(#|//|\*|/\*).*${pat}" 2>/dev/null || true)
  if [[ -n "$hits" ]]; then echo "BANNED [$pat]"; echo "$hits"; status=1; fi
done < "$BANNED"

# 2. TODO/FIXME/HACK without issue reference
hits=$(echo "$files" | xargs -r grep -nE '(TODO|FIXME|HACK)' 2>/dev/null | grep -vE '#[0-9]+|[A-Z]+-[0-9]+|https?://' || true)
if [[ -n "$hits" ]]; then echo "TODO WITHOUT ISSUE"; echo "$hits"; status=1; fi

# 3. inline trailing comments (code then comment on same line) — Python/TS/Rust/C#
hits=$(echo "$files" | xargs -r grep -nE '^\s*[^#/[:space:]][^#/]*\S\s+(#|//)\s*[A-Za-z]' 2>/dev/null | grep -vE 'RULE-[0-9]+|https?://|(#|//)\s*(noqa|type:|eslint|pragma)' || true)
if [[ -n "$hits" ]]; then echo "INLINE COMMENT"; echo "$hits"; status=1; fi

exit $status
