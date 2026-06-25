# Comandos Flutter — myide

> Lembre do [[ambiente-desenvolvimento]]: neste shell, todo comando `flutter` precisa do **wrapper de PATH**, e o `flutter test` precisa do **proxy desabilitado**.

## Dependências
```bash
flutter pub get          # instalar/atualizar deps (rodar após mexer no pubspec.yaml)
flutter pub add hux      # adicionar pacote
```

## Rodar
```bash
flutter run -d windows   # desktop Windows (ou -d linux / -d macos)
```

## Qualidade
```bash
flutter analyze                            # análise estática / lints
flutter test                               # todos os testes
flutter test test/widget_test.dart         # um arquivo
flutter test --plain-name "Contador"       # um teste por nome
```

## Build de release
```bash
flutter build windows      # (ou linux / macos)
```

## Exemplo completo (rodar o teste neste shell)
```bash
cd "C:/Users/manoel.messias/Desktop/Projetos/myide"
unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
export NO_PROXY="127.0.0.1,localhost,::1" no_proxy="$NO_PROXY"
WINPATH='C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32\OpenSSH;C:\Program Files\Git\mingw64\bin;C:\Program Files\Git\usr\bin;C:\Users\manoel.messias\Desktop\instaladores\flutter\bin'
PATH="$WINPATH" /c/Windows/System32/cmd.exe //c "flutter test --no-pub"
```

## Veja também
- [[ambiente-desenvolvimento]] · [[visao-geral]]
