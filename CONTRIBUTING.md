# Contribuindo com o FluenJ

Obrigado por querer contribuir com o FluenJ! 🎉 Este guia cobre o setup do ambiente,
os padrões do projeto e o fluxo de Pull Requests.

## Código de Conduta

Participar deste projeto exige aceitar o nosso [Código de Conduta](CODE_OF_CONDUCT.md).
Seja respeitoso e acolhedor.

## Ambiente de desenvolvimento

### Pré-requisitos
- **Flutter 3.44+** / **Dart 3.12+** (channel stable)
- **JDK 21+** (para os language servers, quando a Fase 2+ estiver implementada)
- **Windows:** ative o **Modo de Desenvolvedor** (`start ms-settings:developers`) — o build
  de plugins precisa de suporte a symlinks

### Clone e setup
```bash
git clone https://github.com/pitchhybrid/FluenJ.git
cd FluenJ
flutter pub get
flutter run -d windows   # ou linux / macos
```

### ⚠️ Peculiaridades deste ambiente (Windows + Git Bash)

Há três pegadinhas documentadas; se você usa **cmd/PowerShell**, pode ignorar a maior parte.

1. **PATH no Git Bash:** o processo nativo do Flutter não lê o PATH em formato MSYS.
   Use o helper: `./scripts/dev.sh "<comando flutter>"`.
   ```bash
   ./scripts/dev.sh "run -d windows"
   ./scripts/dev.sh "analyze"
   ./scripts/dev.sh "build windows"
   ```
2. **Proxy NTLM × `flutter test`:** o proxy quebra o WebSocket local do host de testes.
   Rode o teste com `--no-pub` e o proxy desligado (o `dev.sh` já faz isso):
   ```bash
   ./scripts/dev.sh "test --no-pub"
   ```
3. **Developer Mode:** necessário para build/run de desktop com plugins (symlinks).

## Padrões de código

- **Lints:** usamos o conjunto `flutter_lints`. Rode `flutter analyze` antes de abrir o PR —
  deve estar **sem issues**.
- **Estilo de UI:** o projeto usa **`shadcn_ui`** (`ShadApp` puro, **sem `MaterialApp`**).
  - Importe `package:flutter/widgets.dart` (não `material.dart`).
  - Use `ShadTheme.of(context)` para cores/texto (nunca `Theme.of`).
  - Prefira componentes shadcn (`ShadButton`, `ShadCard`, …). Decisão formal: ADR-0004 no vault.
- **State management:** [Riverpod](https://riverpod.dev). Estado em `lib/core/state/`.
- **Testes:** mantenha os testes passando. Adicione testes para novas lógicas em `lib/core/`.

## Commits e Pull Requests

- **Mensagens de commit:** use o formato _Conventional Commits_ quando possível
  (`feat:`, `fix:`, `docs:`, `refactor:`, …), no imperativo.
- **Um PR = um assunto.** Mantenha o escopo focado.
- **Descreva o "porquê"** no PR, não só o "o quê".
- **Assinatura GPG** é opcional (mas bem-vinda).
- Antes de enviar, confirme: `flutter analyze` limpo e `flutter test` passando.

### Fluxo
1. Abra uma issue descrevendo o que vai mudar (para features/fixes grandes).
2. Crie um branch: `git switch -c feat/minha-feature`.
3. Faça commits claros.
4. Abra o PR preenchendo o template e referenciando a issue.

## Estrutura do projeto

Veja o [`README.md`](README.md#-estrutura) e o vault em [`.context/`](.context/) para a
arquitetura, os ADRs (decisões) e o roadmap. Os ADRs são a fonte das decisões importantes
(por que shadcn, por que Riverpod, compatibilidade de JDK, etc.) — consulte antes de propor
mudanças arquiteturais.

## Precisa de ajuda?

Abra uma [Discussion](https://github.com/pitchhybrid/FluenJ/discussions) ou uma
[issue](https://github.com/pitchhybrid/FluenJ/issues) com a label `question`.

Obrigado por contribuir! 💙
