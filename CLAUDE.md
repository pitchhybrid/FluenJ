# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Visão geral

**FluenJ** é uma IDE **desktop-only** para Java (estilo Eclipse, inicialmente básica), em Flutter, para Windows, Linux e macOS. A UI é **`shadcn_ui`** com `ShadApp` como root (**zero Material**); o estado é gerido com **Riverpod**; a janela é **frameless** (`window_manager`).

- **Stack:** Flutter 3.44.x / Dart ^3.12.2 / `shadcn_ui` ^0.52.3 / `flutter_riverpod` ^3.3.2 / `window_manager` ^0.5.1 / `re_editor` ^0.9.0 / `multi_split_view` ^3.6.2 / `file_picker` ^8.0.7
- **Plataformas:** `windows`, `linux`, `macos` (android/ios/web foram removidos do projeto)
- **Publicação:** `publish_to: 'none'` (pacote privado, nome `fluenj`)
- **Editor:** **próprio, do zero** (`CustomPaint` + `TextPainter`, sem `re_editor`/`code_forge`) — `lib/ui/editor/custom/`. `re_highlight` (parser) mantido. Ver ADR-0008.

## Documentação estendida: vault `.context/`

Toda documentação, análise e levantamento de requisitos vivem no **vault** (gerido pelo VaultForge MCP) em `.context/`. O `CLAUDE.md` é o resumo operacional; o vault é a fonte detalhada.

- `.context/projeto/` — visão-geral e arquitetura (espelha e estende este arquivo)
- `.context/decisoes/` — ADRs (ADR-0004 shadcn_ui, ADR-0003 Riverpod, ADR-0002 JDK, ...)
- `.context/ide/` — spec da IDE (roadmap, LSP, DAP, build, lemminx, terminal)
- `.context/ui/` — guias de UI (`shadcn-ui.md`, `componentes-shadcn.md`; notas Hux são histórico)

Ao produzir análise/requisitos/decisões, **escreva no vault** via `mcp__vaultforge__*` (notas em português, kebab-case, wikilinks na forma `[[pasta/nota]]` — com o caminho da subpasta, ex. `[[ide/roadmap]]`, pois a forma achatada `[[ide-roadmap]]` não resolve).

## Comandos essenciais

```bash
flutter pub get                              # instalar deps (rodar após mexer no pubspec.yaml)
flutter run -d windows                       # rodar no Windows (ou -d linux / -d macos)
flutter analyze                              # análise estática / lints (perfil rigoroso — ver abaixo)
flutter test                                 # todos os testes
flutter test test/widget_test.dart           # um arquivo
flutter test --plain-name "boas-vindas"      # um teste por nome
flutter build windows                        # build de release por plataforma
```

⚠️ Veja **"Rodar o Flutter neste ambiente"** abaixo — no shell atual, `flutter` direto falha; é preciso o wrapper de PATH.

## UI: shadcn_ui (ShadApp puro, zero Material)

A UI usa **`shadcn_ui`** com **`ShadApp` como root** (`lib/app.dart`) — **sem `MaterialApp`**. O `ShadApp` usa `WidgetsApp` por baixo (zero Material na UI). Decisão formal: **ADR-0004** (no vault `.context/decisoes/`), que suprime o antigo ADR-0001 (Hux sobre MaterialApp).

Regras:
- **Root:** `ShadApp(theme/darkTheme: ShadThemeData(...), home: const IdeShell())`. Sem `materialThemeBuilder`.
- **Imports:** use `package:flutter/widgets.dart`, **não** `package:flutter/material.dart`. Evite `Scaffold`, `InkWell`, `Theme.of`, `AppBar`, `Icons.*`, `MaterialApp`, `Colors.*`.
- **Tema:** `ShadTheme.of(context).colorScheme` (background/foreground/primary/border/card/muted/...), `.textTheme` (h1/h2/small/muted/...), `.brightness`.
- **Componentes:** `ShadButton`, `ShadBadge`, `ShadCard`, `ShadInput`, `ShadMenubar`, etc. Notificações via **`ShadToaster`** (não `SnackBar`).
- Substituições comuns: `Scaffold`→`Column`/`Container`; `InkWell`→`GestureDetector`; `Divider`→`Container(height:1, color: border)`; `Theme.of(...)`→`ShadTheme.of(...)`; `Colors.transparent`→`Color(0x00000000)`; `Icons.*`→`LucideIcons.*` (`lucide_icons_flutter`).

Doc: https://mariuti.com/flutter-shadcn-ui/

## Estado: Riverpod

- Sintaxe moderna `Notifier`/`NotifierProvider` (sem `StateNotifier`). Estados imutáveis com `copyWith`; o notifier reatribui `state` para notificar.
- Providers centralizados em `lib/core/state/`: `workspaceProvider`, `layoutProvider`, `editorProvider`, `fileTreeProvider`, `packageTreeProvider`, `explorerModeProvider`.
- A UI é `ConsumerWidget`/`ConsumerStatefulWidget`: só faz `ref.watch(...)` e despacha ações via `ref.read(<provider>.notifier)`.
- Root envolvido por `ProviderScope` em `lib/main.dart`. Serviços de I/O puros são `Provider<T>` injetados via `ref.read`. Decisão: ADR-0003.

