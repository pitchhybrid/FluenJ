# myide IDE — roadmap

Fases incrementais. Cada fase deixa o app utilizável antes da próxima começar.

## ✅ Fase 0 — Base (concluída)
App desktop Flutter + Hux UI sobre MaterialApp. Ver [[visao-geral]] e [[arquitetura]].

## ✅ Fase 1 — Shell da IDE (concluída)
- Layout multi-painel: **sidebar** (explorers) + **editor area** (abas) + **status bar** + **output panel**.
- **File explorer** funcional: navegar árvore, abrir/criar/renomear/excluir arquivos.
- **Editor com abas**: abrir vários arquivos, dirty-state, salvar.
- **Terminal integrado** (painel inferior): `xterm` + `flutter_pty` — ver [[ide-terminal]].
- Definir **state management** (ver [[ide-stack]]) e **event bus**.
- Entrega: editor de texto "burro" que abre projetos locais.
- **Status (2026-06-25):** ✅ shell multi-painel (`multi_split_view`) + welcome + **Open Folder** (`file_picker`) + **file explorer** (árvore lazy, ícones por extensão) + **editor com abas** (`re_editor`, highlight Java/JSON/XML, dirty-state, salvar via provider) + **status bar**. `flutter analyze` limpo; `flutter test --no-pub` passa. State management com **Riverpod** ([[adr-0003-riverpod]]).
- ⏳ **Pendente (sub-fase):** **terminal integrado** real (xterm + flutter_pty) — placeholder no painel de output; adiar por exigir build de plugin (ConPTY + Developer Mode no Windows). Ver [[ide-terminal]].

## 🧠 Fase 2 — Núcleo LSP
- Cliente **JSON-RPC/LSP** em Dart (framing `Content-Length` sobre `dart:io` Process).
- **Detecção/instalação** do JDT LS (ver [[ide-prereqs]]).
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
- Integrar **lemminx** (LSP XML) — [[ide-lemminx]].
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
- [[ide-arquitetura]] · [[ide-stack]] · [[ide-prereqs]] · [[ide-visao-geral]]
