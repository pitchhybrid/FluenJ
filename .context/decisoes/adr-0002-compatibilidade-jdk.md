# ADR-0002 — Compatibilidade de JDK segue o range do jdt.ls

**Status:** Aceito · **Data:** 2026-06-25

## Contexto
A IDE edita projetos Java de usuários diferentes, com versões de linguagem diferentes. Era preciso definir:
- Qual range de Java a IDE suporta para **projetos**?
- Como a versão da JDK influencia o editor?
- Como separar a JDK que *roda os servers* da JDK dos *projetos*?

## Decisão
O **editor/IDE é compatível com qualquer projeto Java dentro do range aceito pelo Eclipse JDT Language Server — Java 1.8 a 24** — e segue a **JDK padrão configurada** no projeto. **A IDE não impõe uma versão** ao projeto.

Há dois papéis distintos de JDK:
1. **Runtime dos servers** (jdt.ls, lemminx, java-debug) → **Java 21+**. É **infraestrutura interna, invisível** ao usuário/projeto. Não limita a compatibilidade.
2. **Runtime do projeto** → escolhida pelo usuário, no range **1.8 a 24** (via `java.configuration.runtimes` do jdt.ls e/ou toolchains do Maven/Gradle). Determina o **nível de linguagem**; o editor mostra os recursos conforme essa versão.

## Motivos
- O jdt.ls analisa/compila projetos de **1.8 a 24** nativamente — é a fonte de verdade do "range suportado".
- Separar *runtime do server* (21+) de *runtime do projeto* (1.8–24) evita acoplar a compatibilidade ao motor interno da IDE.
- "A JDK padrão setada" do projeto é soberana: a IDE respeita o que o usuário configurou, sem forçar upgrade/downgrade.

## Consequências
- ✅ Suporte a projetos Java **1.8 a 24**.
- ✅ A UI de **Settings** deve permitir **múltiplas runtimes** e associar cada uma a um projeto (`java.configuration.runtimes`).
- ✅ O editor (re_editor) reflete o **nível de linguagem** do projeto (records, sealed classes, pattern matching, virtual threads, etc.) — o jdt.ls fornece a análise.
- ✅ **Maven/Gradle** usam a JDK do projeto (toolchains); a IDE não substitui por outra.
- 📌 Documentar sempre essa separação (server 21+ interno ≠ projeto 1.8–24) para não confundir usuários.
- 🔁 Se o jdt.ls ampliar/alterar o range suportado no futuro, basta atualizar este ADR.

## Alternativas consideradas
- **Fixar uma versão mínima de projeto** (ex.: só Java 17+) — rejeitado por limitar usuários legados.
- **Exigir a mesma JDK do server para os projetos** — rejeitado: o usuário escolhe a JDK do seu projeto.

## Veja também
- [[ide/prereqs]] · [[ide/lsp-features]] · [[ide/arquitetura]] · [[ide/maven]] · [[ide/gradle]] · [[adr-0001-hux-sobre-material]]
