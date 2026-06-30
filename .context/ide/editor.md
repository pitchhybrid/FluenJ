# Componente — Editor de código

> Parte de [[ide/arquitetura]]. Fases 1–3.

## Widget base: `re_editor` (0.9.0)
Editor leve, performático, ativamente mantido (Reqable). Suporta:
- Syntax highlighting (com grammar/highlighter).
- Multi-buffer, bi-directional scroll, line numbers, code folding.
- Edição multi-linha (melhor que `TextField`).
- Builders para overlays (diagnostics, gutter de breakpoints).

Alternativas (não escolhidas): `code_text_field`/`code_field` (menos mantidos), `flutter_highlight` (só read-only).

## Abas (tabs)
- Usar **`HuxTabs`** (ou `HuxTabView`) para a área de abas — mantém a UI no Hux.
- Estado por aba: caminho, conteúdo, cursor, dirty (modificado), encoding.
- Fechar com confirm se dirty; "close others/close all".

## Integração com LSP ([[ide/lsp]])
- `re_editor.onChange` → `textDocument/didChange` (incremental se possível).
- Diagnostics: mapear `publishDiagnostics` → **squiggles** no editor (overlay).
- Completion: na posição do cursor, chamar `textDocument/completion` → popup (HuxDropdown/popover).
- Hover: tooltip com `textDocument/hover`.
- Go-to-definition: Ctrl/Cmd+Click → `definition`.
- Salvar (`Ctrl+S`) → `didSave` + flush no disco.

## Syntax highlighting Java
- `re_editor` usa um `CodeLine`/highlighter; fornecer gramática de Java (palavras-chave, strings, comentários, anotações, números).
- Gramáticas para XML/Gradle (Groovy/Kotlin) também — ou delegar o destaque de XML ao lemminx quando houver.

## Integração com DAP ([[ide/dap]])
- Gutter de **breakpoints** (toggle na margem esquerda).
- Linha atual de execução destacada quando `stopped`.
- Hover de variável → `evaluate`.

## Estado
```
EditorState {
  openTabs: List<Tab>,
  activeTab,
  dirtySet,
}
```
- Persistir "arquivos abertos recentes" entre sessões.

## Decisões
- Encoding padrão UTF-8; detectar BOM.
- Tamanho de arquivo: limiar para abrir em modo "read-only grande" (evitar travar o editor).

## Veja também
- [[ide/editor-features]] (API do re_editor + integrações LSP/DAP) · [[ide/lsp]] · [[ide/dap]] · [[ide/stack]] · [[ide/explorers]]
