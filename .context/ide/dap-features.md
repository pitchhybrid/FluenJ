# Catálogo de features — DAP / java-debug

> Referência rica de **Debug Adapter Protocol** + **java-debug** (Microsoft). Fontes: [VS Code Java debugging](https://code.visualstudio.com/docs/java/java-debugging), [Debugger for Java](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-debug), [DebugAgent comparison](https://debugagent.com/what-are-you-missing-by-debugging-in-vs-code). Complementa [[ide/dap]].

> Relembre: o java-debug é um **bundle dentro do jdt.ls**; o DAP roda sobre stdio do mesmo processo. Ver [[ide/dap]] e [[adr-0002-compatibilidade-jdk]].

## DAP — padrão (aplicável a qualquer adapter)
| Recurso | Uso |
|---|---|
| **Breakpoints** de linha | `setBreakpoints` (arquivo+linha) |
| **Conditional breakpoints** | condição booleana; só para se verdadeira |
| **Hit count breakpoints** | parar após N ocorrências |
| **Logpoints** | loga mensagem sem parar (`{expr}` interpolado) |
| **Data/Variable breakpoints** | parar em leitura/escrita de variável |
| **Function breakpoints** | parar em função por nome |
| **Stepping** | `next` (step over), `stepIn`, `stepOut`, `continue`, `stepBack` (se suportado) |
| **Threads** | `threads`, e evento `thread` |
| **Call stack** | `stackTrace` → `scopes` → `variables` |
| **Watch / Evaluate** | `evaluate` (watch, REPL, hover) |
| **Run/launch vs attach** | `launch` (cria JVM) / `attach` (JDWP socket) |
| **Terminate** | `disconnect` / `terminate` |

## java-debug — específico (features que valem integrar)
| Feature | Status | Notas |
|---|---|---|
| **Hot Code Replace (HCR)** ✅ | aplica `.class` alterados **sem reiniciar** a sessão — envia pelo canal de debug | event `hotcodereplace`; ótimo p/ iteração rápida |
| **Step Filters** ✅ | pular `java.*`, `sun.*`, getters/synthetics/construtores durante o step | setting `java.debug.settings.stepping.*` / `stepFilters` |
| **Exception Breakpoints** ✅ | parar em exceções **caught/uncaught**, por tipo | `java.debug.settings.exceptionBreakpoint.*` |
| **Expression Evaluation** ✅ | avaliar expressões Java no contexto do frame | `evaluate`, watch, REPL |
| **No-Config Debug** ✅ | debugar `main()` sem `launch.json` | `java.resolveMainClass` |
| **Method Breakpoint** ⚠️ parcial | parar na entrada/saída de método | menos robusto que IntelliJ |
| **Field Watchpoint** ⚠️ parcial | parar em acesso/modificação de campo | limitado |
| **Virtual Threads (JDK 21+)** ⚠️ emergente | debugar virtual threads | suporte em evolução |

## Eventos DAP (server → client)
- `stopped` (reason: breakpoint/step/exception/pause) → buscar `stackTrace`/`variables`
- `output` (stdout/stderr/console) → **Debug Console**
- `terminated` / `exited`
- `breakpoint` (validação: resolvido/não-resolvido/inválido)
- **`hotcodereplace`** (custom java-debug) → perguntar/ reaplicar mudanças

## Settings relevantes (jdt.ls + java-debug)
- `java.debug.settings.stepping.*` (skip getters/statics/constructors/synthetic)
- `java.debug.settings.exceptionBreakpoint.*` (caught/uncaught, classes)
- `java.debug.settings.hotCodeReplace`
- `java.debug.settings.console`, `java.debug.settings.logLevel`, `java.debug.settings.vmArgs`
- `java.debug.settings.enableRunDebugCodeLens` → liga o code lens **Run | Debug**

## Detalhes práticos para a UI
- **Code lens Run|Debug** acima de `main()`/`@Test` depende do java-debug + `java.resolveMainClass` — liga após o DAP estar pronto.
- **Launch args**: `mainClass`, `projectName`, `args`, `vmArgs`, `modulePaths`, `classPaths` — o java-debug resolve com o jdt.ls.
- **Attach**: `{ hostName, port }` para JVM com `-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005`.
- **HCR** é a feature "mágica" que aproxima a experiência do IntelliJ — priorizar.

## Sugestão de prioridade (no [[ide/roadmap]], Fase 6)
- **Core**: launch/attach, breakpoints de linha/conditional/logpoint, step, stack, variables, console.
- **Sequência**: evaluate/watch, step filters, exception breakpoints.
- **Diferencial**: **Hot Code Replace**, code lens Run|Debug, method/field breakpoints.

## Veja também
- [[ide/dap]] · [[ide/lsp-features]] · [[ide/roadmap]] · [[ide/editor]]
