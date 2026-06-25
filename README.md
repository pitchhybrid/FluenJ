<div align="center">

# FluenJ

**Uma IDE para Java, feita em Flutter.**

Desktop-first · Windows · Linux · macOS

[![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/platforms-Windows%20%7C%20Linux%20%7C%20macOS-blue)](#plataformas)
[![Stage](https://img.shields.io/badge/stage-alpha-orange)](#roadmap)

</div>

> ⚠️ **Status: Alpha (Fase 1).** Hoje o FluenJ é o **shell da IDE** — layout multi-painel,
> explorador de arquivos e editor com abas. A inteligência de linguagem (LSP/JDT LS),
> depuração (DAP), build (Maven/Gradle), XML (lemminx) e terminal integrado estão no
> [roadmap](#roadmap) e sendo construídos.

## ✨ Visão

O FluenJ nasce de uma pergunta simples: **e se uma IDE Java moderna fosse construída em Flutter?**

Aproveitando o Flutter desktop e o ecossistema maduro do **Eclipse JDT Language Server**,
o FluenJ orquestra processos nativos (JDK, JDT LS, java-debug, lemminx, Maven, Gradle) e
fala **LSP/DAP por JSON-RPC sobre stdio** — com uma UI rápida e customizável em
[`shadcn_ui`](https://pub.dev/packages/shadcn_ui) (sem Material na aparência).

### Features atuais (Fase 1)
- 🗂️ **Explorador de arquivos** com árvore preguiçosa (lazy) e ícones por extensão
- 📝 **Editor com abas** baseado em [`re_editor`](https://pub.dev/packages/re_editor) com syntax highlighting (Java, JSON, XML)
- 🪟 **Layout multi-painel** redimensionável (sidebar · editor · output · status bar)
- 🎨 **UI shadcn** (estética limpa, dark/light)
- 💾 Abrir projetos locais, editar, marcar alterações (dirty), salvar

### Features planejadas
- 🧠 **LSP** (Eclipse JDT LS): completion, hover, diagnostics, go-to-definition, símbolos
- 🔎 **Open Type / Open Symbol**
- 🐞 **Debug (DAP)** via java-debug: breakpoints, step, variáveis, **hot code replace**
- 🔨 **Maven** e **Gradle** (build/run dentro da IDE)
- 📄 **lemminx** para XML/XHTML (`pom.xml`, `web.xml`, etc.)
- 🖥️ **Terminal integrado** (xterm + PTY)

## 🚀 Quick start

### Pré-requisitos
- [Flutter](https://docs.flutter.dev/get-started/install) **3.44+** (stable) e Dart **3.12+**
- **JDK 21+** (será usado pelo JDT LS/lemminx — *planejado*; a IDE em si compila projetos Java **1.8 a 24**)
- **Windows:** habilite o **Modo de Desenvolvedor** (`start ms-settings:developers`) — necessário para o build de plugins (symlinks)

### Rodar
```bash
flutter pub get
flutter run -d windows   # ou: -d linux / -d macos
```

> 💡 **No Git Bash (Windows)** o `flutter` direto falha (PATH em formato MSYS). Use o helper
> `./scripts/dev.sh "run -d windows"` — ele resolve o PATH e desliga o proxy para o `test`. Veja
> [`CONTRIBUTING.md`](CONTRIBUTING.md#ambiente).

### Build de release
```bash
flutter build windows   # ou linux / macos
```

## 🏗️ Arquitetura

```
┌──────────────────────────────────────────────────────────┐
│  UI  (Flutter + shadcn_ui · ShadApp · zero Material)      │
│   explorers · editor(abas) · terminal · open type/symbol  │
├──────────────────────────────────────────────────────────┤
│  Aplicação (Dart · Riverpod)                              │
│   workspace · editor state · file service · event bus     │
├──────────────────┬───────────────┬───────────────────────┤
│  Language Svc    │  Build        │  Process / Transport   │
│  LSP client ─────┤  Maven        │  dart:io Process        │
│  DAP client ─────┤  Gradle       │  JSON-RPC over stdio    │
│  lemminx client ─┘               │  (Content-Length)       │
└──────────────────┴───────────────┴───────────────────────┘
        │                                                 │
        ▼                                                 ▼
  Eclipse JDT LS (núcleo: LSP + DAP) · lemminx · mvn · gradlew
```

O **Eclipse JDT LS é o núcleo** de quase tudo: linguagem (LSP), depuração (DAP via bundles
`java-debug`) e símbolos. Documentação detalhada no diretório [`.context/`](.context/) (vault).

## 📁 Estrutura

```
lib/
  main.dart / app.dart        ProviderScope + ShadApp (root)
  core/
    models/                   FileNode, ...
    services/                 FileSystemService
    state/                    Riverpod: workspace, editor, file_tree
  ui/
    ide_shell.dart            layout multi-painel (multi_split_view)
    sidebar/ explorer/ editor/ output/ welcome/ widgets/
.context/                     vault de documentação (arquitetura, ADRs, roadmap)
scripts/dev.sh                helper para comandos flutter neste ambiente
```

## 🗺️ Roadmap

| Fase | Status | Descrição |
|------|--------|-----------|
| 0 — Base | ✅ | App desktop + shadcn_ui |
| 1 — Shell da IDE | ✅ | Layout, explorador, editor com abas, status bar |
| 2 — Núcleo LSP | 🚧 | Cliente JSON-RPC/LSP + JDT LS (diagnostics, hover, completion) |
| 3 — Open Type/Symbol | 📋 | `workspace/symbol`, command palette |
| 4 — Build tools | 📋 | Maven + Gradle (CLI via Process) |
| 5 — XML/lemminx | 📋 | LSP para XML/XHTML |
| 6 — Debug (DAP) | 📋 | Breakpoints, step, hot code replace |
| 7 — Polimento | 📋 | Project explorer Java, run configs, search |

Veja o roadmap detalhado em [`.context/ide/roadmap.md`](.context/ide/roadmap.md).

## 🤝 Contribuindo

Contribuições são bem-vindas! Leia o [**CONTRIBUTING.md**](CONTRIBUTING.md) (setup do ambiente,
padrões de código e como enviar PRs) e o [Código de Conduta](CODE_OF_CONDUCT.md).

## 📄 Licença

Distribuído sob a licença **MIT**. Veja [`LICENSE`](LICENSE).

## 🙏 Agradecimentos

- [Eclipse JDT Language Server](https://github.com/eclipse-jdtls/eclipse.jdt.ls) — a inteligência Java
- [java-debug (Microsoft)](https://github.com/microsoft/java-debug) — debug adapter
- [Eclipse LemMinX](https://github.com/eclipse/lemminx) — XML language server
- [shadcn_ui](https://pub.dev/packages/shadcn_ui), [re_editor](https://pub.dev/packages/re_editor),
  [multi_split_view](https://pub.dev/packages/multi_split_view), [Riverpod](https://riverpod.dev)

<div align="center">

Feito com 💙 em Flutter · _FluenJ contributors_

</div>
