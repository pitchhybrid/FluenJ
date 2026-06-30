# Visão geral — FluenJ

**FluenJ** é uma **IDE desktop-only para Java**, em Flutter, para **Windows, Linux e macOS**. Não é mais um app de exemplo (contador) — o objetivo é um editor/IDE Java local estilo Eclipse/VS Code.

A interface usa **`shadcn_ui`** — `ShadApp` como root puro sobre `WidgetsApp`, **zero Material** (decisão formal [[adr-0004-shadcn-ui]]). O Hux UI (`hux`) foi abandonado; as notas [[hux-ui]] e [[componentes-hux]] são histórico obsoleto.

## Stack
Versões confirmadas em `pubspec.yaml`:

- **Flutter** 3.44.x (channel stable) · **Dart** SDK `^3.12.2`
- **UI:** `shadcn_ui` `^0.52.3` (ShadApp, ShadTheme, ShadButton/ShadBadge/ShadInput/ShadMenubar, LucideIcons via `lucide_icons_flutter` `^3.1.14+2`)
- **Estado:** `flutter_riverpod` `^3.3.2` (`Notifier`/`NotifierProvider`, `ProviderScope`)
- **Janela desktop:** `window_manager` `^0.5.1` (frameless, `TitleBarStyle.hidden`, title bar custom)
- **Editor de código:** `re_editor` `^0.9.0` + `re_highlight` `^0.0.3` (highlight Java/JSON/XML)
- **Layout:** `multi_split_view` `^3.6.2` (sidebar|editor, editor|output)
- **I/O e projeto:** `file_picker` `^8.0.7` (abrir pasta), `path` `^1.9.1`, `xml` `^7.0.1` (parse de `pom.xml`), `collection` `^1.19.1`
- **Lints:** `flutter_lints` `^6.0.0` com perfil strict (strict-casts/inference/raw-types + lints promovidos a erro — gate de CI)

## Plataformas
- ✅ `windows`, `linux`, `macos` (desktop)
- ❌ `android`, `ios`, `web` — **removidos** do projeto

## Publicação
- `publish_to: 'none'` — pacote privado (`name: fluenj`, `version: 1.0.0+1`).

## Objetivo / roadmap da IDE
Reunir num client LSP/DAP em Dart com UI em Flutter: edição com inteligência de linguagem (**JDT LS**), depuração (**DAP**), build (**Maven/Gradle**) e suporte a XML/XHTML (**lemminx**). Detalhes em [[ide/visao-geral]] e [[ide/roadmap]].

## Veja também
- [[arquitetura]] · [[adr-0004-shadcn-ui]] · [[ide/visao-geral]] · [[ide/arquitetura]]
