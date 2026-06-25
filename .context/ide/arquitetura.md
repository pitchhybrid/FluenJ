# myide IDE — arquitetura

## Camadas

```
┌─────────────────────────────────────────────────────────┐
│  UI (Flutter + Hux UI)                                   │
│   explorers · editor(tabs) · open types/symbols          │
│   debug view · build panel · command palette · terminal  │
├─────────────────────────────────────────────────────────┤
│  Aplicação (Dart)                                        │
│   workspace/project model · file service · editor state  │
│   run/debug configurations · event bus                   │
├──────────────────┬───────────────┬───────────────────────┤
│  Language Svc    │  Build        │  Process/Transport     │
│  LSP client ─────┤  Maven        │  dart:io Process        │
│  DAP client ─────┤  Gradle       │  JSON-RPC over stdio    │
│  lemminx client ─┘               │  (json_rpc_2 + framing) │
└──────────────────┴───────────────┴───────────────────────┘
            │                │                  │
            ▼                ▼                  ▼
   processos externos:  JDT LS (jdt.ls) · lemminx · mvn · gradlew
```

## O JDT LS é o núcleo
**Um único processo (Eclipse JDT Language Server) entrega a maior parte da inteligência:**
- **LSP**: completion, hover, definition, references, rename, diagnostics, **document/workspace symbols** (open types/symbols), formatação.
- **DAP**: ao carregar os **bundles `java-debug`** (Microsoft), o mesmo processo passa a também falar **Debug Adapter Protocol** sobre stdio.

> ⚠️ `java-debug` **não é um DAP server standalone** — é um *bundle OSGi carregado dentro do jdt.ls*. Para depurar, lança-se o jdt.ls **com** os bundles java-debug e fala-se DAP pelo stdio dele. Ver [[ide-dap]].

Processos independentes:
- **shell (PTY)** — terminal integrado via `flutter_pty` (bash/pwsh/cmd/zsh). Ver [[ide-terminal]].
- **lemminx** — LSP próprio (XML/XHTML), processo à parte. Ver [[ide-lemminx]].
- **mvn / gradlew** — processos efêmeros (uma execução por build/run). Ver [[ide-maven]], [[ide-gradle]].

## Transporte LSP/DAP (JSON-RPC sobre stdio)
Formato das mensagens (base protocol do LSP):
```
Content-Length: <nbytes>\r\n
\r\n
<JSON-RPC 2.0 payload>
```
- Implementação em Dart: **`json_rpc_2`** para o payload + um *framing* manual que lê o header `Content-Length` de `process.stdout` e escreve `header+payload` em `process.stdin`.
- Servidor/cliente podem enviar **notificações** (sem resposta) e **requests** (com id).

## Fluxo típico de edição (LSP)
1. Spawn do jdt.ls com `-data <workspace>` (o workspace do Eclipse; distinto do projeto).
2. `initialize` → `initialized`.
3. `workspace/didChangeConfiguration` (JDK, formatter, etc.).
4. `textDocument/didOpen` ao abrir um arquivo; `didChange` ao editar; `didSave`/`didClose`.
5. Recursos consumidos: `completion`, `hover`, `definition`, `references`, `documentSymbol`, `workspace/symbol`, `rename`, e **diagnósticos** chegam como notificação `textDocument/publishDiagnostics`.
6. APIs custom do jdt.ls via `workspace/executeCommand` (ex.: `java.resolveMainClass`, `java.decompile`).

## Gestão de processos
- Um **LanguageServiceManager** owns os processos longos (jdt.ls, lemminx) e reconecta/reinicia conforme necessário.
- Saída de erro/log dos servers roteada para um painel de "language servers" (debug).
- Shutdown limpo: `shutdown` → `exit` (LSP) e `Process.kill` ao fechar o app.

## Estado e eventos
- **Event bus** interno publica: diagnóstico mudou, workspace indexado, build iniciou/terminou, evento de debug, etc. A UI assina para atualizar reativamente.
- Editor state (arquivos abertos, cursor, sujo/não) isolado da camada de linguagem.

## Veja também
- [[ide-lsp]] · [[ide-dap]] · [[ide-stack]] · [[ide-prereqs]] · [[arquitetura]]
