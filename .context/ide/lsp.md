# Componente — LSP (Java via JDT LS)

> Parte de [[ide-arquitetura]]. Base da inteligência de linguagem.

## O que é
Cliente **LSP (Language Server Protocol)** em Dart que conversa com o **Eclipse JDT Language Server (jdt.ls)** por **stdin/stdout**.

## Transporte (dart + json_rpc_2)
- Spawn via `dart:io` `Process.start('java', [...args])`. Ver launch em [[ide-prereqs]].
- **Framing LSP**: cada mensagem = `Content-Length: N\r\n\r\n` + N bytes JSON.
  - Leitura: stream de `process.stdout` → buffer → ler header → ler N bytes → `jsonDecode` → dispatch.
  - Escrita: `jsonEncode(msg)` → bytes → `"Content-Length: ${bytes.length}\r\n\r\n"` + bytes → `process.stdin.add(...)`.
- Usar **`json_rpc_2`** (Peer) para o dispatch request/response/notification, **ou** um dispatcher manual leve (o framing é o ponto crítico).
- **Conexão**: o jdt.ls aceita **stdio** (padrão), **socket** (`-DCLIENT_PORT=…`) e **named pipe**. Socket/pipe podem simplificar a coexistência LSP + DAP. Ver [[ide-dap]].

## Lifecycle (obrigatório na ordem)
1. `initialize` (params: `rootUri`, capabilities do cliente, `workspaceFolders`)
2. `initialized` (notification)
3. `workspace/didChangeConfiguration` (JDK, java.* settings)
4. `workspace/didChangeWorkspaceFolders` (adicionar/remover projetos)
5. No encerramento: `shutdown` → `exit`.

## Document sync
- `textDocument/didOpen` (ao abrir), `didChange` (edição incremental ou full), `didSave`, `didClose`.
- O editor `re_editor` emite mudanças → repassamos ao LSP. Ver [[ide-editor]].

## Recursos consumidos (capacidades a declarar no `initialize`)
| Recurso LSP | Onde entra na UI |
|---|---|
| `textDocument/publishDiagnostics` | squiggles no editor, painel "Problems" |
| `textDocument/hover` | tooltip no cursor |
| `textDocument/completion` | popup de autocomplete |
| `textDocument/definition` | go-to-definition (F12) |
| `textDocument/references` | "Find usages" |
| `textDocument/documentSymbol` | outline do arquivo |
| `workspace/symbol` | **Open Symbol** (ver [[ide-open-types-symbols]]) |
| `textDocument/rename` | rename |
| `textDocument/formatting` / `rangeFormatting` | formatar código |

## Comandos custom do jdt.ls (via `workspace/executeCommand`)
- `java.resolveMainClass` — achar `main()` para run/debug.
- `java.decompile` — abrir fonte de classes de biblioteca.
- `java.overrideMethods`, `java.organize.imports`, etc.

## Detalhes práticos
- **workspace do Eclipse** (`-data`): diretório de índice por projeto; manter em `<runtime>/workspaces/<hash-do-projeto>`.
- **Settings Java**: passar `java.home`, `java.configuration.runtimes`, `java.import.gradle.enabled`, etc.
- **Indexação inicial**: o jdt.ls demora no primeiro open; mostrar "Indexing…" no status.

## Estado interno (Dart)
- `LspClient`: processo + transporte + map de requests pendentes (id → completer).
- Buffer de diagnostics por arquivo (debounce antes de repintar).

## Veja também
- [[ide-lsp-features]] (catálogo completo de features do jdt.ls) · [[ide-stack]] · [[ide-dap]] · [[ide-prereqs]] · [[ide-editor]]
