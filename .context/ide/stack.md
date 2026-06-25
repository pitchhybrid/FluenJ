# myide IDE — stack de pacotes Dart/Flutter

Pacotes confirmados no pub.dev (versões e score verificados).

## UI / base
| Pacote | Versão | Uso |
|---|---|---|
| `hux` | 1.2.1 ✅ (já) | componentes de UI (sobre MaterialApp shell) |
| `re_editor` | 0.9.0 | **editor de código** (alta perf, mantido — Reqable) |
| `flutter_directory_tree` | 1.0.0 | **tree view** desktop (virtualizado, multi-root) — explorers |

## Terminal
| Pacote | Versão | Uso |
|---|---|---|
| `xterm` | 4.0.0 | **emulador de terminal** (render na UI, 256/truecolor, mouse) |
| `flutter_pty` | 0.4.2 | **PTY nativo** — spawn de shell real com TTY (ConPTY no Windows) |

## Syntax highlighting
- `re_editor` traz highlight próprio; para mais linguagens, complementar com o pacote `highlight` (highlight.js) se necessário.

## Protocolo / transporte
| Pacote | Versão | Uso |
|---|---|---|
| `json_rpc_2` | 4.1.0 | **JSON-RPC 2.0** — base do LSP e do DAP |
| `lsp_server` | 0.4.0 | **tipos LSP em Dart** (referência/reuso dos models) |

> `lsp_server` é "server-side", mas expõe os tipos LSP gerados a partir da spec — útil como fonte de models para o nosso cliente. O transporte (framing `Content-Length` + stdio) implementamos sobre `json_rpc_2`.

## Parsing / dados
| Pacote | Uso |
|---|---|
| `xml` | ler/escrever `pom.xml` e outros XML |
| `dart:io` (built-in) | Process spawn, FileSystem, stdin/stdout |

## Processos externos (não-Dart, orquestrados)
Eclipse JDT LS, java-debug (bundles), lemminx, Maven, Gradle — ver [[ide-prereqs]].

## Decisões pendentes
- State management: sem lib ainda no app base. Para uma IDE (muito estado, abas, eventos), avaliar **Riverpod** ou **Bloc** ao entrar na Fase 1. Registrar em ADR quando decidir.
- Editor ↔ LSP binding: como o `re_editor` expõe completion/diagnostic overlays.

## Veja também
- [[ide-arquitetura]] · [[ide-editor]] · [[ide-lsp]] · [[ide-roadmap]] · [[adr-0001-hux-sobre-material]]
