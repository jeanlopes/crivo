# Protocolo de evidência e oráculo

Todo veredito tem que apontar para uma evidência concreta e para o critério que ela satisfaz. Sem evidência, o veredito é `BLOCKED`, nunca `PASS`. Essa é a principal defesa contra um oráculo que alucina.

## Tipos de evidência

O agente pede, para cada passo, o tipo mais forte que o ambiente permite (força decrescente). No modo guiado, o agente coleta E1 sozinho sempre que possível.

| Tipo | Exemplos | Quando pedir |
| --- | --- | --- |
| E1: Artefato bruto da máquina | Resposta HTTP, HAR, query no banco, log com timestamp, output de CLI | Sempre que o comportamento tem efeito observável por máquina (preferir coletar o próprio agente) |
| E2: Captura visual | Screenshot da tela inteira com URL e relógio visíveis, gravação curta | Comportamento de UI, mensagens, layout |
| E3: Transcrição literal | O tester copia o texto exato exibido | Quando não dá para capturar a tela |
| E4: Observação declarada | "O som tocou", "o LED piscou" | Apenas para o que é físico ou perceptual. Exige confirmação explícita do tester (`--declared`) |

## Regras do oráculo

1. **Critério antes da evidência.** O resultado esperado e o critério de aceitação ficam registrados no `script.md` *antes* da execução. O agente não pode reescrevê-los depois de ver a evidência. Se perceber que o critério está errado, registra uma emenda (`--type amendment`) com motivo e reexecuta o passo.
2. **Veredito estruturado.** Cada veredito traz `PASS`, `FAIL`, `BLOCKED`, `INCONCLUSIVE` ou `N/V`, a evidência citada, o trecho observado que sustenta a decisão e o grau de confiança (alta/média/baixa).
3. **Descrever antes de julgar.** Antes do veredito, o agente descreve literalmente o que vê na evidência (valores, textos, estados). O tester confirma ou corrige a descrição. Isso pega alucinação de leitura de screenshot antes que ela vire veredito.
4. **Confiança baixa vira pergunta.** Com confiança baixa, o agente pede outra evidência (tipo mais forte, outro ângulo) ou devolve `INCONCLUSIVE`. Nunca emite `PASS` com confiança baixa.
5. **Contestação é cidadã de primeira classe.** O tester pode contestar qualquer veredito. O agente reavalia, registra os dois lados e, se mantiver a divergência, marca `DISPUTED` para o dono do plano decidir.
6. **Probe obrigatório em PASS crítico.** Em requisitos marcados como críticos, um `PASS` dispara pelo menos uma variação: valor limite, entrada inválida, estado concorrente ou permissão diferente.
7. **Integridade da evidência.** O agente registra o hash (SHA-256) de cada arquivo em `session.jsonl` (automático via `acmt_log.py`). Screenshots precisam mostrar algo que os amarre ao ambiente da sessão, como URL, versão ou horário.

## Formato do veredito

```json
{"step": "TC-004.2", "req": ["REQ-011"], "verdict": "FAIL", "confidence": "high",
 "evidence": ["evidence/TC-004.2-http.har"],
 "observed": "POST /orders retornou 200 com body {status: 'pending'}",
 "expected": "201 com status 'created' (plano, seção 3.2)",
 "defect": "DEF-003", "ts": "2026-10-30T14:02:11-03:00"}
```

(No log real, `observed`/`expected` vão em `--text`; o `acmt_log.py` grava `ts`, hashes e o resto.)
