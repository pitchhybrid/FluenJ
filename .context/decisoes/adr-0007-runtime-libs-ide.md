# ADR-0007 — Runtime libs da IDE (LSP, terminal, multi-window, atalhos)

**Status:** ⚠️ Superado por [[adr-0008-editor-proprio]] · **Data:** 2026-06-26 · **Origem:** [[pesquisa/flutter-estado-da-arte-2026]] + [[pesquisa/spike-code-forge]]

## Contexto
As Fases 2+ do [[ide/roadmap]] precisam de: cliente LSP (Java/JDT LS), terminal integrado, multi-window e atalhos globais. A pesquisa apontou `code_forge` como atalho (LSP embutido), mas faltava validação independente.

## Decisão
Stack de runtime da IDE — **tudo Dart puro**, sem build de linguagens estrangeiras:

- **LSP:** construir o cliente **manualmente sobre `json_rpc_2`** (JSON-RPC 2.0 canônico), com framing `Content-Length` sobre stdio (`dart:io` Process), para falar com **JDT LS** e **lemminx**. (Fase 2.)
- **Terminal:** `xterm` + `flutter_pty` (par canônico; ConPTY no Windows). (Fase 1.5.)
- **Multi-window:** `desktop_multi_window` (maduro, usado pelo RustDesk) quando o FluenJ suportar janelas separadas. (Fase 7+.)
- **Atalhos globais (Win/Linux/macOS):** `hotkey_manager` (única cobrindo as 3 plataformas).
- **Editor:** **manter `re_editor`** (Dart puro, alta perf, já integrado).

## Motivos
- O **spike do `code_forge`** ([[pesquisa/spike-code-forge]]) **refutou** a alternativa de LSP embutido: `code_forge` exige compilar um **backend rust via cargokit**, que falha no ambiente FluenJ (proxy NTLM impede o `cargo` de baixar crates + bug de path no cargokit). Mesmo resolvido, adicionaria **custo de build rust permanente**.
- `json_rpc_2` é canônico e Dart puro — mais código (cliente LSP manual), mas **build limpo** e controle total do protocolo.
- `xterm`+`flutter_pty` e `desktop_multi_window` são as escolhas padrão da comunidade desktop Flutter 2026.

## Consequências
- A Fase 2 (LSP) exige **escrever o cliente LSP** (initialize/didOpen/didChange/diagnostics/completion/definition) — mais trabalho que usar `code_forge`, mas sem dependência de build estrangeira.
- Build do projeto permanece **Dart puro** (sem rust toolchain no CI).

## Alternativas consideradas
- **`code_forge`** (LSP embutido) — **rejeitado** pelo spike: build rust inviável. Fica como `watch` (reavaliar se a distribuição incluir binários pré-compilados).
- **APIs nativas de multi-window do Flutter 3.41/3.44** — experimentais, sem ETA; manter `window_manager`/`desktop_multi_window` por enquanto.

## Veja também
[[pesquisa/spike-code-forge]] · [[ide/lsp]] · [[ide/terminal]] · [[ide/stack]] · [[ide/roadmap]]
