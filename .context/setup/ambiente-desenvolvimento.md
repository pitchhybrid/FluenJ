# Ambiente de desenvolvimento — myide

Máquina **Windows + Git Bash**. Há três pegadinhas importantes; as duas primeiras afetam **todo** comando `flutter` neste shell.

## 1. Wrapper de PATH (para qualquer comando `flutter`)

O Flutter (processo nativo) **não interpreta o PATH no formato MSYS** (`/c/...`) do bash — falta `where`, `git`, `PowerShell`, etc. Rode o Flutter via `cmd.exe` com um PATH em formato Windows:

```bash
WINPATH='C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32\OpenSSH;C:\Program Files\Git\mingw64\bin;C:\Program Files\Git\usr\bin;C:\Users\manoel.messias\Desktop\instaladores\flutter\bin'
PATH="$WINPATH" /c/Windows/System32/cmd.exe //c "flutter <comando>"
```

> O `flutter` está em `C:\Users\manoel.messias\Desktop\instaladores\flutter\bin`. O `git` vem do Git for Windows (`C:\Program Files\Git\...`).

**Atalho (recomendado):** o script `scripts/dev.sh` encapsula o wrapper de PATH (e desliga o proxy só para `test`). Ex.: `./scripts/dev.sh "run -d windows"`, `./scripts/dev.sh "build windows"`, `./scripts/dev.sh "test --no-pub"`, `./scripts/dev.sh "analyze"`.

## 2. Proxy NTLM quebra o `flutter test`

Existe um **proxy NTLM** ativo:

```
HTTP_PROXY  = http://127.0.0.1:3128
HTTPS_PROXY = http://127.0.0.1:3128
```

Ele **intercepta o WebSocket local** do host de testes → erro `WebSocketException ... HTTP status code: 500` ao carregar os testes.

⚠️ **Dilema**: o proxy é **necessário para internet** (`pub get`/pub.dev), mas **quebra o websocket local** do `flutter test`. Solução: rode o teste com **`flutter test --no-pub`** (pula a resolução de deps, que já estão feitas) **+ proxy off**:

```bash
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
export NO_PROXY="127.0.0.1,localhost,::1" no_proxy="$NO_PROXY"
# depois: PATH="$WINPATH" cmd.exe //c "flutter test --no-pub"
```

> `flutter analyze` e `flutter pub get` **não** são afetados pelo proxy (funcionam normalmente com o wrapper de PATH).

## 3. Modo de Desenvolvedor (builds desktop com plugins)

Build/run de desktop **exige** Developer Mode (confirmado: `flutter build windows` falha com *"Building with plugins requires symlink support"* sem ele). Habilite o **Modo de Desenvolvedor** no Windows:

```bash
start ms-settings:developers
```

## Confirmação de versões
- Flutter: `3.44.3` (stable) · Dart: `3.12.2` · DevTools: `2.57.0`

## Veja também
- [[comandos-flutter]] · [[visao-geral]]
