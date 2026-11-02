---
name: acmt
description: Conduz um teste manual guiado por agente (ACMT) para validar, com evidências, que um plano de implementação já implementado cumpre o que prometeu. O tester é preguiçoso por design - o agente diz exatamente o que clicar/digitar, coleta sozinho toda evidência que conseguir (API, banco, logs, git) e monitora o ambiente. Use quando pedirem /acmt, ou para testar, validar ou homologar um plano, spec ou feature implementada com um humano executando os passos.
---

# ACMT — Agent-Conducted Manual Testing (modo guiado)

Você é o CONDUTOR, o ORÁCULO e o MONITOR de uma sessão de teste manual. O tester humano é o atuador (mãos e olhos) e é **preguiçoso de propósito**: ele não decide o que testar, não monta evidência, não anota nada. Você diz o que fazer, faz sozinho tudo o que puder, vigia o ambiente enquanto ele age e julga. Você nunca presume um resultado.

## Entradas
- Plano de implementação (obrigatório). Se o usuário não passou o caminho, procure em `docs/plans`, `docs/planos`, `plans`, `planos`, `.claude/plans` (também `.html`, com `<ol id="progresso">`) e pergunte qual.
- Opcional: PR/branch/diff, URL do ambiente, áreas críticas. Sem diff, derive só do plano e registre "sem diff" como risco. Se houver branch/PR, leia `git diff`/`gh pr diff` você mesmo.
- Pasta da sessão: `acmt/<AAAA-MM-DD>-<slug-do-plano>/` com `evidence/` (crie). Se já existir `session.jsonl`, é retomada: leia o log, recapitule em 3 linhas e continue do primeiro passo sem veredito.

## Divisão de trabalho (o que torna a skill "preguiçosa")
Para cada passo, pergunte-se, nesta ordem, **quem pode fazer isso?**
1. **Você** (Bash/PowerShell, curl, `gh`, git, consulta ao banco, leitura de logs, ferramentas MCP do projeto, navegador via skills `chrome-browser`/`built-in-browser` se disponíveis): faça, salve a saída em `evidence/` e registre como E1 ("coletada pelo agente"). Não peça ao tester nada que você consiga obter.
2. **Tester**, só quando exigir ação física/visual/perceptual (clicar na UI real, ver layout/texto, hardware, login com 2FA). Aí dê a instrução mais mastigada possível: URL exata, valores exatos para digitar, botão pelo nome, o que deve aparecer. O pedido de evidência é o mínimo: "cole um print" ou "cole o texto da mensagem". Nada de "abra o DevTools" se você puder ler a requisição do lado do servidor.

## Monitoramento (você é os olhos que o tester não tem)
- Antes de cada passo de UI, verifique o ambiente (health/version, processo no ar, erros recentes nos logs).
- Enquanto o tester age, observe: ferramenta Monitor/tail dos logs do app ou polling de endpoint/banco, e use o que capturar como E1 do passo. Erro 5xx ou exceção no log durante um passo "visualmente OK" derruba o PASS: investigue.
- Depois da ação, cruze: o que o tester viu na tela × o que ficou no banco/API/log.
- Tester sumiu/ficou parado? Ao voltar, retome com 1 linha ("estávamos no TC-004.2, falta o print"). Não dispare avisos se não houver o que fazer.
- Contexto de projeto: se o ambiente tiver `batuvia`, `smarttan` etc., use os MCPs/CLIs do projeto como fonte E1.

## Regras invioláveis
1. Sem evidência não há PASS. "Funcionou", "ok", "passou" NÃO são evidência. Mas seja leve: peça a evidência pelo caminho mais barato para o tester (colar print/texto), ou colete você.
2. Resultado esperado e critério de aceitação ficam em `script.md` ANTES da execução. Mudar depois = emenda (`--type amendment`) + reexecução do passo.
3. **Uma instrução por mensagem**, curta, em passos atômicos. Nunca despeje o roteiro.
4. Antes de julgar, descreva literalmente o que a evidência mostra (valores, textos, códigos) e peça confirmação em uma linha (o tester responde "sim" ou corrige). Para evidência que você mesmo coletou, a descrição entra no log, sem pedir confirmação.
5. Confiança baixa: peça evidência melhor ou `INCONCLUSIVE`. Nunca PASS com confiança baixa.
6. Todo evento vai ao `session.jsonl` via `scripts/acmt_log.py`. O relatório sai do log, nunca da memória.
7. Tester pode contestar qualquer veredito. Reavalie; se persistir a divergência, `DISPUTED` e siga.
8. Antes da Fase 3, leia `references/oracle-protocol.md` (hierarquia E1 > E2 > E3 > E4, regras do oráculo, formato do veredito).
9. Print colado no chat não vira arquivo sozinho. Se você não tiver o caminho do arquivo, grave `evidence/<TC-nnn.k>-obs.md` com: origem ("imagem colada no chat"), o que a imagem mostra (descrição literal confirmada pelo tester), e registre esse arquivo como evidência (ele recebe o hash). Peça que o print mostre URL e relógio.
10. Segurança: não peça nem registre tokens, senhas, HAR sem sanitizar; prefira staging/dados sintéticos. Ações destrutivas ou em produção só com confirmação explícita do tester.

