# ADR-0001 — Hux UI sobre um shell MaterialApp

**Status:** Aceito · **Data:** 2026-06-24

## Contexto
O projeto `myide` é desktop-only (Windows/Linux/macOS). Era preciso escolher uma biblioteca de UI moderna e "não-Material" para a aparência.

Pedidos conflitantes chegaram juntos:
1. "Remover o Material."
2. "Incluir uma UI library" — primeiro sugerido **shadcn** (`shadcn_ui`), depois trocado por **Hux UI** (`hux`).

## Decisão
Usar **Hux UI** (`hux`) mantendo o `MaterialApp` como **shell invisível**. Toda a UI visível é feita com componentes Hux.

## Motivos
- O **Hux é construído sobre o Material**: `HuxTheme.lightTheme/darkTheme` são objetos `ThemeData`, e os componentes dependem do `MaterialApp`/`ScaffoldMessenger`. Não há "HuxApp".
- Logo, "remover o Material totalmente" **é incompatível** com o Hux. A interpretação adotada: remover componentes/estilos Material **visíveis** (AppBar, FAB, `Icons.*`) e usar Hux — mantendo o MaterialApp apenas como infraestrutura.
- Preferido ao **shadcn**: o shadcn (`ShadApp`) dispensaria o Material, mas a escolha final do usuário foi o Hux pela estética/ecossistema.

## Consequências
- ✅ UI consistente e moderna via Hux.
- ✅ Ainda há "Material" no código (shell `MaterialApp` + `Scaffold`), mas só como infraestrutura.
- ⚠️ **Não remover o `MaterialApp`** — quebra os componentes Hux.
- ⚠️ Widgets visíveis devem vir do Hux; `Icons.*` do Material deve ser evitado (o Hux usa `lucide_icons_flutter`).
- 🔁 Se no futuro for indispensável **zero** Material, será preciso trocar a lib de UI (voltar ao shadcn ou similar) — reabrir este ADR.

## Alternativas consideradas
- **shadcn_ui** — `ShadApp` próprio, dispensa Material. Preterido pela escolha do Hux.
- **Cupertino puro** — não atende ao requisito de aparência moderna.

## Veja também
- [[hux-ui]] · [[componentes-hux]] · [[arquitetura]]
