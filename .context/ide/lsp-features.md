# Catálogo de features do JDT LS

> Referência rica dos recursos do **Eclipse JDT Language Server** além do básico (completion/hover/diagnostics). Fonte: [README oficial](https://github.com/eclipse-jdtls/eclipse.jdt.ls). Complementa [[ide/lsp]].

> ⚠️ **Requisito**: o jdt.ls exige **Java 21+** para *rodar* (compila projetos de **1.8 a 24**). Ver [[ide/prereqs]].

## Visão por categoria (suportado oficialmente)

| Categoria | Recursos |
|---|---|
| **Linguagem** | Projetos Java **1.8 → 24**; standalone files; **annotation processing** (auto em Maven) |
| **Erros** | Erros de sintaxe/compilação **as-you-type**; **diagnostic tags** |
| **Edição** | Completion · Javadoc hover · **snippets** · formatting (on-type/selection/file) · organize imports |
| **Navegação** | Go-to definition/references · **outline** · **code navigation** · type search |
| **Estrutura** | **Type Hierarchy** · **Call Hierarchy** |
| **Visual** | **Semantic highlighting** · **semantic selection** (expandir seleção) · **code folding** |
| **Meta** | **Code lens** (references/implementations) · **inlay hints** |
| **Ações** | **Code actions**: quick fixes · **source actions** · **refactorings** |
| **Build** | **Maven** (via M2Eclipse) · **Gradle** (via Buildship, Android experimental) |
| **Fontes** | **Source resolution** automático de jars com coordenada Maven (e decompile) |
| **Extensibilidade** | 30+ **comandos custom `java.*`** (ver abaixo) |

## Code Actions (`textDocument/codeAction`)
Retorna ações contextuais. **Kinds** relevantes:
| Kind | Exemplos |
|---|---|
| `quickfix` | Criar método/variável/classe inexistente, importar, corrigir tipo, "Assign to local/field" |
| `refactor` | **Extract** variable/constant/method, **Inline**, Converter p/ lambda/enhanced-for, Rename |
| `source` | **Generate** constructors/getters/setters/toString/equals+hashCode/delegate, **Organize imports**, **Override/Implement methods**, Surround with try/multicatch, Remove unused |
| `note` | Anotações/dicas |

> Tudo via `textDocument/codeAction` → aplicar com `workspace/applyEdit`. UI: 💡 (lâmpada) no editor + painel "Source Action...".

## Refatorações (refactor kind)
- **Extract**: variable, constant, **method**, field
- **Inline** (variable/method)
- **Rename** (`textDocument/rename` + `prepareRename`) — renomeia em todo o workspace
- **Move** (extrair/mover para outra classe/pacote)
- Converter: Anonymous → Nested, for → forEach/lambda, if-else → switch
- **Change method signature** (via source action em alguns casos)

## Source Actions (geração de código) — comandos `java.*`
| Comando | Gera |
|---|---|
| `java.generate.constructors` | construtores |
| `java.generate.accessors` | getters/setters |
| `java.generate.hashCodeEquals` | `hashCode()` + `equals()` |
| `java.generate.toString` | `toString()` |
| `java.generate.delegateMethods` | métodos delegados |
| `java.overrideMethods` (source action) | override/implement |
| `java.organize.imports` | organizar imports |

## Type Hierarchy & Call Hierarchy (clássico do Eclipse)
- **Type Hierarchy**: `textDocument/prepareTypeHierarchy` → `typeHierarchy/supertypes` / `typeHierarchy/subtypes`. Mostra árvore de herança (interfaces, superclasses). **UI: view "Type Hierarchy"**.
- **Call Hierarchy**: `textDocument/prepareCallHierarchy` → `callHierarchy/incomingCalls` / `callHierarchy/outgoingCalls`. Quem chama / o que é chamado por um método.

## Code Lens & Inlay Hints
- **Code lens** (`textDocument/codeLens`): acima de métodos → "N references", "M implementations", e **Run | Debug** acima de `main()`/testes (com java-debug). Resolve com `codeLens/resolve`.
- **Inlay hints** (`textDocument/inlayHint`): nomes de parâmetros em chamadas, tipos inferidos em `var`.

## Semantic tokens & folding
- **Semantic tokens** (`textDocument/semanticTokens/full` + `/range`): colorização precisa (variável vs campo vs método vs tipo vs static) — melhor que o highlight por regex do `re_editor`.
- **Folding** (`textDocument/foldingRange`): colapsar imports/métodos/blocos/comentários.
- **Selection range** (`textDocument/selectionRange`): expandir seleção semanticamente.

## Outros LSP úteis
- `textDocument/documentHighlight` — destacar ocorrências do símbolo sob cursor
- `textDocument/signatureHelp` — assinatura de método ao digitar `(`
- `textDocument/implementation` / `declaration`
- `textDocument/linkedEditingRange` — editar ocorrências em sincronia
- `textDocument/documentLink` — links em comentários/Javadoc
- **File operations** (`workspace/willRenameFiles`/`didRenameFiles`): mover/renomear classe atualiza package/imports

## Comandos custom `java.*` (`workspace/executeCommand`)
O jdt.ls expõe **30+** comandos (via `JDTDelegateCommandHandler`). Principais:
- **Navegação/abertura**: `java.navigate.openType`, `java.decompile` (ver fonte de libs), `java.navigate.resolveTypeHierarchy`
- **Projeto**: `java.project.getAll`, `java.project.getClasspaths`, `java.project.import`, `java.project.updateSourceAttachment`, `java.resolveBuildFiles`, `java.search.projectStatus`
- **Run/Debug**: `java.resolveMainClass`, `java.getDebugSettings`
- **Edição**: `java.apply.workspaceEdit`, `java.edit.stringFormatting`, `java.source.addAction`, `java.completion.onSelect`
- **Refatoração**: `java.refactor.extract`, `java.refactor.inline`

> Lista completa/atual está nos fontes do jdt.ls (`org.eclipse.jdt.ls.core`); confirmar cada comando antes de depender.

## Conexão (além de stdio)
O jdt.ls aceita **stdio** (padrão), **socket** (`-DCLIENT_PORT=…`) e **named pipe**. Socket/pipe podem simplificar a coexistência **LSP + DAP** no mesmo processo. Ver [[ide/dap]].

## Sugestão de prioridade por fase (mapear no [[ide/roadmap]])
- **Fase 2 (core LSP)**: completion, hover, diagnostics, definition, references, formatting, organize imports.
- **Fase 3**: code actions (quickfix + source generate), rename, document/workspace symbol, outline, folding, documentHighlight, signatureHelp.
- **Fase 4+**: type/call hierarchy, code lens (Run/Debug pós-DAP), inlay hints, semantic tokens, extract/inline, file-ops rename.

## Veja também
- [[ide/lsp]] · [[ide/editor]] · [[ide/open-types-symbols]] · [[ide/prereqs]] · [[ide/roadmap]]
