# Componente — Open Types / Open Symbols

> Parte de [[ide/arquitetura]]. Fase 3. Inspirado no "Open Type" (Ctrl+Shift+T) do Eclipse / VS Code.

## O que são
- **Open Type** — busca rápida por **tipos** (classes/interfaces/enums) do workspace e dependências, pelo nome.
- **Open Symbol** — busca por **qualquer símbolo** (métodos, campos, tipos) no workspace.

## Implementação via LSP
- `workspace/symbol` (`{ query }`) → lista de `SymbolInformation`/`WorkspaceSymbol` com `location` (uri + range). É o motor de ambos.
- Diferença Open Type vs Open Symbol:
  - **Type**: filtrar resultado por `kind == Class | Interface | Enum` (e opção de só do projeto vs com libs).
  - **Symbol**: todos os kinds.
- `documentSymbol` → **outline** do arquivo aberto (árvore de membros).

> O jdt.ls precisa estar **indexado** (status "Indexing…" completo) para retornar símbolos do workspace todo.

## UI: command palette
- Reusar **`HuxCommand`** (command palette do Hux) + `HuxKBD` para atalhos.
- Atalhos: `Ctrl+Shift+T` (Open Type), `Ctrl+Shift+R`/`Ctrl+T` (Open Symbol), `Ctrl+P` (quick open arquivo).
- Comportamento: digitar → debounce → `workspace/symbol` → lista → Enter abre no `definition.location`.

## UX
- Mostrar ícone por kind (classe/interface/método/campo) e caminho relativo do arquivo.
- Ranking fuzzy por relevância (ex.: correspondência de prefixo/camelCase).
- Suporte recente: listar tipos mais usados no topo.

## Fluxo de abertura
1. Usuário digita "ArrayLis".
2. `workspace/symbol { query: "ArrayLis" }`.
3. Resultado → seleciona `java.util.ArrayList` (de lib) ou um tipo do projeto.
4. `workspaceSymbol/location` (resolve a location final) → abre editor na posição.
5. Se for classe de lib → o jdt.ls pode **decompilar** (`java.decompile`) ou abrir source anexada.

## Veja também
- [[ide/lsp]] · [[ide/editor]] · [[ide/arquitetura]]
