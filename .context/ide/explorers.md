# Componente — Explorers (Project & File explorer)

> Parte de [[ide/arquitetura]]. Fase 1.

## Dois exploradores, dois propósitos
1. **File explorer** — árvore **literal** do sistema de arquivos (pastas/arquivos). Simples, sempre disponível.
2. **Project explorer** — visão **lógica** do projeto Java: source folders (`src/main/java`), pacotes, recursos, dependências (Maven/Gradle), bibliotecas. Inspirado no Eclipse "Project Explorer".

> Iniciar só com o **File explorer** (Fase 1). O Project explorer Java vem na Fase 7.

## Widget
- **`flutter_directory_tree`** (1.0.0): tree virtualizada, multi-root, navegação por teclado, seleção tri-state — ideal para desktop.

## File explorer — escopo
- Raiz: a pasta do projeto aberto.
- Lazy loading: expandir pasta sob demanda (não varrer tudo no open).
- Ações de contexto: novo arquivo/pasta, renomear, excluir, copiar caminho, "reveal in OS".
- Filtros: esconder `target/`, `build/`, `.git/` por padrão (configurável).
- Selecionar → abrir no editor ([[ide/editor]]).

## Model (Dart)
```
FileNode {
  path, name, isDir,
  List<FileNode> children (lazy),
  bool loaded
}
FileSystemService {
  list(dir) -> List<FileNode>
  create/move/delete(node)
  watch(path) -> Stream<fs events>   // atualizar a árvore
}
```
- Usar `dart:io` `Directory`/`File` e `FileSystemEntity.watch` para refletir mudanças externas.

## Project explorer — quando chegar (Fase 7)
- Montado a partir de:
  - Estrutura de pastas (Maven standard layout, Gradle).
  - `pom.xml` / `build.gradle` (dependências, módulos).
  - Info do **LSP** (jdt.ls conhece source folders e packages).
- Mostrar: módulos → pacotes → tipos; nó "Referenced Libraries"; nós de dependências.

## Ícones
- Evitar `Icons.*` (Material). Usar set de ícones consistente (ex.: `lucide_icons_flutter`, mesmo que o Hux usa) ou SVG próprio por extensão (`.java`, `.xml`, `.gradle`, `.properties`).

## Veja também
- [[ide/editor]] · [[ide/arquitetura]] · [[ide/maven]] · [[ide/gradle]]
