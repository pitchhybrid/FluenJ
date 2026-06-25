#!/usr/bin/env bash
# Helper para rodar comandos `flutter` neste ambiente.
#
# Por que existe: o Git Bash passa um PATH em formato MSYS (/c/...) que o
# processo nativo do Flutter não entende → "Unable to find git in your PATH".
# Este script roda o Flutter via cmd.exe com um PATH em formato Windows.
#
# Uso (a partir da raiz do projeto):
#   ./scripts/dev.sh "run -d windows"
#   ./scripts/dev.sh "build windows --debug"
#   ./scripts/dev.sh "analyze"
#   ./scripts/dev.sh "test --no-pub"          # test precisa do proxy OFF + --no-pub
#   ./scripts/dev.sh "pub get"
#
# Requisitos:
#   - Modo de Desenvolvedor habilitado no Windows (para build/run com plugins):
#       start ms-settings:developers
set -euo pipefail

WINPATH='C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32\OpenSSH;C:\Program Files\Git\mingw64\bin;C:\Program Files\Git\usr\bin;C:\Users\manoel.messias\Desktop\instaladores\flutter\bin'
CMD="${1:-analyze}"

# `flutter test`: o proxy NTLM quebra o websocket local do host de testes e
# também impede o pub get implícito. Desliga o proxy e usa --no-pub (deps já
# resolvidas). Veja docs/setup/ambiente-desenvolvimento.md.
if [[ "$CMD" == test* ]]; then
  unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
  export NO_PROXY="127.0.0.1,localhost,::1" no_proxy="$NO_PROXY"
fi

export PATH="$WINPATH"
exec /c/Windows/System32/cmd.exe //c "flutter $CMD"
