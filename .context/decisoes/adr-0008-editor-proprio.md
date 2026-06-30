# ADR-0008 — Editor de código próprio (do zero, CustomPaint-based)

**Status:** Aceito · **Data:** 2026-06-26 · **Suprime:** [[adr-0007-runtime-libs-ide]] (que dizia "manter re_editor")

## Contexto
O spike do `code_forge` ([[pesquisa/spike-code-forge]]) mostrou os riscos de pacotes de editor de terceiros: `code_forge` exige build rust (cargokit + proxy, inviável); `re_editor` é terceiro (upstream, limites de customização). Decisão do projeto: **não depender de pacotes de editor de terceiros** — construir o próprio.

## Decisão
Construir um **editor de código próprio do zero**, baseado em **`CustomPaint` + `TextPainter`** com handler de **input/IME/seleção/undo manuais** — controle total para alcançar parity com re_editor/code_forge (multi-cursor, folding, minimap, snippets, code actions).

- **Render:** `CustomPaint` próprio — `TextPainter` por linha, layout de linhas manual, scroll próprio (vertical/horizontal).
- **Input/IME/seleção/undo/redo:** implementados manualmente (`HardwareKeyboard`/`RawKeyboardListener` + `TextInputConnection` para IME; command stack para undo).
- **Highlight:** **manter `re_highlight`** (parser/port do highlight.js, **não** é editor) — converte a saída em `TextSpan`. Aceitável porque é parsing, não lógica de editor.
- **Remover:** `re_editor` e `code_forge` do `pubspec.yaml`.

## Motivos
- Independência total de upstream (`re_editor`) e de build estrangeira (`code_forge`/rust).
- `CustomPaint`-based é o caminho para parity completo (multi-cursor/folding/minimap são naturais no design próprio; não cabem sobre `EditableText`).

## Consequências
- **Trabalho de longo prazo** (semanas/meses para parity completo). Entrega incremental:
  1. **MVP:** texto + cursor + seleção + numeração de linhas + highlight + scroll + undo/redo + dirty/salvar.
  2. find/replace · 3. gutter de diagnostics (overlay LSP) · 4. folding · 5. snippets · 6. multi-cursor · 7. minimap · 8. code actions.
- `lib/core/state/editor.dart` muda: `EditorTab.controller` deixa de ser `CodeLineEditingController` (re_editor) e passa a ser um `CodeEditorController` próprio.
- Sem IME/undo "de graça" do Flutter — implementados manualmente (mais controle, mais código).

## Alternativas consideradas
- **`EditableText`-based** (Flutter core, não terceiro) — rejeitado: multi-cursor/minimap profundos não cabem; o destino é parity total.
- **`re_editor`** (manter) — rejeitado pela decisão de não depender de terceiros.
- **`code_forge`** — rejeitado pelo spike.

## Veja também
[[adr-0007-runtime-libs-ide]] (superada) · [[pesquisa/spike-code-forge]] · [[ide/stack]] · [[ide/roadmap]]
