#!/usr/bin/env python3
"""Acrescenta um evento ao session.jsonl da sessão ACMT, com hash das evidências."""
import argparse, datetime, hashlib, json, pathlib

TYPES = ['instruction', 'evidence', 'description', 'verdict', 'dispute',
         'amendment', 'defect', 'note']
VERDICTS = ['PASS', 'FAIL', 'BLOCKED', 'INCONCLUSIVE', 'N/V', 'DISPUTED']

def sha256(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 16), b''):
            h.update(chunk)
    return h.hexdigest()

ap = argparse.ArgumentParser()
ap.add_argument('--session', required=True, help='pasta acmt/<sessao>')
ap.add_argument('--type', required=True, choices=TYPES)
ap.add_argument('--step')
ap.add_argument('--req', nargs='*', default=[])
ap.add_argument('--verdict', choices=VERDICTS)
ap.add_argument('--confidence', choices=['high', 'medium', 'low'])
ap.add_argument('--evidence', nargs='*', default=[], help='caminhos relativos à sessão')
ap.add_argument('--declared', help='observação E4 confirmada pelo tester')
ap.add_argument('--text', default='')
a = ap.parse_args()

root = pathlib.Path(a.session)
if a.type in ('verdict', 'dispute') and not a.verdict:
    raise SystemExit('veredito sem --verdict')
if a.verdict == 'PASS':
    if not (a.evidence or a.declared):
        raise SystemExit('PASS sem evidência é proibido')
    if a.confidence in (None, 'low'):
        raise SystemExit('PASS exige confiança medium ou high')

evidence = []
for rel in a.evidence:
    p = root / rel
    if not p.is_file():
        raise SystemExit(f'evidência não encontrada: {rel}')
    evidence.append({'path': rel, 'sha256': sha256(p)})

record = {
    'ts': datetime.datetime.now().astimezone().isoformat(timespec='seconds'),
    'type': a.type, 'step': a.step, 'req': a.req, 'verdict': a.verdict,
    'confidence': a.confidence, 'evidence': evidence,
    'declared': a.declared, 'text': a.text,
}
record = {k: v for k, v in record.items() if v not in (None, [], '')}
with open(root / 'session.jsonl', 'a', encoding='utf-8') as f:
    f.write(json.dumps(record, ensure_ascii=False) + '\n')
print('ok')
