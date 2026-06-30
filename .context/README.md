# FluenJ — Vault de documentação

Este vault (gerido pelo **VaultForge**) é a fonte de documentação do projeto **FluenJ**. Ele complementa o `CLAUDE.md` do repositório com notas mais detalhadas e conectadas por links.

> Stack: Flutter 3.44 / Dart 3.12 / **shadcn_ui** (`ShadApp` puro, zero Material) · Desktop-only (Windows, Linux, macOS)

## Índice

### Projeto
- [[visao-geral]] — o que é o myide, stack, plataformas
- [[arquitetura]] — como o código se organiza (ShadApp + IdeShell multi-painel)

### Setup
- [[ambiente-desenvolvimento]] — rodar o Flutter neste Windows (PATH, proxy, Developer Mode)
- [[comandos-flutter]] — comandos essenciais do CLI

### UI
- [[adr-0004-shadcn-ui]] — UI ativa: `ShadApp` como root (zero Material), regras de tema e componentes (ADR-0004)
- [[hux-ui]] — _(histórico/obsoleto)_ guia de uso do Hux UI sobre MaterialApp (superseded por ADR-0004)
- [[componentes-hux]] — _(histórico/obsoleto)_ referência de componentes e enums do Hux (superseded por ADR-0004)

### IDE
- [[ide/README]] — índice da seção IDE (features, arquitetura, pré-requisitos, componentes)
- [[ide/visao-geral]] — myide como IDE para Java (escopo, LSP/DAP/build)
- [[ide/roadmap]] — fases incrementais (base → LSP → build → debug)

### Ambiente / ferramental
- [[mcps-disponiveis]] — MCPs disponíveis nesta sessão (dart-server, vaultforge, etc.)

### Decisões (ADRs)
- [[adr-0003-riverpod]] — state management com Riverpod (`flutter_riverpod`)
- [[adr-0004-shadcn-ui]] — UI `ShadApp` pura, zero Material (suprime ADR-0001)
- [[adr-0001-hux-sobre-material]] — _(superada por ADR-0004)_ Hux UI sobre shell MaterialApp
- [[adr-0002-compatibilidade-jdk]] — compatibilidade de JDK segue o range do jdt.ls (1.8–24); a JDK 21 dos servers é interna
- [[adr-0005-tooling-testes-2026]] — stack de tooling/testes 2026 (very_good_analysis, alchemist, mocktail)
- [[adr-0006-riverpod-codegen]] — manter Riverpod 3; codegen adiado (incompatível com 3.3.2)
- [[adr-0007-runtime-libs-ide]] — _(superada por ADR-0008)_ runtime da IDE (json_rpc_2 p/ LSP, xterm+flutter_pty)
- [[adr-0008-editor-proprio]] — editor de código próprio do zero (CustomPaint); suprime ADR-0007, remove re_editor/code_forge

### Pesquisas
- [[pesquisa/flutter-estado-da-arte-2026]] — estado-da-arte Flutter/Dart junho/2026 (state mgmt, signals, padroes, libs)
- [[pesquisa/spike-code-forge]] — spike do code_forge: refutado (build rust inviável); manter re_editor

## Convenções do vault
- Notas em português, nomes em kebab-case.
- Use wikilinks `[[nome]]` para ligar notas **que existem**.
- Atualize a nota correspondente (e este índice) sempre que a decisão/arquitetura mudar.
- Notas Hux (UI antiga) são preservadas como _histórico/obsoleto_ com banner, sem apagar o conteúdo.
