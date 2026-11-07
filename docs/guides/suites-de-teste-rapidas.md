# Suítes de teste rápidas — práticas e lições medidas

> Parte do framework do crivo. Escrito em **2026-11-06** a partir de um caso real: uma suíte de ~13 mil testes (servidor .NET, front em TypeScript e uma camada de regressão em Gherkin) que levava **48 minutos** numa máquina de 8 núcleos e passou a levar uma fração disso, **sem apagar nem enfraquecer nenhum teste**. Os exemplos são em .NET/NUnit, mas as lições valem para qualquer pilha.

## Por que isto importa para o crivo

O [gauntlet](../../gauntlet/README.md) só protege o que roda. Uma suíte que leva 48 minutos é uma suíte que quem desenvolve deixa de rodar inteira, que roda "no fim do plano", que se roda mal ("só o que mudei"), e cujo vermelho aparece tarde demais para ser barato. **Velocidade da suíte é uma propriedade de segurança**: a confiança calibrada do índice depende de o gate rodar de verdade, a cada mudança, num tempo que ninguém queira contornar.

## A regra-mãe

**Meça antes de otimizar e prove que o resultado é idêntico depois.** Otimizar teste não é apagar teste nem afrouxar asserção: é a *mesma lista* de testes, com o *mesmo resultado* teste a teste, em menos tempo. O número que vale é o **tempo de relógio da rodada oficial**, com o ambiente completo ligado.

Receita mínima:

1. Rode o projeto com um relatório por teste (`--logger trx`, JUnit XML, `--json`...) e some a duração **por classe**.
2. Escolha a hipótese pela evidência, não pela intuição.
3. Mude **uma** coisa.
4. Rode de novo e compare **por nome de teste e por resultado** (um multiconjunto `(classe, nome, resultado)` antes × depois; tem de ser vazio de diferenças).
5. Só então escreva o número no commit.

## Lições

### 1. O custo pode não estar onde você acha
Numa suíte web, 900 de ~2.900 testes custavam ~0,85 s cada, e a hipótese óbvia era «subir o servidor por teste» ou «o login». Um microbenchmark por etapa mostrou: criar a fábrica de teste ≈ 0 ms, subir o host ≈ 25 ms, banco de teste ≈ 30 ms, login ≈ 3 ms — e **a primeira requisição a um host novo ≈ 850 ms**, porque o framework **compila uma árvore de expressão por endpoint** (285 endpoints), refeito em cada host sem cache entre hosts. A solução depende da causa verdadeira; sem a medição por etapa, o esforço iria para o lugar errado.

### 2. Um interruptor de ambiente no *processo de teste* pode valer mais que reescrever testes
Rodar o processo de teste com o JIT sem otimização (`DOTNET_JITMinOpts=1`, configurado no `.runsettings`) reduziu o custo por host de ~850 para ~300 ms: a suíte web caiu de **18 min 34 s para 8 min 13 s**, com 2.879 testes idênticos. Funciona porque o que dominava era compilar muito código dinâmico uma única vez por host. É um ajuste **só do processo de teste** (a produção compila como sempre) e **não serve** para teste que mede desempenho.

### 3. O atalho óbvio pode ser um beco: rode a suíte inteira nele
`RuntimeFeature.IsDynamicCodeSupported=false` deixaria o host ~7× mais rápido (o framework web passa a interpretar em vez de compilar). Mas o ORM trata esse valor como «publicação AOT» e **recusa montar o modelo**: 2.113 de 2.880 testes falharam. Antes de adotar um interruptor de runtime, rode a suíte *inteira* com ele, não só o benchmark que ele acelera.

