# FluenJ IDE — stack de pacotes Dart/Flutter

Pacotes do `pubspec.yaml` (versões e score verificados). Origem das decisões: ADRs e [[pesquisa/flutter-estado-da-arte-2026]].

## Em uso (pubspec.yaml)

### UI / base
| Pacote | Versão | Uso |
|---|---|---|
| `shadcn_ui` | ^0.52.3 | **UI** — `ShadApp` puro (zero Material) — [[adr-0004-shadcn-ui]] |
| `flutter_riverpod` | ^3.3.2 | **estado** — `Notifier`/`NotifierProvider` — [[adr-0003-riverpod]] |
| `window_manager` | ^0.5.1 | janela **frameless** (title bar custom) |
| _(editor de código)_ | — | **editor próprio** do zero (`CustomPaint` + `TextPainter`) — [[adr-0008-editor-proprio]] |
| `re_highlight` | ^0.0.3 | syntax highlight (parser, java/json/xml) — **mantido**, não é editor |
| `multi_split_view` | ^3.6.2 | layout multi-painel |
| `file_picker` | ^8.0.7 | diálogos (Open Folder) |
| `lucide_icons_flutter` | ^3.1.14+2 | ícones (em vez de Material `Icons.*`) |
| `xml` | ^7.0.1 | ler/escrever `pom.xml` e XML |
| `path` / `collection` | — | utilitários |

### Dev (testes / lints)
| Pacote | Versão | Uso |
|---|---|---|
| `very_good_analysis` | ^10.3.0 | **lints** (preset VGV rigoroso, gate de CI) — [[adr-0005-tooling-testes-2026]] (substituiu `flutter_lints`) |
| `alchemist` | ^0.14.0 | **golden tests** sem flakiness de fonte/render (contorna o proxy NTLM no CI) |
| `mocktail` | ^1.0.5 | mocks sem codegen |
| `integration_test` | (sdk) | testes E2E |
| `flutter_test` | (sdk) | testes de widget |

## Planejados (Fase 2+ — ainda NÃO no pubspec)
| Pacote | Versão alvo | Uso | Quando |
|---|---|---|---|
| `json_rpc_2` | ^4.1.0 | **JSON-RPC 2.0** — base do LSP/DAP | Fase 2 (LSP) — [[adr-0007-runtime-libs-ide]] |
| `xterm` | ^4.0.0 | emulador de terminal | Fase 1.5 (terminal) |
| `flutter_pty` | ^0.4.2 | PTY nativo (ConPTY) | Fase 1.5 (terminal) |
| `desktop_multi_window` | — | multi-window (janelas separadas) | Fase 7+ |
| `hotkey_manager` | — | atalhos globais Win/Linux/macOS | quando necessário |

> Transporte LSP (framing `Content-Length` + stdio) sobre `json_rpc_2`. Tipos LSP podem reusar `lsp_server` (server-side, mas expõe os models gerados da spec).

## Avaliados e rejeitados
- **`code_forge` 10.6.0** — editor rust-backed com LSP embutido. **Refutado pelo spike** ([[pesquisa/spike-code-forge]]): exige build rust via cargokit (inviável no ambiente: proxy NTLM + bug de path). Fica como `watch`. Manter `re_editor`.
- **`riverpod_generator` 4.x** — codegen Riverpod. **Incompatível** com `flutter_riverpod` 3.3.2 (cobre só até riverpod 3.0.3). Adiado — [[adr-0006-riverpod-codegen]].

## Veja também
[[ide/arquitetura]] · [[ide/editor]] · [[ide/lsp]] · [[ide/roadmap]] · [[adr-0004-shadcn-ui]] · [[adr-0005-tooling-testes-2026]] · [[adr-0007-runtime-libs-ide]]
