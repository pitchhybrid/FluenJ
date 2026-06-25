# ADR-0003 — State management com Riverpod

**Status:** Aceito · **Data:** 2026-06-25

## Contexto
A IDE tem muito estado: projetos abertos, abas de editor (múltiplas, com dirty/ctrl), árvore de arquivos, sessões de terminal, eventos de linguagem (futuro LSP/DAP) e builds. Precisávamos de um state-management robusto antes da Fase 1 (ver [[ide-stack]]).

## Decisão
Adotar **Riverpod** (`flutter_riverpod`) como camada de estado da IDE.

## Motivos
- **Async first**: LSP/DAP/processos são todos assíncronos — Riverpod (`AsyncValue`, `FutureProvider`, `StreamProvider`) modela isso nativamente.
- **Segurança em tempo de compilação**: providers tipados, sem `BuildContext` obrigatório (testável sem widget tree).
- **Escalável** para estado global complexo e de longa duração (sessões de IDE), melhor que `setState`/`InheritedWidget`.
- **Sem codegen no início**: usar providers clássicos (`NotifierProvider`/`StateNotifierProvider`) para reduzir dependências de build_runner; migrar para `riverpod_generator` se pesar.

## Consequências
- `ProviderScope` no root do app (`app.dart`).
- Estado organizado em `lib/core/state/` (workspace, editor tabs, file tree, terminal).
- Serviços (`FileSystemService`, futuro `LanguageServiceManager`) expostos como providers.
- Eventos (diagnostics, builds) via streams/providers, não por event-bus próprio.

## Alternativas consideradas
- **Bloc**: robusto, mas mais verboso para o volume de estado fino de uma IDE.
- **GetX/MobX**: menos alinhados ao ecossistema atual do Flutter.

## Veja também
- [[ide-stack]] · [[ide-arquitetura]] · [[ide-roadmap]] · [[adr-0001-hux-sobre-material]]
