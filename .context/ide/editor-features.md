# Catálogo de features — Editor (re_editor)

> Referência da API do **re_editor** (0.9.0). Fonte: [README reqable/re-editor](https://github.com/reqable/re-editor). Complementa [[ide-editor]].

> re_editor **não é baseado em `TextField`** — implementa layout/desenho/eventos próprios, otimizado para textos grandes. É "leve": **não tem análise semântica** — por isso os prompts/completion devem vir do **LSP** (jdt.ls/lemminx).

## Widget e controller
```dart
CodeEditor(
  controller: CodeLineEditingController.fromText('...'),
  style: CodeEditorStyle(...),
  indicatorBuilder: ...,
  chunkAnalyzer: DefaultCodeChunkAnalyzer(),
  scrollController: CodeScrollController(verticalScroller: ..., horizontalScroller: ...),
  findBuilder: ...,
  toolbarController: ...,
  shortcutsActivatorsBuilder: ...,
  readOnly: false,
)
```
- Controller: `CodeLineEditingController` (análogo ao `TextEditingController`, mas por linha).

## Syntax highlighting (re-highlight)
```dart
CodeEditorStyle(
  codeTheme: CodeHighlightTheme(
    languages: { 'java': CodeHighlightThemeMode(mode: langJava), 'json': ... },
    theme: atomOneLightTheme,
  ),
)
```
- Baseado em **re-highlight** (~100 linguagens + temas). Prover gramáticas de **Java, Groovy/Kotlin (Gradle DSL), XML/HTML**.
- Para destaque **semântico** (variável vs campo vs método vs tipo) — opção futura: sobrepor com `textDocument/semanticTokens` do jdt.ls ([[ide-lsp-features]]).

## Line numbers + folding (indicatorBuilder)
```dart
indicatorBuilder: (context, editingController, chunkController, notifier) => Row(children: [
  DefaultCodeLineNumber(controller: editingController, notifier: notifier),
  DefaultCodeChunkIndicator(width: 20, controller: chunkController, notifier: notifier),
])
```
- Folding: `DefaultCodeChunkAnalyzer` (detecta `{}`/`[]`); desligar com `NonCodeChunkAnalyzer`; custom via `CodeChunkAnalyzer.run(CodeLines)`.
- O gutter do `indicatorBuilder` é onde pintamos **breakpoints** e a **linha atual de execução** (DAP).

## ⭐ Autocomplete → aqui plugamos o LSP
```dart
CodeAutocomplete(
  viewBuilder: (context, notifier, onSelected) { /* popup custom (Hux) */ },
  promptsBuilder: DefaultCodeAutocompletePromptsBuilder(language: langJava), // ← substituir
  child: CodeEditor(),
)
```
- Implementar um **promptsBuilder customizado** que, na posição do cursor, chame `textDocument/completion` (jdt.ls) / lemminx → devolve itens → `viewBuilder` renderiza com **HuxDropdown**.
- `completionItem/resolve` para detalhes (documentação) sob demanda.

## Outros recursos nativos
| Recurso | Como |
|---|---|
| **Scroll bidirecional** | `CodeScrollController(vertical, horizontal)` |
| **Find/Replace** | lógica nativa; UI custom via `findBuilder` (`CodeFindPanelView`) |
| **Context menu** (desktop) | `toolbarController` (`SelectionToolbarController`) — use HuxContextMenu |
| **Atalhos** | built-in + `shortcutsActivatorsBuilder` (só desktop) |
| **Large files** | otimizado; prever modo read-only acima de um limiar |
| **Read-only** | `readOnly: true` |

## Atalhos já embutidos (desktop)
`Ctrl+A/C/V/Z`, `Ctrl+L` (sel. linha), `Ctrl+D` (del. linha), `Alt+↑↓` (mover linha), `Tab/Shift+Tab` (indent), `Ctrl+/` (comentar), `Shift+Ctrl+/` (comentar bloco), `Ctrl+T` (transpor), `Ctrl+F` (buscar), `Alt+Ctrl+F` (substituir), `Ctrl+S` (salvar).

## Integrações que construímos sobre o re_editor
| Fonte | Como entra no editor |
|---|---|
| LSP **diagnostics** (`publishDiagnostics`) | overlay de **squiggles** (widget por cima das linhas) |
| LSP **completion** | `CodeAutocomplete.promptsBuilder` → jdt.ls/lemminx |
| LSP **hover** | tooltip na posição do cursor |
| LSP **definition/references** | Ctrl/Cmd+Click; "Find usages" |
| LSP **documentSymbol** | outline view |
| LSP **codeAction** | 💡 (lâmpada) → menu Hux |
| LSP **semanticTokens** | sobrepor ao highlight do re-highlight |
| LSP **foldingRange** | alimentar `CodeChunkAnalyzer` custom |
| DAP **breakpoints** | gutter no `indicatorBuilder` |
| DAP **linha atual** (`stopped`) | destaque no `indicatorBuilder`/overlay |
| DAP **hover de variável** | `evaluate` no tooltip |

## Model sugerido (Dart)
```
EditorTab { path, controller: CodeLineEditingController, dirty, cursor, breakpoints: Set<int> }
```
- Manter o controller vivo por aba; reconectar ao LSP ao trocar de aba (`didOpen`/`didClose`).

## Veja também
- [[ide-editor]] · [[ide-lsp]] · [[ide-lsp-features]] · [[ide-dap]] · [[ide-stack]]
