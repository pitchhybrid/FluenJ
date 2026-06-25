# Componente — DAP (Debug Adapter Protocol, Java)

> Parte de [[ide-arquitetura]]. A parte mais complexa — deixar para a Fase 6.

## Como o debug Java funciona
**`java-debug` (Microsoft) NÃO é um DAP server standalone.** É um **bundle OSGi carregado dentro do jdt.ls**. Assim:
- Lança-se o **mesmo** processo jdt.ls, porém **com os bundles java-debug** (via `-javaagent`/config ou dropins).
- Esse processo fala **DAP sobre stdio** (JSON-RPC com framing `Content-Length`, igual ao LSP).
- Internamente, o java-debug usa o jdt.ls para resolver classes/paths e JDWP para falar com a JVM alvo.

> Prático: temos um **cliente DAP** (análogo ao cliente LSP) apontando para um processo jdt.ls+"debug".

## Sequência DAP típica
1. `initialize` (capabilities do cliente: suporta breakpoints, variáveis, etc.)
2. `launch` **ou** `attach`
   - `launch`: `{ mainClass, projectName, args, vmArgs, classPaths?, modulePaths? }`
   - `attach`: `{ hostName, port }` (JVM já rodando com `-agentlib:jdwp=...`)
3. `setBreakpoints` (por arquivo/linha) — antes do `configurationDone`
4. `configurationDone` → o debug **realmente inicia**
5. `threads` → `stackTrace` → `scopes` → `variables` (para montar a árvore de variáveis)
6. Controle: `continue`, `next`, `stepIn`, `stepOut`, `pause`, `disconnect`
7. Pontos de parada chegam como evento **`stopped`** (com `reason`: breakpoint/exception/step)
8. `terminated` / `exited` → fim da sessão

## Eventos importantes (server → client)
- `stopped` — pausou; buscar `stackTrace`/`variables`
- `output` — stdout/stderr/console do programa → **console de debug**
- `terminated` / `exited`
- `breakpoint` (validação: breakpoint válido/inválido/não resolvido)

## Resolução de launch args
- **mainClass**: via `java/resolveMainClass` (comando LSP do jdt.ls) — lista mains do projeto.
- **classpath/projectName**: o jdt.ls já conhece; o java-debug resolve.

## UI de debug (mapeamento)
| DAP | UI |
|---|---|
| `setBreakpoints` | gutter do editor (toggle no `re_editor`) |
| `stackTrace` | painel **Call Stack** |
| `variables` | painel **Variables** + Watch |
| `output` | **Debug Console** |
| `stopped` | destacar linha atual, habilitar controles de step |
| `evaluate` | REPL do console / hover de variável |

## Roteamento LSP vs DAP
- Dois **processos** jdt.ls, ou um só que fala os dois protocolos?
- Abordagem simples (inicial): **um processo para LSP** (edição) e **outro processo** (com bundles java-debug) **lançado sob demanda** para a sessão de debug — isolamento de falhas.

## Veja também
- [[ide-dap-features]] (catálogo de features DAP/java-debug: HCR, step filters, etc.) · [[ide-lsp]] · [[ide-prereqs]] · [[ide-roadmap]]
