import 'dart:io';

import 'package:path/path.dart' as p;

/// Um nó da árvore de arquivos do explorador.
///
/// A árvore é carregada de forma preguiçosa: os filhos só são listados
/// quando o diretório é expandido pelo usuário.
class FileNode {
  FileNode({
    required this.path,
    required this.name,
    required this.isDir,
    this.depth = 0,
    List<FileNode>? children,
    this.isExpanded = false,
    this.isLoading = false,
  }) : children = children ?? [];

  /// Caminho absoluto no sistema de arquivos.
  final String path;

  /// Nome de exibição (último segmento do caminho).
  final String name;

  /// É diretório?
  final bool isDir;

  /// Nível de profundidade na árvore (para indentação).
  final int depth;

  /// Filhos (somente para diretórios; populado ao expandir).
  final List<FileNode> children;

  /// Diretório atualmente expandido no explorador.
  bool isExpanded;

  /// Em processo de carregamento dos filhos.
  bool isLoading;

  factory FileNode.fromEntity(FileSystemEntity entity, {int depth = 0}) {
    return FileNode(
      path: entity.path,
      name: p.basename(entity.path),
      isDir: entity is Directory,
      depth: depth,
    );
  }

  @override
  String toString() => '$name${isDir ? '/' : ''}';
}