### 4. Compartilhe o que é só leitura; isole o que muda
Numa fixture que cria, migra e semeia um banco **por teste** (~1 s cada), 18 de 35 testes só liam o que o seed plantou. Esses passaram a dividir **um** banco migrado e semeado por fixture (`OneTimeSetUp`), os 17 que inserem dados ou semeiam com relógio próprio continuaram com banco descartável. Marque quem compartilha com uma **propriedade/atributo** no teste, em vez de mover testes de classe (mover muda a identidade do teste e quebra a comparação antes × depois). Tempo da fixture: 69 s → 40 s.

Nem tudo se compartilha: testes que **provam a instalação, a migração ou scripts que mutam** precisam do próprio banco vazio — aí o custo é o preço da prova.

### 5. O que parece I/O pode ser CPU: teste a hipótese barata
Antes de mexer no setup de banco, tentamos `innodb_flush_log_at_trx_commit=0` (menos fsync) esperando uma queda grande: 40 s → 38 s. O custo era CPU do ORM migrando, não disco. Hipóteses baratas de testar valem a pena; as caras (clonar esquema, template databases) só depois.

### 6. Nunca espere por tempo fixo; espere por condição — e saiba de onde vem cada prazo
39 testes terminavam em «nada chegou em 5000 ms». A tentação era zerar o prazo. A investigação mostrou que o prazo era o *padrão de um helper de teste* (e que a leitura já esperava por evento, não por polling); ele só era pago por testes **vermelhos** (uma regra de negócio nova os deixara falhando). Corrigido o vermelho, nenhum teste verde pagava os 5 s. Lição: antes de «consertar» uma espera, descubra se é margem do código de produção ou default de helper, e se só o teste vermelho a paga.

Quando a espera é de uma **configuração da própria aplicação** (ex.: quanto tempo o escritor aguarda a trava de um arquivo, 10 s por padrão), o teste configura o mínimo permitido: 11 s → 3 s com a mesma asserção.

### 7. Relógio injetado ≠ relógio sob controle: cuidado com o tempo real escondido
Um `FakeTimeProvider` avançado em passos de 1 s com uma espera *real* curta entre eles custava ~15,6 ms por passo no Windows (resolução do timer): 10 minutos simulados = 10 s reais. Trocar a espera real por `Task.Yield` **quebrou testes**, e elevar a resolução do timer do sistema também: os testes **dependiam** de tempo real passar entre os avanços (um comentário antigo do próprio projeto documentava: com o timer a 1 ms eles reprovavam de forma consistente). Tornar o tempo «totalmente determinístico» exigiria que o código sob teste anunciasse quando terminou de reagir — mudança de produção, fora de escopo.

O ganho seguro foi **passo maior onde a hora só precisa chegar lá**: testes de 10 s e 4 s para < 2 s, com um parâmetro opcional (`passo`) e padrão inalterado.

### 8. Rode o runner do front uma vez só
O gate rodava o vitest completo (98–180 s) e, depois, uma camada de regressão em Gherkin rodava o vitest **de novo** para provar que cada regra tem teste de tela (93 s só para o primeiro cenário). Solução: a etapa do front grava o relatório JSON; a camada Gherkin **lê** esse relatório quando ele é mais novo que o código-fonte do front (checagem por data de modificação), e cai no comportamento antigo (roda o runner) quando não há relatório — CI e `dotnet test` avulso continuam funcionando. 865 cenários: 129 s → 15 s.

### 9. Paralelismo: por fixture, com estado isolado, com teto de memória
`[assembly: Parallelizable(ParallelScope.Fixtures)]` roda **fixtures** em paralelo e mantém os testes de cada fixture em série. Resultados medidos (mesmos testes, mesmo resultado, 4 workers): suíte web 8 min 13 s → 4 min 10 s; suíte de serviços 3 min 48 s → 2 min 34 s; núcleo 51 s → 18 s; integração 51 s → 27 s. Com 8 workers o ganho adicional foi de 11% (a CPU satura).

