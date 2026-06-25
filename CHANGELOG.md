# Changelog

Todas as mudanças notáveis deste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto adota [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Planejado
- **LSP (Eclipse JDT LS):** cliente JSON-RPC sobre stdio; diagnostics, hover, completion,
  go-to-definition, document/workspace symbols.
- **Open Type / Open Symbol** (command palette).
- **Maven** e **Gradle** (build/run via CLI `dart:io` Process).
- **lemminx** para XML/XHTML.
- **Debug (DAP)** via `java-debug`: breakpoints, step, variáveis, hot code replace.
- **Terminal integrado** (xterm + flutter_pty).
- Atalhos de teclado (Ctrl+S, etc.) e confirmação ao fechar abas com alterações.

## [0.1.0] - 2026-06-25

### Adicionado
- Shell da IDE (Fase 1): layout multi-painel redimensionável
  (sidebar · editor · output · status bar).
- Explorador de arquivos com árvore **lazy**, ícones por extensão e filtros
  (`target/`, `build/`, `.git/`…).
- Editor com abas baseado em `re_editor` com syntax highlighting (Java, JSON, XML),
  detecção de alterações (dirty) e salvamento.
- UI em **`shadcn_ui`** com `ShadApp` puro (**zero `MaterialApp`**) — ADR-0004.
- State management com **Riverpod** — ADR-0003.
- Tela de boas-vindas com seletor de pasta (`file_picker`).
- Plataformas: **Windows, Linux, macOS** (android/ios/web removidos).
- Vault de documentação em `.context/` (arquitetura, roadmap, ADRs, catálogos de features).
- `scripts/dev.sh` (helper de PATH/proxy para o Flutter no Git Bash/Windows).
- Documentação open-source: `README`, `CONTRIBUTING`, `CODE_OF_CONDUCT`, `SECURITY`.

### Decisões de arquitetura (ADRs)
- ADR-0001 _(superado)_ — Hux UI sobre MaterialApp.
- ADR-0002 — Compatibilidade de JDK segue o range do jdt.ls (1.8–24).
- ADR-0003 — State management com Riverpod.
- ADR-0004 — UI com shadcn_ui (ShadApp puro, zero Material) — _suprime ADR-0001_.

[Unreleased]: https://github.com/pitchhybrid/FluenJ/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/pitchhybrid/FluenJ/releases/tag/v0.1.0
