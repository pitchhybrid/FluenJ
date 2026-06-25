# Arquitetura — myide

A arquitetura é simples: um **shell `MaterialApp`** (infraestrutura invisível) + componentes **Hux UI** para tudo que é visível. Detalhes em [[hux-ui]].

## Fluxo do app
```
main() → runApp(MyApp())
  MyApp (StatelessWidget) → MaterialApp(shell)
    theme: HuxTheme.lightTheme
    darkTheme: HuxTheme.darkTheme
    home: HomePage()
      HomePage (StatefulWidget, _counter)
        Scaffold
          └ body → Center → Column de componentes Hux:
               HuxBadge, HuxCard(título + HuxButton×2), HuxInput
```

## Arquivos principais
| Arquivo | Papel |
|---|---|
| `lib/main.dart` | `MyApp` (shell `MaterialApp` + `HuxTheme`) e `HomePage` (exemplo com Hux) |
| `test/widget_test.dart` | valida o incremento do contador via `HuxButton` |
| `pubspec.yaml` | deps: `flutter` + `hux` (^1.2.1); sem `cupertino_icons` |
| `analysis_options.yaml` | ativa `package:flutter_lints/flutter.yaml` |
| `.metadata` | rastreia apenas windows/linux/macos |
| `windows/`, `linux/`, `macos/` | configs de plataforma |

## Princípios de código
1. **UI visível = Hux.** Use `HuxButton`, `HuxCard`, `HuxInput`, `HuxBadge`, `context.showHuxSnackbar(...)`, etc.
2. **Não remova o `MaterialApp`.** O Hux depende do `ThemeData` e do `ScaffoldMessenger` dele.
3. **Evite widgets Material visíveis** (`AppBar`, `FloatingActionButton`, `Icons.*`). Widgets de layout (`Scaffold`, `Column`, `Padding`, `Center`, `Text`) seguem normais.
4. **StatefulWidget local** para estado simples (como o contador). Ainda não há lib de estado/HTTP/roteamento — ao introduzir, registre em `pubspec.yaml` e rode `flutter pub get`.

## Evoluindo a estrutura
Quando o app crescer, considere separar em `lib/pages/`, `lib/widgets/`, `lib/theme/` e refletir aqui.

## Veja também
- [[hux-ui]] · [[componentes-hux]] · [[visao-geral]]
