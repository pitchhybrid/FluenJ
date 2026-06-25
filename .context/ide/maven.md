# Componente — Maven integration

> Parte de [[ide-arquitetura]]. Fase 4.

## Detecção de projeto Maven
- Raiz do projeto contém `pom.xml` (ou herança via `parent`).
- Detecção: ao abrir workspace, varrer raiz e submódulos por `pom.xml`.

## Abordagem: CLI via `dart:io` Process
- Chamar `mvn` (ou `mvnw`/`mvnw.cmd` se existir) com os argumentos do goal.
- Preferir o **wrapper** do projeto (`./mvnw`) quando presente — garante a versão certa.
- Detecção do executável: `mvnw` local → `mvn` no PATH → `M2_HOME/bin`.
- Capturar stdout/stderr em **stream** → painel de build/output ([[ide-explorers]] output panel).

## Tarefas Maven comuns
- `mvn compile` · `mvn test` · `mvn package` · `mvn clean install` · `mvn verify`
- `mvn dependency:tree` · `mvn dependency:analyze`
- `mvn exec:java` (rodar) · `mvn spring-boot:run`
- `mvn versions:display-dependency-updates`

## Parse de pom.xml (pacote `xml`)
- Ler: `groupId/artifactId/version`, `packaging`, `properties`, `dependencies`, `dependencyManagement`, `modules`, `build/plugins`, `profiles`.
- Usado para:
  - **Project explorer**: nó de dependências.
  - Estrutura de módulos (multi-module).
  - Sugerir goals/plugins.

## Repositório local
- `~/.m2/repository` (`M2_REPO`) — para "Open Type" achar classes de dependências, o jdt.ls já indexa via `java.import.maven.enabled`.

## Integração com LSP
- O jdt.ls tem importador Maven: ao apontar o projeto, ele resolve dependências e constrói o classpath sozinho.
- Passar settings: `java.import.maven.enabled: true`, `maven.userSettings`/`globalSettings` se houver.
- **Bônus — editor de pom.xml**: a extensão **lemminx-maven** (carregada no lemminx) dá completion de **groupId/artifactId/version consultando o Maven Central** dentro do editor de `pom.xml`. Ver [[ide-lemminx-features]].

## UI
- Painel **Maven** (sidebar): lista de projetos → Lifecycle (clean/validate/compile/test/package/...) → Plugins → Dependências. Clique = rodar goal.
- Output panel com cores/logs; mostrar BUILD SUCCESS/FAILURE.

## Riscos
- Download de dependências no primeiro build (offline depois).
- Encoding do output do mvn no Windows (pode ser cp1252) — normalizar para UTF-8.

## Veja também
- [[ide-gradle]] · [[ide-prereqs]] · [[ide-lsp]] · [[ide-explorers]]
