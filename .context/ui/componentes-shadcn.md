# Componentes shadcn_ui — referência rápida

Componentes do **shadcn_ui** (`package:shadcn_ui/shadcn_ui.dart`, `^0.52.3`) **efetivamente usados** no FluenJ. Esta nota lista só o que está no código real (grep em `lib/`) — não é o catálogo completo da biblioteca. Para a decisão zero-Material, ver [[adr-0004-shadcn-ui]]; para a biblioteca, veja a nota shadcn-ui (a criar).

> Substitui a camada Hux — o histórico obsoleto fica em [[componentes-hux]] / [[hux-ui]].

## Root e tema

### `ShadApp` — root do app (zero `MaterialApp`)
Usado em `lib/app.dart`. Baseia-se em `WidgetsApp`; define `theme`/`darkTheme` via `ShadThemeData` e a `home`.
```dart
return ShadApp(
  title: 'FluenJ',
  debugShowCheckedModeBanner: false,
  theme: ShadThemeData(brightness: Brightness.light),
  darkTheme: ShadThemeData(brightness: Brightness.dark),
  home: const IdeShell(),
);
```

### `ShadTheme.of(context)` — acesso único a cores/texto/brightness
Padrão repetido em **todos** os widgets de UI: obtém `ShadThemeData` e lê `colorScheme` (background/foreground/border/primary/muted/mutedForeground) e `textTheme` (h1/h2/small/muted...). Substitui `Theme.of` do Material.
```dart
final theme = ShadTheme.of(context);
// theme.colorScheme.background / .border / .primary / .mutedForeground
// theme.textTheme.h1 / .muted / .small
// theme.brightness == Brightness.dark   // seleção de tema de highlight
```
Usado em: `lib/app.dart`, `lib/ui/ide_shell.dart`, `lib/ui/sidebar/sidebar.dart`, `lib/ui/explorer/file_explorer.dart`, `lib/ui/explorer/package_explorer.dart`, `lib/ui/widgets/status_bar.dart`, `lib/ui/widgets/title_bar.dart`, `lib/ui/widgets/menu_bar.dart`, `lib/ui/welcome/welcome_screen.dart`, `lib/ui/editor/editor_area.dart`, `lib/ui/editor/code_editor_view.dart`, `lib/ui/output/output_panel.dart`.

`ShadThemeData(brightness:)` — construtor do tema (light/dark), montado em `lib/app.dart`.

## Botões

### `ShadButton` — botão primário
Usado em `lib/ui/welcome/welcome_screen.dart` (botão "Abrir pasta"). Aceita `leading` (ícone) + `onPressed` + `child` (rótulo).
```dart
ShadButton(
  leading: const Icon(LucideIcons.folderOpen, size: 16),
  onPressed: () =>
      ref.read(workspaceProvider.notifier).openFolderPicker(),
  child: const Text('Abrir pasta'),
)
```

## Badges

### `ShadBadge` — etiqueta pequena
Usado em `lib/ui/welcome/welcome_screen.dart` (badge "FluenJ"). `child` é o conteúdo (geralmente `Text`).
```dart
const ShadBadge(child: Text('FluenJ'))
```

## Menus

### `ShadMenubar` — barra de menus estilo Zed
Container horizontal de menus suspensos. Usado em `lib/ui/widgets/menu_bar.dart` com bordas transparentes (`ShadBorder.all(color: const Color(0x00000000))`) e padding zero para visual "flat".
```dart
ShadMenubar(
  backgroundColor: theme.colorScheme.background,
  border: ShadBorder.all(color: const Color(0x00000000)),
  padding: EdgeInsets.zero,
  items: [ /* ShadMenubarItem... */ ],
)
```

### `ShadMenubarItem` — item de menu com submenu
Cada item (`File`, `View`, `Help`) recebe `items` (lista de `ShadContextMenuItem`) e um `child` (rótulo `Text`).
```dart
ShadMenubarItem(
  items: [
    ShadContextMenuItem(
      onPressed: () =>
          ref.read(workspaceProvider.notifier).openFolderPicker(),
      child: const Text('Open Folder…'),
    ),
    ShadContextMenuItem(
      onPressed: () => ref.read(editorProvider.notifier).saveActive(),
      child: const Text('Save'),
    ),
  ],
  child: const Text('File'),
)
```

### `ShadContextMenuItem` — item de menu de contexto
Ação individual (`onPressed: VoidCallback` + `child: Widget`). É o nó-folha dos submenus da `ShadMenubar`. Exemplos acima (Open Folder…, Save, toggle Sidebar/Output/MenuBar, About).

## Ícones — `LucideIcons` (embutido no shadcn_ui)
Não é um widget shadcn, mas vem do pacote `shadcn_ui` (via `lucide_icons_flutter`). É o conjunto de ícones padrão em todo o projeto (sem `Icons.*` do Material).
```dart
const Icon(LucideIcons.folderOpen, size: 16)
Icon(LucideIcons.terminal)
node.isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight
```
Usado extensivamente em: `welcome_screen.dart`, `title_bar.dart`, `status_bar.dart`, `sidebar.dart`, `file_explorer.dart`, `package_explorer.dart`, `editor_area.dart`.

## Auxiliares de tema/borda

### `ShadBorder.all(...)` — borda uniforme
Usado em `lib/ui/widgets/menu_bar.dart` para anular a borda padrão da `ShadMenubar` (transparente `Color(0x00000000)`).

## Componentes NÃO usados (não inventar)

Os seguintes **não** aparecem em `lib/` atualmente (podem entrar em fases futuras):
- `ShadInput` / `ShadTextarea` — ainda sem campos de texto na UI.
- `ShadCard` — sem cartões.
- `ShadDialog` / `showShadDialog` — sem diálogos.
- `ShadPopover` / `ShadTooltip` — sem popovers/tooltips.
- `ShadSelect` / `ShadSwitch` / `ShadTabs` / `ShadCheckbox` — sem selects/switches/tabs/checkbox shadcn (a sidebar tem _tabs próprios `_ModeTab`, não `ShadTabs`).
- **`ShadToaster`** — **não está integrado.** O padão de notificação (toasts) está **ausente** no código atual; quando surgir, deve substituir qualquer `SnackBar` Material (proibido pelo ADR-0004).

## Padrões derivados

- **Fonte única de estilo:** todo widget lê `ShadTheme.of(context)` no início do `build` — nada de `Theme.of`/`Colors.*`.
- **Container/Column no lugar de Scaffold:** a UI é montada com `Column`/`Container`/`Expanded`/`MultiSplitView`, sem `Scaffold` Material.
- **GestureDetector no lugar de InkWell:** taps e cliques usam `GestureDetector` (ver `status_bar.dart`, explorers).
- **Notificação por enquanto via estado,** não por toast: feedback de "salvo/sujo" é refletido no título da aba (`'• '` prefix) e na status bar — não há `ShadToaster` montado.
- **Decisão formal:** ver [[adr-0004-shadcn-ui]] (suprime [[adr-0001-hux-sobre-material]]).

## Veja também
- [[adr-0004-shadcn-ui]] · [[componentes-hux]] (histórico obsoleto) · [[hux-ui]]
- Doc externa: https://mariuti.com/flutter-shadcn-ui/
