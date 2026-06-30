# Componente — lemminx (XML/XHTML LSP)

> Parte de [[ide/arquitetura]]. Fase 5.

## O que é
**Eclipse LemMinX** — Language Server (LSP) para **XML/XHTML** da Red Hat/Eclipse. Dá:
- Validação (well-formedness + schema/DTD)
- Completion de tags/atributos
- Auto-close de tags, folding
- Navegação (go-to-definition de refs)
- Formatação
- Diagnósticos

## Por que usar no myide
Arquivos comuns em projetos Java que são **XML**:
- `pom.xml` (Maven) — com schema do Maven, completion de tags/plugins
- `web.xml`, `application.xml` (Jakarta/Java EE)
- `persistence.xml`, `beans.xml`, `ejb-jar.xml`
- `application.yml`/`.properties` (não XML — outro caso)
- **XHTML** / JSF (`.xhtml`, `.jspx`)
- Config de Spring (XML), Hibernate mappings

## Como roda
- **Processo à parte** (independente do jdt.ls): LSP sobre stdio, igual ao Java.
- Launch:
  - JAR: `java -jar org.eclipse.lemminx-<v>-uber.jar`
  - ou **binário nativo** (desde v0.15.0): `./lemminx-<os>` — sem Java.
- ⚠️ **Trade-off**: só a **versão Java** suporta **extensões** (ex.: lemminx-maven p/ pom.xml). Para IDE Java, rodar a versão Java. Detalhes em [[ide/lemminx-features]].
- Reutiliza o **mesmo cliente LSP** Dart do Java (framing idêntico), só com outro binário e settings.

## Schema / catalog awareness
- lemminx resolve schemas via `xsi:schemaLocation` / `xmlns` automaticamente.
- Configurar **XML catalogs** (ex.: schemas do Maven, Jakarta) para offline/velocidade: setting `xml.catalogs`.
- Extensions específicas (ex.: suporte a Spring/Maven schemas) via settings/JARs no classpath do lemminx.

## Associação de arquivo → server
- `.xml`, `.xsd`, `.xsl`, `.xhtml`, `.jspx`, `.tld` → lemminx.
- `.java` → jdt.ls.
- O `LanguageServiceManager` roteia por extensão ao abrir cada arquivo.

## Settings úteis (LSP `workspace/didChangeConfiguration`)
- `xml.validation.enabled`, `xml.validation.schema`
- `xml.format.*`
- `xml.completion.*`
- `xml.server.binary.path` / `xml.server.vmargs` (se empacotado)

## Detalhes
- Reaproveitar o cliente LSP genérico ([[ide/lsp]]) — lemminx é "só" outro server.
- Diagnósticos de XML aparecem no mesmo painel "Problems".

## Veja também
- [[ide/lemminx-features]] (catálogo completo de features/extensões do lemminx) · [[ide/lsp]] · [[ide/prereqs]] · [[ide/arquitetura]] · [[ide/editor]]
