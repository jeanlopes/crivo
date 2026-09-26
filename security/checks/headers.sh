#!/usr/bin/env bash
# Response-header and browser-policy checks against a running deployment (P11, `headers` mechanism).
# Usage: security/checks/headers.sh <https-url> [cookie-header-for-an-authenticated-page]
# Prints PASS/WARN/FAIL lines tagged with the SEC- control. Exit 1 on any FAIL.
set -uo pipefail
URL="${1:?usage: headers.sh <https-url> [cookie]}"
COOKIE="${2:-}"
EVIL_ORIGIN="https://crivo-probe.invalid"
fails=0

pass() { echo "PASS $1 $2"; }
warn() { echo "WARN $1 $2"; }
fail() { echo "FAIL $1 $2"; fails=$((fails + 1)); }

fetch_headers() {
  curl -sS -o /dev/null -D - --max-time 15 "$@" | tr -d '\r'
}
header() {
  grep -i "^$1:" <<<"$2" | head -1 | cut -d: -f2- | sed 's/^ *//'
}

H=$(fetch_headers ${COOKIE:+-H "Cookie: $COOKIE"} "$URL") || { echo "FAIL - cannot fetch $URL"; exit 1; }

# SEC-021 HSTS
if [[ "$URL" != https://* ]]; then
  fail SEC-021 "target is not HTTPS"
else
  hsts=$(header strict-transport-security "$H")
  age=$(grep -oiE 'max-age=[0-9]+' <<<"$hsts" | cut -d= -f2)
  if [[ -z "$hsts" ]]; then fail SEC-021 "Strict-Transport-Security missing"
  elif (( ${age:-0} < 15552000 )); then fail SEC-021 "HSTS max-age ${age:-0} < 180 days"
  else pass SEC-021 "HSTS $hsts"; fi
  http_url="http://${URL#https://}"
  loc=$(fetch_headers "$http_url" 2>/dev/null | grep -i '^location:' | head -1 | cut -d: -f2- | sed 's/^ *//')
  if [[ -n "$loc" && "$loc" != https://* ]]; then fail SEC-021 "plain HTTP does not redirect to HTTPS"; fi
fi

# SEC-020 / SEC-023 CSP and framing
csp=$(header content-security-policy "$H")
if [[ -z "$csp" ]]; then
  if [[ -n "$(header content-security-policy-report-only "$H")" ]]; then warn SEC-020 "CSP is report-only"
  else fail SEC-020 "Content-Security-Policy missing"; fi
else
  before=$fails
  script_src=$(tr ';' '\n' <<<"$csp" | grep -iE '^ *script-src ' | head -1)
  [[ -z "$script_src" ]] && script_src=$(tr ';' '\n' <<<"$csp" | grep -iE '^ *default-src ' | head -1)
  if grep -qi "'unsafe-eval'" <<<"$script_src"; then fail SEC-020 "script-src allows 'unsafe-eval'"; fi
  if grep -qi "'unsafe-inline'" <<<"$script_src" && ! grep -qiE "'nonce-|'sha(256|384|512)-|'strict-dynamic'" <<<"$script_src"; then
    fail SEC-020 "script-src allows 'unsafe-inline' without nonce/hash"
  fi
  if [[ -z "$script_src" ]]; then fail SEC-020 "CSP has neither script-src nor default-src"; fi
  grep -qiE "object-src 'none'|default-src 'none'" <<<"$csp" || warn SEC-020 "object-src 'none' not set"
  grep -qi 'base-uri' <<<"$csp" || warn SEC-020 "base-uri not set"
  (( fails == before )) && pass SEC-020 "CSP script policy"
fi
if grep -qi 'frame-ancestors' <<<"$csp" || [[ -n "$(header x-frame-options "$H")" ]]; then pass SEC-023 "framing restricted"
else fail SEC-023 "neither CSP frame-ancestors nor X-Frame-Options"; fi

# SEC-022 baseline headers
[[ "$(header x-content-type-options "$H" | tr 'A-Z' 'a-z')" == "nosniff" ]] && pass SEC-022 "nosniff" || fail SEC-022 "X-Content-Type-Options: nosniff missing"
rp=$(header referrer-policy "$H" | tr 'A-Z' 'a-z')
case "$rp" in
  "") fail SEC-022 "Referrer-Policy missing" ;;
  *unsafe-url*|*no-referrer-when-downgrade*) fail SEC-022 "Referrer-Policy leaks full URLs: $rp" ;;
  *) pass SEC-022 "Referrer-Policy $rp" ;;
esac
for b in server x-powered-by x-aspnet-version; do
  v=$(header "$b" "$H")
  if grep -qE '[0-9]+\.[0-9]+' <<<"$v"; then fail SEC-022 "version banner $b: $v"; fi
done

# SEC-026 cookies
while IFS= read -r c; do
  [[ -z "$c" ]] && continue
  name=${c%%=*}
  grep -qi '; *secure' <<<"$c" || fail SEC-026 "cookie $name without Secure"
  grep -qi '; *samesite=' <<<"$c" || warn SEC-026 "cookie $name without SameSite"
  if grep -qiE 'sess|sid|auth|token|jwt' <<<"$name" && ! grep -qi '; *httponly' <<<"$c"; then
    fail SEC-026 "session-like cookie $name without HttpOnly"
  fi
  grep -qi '; *domain=' <<<"$c" && warn SEC-026 "cookie $name sets Domain (shared with every subdomain)"
done < <(grep -i '^set-cookie:' <<<"$H" | cut -d: -f2- | sed 's/^ *//')

# SEC-024 CORS
before=$fails
for origin in "$EVIL_ORIGIN" "null"; do
  C=$(fetch_headers -H "Origin: $origin" ${COOKIE:+-H "Cookie: $COOKIE"} "$URL")
  acao=$(header access-control-allow-origin "$C")
  acac=$(header access-control-allow-credentials "$C")
  if [[ "$acao" == "$origin" ]]; then fail SEC-024 "CORS reflects Origin: $origin"
  elif [[ "$acao" == "*" && "$acac" == "true" ]]; then fail SEC-024 "CORS '*' with credentials"
  fi
done
(( fails == before )) && pass SEC-024 "CORS does not trust foreign or null origins"

# SEC-032 caching of authenticated responses
if [[ -n "$COOKIE" ]]; then
  cc=$(header cache-control "$H" | tr 'A-Z' 'a-z')
  grep -qE 'no-store|private' <<<"$cc" && pass SEC-032 "Cache-Control $cc" || fail SEC-032 "authenticated response cacheable: '${cc:-none}'"
fi

# SEC-031 public source maps
base=$(sed -E 's#(https?://[^/]+).*#\1#' <<<"$URL")
scripts=$(curl -sS --max-time 15 ${COOKIE:+-H "Cookie: $COOKIE"} "$URL" | grep -oE '<script[^>]+src="[^"]+"' | sed -E 's/.*src="([^"]+)"/\1/' | head -5)
for s in $scripts; do
  case "$s" in
    //*|http*) [[ "$s" == "$base"* ]] || continue; src="$s" ;;
    /*) src="$base$s" ;;
    *) continue ;;
  esac
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$src.map")
  [[ "$code" == "200" ]] && fail SEC-031 "source map served: $src.map"
done

# SEC-137 security.txt
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$base/.well-known/security.txt")
[[ "$code" == "200" ]] && pass SEC-137 "security.txt present" || warn SEC-137 "no /.well-known/security.txt"

echo "headers: $fails failure(s)"
exit $(( fails > 0 ? 1 : 0 ))
