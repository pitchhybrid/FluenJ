import 'dart:io';

import 'package:path/path.dart' as p;

/// Tipo lógico de um nó (usado pelo package explorer).
enum NodeKind {
  file,
  folder,
  package,
  sourceFolder,
  classFile,
  library,
  jre,
  webApp,
  webResource,
}

/// Um nó da árvore de arquivos (file explorer) ou lógica (package explorer).
class FileNode {
  FileNode({
    required this.path,
    required this.name,
    required this.isDir,
    this.depth = 0,
    this.kind,
    List<FileNode>? children,
    this.isExpanded = false,
    this.isLoading = false,
  }) : children = children ?? [];

  factory FileNode.fromEntity(FileSystemEntity entity, {int depth = 0}) {
    return FileNode(
      path: entity.path,
      name: p.basename(entity.path),
      isDir: entity is Directory,
      depth: depth,
    );
  }

  /// Caminho absoluto (pode ser vazio em nós lógicos como "JRE").
  final String path;

  /// Nome de exibição.
  final String name;

  /// É diretório/pacote (tem filhos)?
  final bool isDir;

  /// Nível de profundidade (para indentação).
  final int depth;

  /// Tipo lógico (package explorer); `null` = derivar (file explorer).
  final NodeKind? kind;

  /// Filhos (populados ao expandir).
  final List<FileNode> children;

  /// Atualmente expandido no explorador.
  bool isExpanded;

  /// Em processo de carregamento dos filhos.
  bool isLoading;

  @override
  String toString() => '$name${isDir ? '/' : ''}';
}
