# Arquitetura — FluenJ

O **FluenJ** é uma IDE **desktop-only** (Windows/Linux/macOS) em Flutter para Java. A arquitetura segue três decisões formais: UI **zero-Material** via `shadcn_ui` ([[adr-0004-shadcn-ui]]), estado reativo com **Riverpod** ([[adr-0003-riverpod]]) e **chrome de janela manual/frameless** (`window_manager` + `TitleBarStyle.hidden`).

## Fluxo do app

```
main() (lib/main.dart)
  ├─ WidgetsFlutterBinding.ensureInitialized()
  ├─ window_manager: janela frameless 1280x800 (min 900x600, titleBarStyle: hidden)
  │    └─ maximize() APÓS waitUntilReadyToShow (evita o "eco" 1280x800 no canto)
  └─ runApp(ProviderScope(child: MyApp()))
        └─ MyApp (StatelessWidget) — lib/app.dart
              └─ ShadApp (root, ZERO MaterialApp; usa WidgetsApp por baixo)
                    theme/darkTheme: ShadThemeData(brightness)
                    home: IdeShell() — lib/ui/ide_shell.dart
                          ├─ TitleBar            (32px, frameless: DragToMoveArea + botões min/max/close)
                          ├─ IdeMenuBar?         (30px, toggable por Alt — estilo Zed)
                          └─ body (envolto por _GlobalShortcuts + Focus/Actions):
                                if !workspace.isOpen → WelcomeScreen  (fallback)
                                else →
                                  Column[
                                    Expanded(MultiSplitView horizontal:  sidebar(size260) | direita )
                                                                          │
                                                                          └─ MultiSplitView vertical?  editor(flex) | OutputPanel(size160)
                                                                                      (só se layout.showOutput; senão só EditorArea)
                                    StatusBar (26px, projeto + arquivo ativo/dirty + toggles)
                                  ]
```