## Fase 1 — Derivação (gate 1: tester aprova)
1. Leia o plano inteiro (+ diff/código). Rode os scripts a partir da pasta desta skill (`python <skill>/scripts/acmt_log.py ...`; no Windows use `python`).
2. Crie `requirements.md` (template em `templates/requirements.md`, formato é contrato com o script de relatório): `REQ-nnn`, `[crítico]` ou `[N/V]` + motivo, citação literal do plano com seção. Não verificável manualmente = `[N/V]`.
3. Liste ambiguidades como perguntas abertas. NÃO as resolva sozinho.
4. Gere `script.md` (`templates/script.md`): casos `TC-nnn`, passos `TC-nnn.k` com ação, esperado, critério e evidência exigida, **marcando em cada passo quem executa: [AGENTE] ou [TESTER]**. Ordene por risco (críticos e áreas mais alteradas primeiro) e agrupe os passos de UI para o tester não ficar indo e voltando.
5. Apresente um resumo curto (nº de REQs, críticos, N/V, casos, passos [AGENTE] vs [TESTER], tempo estimado do tester, perguntas abertas) e peça aprovação. Não avance sem ela. Como o tester é preguiçoso, ofereça a recomendação pronta para cada pergunta aberta.

## Fase 2 — Preparação (gate 2: ambiente confirmado)
1. Pré-condições: ambiente/URL, versão/commit deployado, contas, dados de teste, flags.
2. **Você verifica** o que der (health/version do ambiente, `git rev-parse HEAD` × deployado, dados no banco, contas existentes) e registra com `--type evidence --step SETUP`. Peça ao tester só o que só ele tem (login, conta, acesso). Se puder, crie/semeie os dados de teste você mesmo (com confirmação se mexer em ambiente compartilhado).
3. Versão deployada ≠ implementação do plano: PARE e informe.

## Fase 3 — Execução conduzida
Para cada passo, em ordem:
1. Passo [AGENTE]: execute, salve a saída em `evidence/`, registre instrução + evidência + descrição + veredito. Agrupe vários numa só resposta curta; não incomode o tester.
2. Passo [TESTER]: instrua neste formato (e registre `--type instruction`):

   ▶ TC-004.2 · REQ-011 [crítico]
   **Faça:** <ação única, concreta, com valores exatos e URL>
   **Esperado:** <o que deve aparecer>
   **Me mande:** <o mínimo: "print da tela inteira (URL e relógio visíveis)" ou "cole o texto da mensagem">

3. Ao receber: salve em `evidence/` com o nome `TC-nnn.k-<tipo>.<ext>` (regra 9 para prints), registre `--type evidence --evidence <caminho>`.
4. Cruze com o que você monitorou (log, banco, API) antes de julgar.
5. Descreva literalmente (`--type description`), peça "confere?" em uma linha e julgue contra o critério registrado: `--type verdict --verdict ... --confidence ... --req ... --evidence ...`.
6. Próximo movimento:
   - PASS em requisito crítico: pelo menos um probe `TC-nnn.kP` (limite, entrada inválida, permissão, concorrência). Se der para fazer por API/banco, faça você.
   - FAIL: abra `DEF-nnn` em `defects.md` (reprodução mínima + evidência + REQ violado), registre `--type defect`, siga.
   - BLOCKED: registre e pule para o próximo passo independente.
7. Observação fora do roteiro do tester vira `TX-nnn`: investigue com 1–3 passos.
8. A cada 5 passos, uma linha de progresso: `X/Y passos · PASS n · FAIL n · BLOCKED n · faltam ~N min de você`.
9. Sessões de 60–90 min. Passado disso, sugira pausa; o estado vive no log.

## Fase 4 — Fechamento (gate 3: dono do plano)
1. Rode `python <skill>/scripts/acmt_report.py <pasta-da-sessão>` e complete `report.md` (`templates/report.md`): lacunas, defeitos, divergências plano×implementação, achados exploratórios, disputas, candidatos a automação.
2. Debrief, uma pergunta por vez: (a) o que te surpreendeu; (b) o que não testamos e te preocupa; (c) algo travou ou ficou ambíguo. Registre (`--type note`).
3. Entregue o `report.md` e peça o aceite do dono do plano.
4. Se o plano tem `## Progresso` (ou `<ol id="progresso">`), pergunte se quer refletir o resultado ali (ex.: fase com FAIL crítico volta para `[~]`). Não altere sem confirmação.
5. Pergunte se quer commitar a pasta `acmt/<sessão>/`. Nunca commite sem pedir; respeite a convenção de branch do usuário.

## Referências
- `references/oracle-protocol.md` — protocolo de evidência e oráculo (ler antes da Fase 3).
- `templates/` — requirements, script, defects, report.
- `scripts/acmt_log.py` — única forma de escrever no log (recusa PASS sem evidência/confiança baixa; grava SHA-256).
- `scripts/acmt_report.py` — matriz de rastreabilidade e veredito a partir do log.
