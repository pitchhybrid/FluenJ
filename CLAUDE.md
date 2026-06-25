# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Visão geral

Aplicação **desktop-only** (`myide`) para Windows, Linux e macOS, em Flutter. A interface usa a biblioteca **Hux UI** (`hux`), construída sobre o Material.

- **Stack:** Flutter 3.44.x / Dart ^3.12.2 / `hux` ^1.2.1
- **Plataformas:** `windows`, `linux`, `macos` (android/ios/web foram removidos do projeto)
- **Publicação:** `publish_to: 'none'` (pacote privado)

## Comandos essenciais

```bash
flutter pub get                              # instalar deps (rodar após mexer no pubspec.yaml)
flutter run -d windows                       # rodar no Windows (ou -d linux / -d macos)
flutter analyze                              # análise estática / lints
flutter test                                 # todos os testes
flutter test test/widget_test.dart           # um arquivo
flutter test --plain-name "Contador"         # um teste por nome
flutter build windows                        # build de release por plataforma
```

⚠️ Veja **"Rodar o Flutter neste ambiente"** abaixo — no shell atual, `flutter` direto falha; é preciso o wrapper de PATH.

## UI: shadcn_ui (ShadApp puro, zero Material)

A UI usa **`shadcn_ui`** com **`ShadApp` como root** (`lib/app.dart`) — **sem `MaterialApp`**. O `ShadApp` usa `WidgetsApp` por baixo (zero Material na UI). Decisão formal: **ADR-0004** (no vault `.context/decisoes/`), que suprime o antigo ADR-0001 (Hux sobre MaterialApp).

Regras:
- **Root:** `ShadApp(theme/darkTheme: ShadThemeData(...), home: const IdeShell())`. Sem `materialThemeBuilder`.
- **Imports:** use `package:flutter/widgets.dart`, **não** `package:flutter/material.dart`. Evite `Scaffold`, `InkWell`, `Theme.of`, `AppBar`, `Icons.*`, `MaterialApp`, `Colors.*`.
- **Tema:** `ShadTheme.of(context).colorScheme` (background/foreground/primary/border/card/muted/...), `.textTheme` (h1/h2/small/muted/...), `.brightness`.
- **Componentes:** `ShadButton`, `ShadBadge`, `ShadCard`, `ShadInput`, etc. Notificações via **`ShadToaster`** (não `SnackBar`).
- Substituições comuns: `Scaffold`→`Column`/`Container`; `InkWell`→`GestureDetector`; `Divider`→`Container(height:1, color: border)`; `Theme.of(...)`→`ShadTheme.of(...)`; `Colors.transparent`→`Color(0x00000000)`.

Doc: https://mariuti.com/flutter-shadcn-ui/

## Estrutura

- `lib/main.dart` — ponto de entrada. `MyApp` (shell `MaterialApp` + `HuxTheme`) e `HomePage` (StatefulWidget de exemplo usando `HuxCard`, `HuxButton`, `HuxBadge`, `HuxInput`, snackbar).
- `test/widget_test.dart` — valida o incremento do contador via `HuxButton`.
- `windows/`, `linux/`, `macos/` — configs de plataforma. Não há mais `android/`, `ios/` ou `web/`.
- `analysis_options.yaml` — ativa `package:flutter_lints/flutter.yaml`.

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

- Lints ativos: conjunto `flutter_lints` (v6). Rode `flutter analyze` antes de considerar trabalho concluído.
- Ao adicionar a primeira dependência com estado/HTTP/roteamento, registre-a em `pubspec.yaml` e rode `flutter pub get`.
