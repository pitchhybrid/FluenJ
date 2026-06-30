# myide IDE — pré-requisitos do sistema

O app não embute tudo; ele **orquestra** ferramentas externas já instaladas (ou bundled em `~/.myide/runtime`). Definir uma política de detecção e download.

## Compatibilidade de JDK (princípio)
A IDE/editor é compatível com **qualquer projeto Java dentro do range aceito pelo jdt.ls: 1.8 a 24**, seguindo a **JDK padrão configurada** do projeto. A IDE **não impõe** versão ao projeto.
- **Runtime dos servers** (Java 21+, para rodar jdt.ls/lemminx/java-debug) = infraestrutura interna, **invisível** — não limita a compatibilidade.
- **Runtime do projeto** (1.8–24, escolhida pelo usuário via `java.configuration.runtimes`) = determina o nível de linguagem; o editor mostra features conforme ela.
- Decisão formal: [[adr-0002-compatibilidade-jdk]].

## Essenciais
| Item | Por quê | Detecção |
|---|---|---|
| **JDK 21+** | **roda o jdt.ls** (exige Java 21) e o java-debug | `JAVA_HOME` / `java -version` |
| **Eclipse JDT LS (jdt.ls)** | LSP + host do DAP | bundle em `<runtime>/jdt.ls/` |
| **java-debug (microsoft)** | debug (bundle OSGi no jdt.ls) | bundles em `<runtime>/jdt.ls/bundles/` |
| **lemminx** | LSP de XML/XHTML | `<runtime>/lemminx/lemminx-*.jar` (ou binário) |

## Build tools (opcionais, conforme o projeto)
| Item | Uso | Detecção |
|---|---|---|
| **Maven** | projetos `pom.xml` | `mvn -v` / `M2_HOME` / `mvnw` |
| **Gradle** | projetos `build.gradle(.kts)` | `gradlew` do projeto / `gradle -v` |

## Launch do jdt.ls (referência)
```bash
java \
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \
  -Declipse.product=org.eclipse.jdt.ls.core.product \
  -Dosgi.bundles.defaultStartLevel=4 \
  --add-modules=ALL-SYSTEM \
  -Xmx1G \
  -jar ./plugins/org.eclipse.equinox.launcher_<versão>.jar \
  -configuration ./config_<linux|mac|win> \
  -data <workspace_dir> \
  -javaagent:<bundles>/java-debug/*.jar   # carrega java-debug (para DAP)
```
- `config_linux` / `config_mac` / `config_win` — escolher conforme `Platform`.
- `-data` = workspace do Eclipse (dados de índice), **distinto** do projeto aberto.

## Launch do lemminx
```bash
java -jar org.eclipse.lemminx-<versão>-uber.jar     # JAR (requer Java)
# ou binário nativo: ./lemminx-<os>                  # sem Java
```

## Detecção de JDK
- O jdt.ls **exige Java 21+ para rodar**, mas compila projetos de **1.8 a 24**.
- Logo, há normalmente **dois papéis**: (a) **runtime do server** (Java 21+) e (b) **runtimes dos projetos** (1.8–24, via `java.configuration.runtimes`).
- Respeitar `JAVA_HOME`; senão, varrer locais comuns (Windows: `Program Files\Java\*`, `Program Files\Eclipse Adoptium\*`).
- Permitir configurar manualmente nas Settings.

## Empacotamento/first-run
- **Primeira execução**: wizard que confirma/instala JDK + jdt.ls + java-debug + lemminx (download para `<runtime>`).
- Cache de versões para não baixar a cada run.

## Veja também
- [[ide/arquitetura]] · [[ide/lsp]] · [[ide/dap]] · [[ide/lemminx]] · [[ambiente-desenvolvimento]]
