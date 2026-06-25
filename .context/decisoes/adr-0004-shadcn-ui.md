# ADR-0004 — UI com shadcn_ui (ShadApp puro, zero Material)

**Status:** Aceito · **Data:** 2026-06-25
**Suprime:** [[adr-0001-hux-sobre-material]]

## Contexto
O ADR-0001 adotou **Hux UI sobre `MaterialApp`** — porque o Hux é Material-based e não tem app-root próprio. Mas o desejo original do projeto sempre foi "**sem Material**". Após avaliar alternativas, `shadcn_ui` tem **app-root próprio (`ShadApp`)** e boa documentação.

## Decisão
Migrar a UI de **Hux UI → `shadcn_ui`**, usando **`ShadApp` como root puro (sem `MaterialApp`)**. O `ShadApp` usa `WidgetsApp` por baixo → **zero Material na UI**.

- **Root:** `ShadApp(theme/darkTheme: ShadThemeData(...), home: IdeShell)`. Sem `materialThemeBuilder`.
- **Componentes:** `ShadButton`, `ShadBadge`, `ShadInput`, `ShadCard`, `ShadToaster`, etc.
- **Tema:** `ShadTheme.of(context).colorScheme` / `.textTheme` / `.brightness`.
- **Sem widgets Material:** `Scaffold`→`Column`/`Container`; `InkWell`→`GestureDetector`; `Divider`→`Container` com borda; `Theme.of`→`ShadTheme.of`. Imports usam `package:flutter/widgets.dart` (não `material.dart`).

## Motivos
- Atende **100% ao "sem Material"** (`ShadApp` + `WidgetsApp`).
- `shadcn_ui`: **boa documentação** (mariuti.com/flutter-shadcn-ui), app-root próprio, estética neutra cross-platform.
- `re_editor` e `multi_split_view` continuam (não são libs de UI) e funcionam sob `WidgetsApp`.

## Consequências
- **ADR-0001 superado** (Hux sobre MaterialApp).
- Sem `ScaffoldMessenger`: notificações via **`ShadToaster`** (não `SnackBar`).
- Sem `Theme.of(context)` — sempre `ShadTheme.of(context)`.
- Notas `.context/ui/hux-ui.md` e `componentes-hux.md` ficam como **histórico** (obsoletas).
- Se um widget de terceiro exigir ancestral `Material`, envolver pontualmente (ex.: o editor) — avaliar caso a caso.

## Alternativas consideradas
- **Hux** (mantido) — rejeitado: exigia `MaterialApp`.
- **fluent_ui** — rejeitado: visual Windows-only; a IDE é Windows/Linux/macOS.

## Veja também
[[adr-0001-hux-sobre-material]] (superado) · [[ide-stack]] · [[ide-arquitetura]] · [[adr-0003-riverpod]]
