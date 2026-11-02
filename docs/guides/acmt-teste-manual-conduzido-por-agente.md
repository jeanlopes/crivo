# Agent-Conducted Manual Testing (ACMT) — metodologia e skill

> Parte do framework do crivo. Escrito em **2026-10-30** por Jean Lopes. A skill `/acmt` que implementa esta metodologia está versionada em [`skills/acmt/`](../../skills/acmt/).

## Resumo

ACMT (Agent-Conducted Manual Testing) inverte a automação de testes: o agente de IA é o *test runner* e o humano é o atuador e sensor. O agente lê a spec ou o plano de implementação, deriva um roteiro rastreável, conduz o tester passo a passo, exige evidência de cada verificação e emite o veredito. Quem decide pass/fail é o agente, mas só com base na evidência. O tester pode contestar, e a contestação fica registrada.

O uso-alvo deste documento é **validar um plano de implementação que já foi implementado**: confirmar, com evidência, que o que o plano prometeu existe e se comporta como descrito.

**Quando ACMT é a escolha certa**

- O sistema não tem acesso programático confiável: legado, UI de terceiros, hardware físico, ambientes travados.
- A validação exige julgamento humano: UX, texto, fluxo de negócio, percepção.
- O plano acabou de ser implementado e ainda não existe suíte automatizada. ACMT valida agora e deixa um roteiro que depois pode virar automação.
- Auditoria ou compliance: é preciso provar o que foi verificado, por quem, com qual evidência.

**Quando não usar:** regressão de alto volume que já pode ser automatizada, ou verificação de lógica pura que um teste unitário cobre melhor.

**A tese central:** gerar roteiro a partir de spec virou commodity. O valor está no meio do loop. São três coisas: (1) o agente atua como oráculo sobre a evidência, (2) a condução é adaptativa, com estado de cobertura, e (3) a rastreabilidade é auditável, ligando requisito, passo, evidência e veredito.

## Fundamentação e trabalhos relacionados

Nenhum trabalho publicado propõe o loop completo da ACMT. As peças existem separadas, e a ACMT as combina.

