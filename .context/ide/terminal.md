# Componente — Terminal integration

> Parte de [[ide/arquitetura]]. Painel inferior de terminal embutido (como VS Code / Eclipse).

## O que é
Um terminal **real** dentro da IDE: roda o shell nativo do usuário com **TTY**, suportando cores (256/truecolor), mouse, e programas interativos (`vim`, `less`, `top`, `htop`). Não é só "capturar stdout de um Process" — precisa de **PTY**.

## Stack (TerminalStudio)
| Pacote | Versão | Papel |
|---|---|---|
| `xterm` | 4.0.0 | **frontend** — emulador de terminal em Flutter (renderiza células, escape sequences, scrollback) |
| `flutter_pty` | 0.4.2 | **backend** — PTY nativo; cria processo de shell com file descriptors de pseudo-terminal |

> `xterm` é agnóstico de backend: pode usar PTY local, SSH, serial, etc. Aqui pareamos com `flutter_pty` para o terminal local.

## Como funciona
1. `flutter_pty` aloca um PTY e spawna o shell (detectado por OS — ver abaixo).
2. `output` do PTY (bytes) → `terminal.write(String.fromCharCodes(...))` do `xterm` → render na UI.
3. Teclas na UI → `terminal` → `pty.write(...)` (input do usuário).
4. `pty.resize(cols, rows)` ao redimensionar o painel (repassa ao TTY → apps refazem layout).
5. `pty.exitCode` → notifica "processo terminou".

## Shell padrão por plataforma
| OS | Shell | Detecção |
|---|---|---|
| Windows | **PowerShell** (`pwsh` ou `powershell`) / fallback `cmd` | `COMSPEC`, existência de `pwsh.exe` |
| Linux | `bash` (fallback `sh`, ou `$SHELL`) | `SHELL` |
| macOS | `zsh` (ou `$SHELL`) | `SHELL` |
- Permitir configurar shell/args nas Settings.

## Detalhes técnicos
- **TERM**: o xterm publica `xterm-256color`; passar como env do PTY para apps saberem as capacidades.
- **ConPTY (Windows)**: `flutter_pty` usa ConPTY no Windows 10+ (necessário para shells modernos). Em sistemas muito antigos, fallback `winpty`/limitações.
- **cwd**: iniciar o PTY no diretório do projeto aberto (`workingDirectory`).
- **Env**: herdar `Platform.environment` + adicionar `TERM`, `COLORTERM=truecolor`, e paths úteis (ex.: `JAVA_HOME`, `MAVEN_HOME`).
- **Encoding**: tratar saída como UTF-8; no Windows, forçar `chcp 65001` ou decodificar a página ativa.

## Recursos da UI
- **Múltiplos terminais** (abas), **split** (lado a lado), **kill**, **clear**, **copy/paste**.
- Dropdown para escolher perfil (PowerShell, cmd, Git Bash, WSL no Windows).
- Botão "+" e atalho `Ctrl+`` para abrir/fechar.
- Integração: botão "Run in Terminal" em tasks Maven/Gradle e em run configs (ver [[ide/maven]], [[ide/gradle]]) — em vez de só capturar stdout, roda no terminal real (interativo).

## Model (Dart)
```
TerminalSession {
  Pty pty;
  Terminal terminal;          // xterm
  String title;               // ex.: "pwsh — myide"
  int exitCode?;
}
TerminalService {
  create(profile, cwd) -> TerminalSession
  close(session)
  list sessions
}
```

## Riscos / atenção
- ConPTY depende de Windows 10 1809+ (praticamente universal hoje).
- Performance com muito output (ex.: `mvn` verboso) — o xterm lida bem, mas limitar scrollback.
- Multiplataforma: testar caret, atalhos de teclado (Ctrl+C, setas) por OS — key mapping no desktop Flutter.
- Segurança: o terminal executa comandos arbitrários do usuário (esperado numa IDE).

## Veja também
- [[ide/stack]] · [[ide/arquitetura]] · [[ide/roadmap]] · [[ide/maven]] · [[ide/gradle]]
