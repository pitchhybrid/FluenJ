# Visão geral — myide

**myide** é uma aplicação **desktop-only** em Flutter para **Windows, Linux e macOS**. A interface é construída com a biblioteca **Hux UI** (`hux`), que por baixo usa o Material.

## Stack
- **Flutter** 3.44.x (channel stable)
- **Dart** SDK `^3.12.2`
- **Hux UI** (`hux`) `^1.2.1` — [docs](https://docs.thehuxdesign.com/) · [pub.dev](https://pub.dev/packages/hux)
- **flutter_lints** v6 (análise estática)

## Plataformas
- ✅ `windows`, `linux`, `macos` (desktop)
- ❌ `android`, `ios`, `web` — **removidos** do projeto (diretórios excluídos e `.metadata` limpo)

## Publicação
- `publish_to: 'none'` — pacote privado, não deve ser publicado no pub.dev.

## Objetivo do projeto
Hoje é um app de exemplo (contador) usando componentes Hux. Evoluções futuras devem:
- Manter o padrão **Hux UI** para a interface visível.
- Manter o `MaterialApp` como shell (ver [[hux-ui]]).
- Atualizar a [[arquitetura]] e as [[decisoes]] sempre que o padrão mudar.

## Veja também
- [[arquitetura]] · [[ambiente-desenvolvimento]] · [[adr-0001-hux-sobre-material]]
