# shadcn_ui no FluenJ — guia de uso

A UI do FluenJ é construída com **`shadcn_ui` (^0.52.3)** como biblioteca de componentes e theming. O root do app é **`ShadApp` puro, sem `MaterialApp`** — o `ShadApp` usa `WidgetsApp` por baixo, portanto **zero Material na UI**. Decisão formal registrada em [[adr-0004-shadcn-ui]] (que suprime o antigo [[componentes-hux]] baseado em Hux/Material).

Referência rápida de componentes (assinaturas e exemplos por componente): [[componentes-shadcn]]. Visão de camadas e shell da IDE: [[ide/arquitetura]].

## Setup (raiz do app)

Já configurado em `lib/app.dart`:

```dart
import 'package:flutter/widgets.dart';   // NÃO use package:flutter/material.dart
import 'package:shadcn_ui/shadcn_ui.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'FluenJ',
      debugShowCheckedModeBanner: false,
      theme: ShadThemeData(brightness: Brightness.light),
      darkTheme: ShadThemeData(brightness: Brightness.dark),
      home: const IdeShell(),
    );
  }
}
```

- `ShadApp` é o root (não há `MaterialApp`, nem `materialThemeBuilder`).
- Tema light/dark via `ShadThemeData(brightness: ...)`.
- `home` aponta para o shell da IDE (`IdeShell`).

## Tema — única fonte de cores e tipografia

Sempre obtenha cores e texto de `ShadTheme.of(context)`. **Nunca** use `Theme.of(context)` nem constantes `Colors.*`.

```dart
final theme = ShadTheme.of(context);

theme.colorScheme.background       // fundo de painéis/barra
theme.colorScheme.foreground
theme.colorScheme.primary          // destaques, ícones ativos, dirs/pacotes
theme.colorScheme.border           // bordas de splitter/painéis
theme.colorScheme.card             // fundo de sidebar/output
theme.colorScheme.muted            // fundo de tab/status inativo
theme.colorScheme.mutedForeground  // texto/ícones secundários

theme.textTheme.h1                 // título da welcome screen
theme.textTheme.small              // rótulos de status bar, abas, tiles
theme.textTheme.muted              // texto de placeholder ("Sem pasta", "Sem projeto")

theme.brightness                   // light/dark — usado p/ selecionar tema do editor (atom-one-dark/light)
```

Esses tokens são efetivamente usados em `lib/ui` (title_bar, status_bar, menu_bar, sidebar, explorers, editor_area, output_panel).

## Componentes principais

| Componente | Uso típico no FluenJ |
|---|---|
| `ShadButton` | Botão "Abrir pasta" (`welcome_screen.dart`), com `leading: Icon(LucideIcons.folderOpen)`. |
| `ShadBadge` | Badge "FluenJ" na welcome screen. |
| `ShadMenubar` / `ShadMenubarItem` / `ShadContextMenuItem` | Barra de menus estilo Zed (File/View/Help) em `menu_bar.dart`. |
| `ShadCard` | Card container (disponível; atualmente o shell usa `Container`/`Column`). |
| `ShadInput` | Campo de texto (disponível para futuros comandos/buscas). |

Ícones vêm de `lucide_icons_flutter` (`LucideIcons.*`), não do Material `Icons.*`.

### Notificações

Sem `ScaffoldMessenger`/`SnackBar`. Use **`ShadToaster`** (conforme ADR-0004). (Ainda não há uso ativo de toaster no shell atual.)

## Substituições Material → shadcn

| Material | shadcn / Flutter puro |
|---|---|
| `Scaffold` | `Column` / `Container` (+ `Expanded`) |
| `InkWell` | `GestureDetector` |
| `Divider` | `Container(height: 1, color: theme.colorScheme.border)` |
| `Theme.of(context)` | `ShadTheme.of(context)` |
| `Colors.transparent` | `Color(0x00000000)` |
| `Icons.*` | `LucideIcons.*` |
| `SnackBar` | `ShadToaster` |

Exemplo real de "Divider" e "transparent" (sidebar.dart):
```dart
Container(height: 1, color: theme.colorScheme.border)          // divisor
color: active ? theme.colorScheme.muted : const Color(0x00000000)  // fundo transparente
```

## Imports

Sempre `package:flutter/widgets.dart`, **nunca** `package:flutter/material.dart`. Se um widget de terceiro exigir ancestral `Material`, envolver pontualmente e avaliar caso a caso (ver [[adr-0004-shadcn-ui]], "Consequências").

## Documentação externa

- shadcn_ui (Flutter): https://mariuti.com/flutter-shadcn-ui/

## Veja também
[[adr-0004-shadcn-ui]] · [[componentes-shadcn]] · [[ide/arquitetura]] · [[componentes-hux]] (obsoleto)
