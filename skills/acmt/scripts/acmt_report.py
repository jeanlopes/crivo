#!/usr/bin/env python3
"""Gera matriz de rastreabilidade e veredito do plano a partir do session.jsonl.
Uso: acmt_report.py <pasta-da-sessao> [limite_lacunas=0.20]"""
import io, json, pathlib, re, sys
from collections import defaultdict

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

root = pathlib.Path(sys.argv[1])
gap_limit = float(sys.argv[2]) if len(sys.argv) > 2 else 0.20

req_re = re.compile(r'^- \*\*(REQ-\d{3})\*\*(?P<tag> \[(?:crítico|N/V)\])?: (?P<desc>.+)$')
reqs = {}
for line in (root / 'requirements.md').read_text(encoding='utf-8').splitlines():
    m = req_re.match(line.strip())
    if m:
        tag = (m.group('tag') or '').strip()
        reqs[m.group(1)] = {'crit': tag == '[crítico]', 'nv': tag == '[N/V]',
                            'desc': m.group('desc').split(' — ')[0]}

last = {}  # último veredito/disputa por passo
log = root / 'session.jsonl'
for line in (log.read_text(encoding='utf-8').splitlines() if log.exists() else []):
    e = json.loads(line)
    if e.get('type') in ('verdict', 'dispute') and e.get('verdict'):
        last[e.get('step') or ','.join(e.get('req', []))] = e

by_req = defaultdict(list)
for step, e in last.items():
    for r in e.get('req', []):
        by_req[r].append((step, e))

ORDER = ['FAIL', 'DISPUTED', 'BLOCKED', 'INCONCLUSIVE', 'PASS']
def status(rid):
    if reqs[rid]['nv']:
        return 'N/V'
    verdicts = {e['verdict'] for _, e in by_req[rid]}
    return next((v for v in ORDER if v in verdicts), 'SEM COBERTURA')

rows, st = [], {}
for rid in sorted(reqs):
    st[rid] = status(rid)
    steps = ', '.join(sorted(s for s, _ in by_req[rid])) or '—'
    ev = ', '.join(sorted({x['path'] for _, e in by_req[rid] for x in e.get('evidence', [])})) or '—'
    crit = ' [crítico]' if reqs[rid]['crit'] else ''
    rows.append(f"| {rid}{crit} | {reqs[rid]['desc']} | {steps} | {st[rid]} | {ev} |")

testable = [r for r in reqs if not reqs[r]['nv']]
uncovered = [r for r in testable if st[r] in ('SEM COBERTURA', 'BLOCKED', 'INCONCLUSIVE')]
crit_fail = [r for r in testable if reqs[r]['crit'] and st[r] == 'FAIL']
crit_not_pass = [r for r in testable if reqs[r]['crit'] and st[r] != 'PASS']
any_fail = [r for r in testable if st[r] in ('FAIL', 'DISPUTED')]
ratio = len(uncovered) / len(testable) if testable else 0

if crit_fail or ratio > gap_limit:
    verdict = 'REJEITADO'
elif any_fail or uncovered or crit_not_pass:
    verdict = 'ACEITO COM RESSALVAS'
else:
    verdict = 'ACEITO'

counts = defaultdict(int)
for s in st.values():
    counts[s] += 1
print(f"**Veredito do plano: {verdict}** — " + ', '.join(f'{k}: {v}' for k, v in sorted(counts.items())))
print(f"Lacunas: {len(uncovered)}/{len(testable)} ({ratio:.0%}, limite {gap_limit:.0%})\n")
print('| REQ | Requisito | Passos | Status | Evidência |')
print('| --- | --- | --- | --- | --- |')
print('\n'.join(rows))
