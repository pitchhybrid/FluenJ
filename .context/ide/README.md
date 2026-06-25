# myide — a IDE Java (seção)

Esta seção do vault documenta a transformação do `myide` em uma **IDE para Java** (estilo Eclipse, inicialmente básica), **desktop-only** (Windows/Linux/macOS).

> Ver também o contexto do app base: [[visao-geral]] e [[arquitetura]].

## Features planejadas
- **Project explorer** e **file explorer**
- **Open file** (editor com abas)
- **Open types** e **Open symbols** (via LSP)
- **LSP** (Eclipse JDT Language Server) — completion, hover, go-to-definition, diagnostics
- **DAP** (Debug Adapter Protocol) — breakpoints, step, variáveis
- **Maven integration** e **Gradle integration**
- **lemminx** — LSP para XML/XHTML (pom.xml, web.xml, xhtml)

## Princípio arquitetural
O app Flutter **desktop** spawna processos nativos via `dart:io` (JDK, JDT LS, java-debug, lemminx, mvn, gradle) e fala **LSP/DAP por JSON-RPC sobre stdio**. O **JDT LS é o núcleo** de quase tudo (linguagem + debug + símbolos).

**Compatibilidade de JDK**: o editor suporta projetos **Java 1.8 a 24** (o range aceito pelo jdt.ls), seguindo a **JDK padrão configurada** do projeto — a IDE não impõe versão. O Java 21+ dos *servers* é interno. Ver [[adr-0002-compatibilidade-jdk]].

## Índice da seção
- [[ide-visao-geral]] — objetivo, escopo, o que é/inicialmente não é
- [[ide-arquitetura]] — camadas, fluxo de dados, processo-mestre
- [[ide-prereqs]] — requisitos do sistema (JDK, jdt.ls, lemminx, mvn, gradle)
- [[ide-stack]] — pacotes Dart/Flutter escolhidos
- [[ide-roadmap]] — fases de implementação
- Componentes (um por feature):
  - [[ide-explorers]] · [[ide-editor]] · [[ide-editor-features]] · [[ide-terminal]]
  - [[ide-lsp]] · [[ide-lsp-features]] · [[ide-dap]] · [[ide-dap-features]]
  - [[ide-open-types-symbols]] · [[ide-maven]] · [[ide-gradle]] · [[ide-gradle-features]] · [[ide-lemminx]] · [[ide-lemminx-features]]
