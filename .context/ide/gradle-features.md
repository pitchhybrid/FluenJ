# Catálogo de features — Gradle integration

> Referência rica: **Tooling API vs CLI**, e como o Gradle se encaixa no myide. Fontes: [Tooling API](https://docs.gradle.org/current/userguide/tooling_api.html), [Version Catalogs](https://docs.gradle.org/current/userguide/version_catalogs.html). Complementa [[ide/gradle]].

## 💡 Insight central: o jdt.ls já resolve o Gradle (estrutura)
O **Eclipse JDT LS embute o [Buildship](https://github.com/eclipse/buildship)** (suporte Gradle) — igual ao M2Eclipse para Maven. Ou seja:
- **Estrutura de projeto, source folders, classpath, dependências, toolchains por subprojeto** → vêm do **jdt.ls** ao importar o projeto. **Não** precisamos chamar Gradle para isso.
- O **CLI `gradlew`** é necessário só para **executar tarefas** (build/test/run/clean) e descobrir a lista de tasks.

> Consequência: a integração Gradle do myide é **mais leve** do que parece — CLI para executar + LSP para entender.

## Tooling API vs CLI
| | Tooling API (`org.gradle:gradle-tooling-api`) | CLI (`gradlew`) |
|---|---|---|
| Linguagem | **Java** (precisa de JVM/sidecar) | processo via `dart:io` |
| Daemon | sempre on, automático | default on; `--no-daemon`/`--foreground`/`--status`/`--stop` |
| **Modelos estruturados** | ✅ `IdeaModel`, `EclipseModel`, `BuildEnvironment`, `GradleBuild`, `JavaEnvironment`, `BasicIdeaModel` | ❌ só texto |
| Grafo de dependências | ❌ sem modelo first-class ([#4215](https://github.com/gradle/gradle/issues/4215)) | ✅ tasks `dependencies`/`dependencyInsight` |
| Executar tarefas | `BuildLauncher` + listeners | flags ricas (`--parallel`, `--continuous`, `--offline`, `--rerun-tasks`, `--dry-run`) |
| Toolchains | detectado via modelo | DSL + **auto-provisioning** (`foojay-resolver-convention`) |
| Version catalog (TOML) | lido no sync, sem modelo dedicado | first-class `libs.versions.toml` |
| Configuration cache | suportado c/ arestas; sem API programática ([#37011](https://github.com/gradle/gradle/issues/37011)) | mais maduro (`--configuration-cache`, estável 8.1; Gradle 9 recomenda) |
| Compat. de versão | últimos **5 majors** do Gradle | = versão do wrapper |

## Decisão para o myide (app Dart)
- **Adotar CLI** (`gradlew` via `dart:io` Process) para **executar tasks** — direto, cross-platform, sem sidecar Java.
- **Estrutura/projetos/deps/toolchains** → delegar ao **jdt.ls (Buildship)** — já temos o processo rodando.
- **Tooling API** só se no futuro for preciso um **modelo estruturado que o jdt.ls não exponha** (ex.: grafo de dependências rico, eventos de build granulares) — nesse caso, um pequeno **sidecar Java** que fala com a IDE via JSON/stdio.

## Recursos do Gradle a explorar (via CLI/jdt.ls)
- **Tasks**: `build`, `test`, `clean`, `assemble`, `check`, `jar`, `run` (application), `bootRun` (Spring). Descobrir: `gradlew tasks --all --console=plain`.
- **Version catalog** (`gradle/libs.versions.toml`): aliases `libs.xxx` / `libs.plugins.xxx`; editar no editor com/sem lemminx. A IDE lista como nó de dependências.
- **Toolchains**: `java { toolchain { languageVersion = JavaLanguageVersion.of(N) } }` — respeitar a JDK do projeto ([[adr-0002-compatibilidade-jdk]]); o jdt.ls detecta por subprojeto.
- **Configuration/Build cache**: `--configuration-cache`, `--build-cache` para builds mais rápidos.
- **Continuous build**: `--continuous` para rebuild em mudança de arquivo (pode alimentar o painel de output).
- **Test**: integração com **Test Runner** (Junit view) — `gradlew test` parseando resultados XML em `build/test-results/`.

## Detalhes práticos
- Sempre **wrapper** (`./gradlew` / `gradlew.bat`) para pin de versão.
- `--console=plain` para saída parseável (sem ANSI).
- `-p <dir>` para escolher a raiz do projeto multi-módulo.
- Detectar settings: `settings.gradle(.kts)` (inclui `include`), `gradle.properties`, `init.d`.

## Veja também
- [[ide/gradle]] · [[ide/maven]] · [[ide/lsp]] · [[ide/prereqs]] · [[adr-0002-compatibilidade-jdk]]
