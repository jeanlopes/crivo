# Roteiro — <nome do plano>

Ordem por risco. Executor: [AGENTE] ou [TESTER]. Critérios congelados antes da execução (mudança só por emenda).

## TC-004 — Criação de pedido · REQ-001
Pré-condições: usuário com papel 'vendedor'; carrinho com 1 item

| Passo | Quem | Ação | Esperado | Critério de aceitação | Evidência |
| --- | --- | --- | --- | --- | --- |
| TC-004.1 | [TESTER] | Clicar em "Finalizar" | Tela de confirmação | Título "Pedido criado" visível | E2: print com URL e relógio |
| TC-004.2 | [AGENTE] | Consultar a requisição no log/API | 201, status 'created' | Status HTTP == 201 e body.status == 'created' | E1: saída salva em evidence/ |
