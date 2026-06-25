# myide IDE — visão geral

**myide** está se tornando uma **IDE para Java** estilo Eclipse (versão básica), em Flutter desktop (Windows/Linux/macOS).

## Objetivo
Um editor/IDE Java local que reúne: edição com inteligência de linguagem (LSP/JDT LS), depuração (DAP), build (Maven/Gradle) e suporte a XML/XHTML (lemminx).

## Escopo (inicial — "básico")
**Inclui:**
- Abrir/gerenciar projetos Java (Maven e Gradle)
- Editar arquivos com syntax highlight + LSP (completion, hover, diagnostics, go-to-definition)
- Abrir tipos e símbolos do workspace
- Rodar builds Maven/Gradle
- Depurar (breakpoints, step, variáveis, console)
- Editar XML/XHTML com validação/completion (lemminx)

**Fora do escopo inicial (deixar explícito):**
- Refatorações complexas (extract method, etc.) — só rename via LSP no começo
- Suporte a múltiplas linguagens além de Java/XML
- Git/VCS integrado (fase futura)
- Marketplace de plugins

## Como é possível em Flutter
O Flutter desktop tem acesso a **`dart:io`** (Process, FileSystem), então o app pode:
1. Spawnar e manter processos server (JDT LS, lemminx).
2. Falar com eles via **stdin/stdout** usando **JSON-RPC 2.0** (framing `Content-Length`).
3. Chamar ferramentas CLI (`mvn`, `gradlew`) e capturar saída.

## Comparações / referências
- Eclipse, VS Code + "Extension Pack for Java", IntelliJ Community — modelos de UX.
- nvim-jdtls / coc-java — exemplos de clients LSP Java fora do VS Code.
- O app é, em essência, um **client LSP/DAP** em Dart com UI em Flutter/Hux.

## Veja também
- [[ide-arquitetura]] · [[ide-prereqs]] · [[ide-roadmap]] · [[visao-geral]]
