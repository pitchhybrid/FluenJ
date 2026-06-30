# Hux UI — guia de uso

> **⚠️ OBSOLETO (historico).** Superado por [[adr-0004-shadcn-ui]] — a UI do FluenJ agora usa shadcn_ui. Esta nota fica apenas como registro da fase Hux.

O **Hux UI** (`package:hux/hux.dart`, v1.2.1) é uma camada de componentes **construída sobre o Material**. Não tem app root próprio (diferente do shadcn, que tem `ShadApp`). Ver [[adr-0001-hux-sobre-material]].

## Regra de ouro
> O `MaterialApp` é só **shell/infraestrutura**. **Nunca remova** — os componentes Hux dependem do `ThemeData` e do `ScaffoldMessenger` dele.

- O tema vem do Hux: `theme: HuxTheme.lightTheme`, `darkTheme: HuxTheme.darkTheme`.
- A UI **visível** deve ser Hux (`HuxButton`, `HuxCard`, `HuxInput`, `HuxBadge`, snackbar...).
- Evite widgets Material visíveis (`AppBar`, `FloatingActionButton`, `Icons.*`).
- Layout básico do Flutter continua OK: `Scaffold`, `Column`, `Row`, `Padding`, `Center`, `Text`, `Wrap`, `ConstrainedBox`.

## Setup (já pronto em `lib/main.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:hux/hux.dart';

MaterialApp(
  title: 'myide',
  theme: HuxTheme.lightTheme,
  darkTheme: HuxTheme.darkTheme,
  themeMode: ThemeMode.system,
  home: const HomePage(),
);
```

## Snackbar
O snackbar é uma extensão no `BuildContext` (precisa do `ScaffoldMessenger` do MaterialApp):
```dart
context.showHuxSnackbar(
  message: 'Operação concluída.',
  title: 'Pronto',
  variant: HuxSnackbarVariant.success,
);
```

## Enums principais
| Enum | Valores |
|---|---|
| `HuxButtonVariant` | primary, secondary, outline, ghost |
| `HuxButtonSize` | small, medium, large |
| `HuxBadgeVariant` | primary, secondary, success, outline, error, destructive |
| `HuxBadgeSize` | small, medium |
| `HuxSnackbarVariant` | info, success, warning, error |

## Referência rápida de componentes
→ [[componentes-hux]] (assinaturas + exemplos)

## Documentação externa
- Docs: https://docs.thehuxdesign.com/
- Live demo: https://ui.thehuxdesign.com/
- pub.dev: https://pub.dev/packages/hux
- GitHub: https://github.com/lofidesigner/hux

## Veja também
- [[componentes-hux]] · [[arquitetura]] · [[adr-0001-hux-sobre-material]]
