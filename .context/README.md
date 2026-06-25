# myide — Vault de documentação

Este vault (gerido pelo **VaultForge**) é a fonte de documentação do projeto **myide**. Ele complementa o `CLAUDE.md` do repositório com notas mais detalhadas e conectadas por links.

> Stack: Flutter 3.44 / Dart 3.12 / **Hux UI** (`hux`) · Desktop-only (Windows, Linux, macOS)

## Índice

### Projeto
- [[visao-geral]] — o que é o myide, stack, plataformas
- [[arquitetura]] — como o código se organiza (shell `MaterialApp` + componentes Hux)

### Setup
- [[ambiente-desenvolvimento]] — rodar o Flutter neste Windows (PATH, proxy, Developer Mode)
- [[comandos-flutter]] — comandos essenciais do CLI

### UI
- [[hux-ui]] — guia de uso do Hux UI e regras sobre o MaterialApp
- [[componentes-hux]] — referência rápida de componentes e enums do Hux

### Ambiente / ferramental
- [[mcps-disponiveis]] — MCPs disponíveis nesta sessão (dart-server, vaultforge, etc.)

### Decisões (ADRs)
- [[adr-0001-hux-sobre-material]] — por que Hux UI sobre um shell MaterialApp (e por que não shadcn)
- [[adr-0002-compatibilidade-jdk]] — compatibilidade de JDK segue o range do jdt.ls (1.8–24); a JDK 21 dos servers é interna

## Convenções do vault
- Notas em português, nomes em kebab-case.
- Use wikilinks `[[nome]]` para ligar notas.
- Atualize a nota correspondente (e este índice) sempre que a decisão/arquitetura mudar.
