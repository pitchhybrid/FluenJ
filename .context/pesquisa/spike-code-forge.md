# Spike — code_forge (validação de viabilidade)

> Data: 2026-06-26. Spike para decidir entre **code_forge** (editor rust-backed + LSP embutido) vs **re_editor + LSP manual**. Origem: [[pesquisa/flutter-estado-da-arte-2026]] (open question #1 — faltava validação independente).

## Objetivo
Validar se `code_forge` 10.6.0 (que promete **LSP embutido** + rope + IA, dispensando construir um cliente LSP manual na Fase 2) é viável para o FluenJ.

## API explorada (confirmada na fonte do pacote)
- `await RustLib.init()` no `main` — inicializa o backend rust (`flutter_rust_bridge` 2.x).
- `LspConfig` é **`sealed`**; subclasses concretas:
  - `LspStdioConfig.start({required executable, required workspacePath, required languageId, List<String>? args, ...})` — LSP via **stdio** (p/ JDT LS, lemminx).
  - `LspSocketConfig({...serverUrl...})` — LSP via **WebSocket**.
- `CodeForgeController(lspConfig:)` — implementa `DeltaTextInputClient`; faz a ponte editor↔LSP (documentSync, completion, diagnostics, hover, code actions). É exatamente o "LSP automático" prometido.
- Widget `CodeForge(undoController:, language:, editorTheme:, controller:, filePath:, tabSize:, ...)` — o editor (usa `re_highlight` para syntax, igual ao `re_editor`).

Para Java/JDT LS: `LspStdioConfig.start(executable: 'jdtls'|'java', languageId: 'java', workspacePath: <projeto>, args: [...launcher...])`.

## Resultado
- ✅ **Integra e compila no nível Dart** — `flutter analyze` limpo com o spike incluído (API correta, exports acessíveis).
- ❌ **Falha no build Windows** — `code_forge` **não vem pré-compilado**: o build aciona o **cargokit** para compilar o backend rust, que falha:
  - `error: failed to get flutter_rust_bridge as a dependency of package code_forge (.../rust)` — o `cargo` não baixa a crate (rede/**proxy NTLM**).
  - `Get-Item C:\Users\...\AppData` não encontrado em `cargokit/cmake/resolve_symlinks.ps1` — bug de path/symlink neste ambiente.
  - `error MSB8066` — build customizado do cargokit encerrado com código -1.

## Conclusão
**code_forge NÃO é viável no estado atual do ambiente FluenJ.** Adotá-lo exigiria:
1. **Rust toolchain** (cargo/rustc) no pipeline de build — hoje o projeto é Dart puro.
2. Resolver o **proxy NTLM** (`127.0.0.1:3128`) para o `cargo` baixar crates do `crates.io`.
3. Contornar o bug de path do cargokit.

Mesmo resolvido, traria **custo operacional permanente** (build rust em cada CI/release) — pesado para uma IDE desktop que já funciona em Dart puro.

**Recomendação: manter `re_editor` e construir o LSP manual sobre `json_rpc_2`** ([[adr-0007-runtime-libs-ide]]). code_forge fica como **`watch`** — reavaliar se a distribuição passar a incluir binários pré-compilados (sem cargokit) ou em ambiente com rust toolchain + rede sem proxy.

## Artefatos
- O código experimental do spike foi **removido** do repo (era temporário); a API acima é o registro durável.
- A dep `code_forge` foi **retirada do `pubspec.yaml`** — o cargokit roda em qualquer build que inclua o plugin, então mantê-la quebraria o build/run do app principal.

## Veja também
[[pesquisa/flutter-estado-da-arte-2026]] · [[ide/stack]] · [[ide/lsp]] · [[ide/roadmap]]
