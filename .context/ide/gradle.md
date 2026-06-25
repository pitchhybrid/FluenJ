# Componente — Gradle integration

> Parte de [[ide-arquitetura]]. Fase 4.

## Detecção de projeto Gradle
- Presença de `build.gradle` (Groovy DSL) ou `build.gradle.kts` (Kotlin DSL), junto de `settings.gradle(.kts)` e `gradlew`.
- Multi-projeto: definido em `settings.gradle` via `include '...'`.

## Abordagem: CLI via `dart:io` Process
- Sempre preferir o **wrapper** `./gradlew` (Linux/macOS) / `gradlew.bat` (Windows) — pin de versão.
- Execução: `gradlew <task>` a partir da raiz do projeto.
- Flags úteis: `--console=plain` (saída parseável, sem ANSI), `-q` (quiet), `--offline`, `-p <dir>`.
- Capturar stdout/stderr em stream → output panel.

## Tarefas Gradle comuns
- `gradlew build` · `test` · `clean` · `assemble` · `check` · `jar`
- `gradlew run` (com plugin application) · `bootRun` (Spring)
- `gradlew dependencies` / `:proj:dependencies`
- `gradlew tasks --all` (descobrir tarefas)

## Descoberta de tasks (para a UI)
- `gradlew tasks --all --console=plain` → parse da lista para popular o painel Gradle (projetos → tasks).
- Ou usar a **Gradle Tooling API** (Java) — **não** adotada inicialmente (exigiria JVM extra/wrapper). CLI é mais simples e cross-platform para um app Dart.

## Parse de build.gradle
- Groovy/Kotlin DSL **não é trivial de parsear** (é código).
- Estratégia: **não** parsear a fundo. Confiar no **jdt.ls** (importador Gradle) para dependências/classpath. A UI lista tasks via `gradlew tasks`.

## Integração com LSP
- Settings no jdt.ls: `java.import.gradle.enabled: true`, `java.import.gradle.wrapper.enabled: true`, `java.import.gradle.home`, versões do Gradle.
- O jdt.ls resolve o classpath e as dependências automaticamente.

## UI
- Painel **Gradle** (sidebar): projetos → tarefas (com grupo/descrição) → dependências. Duplo-clique = rodar task.
- Status de daemon Gradle (longo); permitir "stop daemons".
- Output colorido/estruturado.

## Riscos
- Daemon Gradle ocupa memória; primeira execução é lenta.
- Versões muito novas do Gradle vs JDK — orientar na configuração.
- ANSIfication do output: usar `--console=plain` para evitar escapes.

## Veja também
- [[ide-gradle-features]] (Tooling API vs CLI; **jdt.ls/Buildship já resolve estrutura/classpath**) · [[ide-maven]] · [[ide-prereqs]] · [[ide-lsp]] · [[ide-explorers]]
