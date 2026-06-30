# FluenJ IDE — roadmap

Fases incrementais. Cada fase deixa o app utilizável antes da próxima começar.

> Tooling de testes adotado ([[adr-0005-tooling-testes-2026]]): `very_good_analysis` + `alchemist` + `mocktail`.
>
> **Editor próprio em construção:** substituindo `re_editor` por um editor `CustomPaint` do zero ([[adr-0008-editor-proprio]]). A Fase 2 (LSP) será construída sobre ele.

## ✅ Fase 0 — Base (concluída)
App desktop Flutter + **shadcn_ui** (`ShadApp` sobre `WidgetsApp`, **zero Material** — ADR-0004). Ver [[ide/visao-geral]] e [[ide/arquitetura]].

## ✅ Fase 1 — Shell da IDE (concluída)
- Layout multi-painel: **sidebar** (explorers) + **editor area** (abas) + **status bar** + **output panel**.
- **File explorer** funcional: navegar árvore, abrir/criar/renomear/excluir arquivos.
- **Editor com abas**: abrir vários arquivos, dirty-state, salvar.
- **Terminal integrado** (painel inferior): `xterm` + `flutter_pty` — ver [[ide/terminal]].
- Definir **state management** (ver [[ide/stack]]) e **event bus**.
- Entrega: editor de texto "burro" que abre projetos locais.
- **Status (2026-06-26):** ✅ **shell multi-painel** (`multi_split_view`, splitter horizontal sidebar|editor + vertical editor|output) + **welcome** + **Open Folder** (`file_picker`) + **file explorer** (árvore lazy, ícones por extensão) + **package explorer** estilo Eclipse (source folders, pacotes achatados, classes, libraries do pom.xml, JRE, WebApp) + **editor com abas** (`re_editor`, highlight Java/JSON/XML, dirty-state eficiente, salvar via provider) + **status bar** + **title bar** custom (frameless, `window_manager`, `DragToMoveArea` + botões min/max/restore/close Windows-style) + **menu bar toggable** estilo Zed (Alt-sozinho via `HardwareKeyboard.addHandler`, `ShadMenubar`: File/View/Help). **Painel de output** presente e **inicia OCULTO** (`LayoutState.showOutput=false`). `flutter analyze` limpo; `flutter test --no-pub` passa. State management com **Riverpod** (`Notifier`/`NotifierProvider`) — [[adr-0003-riverpod]]. Ver [[ide/stack]].
- ⏳ **Pendente (sub-fase):** **terminal integrado** real (`xterm` + `flutter_pty`) — o painel de output atual é **placeholder estático** ("Terminal / Output — em breve"); apenas a *visibilidade* do painel foi implementada (toggle Ctrl/Cmd+`, inicia oculto). As deps `xterm`/`flutter_pty` ainda **não** estão no `pubspec.yaml`. Adiar por exigir build de plugin (ConPTY + Developer Mode no Windows). Ver [[ide/terminal]].

## 🧠 Fase 2 — Núcleo LSP
- Cliente **JSON-RPC/LSP** em Dart sobre `json_rpc_2` (framing `Content-Length` sobre `dart:io` Process) — [[adr-0007-runtime-libs-ide]]. Alternativa `code_forge` refutada pelo spike ([[pesquisa/spike-code-forge]]).
- **Detecção/instalação** do JDT LS (ver [[ide/prereqs]]).
- `initialize`/`initialized`, `didOpen`/`didChange`/`didSave`/`didClose`.
- Consumir: **diagnostics**, **hover**, **completion**, **definition**.
- Entrega: o editor "entende" Java (sublinha erros, autocomplete, F12).

## 🔎 Fase 3 — Open types / symbols
- `workspace/symbol` (todos) e `documentSymbol` (arquivo corrente).
- **Command palette** (HuxCommand) com "Open Type" e "Open Symbol".
- Go-to-references, outline view.
- Entrega: navegação rápida pelo workspace.

## 🔨 Fase 4 — Build tools
- **Detecção de projeto** (pom.xml → Maven; build.gradle → Gradle).
- **Maven**: `mvn` via Process; parse de `pom.xml` (deps, goals); painel de tasks e output.
- **Gradle**: `gradlew` via Process; listar/run tasks; output.
- Entrega: build/run dentro da IDE.

## 📄 Fase 5 — XML/lemminx
- Integrar **lemminx** (LSP XML) — [[ide/lemminx]].
- Suporte a pom.xml, web.xml, persistence.xml, xhtml/jspx com completion/validação.
- Entrega: edição inteligente de XML do projeto.

## 🐞 Fase 6 — Debug (DAP)
- Carregar bundles **java-debug** no JDT LS e falar **DAP** sobre stdio.
- UI de debug: breakpoints, step (next/in/out/continue), **call stack**, **variables**, watch, console.
- `launch` (mainClass/args/vmArgs) e `attach` (host/port).
- Entrega: depurar apps Java.

## ✨ Fase 7 — Polimento
- **Project explorer** Java (source folders, packages, dependências).
- Run/debug configurations persistentes.
- Search in files, global find/replace.
- Settings (JDK, formatter, tema).

## Riscos / atenção
- **Performance** do editor com arquivos grandes + LSP (reativar `re_editor` com lazy).
- **Estabilidade** dos processos server (reconnect, crash recovery).
- DAP é a parte mais complexa — deixar por último.
- Depender de downloads de jdt.ls/lemminx → bom fluxo de first-run.

## Veja também
- [[ide/arquitetura]] · [[ide/stack]] · [[ide/prereqs]] · [[ide/visao-geral]]
