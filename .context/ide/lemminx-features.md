# Catálogo de features do lemminx

> Referência rica do **Eclipse LemMinX** (XML Language Server). Fontes: [vscode-xml README](https://github.com/redhat-developer/vscode-xml) e [LemMinX-Extensions](https://github.com/eclipse/lemminx/blob/main/docs/LemMinX-Extensions.md). Complementa [[ide-lemminx]].

## ⚠️ Binário vs Java (decisão que afeta tudo)
| | Binário nativo (default, desde v0.15.0) | Versão Java (JAR, JDK 11+) |
|---|---|---|
| Requer Java | ❌ não | ✅ sim |
| Auto-download | ✅ | — |
| **Suporta extensões** (pom.xml Maven, Liquibase, Camel, Spring…) | ❌ **NÃO** | ✅ **sim** |
| Cache de schema | `~/.lemminx` | `~/.lemminx` |

> Para um IDE Java queremos **completion avançado de `pom.xml`** (lemminx-maven), então devemos rodar a **versão Java** do lemminx (JDK 11+ — já coberto pelo JDK 21 do jdt.ls) e colocar os JARs das extensões no **classpath**. Settings: `xml.server.preferBinary: false`, `xml.java.home`, `xml.server.vmargs`.

## Features LSP (suportadas)
| Categoria | Recursos |
|---|---|
| **Validação** | Syntax (well-formed) · **DTD** · **XSD** · **RelaxNG** (experimental) |
| **Completion** | Geral · baseado em **XSD** · baseado em **DTD** · auto-close tags · auto-indent |
| **Hover** | documentação XSD (annotations) |
| **Navegação** | Document symbols/outline · **XML References** (refs entre elementos) · symbol highlighting |
| **Edição** | Formatting (XML + DTD) · **Auto-rename tag** (linkedEditing) · **Document folding** · **Document links** |
| **Refatoração** | **Surround with Tags/Comments/CDATA** · **Rename** · **Minify XML** |
| **Schema/docs** | **XML catalogs** (OASIS) · **File associations** · **Schema caching** · **XInclude** · **XSL** |
| **Extras** | **XML Colors** (preview de cores) · code actions · diagnostics |

## Schemas / gramáticas suportados
- **XSD** (XML Schema) — validação, hover e completion a partir das annotations
- **DTD** — validação, completion, formatting
- **RelaxNG** — experimental (desde v0.22.0)
- **XSL / XSLT** — plugin built-in (registra XSD do XSL)
- **XInclude** — validação de inclusões
- Resolução via `xsi:schemaLocation`, `xsi:noNamespaceSchemaLocation`, `<!DOCTYPE SYSTEM "...">` ou **catalogs**.

## XML Catalogs & File Associations (ouro para offline)
- **XML Catalogs** (`xml.catalogs`): mapear namespaces/URIs públicos → **schemas locais** (offline, rápido, sem download). Ex.: empacotar catalogs do Maven, Jakarta EE, Spring, Tomcat.
- **File associations** (`xml.fileAssociations`): amarrar extensão/padrão de arquivo a um schema. Ex.: associar `*.config` a um XSD próprio.
- **Schema caching** (`xml.server.workDir`, default `~/.lemminx`): caches de schemas baixados.

## Extensões (Java SPI — JARs no classpath)
O lemminx é estendido implementando `IXMLExtension` (Java SPI) e registrando *participants* (completion, hover, diagnostics, code action, …).

**Built-in:** content-model (XSD/DTD), XSL, e vários em `.../extensions/`.

**Externas relevantes para Java:**
| Extensão | O que adiciona |
|---|---|
| **lemminx-maven** ⭐ | `pom.xml` avançado: completion de **groupId/artifactId/version consultando o Maven Central**, dependency management, plugins, properties |
| **lemminx-liberty** | Open Liberty `server.xml` (features, diagnostics) |
| **lemminx-liquibase** | changelog XML com validação em DB in-memory |
| **lemminx-camel** | Apache Camel XML DSL (rotas) |
| **lemminx-spring** | config XML do Spring |
| *própria* | suporte a XML custom do domínio (ex.: config proprietária) |

> Combinar com [[ide-maven]]: o **lemminx-maven** complementa o painel Maven dando completion inteligente de dependências **dentro do editor** de `pom.xml`.

## Settings principais (`xml.*`) — via `workspace/didChangeConfiguration`
- **Server**: `xml.java.home`, `xml.server.vmargs`, `xml.server.workDir`, `xml.server.preferBinary`, `xml.server.binary.path`
- **Schema/catalog**: `xml.catalogs`, `xml.fileAssociations`, `xml.schemas`
- **Validação**: `xml.validation.enabled`, `xml.validation.schema`, `xml.validation.xInclude`
- **Formatação**: `xml.format.*` (preserve empty tags, split attributes, wrapping, line width…)
- **Completion**: `xml.completion.autoCloseTags`
- **Symbols**: `xml.symbols.excluded`, `xml.symbols.showReference`
- **References/Colors/CodeLens**: `xml.references.*`, `xml.colors.*`, `xml.codeLens.*`

## Como rodar no myide
1. Baixar/empacotar o **lemminx uber-JAR** + os JARs das extensões desejadas (lemminx-maven…) em `<runtime>/lemminx/`.
2. Launch (versão Java, com extensões no classpath):
   ```bash
   java -cp "lemminx-uber.jar:ext/*" org.eclipse.lemminx.XMLLanguageServer
   # (ou o entrypoint equivalente do uber-jar)
   ```
3. Reutilizar o **mesmo cliente LSP** Dart do Java (framing `Content-Length` idêntico) — é só outro server. Ver [[ide-lsp]].
4. Roteamento por extensão: `.xml/.xsd/.xsl/.xhtml/.jspx/.tld/.fxml/.pom` → lemminx; `.java` → jdt.ls.

## Sugestão de prioridade (no [[ide-roadmap]])
- **Fase 5 (XML/lemminx)**: validação XSD/DTD + completion + hover + formatting + catalogs (pom.xml, web.xml, persistence.xml).
- **Fase 6+**: extensão **lemminx-maven** (completion de Maven Central no pom), RelaxNG, XML References, Colors, surround/refactors.

## Veja também
- [[ide-lemminx]] · [[ide-lsp]] · [[ide-maven]] · [[ide-prereqs]] · [[ide-roadmap]]