| Trabalho | O que contribui | O que falta para ACMT |
| --- | --- | --- |
| [PentestGPT](https://arxiv.org/pdf/2308.06782) (Deng et al., 2023) | Humano como executor puro das diretivas do LLM, devolvendo resultados sem comentário. É a inversão de papéis da ACMT. | Usado só como método de avaliação. Não tem rastreabilidade com spec nem protocolo de evidência. |
| [BotExpTest](https://arxiv.org/abs/2307.05807v1) (Copche et al., 2023/2024) | Chatbot que acompanha sessões de teste exploratório: timebox, guidelines, report de bugs. | Pré-LLM. Não raciocina sobre evidência nem deriva roteiro de spec. |
| Feldt, Kang, Yoon & Yoo (2023), *Towards Autonomous Testing Agents via Conversational LLMs* | Taxonomia de autonomia. ACMT é o nível *Conversational Testing with Tools*, com o humano no papel de ferramenta. | Taxonomia, não método. |
| [LLM-generated manual tests](https://sol.sbc.org.br/index.php/sast/article/download/36887/36673) (SAST 2025) | Gera casos de teste manuais em linguagem natural com qualidade comparável aos humanos. | Para no roteiro. Não tem execução assistida. |
| Session-Based Test Management (Bach, 2000) | Charter, timebox, sessão e debrief como unidade gerenciável de teste manual. | O condutor é humano. ACMT coloca o agente nesse papel. |
| Oracle problem (Barr et al., 2015) | Formaliza a dificuldade de decidir se uma saída está correta. | ACMT usa um LLM multimodal como oráculo, o que exige salvaguardas (seção de Protocolo de evidência). |

O enquadramento mais preciso é este: **ACMT é SBTM em que o agente é o test lead e o oráculo, sobre roteiros derivados de spec, com rastreabilidade de ponta a ponta.**

## Modelo da metodologia

Uma sessão ACMT tem quatro fases (Derivação, Preparação, Execução conduzida e Fechamento) e dois papéis com autoridade separada. O agente decide o *que* verificar e *se* a evidência basta. O tester decide *como* operar o sistema e pode contestar qualquer veredito.

### Papéis

| Papel | Responsabilidades | Não faz |
| --- | --- | --- |
| Agente (condutor + oráculo) | Deriva o roteiro, ordena os passos por risco, emite instruções atômicas, especifica a evidência exigida, julga a evidência, mantém o estado de cobertura, abre defeitos e escreve o relatório | Inventar resultado sem evidência, pular um requisito sem registrar o motivo, aceitar "funcionou" como evidência |
| Tester (atuador + sensor) | Executa a instrução, captura a evidência pedida, relata observações fora do roteiro, contesta vereditos | Decidir sozinho que um passo passou, alterar o roteiro sem registro |
| Dono do plano (opcional) | Resolve ambiguidade da spec durante a sessão, aceita ou rejeita o relatório final | Executar passos |

### Artefatos

Todos ficam em `acmt/<sessao>/` no repositório ou workspace, versionados e legíveis por humano.

| Arquivo | Conteúdo | Quem escreve |
| --- | --- | --- |
| `requirements.md` | Requisitos atômicos extraídos do plano, cada um com ID `REQ-nnn` e citação literal do trecho de origem | Agente, revisado pelo tester |
| `script.md` | Casos `TC-nnn` com pré-condições, passos `TC-nnn.k`, resultado esperado e evidência exigida por passo | Agente |
| `session.jsonl` | Log append-only de cada evento: instrução, evidência recebida, veredito, contestação | Agente |
| `evidence/` | Screenshots, HARs, logs, outputs, nomeados `TC-nnn.k-<tipo>.<ext>` | Tester |
| `defects.md` | Defeitos `DEF-nnn` com reprodução, evidência e requisito violado | Agente |
| `report.md` | Matriz de rastreabilidade, cobertura, vereditos e riscos residuais | Agente |

### Ciclo de vida

1. **Derivação.** O agente lê o plano e, quando disponível, o diff ou código do que foi implementado. Extrai requisitos atômicos e verificáveis e marca os não verificáveis manualmente como `N/V`, com o motivo. Gera o roteiro e o ordena por risco: o que foi mais alterado e o que é mais crítico vem primeiro. O tester revisa e aprova (*gate* 1).
2. **Preparação.** O agente lista as pré-condições (ambiente, dados, contas, flags) e o tester confirma cada uma com evidência (versão deployada, commit, URL). Sem ambiente confirmado, não há execução (*gate* 2).
3. **Execução conduzida.** O loop principal. Para cada passo, o agente emite **uma** instrução e a evidência exigida. O tester executa e envia a evidência. O agente julga e registra o veredito, e então avança, aprofunda (*probe*) ou abre defeito. Observações fora do roteiro viram passos exploratórios `TX-nnn`.
4. **Fechamento.** O agente consolida a matriz e lista o que não foi coberto e por quê. Faz o debrief com o tester, no estilo SBTM, e entrega o `report.md`. O dono do plano aceita ou rejeita (*gate* 3).

O diagrama abaixo mostra os estados de um passo durante a execução.

```text
PENDENTE -> INSTRUIDO -> EVIDENCIA RECEBIDA -> DESCRITO (tester confirma) -> VEREDITO
VEREDITO: PASS | FAIL (abre DEF) | BLOCKED | INCONCLUSIVE (pede evidência melhor) | N/V
PASS em requisito crítico -> probe obrigatório (TC-nnn.kP)
qualquer veredito -> contestação -> reavaliação -> mantido, alterado ou DISPUTED
```

Qualquer veredito pode ser contestado pelo tester. O agente reavalia e, se a divergência persistir, o passo vira `DISPUTED` e vai para o dono do plano.

## Protocolo de evidência e oráculo

Todo veredito tem que apontar para uma evidência concreta e para o critério que ela satisfaz. Sem evidência, o veredito é `BLOCKED`, nunca `PASS`. Essa é a principal defesa contra um oráculo que alucina.

### Tipos de evidência

O agente pede, para cada passo, o tipo mais forte que o ambiente permite. Na tabela, a força decresce de cima para baixo.

| Tipo | Exemplos | Quando pedir |
| --- | --- | --- |
| E1: Artefato bruto da máquina | Resposta HTTP, HAR, query no banco, log com timestamp, output de CLI | Sempre que o comportamento tem efeito observável por máquina |
| E2: Captura visual | Screenshot da tela inteira com URL e relógio visíveis, gravação curta | Comportamento de UI, mensagens, layout |
| E3: Transcrição literal | O tester copia o texto exato exibido | Quando não dá para capturar a tela |
| E4: Observação declarada | "O som tocou", "o LED piscou" | Apenas para o que é físico ou perceptual. Exige confirmação explícita do tester |

### Regras do oráculo

1. **Critério antes da evidência.** O resultado esperado e o critério de aceitação ficam registrados no `script.md` *antes* da execução. O agente não pode reescrevê-los depois de ver a evidência. Se perceber que o critério está errado, registra uma emenda com motivo e reexecuta o passo.
2. **Veredito estruturado.** Cada veredito traz `PASS`, `FAIL`, `BLOCKED`, `INCONCLUSIVE` ou `N/V`, a evidência citada, o trecho observado que sustenta a decisão e o grau de confiança (alta/média/baixa).
3. **Descrever antes de julgar.** Antes do veredito, o agente descreve literalmente o que vê na evidência (valores, textos, estados). O tester confirma ou corrige a descrição. Isso pega alucinação de leitura de screenshot antes que ela vire veredito.
4. **Confiança baixa vira pergunta.** Com confiança baixa, o agente pede outra evidência (tipo mais forte, outro ângulo) ou devolve `INCONCLUSIVE`. Ele nunca emite `PASS` com confiança baixa.
5. **Contestação é cidadã de primeira classe.** O tester pode contestar qualquer veredito. O agente reavalia, registra os dois lados e, se mantiver a divergência, marca `DISPUTED` para o dono do plano decidir.
6. **Probe obrigatório em PASS crítico.** Em requisitos marcados como críticos, um `PASS` dispara pelo menos uma variação: valor limite, entrada inválida, estado concorrente ou permissão diferente.
7. **Integridade da evidência.** O agente registra o hash (SHA-256) de cada arquivo em `session.jsonl`. Screenshots precisam mostrar algo que os amarre ao ambiente da sessão, como URL, versão ou horário.

### Formato do veredito

```json
{"step": "TC-004.2", "req": ["REQ-011"], "verdict": "FAIL", "confidence": "high",
 "evidence": ["evidence/TC-004.2-http.har"],
 "observed": "POST /orders retornou 200 com body {status: 'pending'}",
 "expected": "201 com status 'created' (plano, seção 3.2)",
 "defect": "DEF-003", "ts": "2026-10-30T14:02:11-03:00"}
```

## Rastreabilidade e relatório final

O relatório responde a uma pergunta: **o plano foi implementado como prometido?** Ele é gerado a partir do `session.jsonl`, nunca da memória do agente, para que cada linha seja verificável.

### Estrutura do `report.md`

1. **Veredito do plano**, em uma frase: `ACEITO`, `ACEITO COM RESSALVAS` ou `REJEITADO`, com a contagem de requisitos por status.
2. **Matriz de rastreabilidade**, uma linha por requisito:

| REQ | Trecho do plano | Casos | Veredito | Evidência | Defeito |
| --- | --- | --- | --- | --- | --- |
| REQ-011 | "Criar pedido retorna 201" (§3.2) | TC-004.1, TC-004.2 | FAIL | TC-004.2-http.har | DEF-003 |
| REQ-012 | "Pedido aparece na listagem" (§3.3) | TC-005.1 | PASS | TC-005.1-screen.png | — |

3. **Lacunas de cobertura.** Requisitos `N/V`, `BLOCKED` ou `INCONCLUSIVE`, cada um com o motivo e o que seria necessário para cobri-lo.
4. **Defeitos**, por severidade, com link para `defects.md`.
5. **Divergências entre plano e implementação** que não são defeitos: comportamento implementado que o plano não descreve, ou trechos ambíguos que precisaram de interpretação.
6. **Achados exploratórios** (`TX-nnn`), fora do roteiro.
7. **Disputas** (`DISPUTED`) que aguardam decisão do dono do plano.
8. **Candidatos a automação.** Passos com evidência E1 e determinísticos, que podem virar teste automatizado.

### Regra de aceite

- `ACEITO`: todos os requisitos críticos `PASS`, nenhum `FAIL`, lacunas justificadas.
- `ACEITO COM RESSALVAS`: sem `FAIL` em requisito crítico, com `FAIL` menores ou lacunas listadas.
- `REJEITADO`: qualquer `FAIL` em requisito crítico, ou mais de 20% dos requisitos sem cobertura. O limite é configurável.

## A skill `/acmt`

A skill vive em [`skills/acmt/`](../../skills/acmt/) neste repositório (fonte da verdade) e roda a partir de `~/.claude/skills/acmt/`.

### Instalar e atualizar

```powershell
# Windows (PowerShell), a partir da raiz do crivo
Copy-Item -Recurse -Force skills\acmt $HOME\.claude\skills\acmt
```

Depois abra uma sessão nova do Claude Code e use `/acmt`. Ao mudar a skill, edite **aqui**, passe pelo PR e reinstale; a cópia em `~/.claude` nunca é editada à mão.

### Conteúdo

```text
skills/acmt/
├── SKILL.md                      protocolo das 4 fases + modo guiado
├── references/oracle-protocol.md tipos de evidência E1-E4, regras do oráculo, formato do veredito
├── templates/                    requirements, script, defects, report
└── scripts/
    ├── acmt_log.py               único caminho de escrita no session.jsonl (recusa PASS sem evidência ou com confiança baixa; grava SHA-256)
    └── acmt_report.py            matriz de rastreabilidade e veredito do plano, gerados do log
```

Os scripts fazem o que não pode depender da disciplina do modelo. O formato de `requirements.md` é contrato com `acmt_report.py` (`- **REQ-nnn** [crítico|N/V]: descrição — fonte: "..." (§x)`).

### Modo guiado (o tester preguiçoso)

Variação adotada no crivo sobre o protocolo base: o tester é só mãos e olhos, e o agente carrega o resto.

- **Divisão de trabalho.** Cada passo do roteiro é marcado `[AGENTE]` ou `[TESTER]`. O que o agente consegue fazer (curl, `gh`, git, banco, logs, MCPs do projeto, navegador) ele faz e salva como evidência E1 coletada por ele. O tester recebe só o que exige ação física ou visual, em instruções atômicas, com URL e valores exatos, e pedido de evidência mínimo ("cole um print").
- **Monitoramento.** O agente verifica o ambiente antes de cada passo de UI, vigia logs/API/banco enquanto o tester age e cruza o que o tester viu com o que o sistema registrou. Erro no log durante um passo "visualmente OK" derruba o PASS.
- **Print colado no chat** não vira arquivo sozinho: o agente grava `evidence/<passo>-obs.md` com a origem, a descrição literal confirmada pelo tester, e esse arquivo recebe o hash.
- **Fechamento.** Perguntar se o resultado deve refletir na seção `## Progresso` do plano e se a pasta `acmt/<sessão>/` deve ser commitada. Nada disso é feito sem pedido.
- As regras do oráculo **não** afrouxam: sem evidência não há PASS, critério congelado antes da execução, descrição literal antes do veredito, contestação registrada.

### Validar a skill antes de usar de verdade

Rode uma sessão de ensaio contra um plano pequeno (3 a 5 requisitos) e confira cinco comportamentos. Se algum falhar, endureça a regra correspondente no `SKILL.md`.

| Cenário de ensaio | Comportamento esperado do agente |
| --- | --- |
| Tester responde "funcionou" sem anexo | Recusa e pede a evidência especificada. Nenhum veredito registrado |
| Screenshot mostra um valor diferente do esperado | Descrição literal cita o valor real. Veredito FAIL e DEF aberto |
| Screenshot ilegível ou cortado | INCONCLUSIVE ou pedido de E1. Nunca PASS |
| Tester contesta um FAIL com bom argumento | Reavalia e registra a contestação. Muda o veredito ou marca DISPUTED |
| Sessão interrompida e retomada em outra conversa | Lê o `session.jsonl`, recapitula e continua do passo certo |

> **Status (2026-10-30):** os scripts foram testados isoladamente (recusa de PASS com confiança baixa, geração da matriz). O ensaio acima **ainda não foi feito** com um plano real.

### Onde ficam os artefatos de cada sessão

`acmt/<AAAA-MM-DD>-<slug-do-plano>/` no repositório **do produto testado**, junto do PR que implementou o plano (não no crivo). O relatório vira registro da entrega.

## Como usar para validar um plano já implementado

Entregue ao agente três coisas: o plano, o que foi implementado (PR ou diff) e o ambiente. Deixe que ele conduza. O diff é o que torna a derivação honesta: o agente prioriza o que mudou e detecta trechos do plano sem código correspondente.

### Prompt de abertura

```text
/acmt

Plano: docs/plans/2026-10-checkout-v2.md
Implementação: PR #482 (branch feat/checkout-v2, já em staging)
Ambiente: https://staging.exemplo.com — conta de teste vendedor@exemplo.com
Crítico: tudo que envolve pagamento e cálculo de frete
Tester: eu. Tenho DevTools e acesso de leitura ao banco de staging.

Quero saber se o plano foi implementado como prometido.
Comece pela Fase 1 e espere minha aprovação do roteiro.
```

Três detalhes desse prompt mudam o resultado:

- **Declarar o que o tester consegue capturar** (DevTools, banco, logs) libera evidência E1. Sem isso, o agente tende a pedir só screenshot.
- **Marcar o crítico** ativa a regra de probe obrigatório onde o risco é maior.
- **Pedir para esperar a aprovação** força o *gate* 1. Revisar `requirements.md` é o momento mais barato para pegar requisitos mal extraídos.

### Como é uma troca típica na Fase 3

```text
Agente: ▶ TC-004.2 · REQ-011 [crítico]
        Faça: no carrinho com 1x "Camiseta P" (R$ 59,90), CEP 90010-000, clique em "Finalizar".
        Esperado: POST /orders responde 201 com status "created" e total 59.90 + frete.
        Envie: [E1] HAR da requisição → evidence/TC-004.2-http.har

Tester: [anexa HAR]

Agente: Observei: POST /orders → 200; body.status = "pending"; body.total = 74.80.
        Confere?

Tester: Confere.

Agente: FAIL (confiança alta). Esperado 201/"created" (plano §3.2); observado 200/"pending".
        Abri DEF-003. Próximo: TC-004.3, que não depende deste.
```

### Dicas de operação

- **Sessões de 60 a 90 minutos**, como no SBTM. Planos grandes viram várias sessões sobre o mesmo `session.jsonl`.
- **Se o agente começar a aceitar "ok"**, lembre a regra 1 do `SKILL.md`. Se acontecer de novo, endureça a regra.
- **Plano sem PR claro**: diga isso explicitamente. O agente então deriva só do plano e marca a falta do diff como risco no relatório.
- **Antes de automatizar**, use a seção "candidatos a automação" do relatório como backlog: são passos já validados, com critério e evidência E1.

## Riscos, limitações e métricas

O maior risco da ACMT é um falso PASS dado com convicção. As salvaguardas do protocolo reduzem esse risco, mas não o eliminam. Por isso a metodologia precisa ser medida, e não apenas adotada.

### Riscos e mitigações

| Risco | Como aparece | Mitigação |
| --- | --- | --- |
| Alucinação na leitura da evidência | O agente "vê" um valor que não está no screenshot | Descrição literal confirmada pelo tester (regra 3) e preferência por E1 |
| Requisito mal extraído | A matriz fica verde, mas testa outra coisa | Citação literal obrigatória e *gate* 1 com revisão humana |
| Critério ajustado à evidência | O agente racionaliza o resultado observado | Critério congelado antes da execução; mudanças só por emenda registrada |
| Complacência do tester | O tester confirma descrições sem olhar | Probes em críticos e amostragem de auditoria (abaixo) |
| Deriva do agente em sessões longas | O agente esquece regras e aceita "ok" | Sessões de até 90 min, estado no log e `acmt_log.py` recusando PASS sem evidência |
| Ambiente errado | Testa uma versão que não é a do PR | *Gate* 2 com evidência de versão/commit |
| Evidência com dados sensíveis | HAR com tokens ou dados pessoais | Usar ambiente de staging com dados sintéticos; sanitizar HAR antes de anexar |

### Limitações

- Não substitui teste de carga, segurança ofensiva ou regressão de alto volume. Esses ficam `N/V` com o motivo.
- A qualidade final depende do plano. Um plano vago gera requisitos vagos, e a ACMT apenas torna isso visível nas perguntas abertas.
- O custo de tempo do tester aumenta em relação a um teste informal. O ganho está na evidência e na rastreabilidade, não na velocidade.

### Métricas para avaliar a própria metodologia

Meça nas primeiras 5 a 10 sessões antes de padronizar no time.

| Métrica | Como medir | Sinal de alerta |
| --- | --- | --- |
| Taxa de falso PASS | Auditor humano reavalia uma amostra de 10% dos PASS a partir das evidências | Qualquer falso PASS em requisito crítico |
| Concordância agente × auditor | % de vereditos iguais na amostra auditada | Abaixo de 90% |
| Taxa de contestação | Contestações / vereditos | Muito alta: critérios ruins. Zero: tester complacente |
| Defeitos escapados | Bugs achados em produção ligados a REQs marcados PASS | Qualquer ocorrência em REQ crítico |
| Cobertura | REQs testáveis com veredito / REQs testáveis | Abaixo de 80% |
| Custo | Minutos de tester por requisito | Comparar com o processo atual |

Essas métricas também respondem à lacuna apontada na literatura. Se forem registradas de forma sistemática, as sessões viram material empírico publicável sobre LLM como oráculo em teste conduzido.

## Fontes

- [PentestGPT: An LLM-empowered Automatic Penetration Testing Tool](https://arxiv.org/pdf/2308.06782)
- [Can a Chatbot Support Exploratory Software Testing? (BotExpTest)](https://arxiv.org/abs/2307.05807v1)
- [Unveiling Assumptions: Exploring the Decisions of AI Chatbots and Human Testers](https://arxiv.org/pdf/2406.11339) (cita a taxonomia de Feldt et al.)
- [LLM-generated manual tests (SAST 2025)](https://sol.sbc.org.br/index.php/sast/article/download/36887/36673)
- [Evaluating the Impact of a Multi-Agent AI Assistant on Human Creativity in Exploratory Testing (Chalmers, 2026)](https://odr.chalmers.se/bitstreams/5dbc91f1-2809-4940-9691-664c0e5f2490/download)