- **O estado compartilhado aparece como falha em massa.** A primeira tentativa derrubou 174 testes («Operations that change non-concurrent collections must have exclusive access»). Rastrear a pilha achou a causa: um `NullabilityInfoContext` **estático** num helper de teste (não é thread-safe). Um por thread resolveu — e o mesmo padrão existia em outra suíte que só passava em paralelo *por sorte*. **Procure o padrão em todos os projetos**, não só onde falhou.
- **Nem tudo paraleliza.** Camada de regressão com **um host e um banco compartilhados**, em que cada cenário limpa o anterior, é serial por construção; testes com **orçamento de tempo** (desempenho) perdem para a disputa de CPU.
- **Teto de memória.** Meça o pico (RSS somado dos processos de teste) e derive o número de workers da **RAM livre** e dos núcleos. Os workers do NUnit são *threads* de um processo: 4 workers custaram ~1 GB. A regra usada: `clamp(RAM_livre_GB ÷ 3, 1, min(4, núcleos ÷ 2))` (3 GB livres por worker, com folga de 3× sobre o medido), sobrescrevível por variável de ambiente; `=1` volta ao serial.

### 10. A medição só vale com o ambiente completo ligado
A rodada original de 41 minutos rodou com **1.731 testes de banco ignorados** por falta de servidor: subestimava o tempo real. Para medir, ligue todos os servidores das matrizes (por exemplo, as duas «pistas» de um banco com comportamento dependente de configuração) e **exija-os** (uma variável que transforma «sem banco» em *falha*, não em *ignorado*). Um verde parcial não é um número.

### 11. Ao consertar vermelho, rode só o vermelho
Rodar a suíte inteira para descobrir se *um* conserto funcionou custa dezenas de minutos por tentativa. Guarde a lista dos vermelhos da última rodada; filtre por ela até zerar; só então rode tudo, uma vez. (Vale também para quem delega a correção: a instrução precisa ser explícita.)

### 12. Log enorme também é custo
`-v n` num `dotnet test` de solução gerava 168 mil linhas (20 MB) que ninguém lia. Verbosidade mínima + relatório por teste (trx) mantém os detalhes das falhas e dá o artefato que a comparação antes × depois precisa.

### 13. Separe unidade de integração
Dos ~2.900 testes de uma suíte web, 1.553 gastavam 21 s **no total**: eram testes que não subiam host. Quem sobe um host inteiro é teste de integração e precisa de um orçamento (e de paralelismo e de setup compartilhado). Se tudo é «integração», tudo é lento.

## O que não fazer

- Subir um host (ou criar um banco) **por teste** sem medir quanto isso custa.
- Zerar uma espera sem saber de onde ela vem.
- Trocar espera real por `Yield` (ou mudar a resolução do timer) para «acelerar» um relógio falso sem provar que os testes não dependem do tempo real.
- Alterar o código de produção para o teste ficar rápido: a fábrica/infraestrutura de teste é que se adapta.
- Comparar uma medição de hoje com uma de outra hora, com a máquina ocupada de outro jeito: repita antes **e** depois nas mesmas condições.
- Otimizar sem a comparação por teste: «ficou mais rápido» sem «e continua testando a mesma coisa» não vale.

## Checklist para uma suíte lenta

- [ ] Existe um relatório por teste (trx/JUnit/JSON) e a soma por classe?
- [ ] A hipótese vem de um microbenchmark por etapa, e não de intuição?
- [ ] Há ambiente completo ligado (todos os servidores das matrizes, `EXIGE_BANCO`)?
- [ ] Há interruptor de ambiente do processo de teste que reduza o custo dominante (e a suíte inteira passou com ele)?
- [ ] Fixtures só-leitura compartilham o que é caro de montar; as que mutam isolam?
- [ ] Nenhum teste verde paga um prazo fixo de espera?
- [ ] O relógio falso avança em passos compatíveis com o que o código precisa ver?
- [ ] O runner do front roda uma vez por gate?
- [ ] Paralelismo por fixture, com teto de memória derivado do que foi medido?
- [ ] O antes × depois foi comparado **por nome e por resultado**?