## Estrutura

```
lib/
├── main.dart              # entry: init window_manager (frameless 1280x800, min 900x600) + maximize() pós-ready + runApp(ProviderScope(MyApp))
├── app.dart               # MyApp → ShadApp (root, sem MaterialApp; theme/darkTheme: ShadThemeData; home: IdeShell)
├── core/
│   ├── models/            # file_node.dart (FileNode + enum NodeKind — nó compartilhado pelas árvores física e lógica)
│   ├── services/          # file_system_service.dart (I/O: listar/ler/gravar/criar/renomear/deletar; utf8 com fallback latin1), project_structure_service.dart (árvore lógica: source folders, pacotes achatados, libs do pom.xml, WebApp)
│   └── state/             # Riverpod: workspace, layout, editor, file_tree, package_tree
└── ui/
    ├── ide_shell.dart     # shell multi-painel (MultiSplitView: sidebar | editor/output) + TitleBar + IdeMenuBar + StatusBar; ref.listen(workspaceProvider) sincroniza as árvores
    ├── welcome/           # welcome_screen.dart (botão "Abrir pasta" via file_picker; fallback quando não há workspace)
    ├── sidebar/           # sidebar.dart
    ├── editor/            # editor_area.dart (abas, dirty-state, salvar) + code_editor_view.dart; custom/ (editor próprio CustomPaint do zero: code_editor_controller + code_editor_painter + code_editor + syntax_highlighter [re_highlight] — ADR-0008)
    ├── explorer/          # file_explorer.dart (árvore física, lazy load) + package_explorer.dart (árvore lógica, Eclipse-style)
    ├── output/            # output_panel.dart (placeholder do terminal — xterm + flutter_pty é roadmap, Fase 1.5)
    └── widgets/           # title_bar.dart (frameless: DragToMoveArea + min/max/close), menu_bar.dart (Zed-style, toggable por Alt), status_bar.dart
```

- `test/widget_test.dart` — valida a welcome screen (botão "Abrir pasta" + título "FluenJ — IDE para Java") sob `ProviderScope`.
- `windows/`, `linux/`, `macos/` — configs de plataforma. Não há `android/`, `ios/` ou `web/`.
- `analysis_options.yaml` — perfil rigoroso (ver "Análise estática").
- `.context/` — vault de documentação (ver "Documentação estendida").

## Análise estática

`analysis_options.yaml` usa o preset **`very_good_analysis`** (`^10.3.0`, substitui `flutter_lints`) + `strict-casts`/`strict-inference`/`strict-raw-types` (gate de CI). Regras opinativas/barulhentas (`public_member_api_docs`, `lines_longer_than_80_chars`, etc.) são afrouxadas com justificativa no arquivo. **Rode `flutter analyze` antes de considerar trabalho concluído** — deve estar limpo.

## Rodar o Flutter neste ambiente

O projeto está numa máquina Windows com Git Bash, mas o Flutter (processo nativo) não interpreta o PATH no formato MSYS (`/c/...`) do bash, e há um **proxy NTLM** (`HTTP_PROXY`/`HTTPS_PROXY = http://127.0.0.1:3128`) que **quebra o `flutter test`** (intercepta o WebSocket local do host de testes → `HTTP 500`).

### Wrapper de PATH (necessário para qualquer comando `flutter`)

Rode o Flutter via `cmd.exe` com um PATH em formato Windows contendo System32, PowerShell, Git e o flutter:

```bash
WINPATH='C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32\OpenSSH;C:\Program Files\Git\mingw64\bin;C:\Program Files\Git\usr\bin;C:\Users\manoel.messias\Desktop\instaladores\flutter\bin'
PATH="$WINPATH" /c/Windows/System32/cmd.exe //c "flutter analyze"
```

### Proxy — desabilite ao rodar `flutter test`

O proxy impede o host de testes de conectar em `127.0.0.1`. Desabilite-o só para o teste (o `flutter test` não precisa de internet):

```bash
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
export NO_PROXY="127.0.0.1,localhost,::1" no_proxy="$NO_PROXY"
# depois o comando de teste com o wrapper de PATH acima
```

### Build de plugins no Windows

Se aparecer *"Building with plugins requires symlink support"* durante um build desktop, habilite o **Modo de Desenvolvedor** no Windows (`start ms-settings:developers`).

## Convenções

- **UI:** `shadcn_ui` (`ShadApp`, zero Material) — ver seção "UI" acima. Ícones via `lucide_icons_flutter`, não `Icons.*`.
- **Estado:** Riverpod (`Notifier`/`NotifierProvider`) — ver seção "Estado" acima.
- **Lints:** `very_good_analysis` (preset rigoroso, ver "Análise estática"). `flutter analyze` limpo é obrigatório.
- **Testes:** `alchemist` (golden), `mocktail` (mocks), `integration_test` (E2E).
- **Documentação:** produzida e mantida no vault `.context/` via VaultForge (português, kebab-case, wikilinks `[[pasta/nota]]`).
- Ao adicionar uma dependência, registre-a em `pubspec.yaml` e rode `flutter pub get`.