Painéis togglables via `layoutProvider` (`showSidebar`/`showOutput`/`showMenuBar`). Atalhos: **Ctrl/Cmd+B** (explorer), **Ctrl/Cmd+`** (terminal), **Alt** sozinho (menu bar). Quando o workspace abre/fecha, `ref.listen(workspaceProvider)` propaga para `fileTreeProvider` e `packageTreeProvider`.

## Camadas

- **`lib/app.dart` + `lib/main.dart`** — bootstrap: `ShadApp` root, `ProviderScope`, `window_manager`.
- **`lib/ui/`** — widgets de UI (sem lógica de domínio, só observam estado e despacham ações via `ref.read(.notifier)`):
  - `ide_shell.dart` (layout multi-painel), `welcome/welcome_screen.dart`, `sidebar/sidebar.dart`, `editor/editor_area.dart` + `editor/code_editor_view.dart` (`re_editor`/`re_highlight`), `explorer/file_explorer.dart` (árvore física, lazy) + `explorer/package_explorer.dart` (árvore lógica, Eclipse-style), `output/output_panel.dart` (placeholder do terminal — Fase 1.5), `widgets/title_bar.dart`, `widgets/menu_bar.dart` (Zed-style), `widgets/status_bar.dart`.
- **`lib/core/state/`** — Riverpod (`Notifier`/`NotifierProvider`): `workspace.dart`, `layout.dart`, `editor.dart`, `file_tree.dart`, `package_tree.dart` (+ `ExplorerMode`/`explorerModeProvider`).
- **`lib/core/services/`** — I/O puro injetado como `Provider<T>`: `file_system_service.dart` (listar/ler/gravar/criar/renomear/deletar, utf8 com fallback latin1), `project_structure_service.dart` (árvore lógica: source folders, pacotes achatados, libs do pom.xml, WebApp).
- **`lib/core/models/`** — `file_node.dart` (`FileNode` + `enum NodeKind`, modelo compartilhado entre as duas árvores).

## Arquivos principais

| Arquivo | Papel |
|---|---|
| `lib/main.dart` | `main()`: init do `window_manager` (frameless 1280x800, min 900x600), `maximize()` pós-ready, `runApp(ProviderScope(child: MyApp()))` |
| `lib/app.dart` | `MyApp` (StatelessWidget) → `ShadApp` (root, `theme`/`darkTheme: ShadThemeData`, `home: IdeShell`). **Sem `MaterialApp`** |
| `lib/ui/ide_shell.dart` | `IdeShell` (ConsumerWidget): layout `MultiSplitView` (sidebar \| editor/output) + TitleBar/MenuBar/StatusBar; `ref.listen(workspaceProvider)` sincroniza as árvores; `_GlobalShortcuts` captura Alt-sozinho |
| `lib/core/state/workspace.dart` | `workspaceProvider`: pasta aberta via `file_picker.getDirectoryPath` |
| `lib/core/state/layout.dart` | `layoutProvider`: `showSidebar`/`showOutput`(=false, terminal inicia oculto)/`showMenuBar` |
| `lib/core/state/editor.dart` | `editorProvider`: abas (abrir/ativar/fechar/salvar), dirty tracking eficiente (notifica só na transição limpo→sujo) |
| `lib/core/state/file_tree.dart` | `fileTreeProvider`: árvore física com **lazy load** por expansão; `linearizeVisible()` (DFS) |
| `lib/core/state/package_tree.dart` | `packageTreeProvider`: árvore lógica (montada inteira no `setRoot` via `ProjectStructureService`) + `ExplorerMode`/`explorerModeProvider` |
| `lib/core/services/file_system_service.dart` | `fileSystemProvider` (`FileSystemService`): I/O de FS com filtro de entradas ocultas (`.git`/`target`/`build`/...) |
| `lib/core/services/project_structure_service.dart` | `projectStructureProvider`: detecta build (Maven/Gradle/standalone), source/resource folders, WebApp, deps do pom.xml |
| `lib/core/models/file_node.dart` | `FileNode` + `enum NodeKind` — nó mutável (UI) compartilhado pelas árvores física e lógica |
| `lib/ui/editor/code_editor_view.dart` | `re_editor.CodeEditor` + `CodeHighlightTheme` (java/json/xml/plaintext; atom-one-dark/light por `ShadTheme.brightness`) |
| `lib/ui/widgets/title_bar.dart` | Title bar custom frameless (32px): `DragToMoveArea` + botões min/max/restore/close (close vermelho Windows-style) |
| `lib/ui/widgets/menu_bar.dart` | `IdeMenuBar` (ShadMenubar estilo Zed, toggable por Alt): File/View/Help |
| `lib/ui/output/output_panel.dart` | Placeholder do terminal (xterm+flutter_pty previstos na Fase 1.5) |

## Princípios de código

1. **UI = `shadcn_ui`, zero Material.** Root é `ShadApp` (sobre `WidgetsApp`). Imports usam `package:flutter/widgets.dart` (**nunca** `material.dart`). Tema via `ShadTheme.of(context).colorScheme`/`.textTheme`/`.brightness`. Sem `Scaffold`→`Column`/`Container`; sem `InkWell`→`GestureDetector`; sem `Theme.of`→`ShadTheme.of`; sem `Colors.*`. Ver [[adr-0004-shadcn-ui]].
2. **Estado via Riverpod.** Sintaxe moderna `Notifier`/`NotifierProvider` (sem `StateNotifier`); estados imutáveis com `copyWith`, notifier reatribui `state` para notificar. Providers centralizados em `lib/core/state/`. UI é `ConsumerWidget`/`ConsumerStatefulWidget` que só faz `ref.watch`/`ref.read(.notifier)`. Ver [[adr-0003-riverpod]].
3. **Notificações via `ShadToaster`.** Sem `ScaffoldMessenger`/`SnackBar` (não há `MaterialApp`). Use `ShadToaster` para toasts.
4. **Camada de estado/HTTP/FS já existe.** Riverpod para estado; `dart:io` para filesystem (envolto em `FileSystemService`); diálogos via `file_picker`. Serviços de I/O são `Provider<T>` sem estado, injetados via `ref.read`.
5. **Layout orientado a estado (não condicional na mão).** `layoutProvider` decide a composição `MultiSplitView` aninhada (horizontal sidebar\|editor, vertical editor\|output) vs. editor puro; painéis ocultos não são renderizados. Reatividade em cascata: `ref.listen(workspaceProvider)` sincroniza `fileTree`/`packageTree`.
6. **Chrome de janela manual.** Frameless (`TitleBarStyle.hidden`) + `TitleBar`/`IdeMenuBar`/`StatusBar` próprios (estilo VS Code/Zed). `maximize()` sempre após `waitUntilReadyToShow`.
7. **Perfil de análise estrito (gate de CI).** `analysis_options.yaml`: `strict-casts`/`strict-inference`/`strict-raw-types` + lints críticos promovidos a erro. Rode `flutter analyze` antes de considerar trabalho concluído.

## Observações

- **Nome do pacote:** `fluenj` (em `pubspec.yaml`); o termo "myide" aparece só em notas antigas.
- **Hux UI é histórico:** o projeto migrou de Hux → `shadcn_ui` (ADR-0004). As notas `[[hux-ui]]`/`[[componentes-hux]]` ficam como histórico/obsoleto.
- **Terminal não implementado:** `OutputPanel` é placeholder; `xterm`+`flutter_pty` são roadmap (Fase 1.5) — `layout.showOutput=false` por default.
- **Dirty tracking:** `closeTab` ainda não confirma descarte de alterações (TODO Fase 1.x).

## Veja também

[[adr-0004-shadcn-ui]] · [[adr-0003-riverpod]] · [[ide/arquitetura]] · [[ide/visao-geral]] · [[ide/stack]]
