# ADR-0006 — Manter Riverpod 3; codegen adiado

**Status:** Aceito · **Data:** 2026-06-26 · **Origem:** [[pesquisa/flutter-estado-da-arte-2026]]

## Contexto
A pesquisa recomendou adotar `riverpod_generator` (codegen idiomático, scoping estático seguro). O FluenJ usa **`flutter_riverpod ^3.3.2`** (que requer `riverpod 3.3.2`).

Tentativa de adoção revelou **incompatibilidade de versão**: `riverpod_annotation ^3.0.0` (e logo `riverpod_generator` 3.x) só cobre até **`riverpod 3.0.3`** — não há codegen compatível com `flutter_riverpod 3.3.2` ainda. O `pub get` falhou com _version solving failed_.

## Decisão
**Manter `flutter_riverpod ^3.3.2`** com providers escritos manualmente (`Notifier`/`NotifierProvider`). **Adiar o codegen** até que:
- `riverpod_annotation`/`riverpod_generator` tenham versão compatível com `riverpod 3.3.x`, **ou**
- o projeto migre para **Riverpod 4.x** (decisão separada, com migração de API).

## Motivos
- Forçar codegen exigiria **downgrade** do riverpod (regredir o projeto) ou migrar para 4.x (risco grande) — nenhum justifica uma conveniência de sintaxe.
- Codegen é _nice-to-have_, não essencial; os providers manuais funcionam bem.

## Consequências
- Providers escritos à mão. Reforçar o padrão: **não guardar estado mutável em campos do `Notifier`** — extrair para providers separados ou inicializar no `build()`.
- Quando o codegen for viável, novos providers podem adotá-lo incrementalmente (`@riverpod`), migrando os existentes aos poucos.

## Alternativas consideradas
- **Downgrade `flutter_riverpod` → `^3.0.3`** — rejeitado: regrediria o projeto.
- **Migrar para Riverpod 4.x** — rejeitado por agora: migração de API + `riverpod_generator` 4.x é trabalho maior, sem necessidade imediata.

## Veja também
[[adr-0003-riverpod]] · [[pesquisa/flutter-estado-da-arte-2026]] · [[ide/stack]]
