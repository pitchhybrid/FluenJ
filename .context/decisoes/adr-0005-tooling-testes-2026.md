# ADR-0005 — Stack de tooling & testes 2026

**Status:** Aceito · **Data:** 2026-06-26 · **Origem:** [[pesquisa/flutter-estado-da-arte-2026]]

## Contexto
A pesquisa de estado-da-arte (junho/2026) recomendou modernizar o tooling. Um ponto crítico do ambiente FluenJ: há um **proxy NTLM** (`127.0.0.1:3128`) que **quebra o `flutter test`** ao interceptar o WebSocket local do host de testes — e golden tests baseados em fonte/render são **flaky** no CI Windows por esse motivo.

## Decisão
Adotar a stack de tooling/testes 2026 (todas com score 160/160 no pub.dev):

- **`very_good_analysis` ^10.3.0** — substitui `flutter_lints` como preset de lints. **Gate de CI rigoroso** (perfil estrito).
- **`alchemist` ^0.14.0** — golden tests **sem flakiness de fonte/render** (resolve o problema do CI Windows + proxy).
- **`mocktail` ^1.0.5** — mocks **sem codegen** (mais simples que `mockito`+build_runner).
- **`integration_test`** (SDK) — testes E2E.

`analysis_options.yaml` usa `include: package:very_good_analysis/analysis_options.yaml` + `strict-casts`/`strict-inference`/`strict-raw-types`.

### Afrouxamentos pragmáticos (documentados no `analysis_options.yaml`)
Regras opinativas/barulhentas do VGA afrouxadas via `analyzer.errors: ...: ignore`, com justificativa em comentário:
- `public_member_api_docs` (doc completa em todo membro público é escopo separado).
- `lines_longer_than_80_chars` (80 chars apertado p/ paths/URLs de IDE desktop).
- `cascade_invocations`, `flutter_style_todos`, `sort_pub_dependencies`, `use_setters_to_change_properties` (estilo opinativo).

Regras de **valor** corrigidas no código (não afrouxadas): `discarded_futures` (`unawaited`/`await`), `avoid_catches_without_on_clauses` (`on Object catch`).

## Motivos
- `alchemist` é a resposta direta ao problema real do proxy NTLM nos testes.
- `very_good_analysis` é o preset mais adotado em projetos sérios de Flutter 2026.
- `mocktail` evita o custo de codegen do `mockito`.

## Consequências
- Gate de CI mais rigoroso; `dart fix --apply` normaliza estilo (imports `package:`, directives ordering).
- Lints de estilo podem ser reabilitados incrementalmente conforme o projeto amadurece.

## Alternativas consideradas
- **`flutter_lints`** (mantido) — rejeitado: menos rigoroso que o VGA.
- **`mockito`** — rejeitado: exige `build_runner` (codegen).

## Veja também
[[adr-0006-riverpod-codegen]] · [[pesquisa/flutter-estado-da-arte-2026]] · [[ide/stack]]
