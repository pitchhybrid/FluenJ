import 'package:fluenj/core/models/file_node.dart';
import 'package:fluenj/core/services/file_system_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Snapshot da árvore de arquivos do explorador.
class FileTreeState {
  const FileTreeState({required this.rootPath, required this.roots});

  final String rootPath;
  final List<FileNode> roots;
}

/// Mantém a árvore de arquivos com carregamento preguiçoso (lazy).
class FileTreeNotifier extends Notifier<FileTreeState?> {
  @override
  FileTreeState? build() => null;

  void setRoot(String path) {
    final fs = ref.read(fileSystemProvider);
    state = FileTreeState(rootPath: path, roots: fs.listDirectory(path));
  }

  void clear() => state = null;

  /// Expande/recolhe um diretório, carregando seus filhos na primeira abertura.
  void toggle(FileNode node) {
    final current = state;
    if (current == null || !node.isDir) return;
    final fs = ref.read(fileSystemProvider);

    if (node.isExpanded) {
      node.isExpanded = false;
    } else {
      node.isExpanded = true;
      if (node.children.isEmpty) {
        node.children
            .addAll(fs.listDirectory(node.path, depth: node.depth + 1));
      }
    }

    // Nova instância para notificar os ouvintes.
    state = FileTreeState(rootPath: current.rootPath, roots: current.roots);
  }
}

/// Provider da árvore de arquivos visível.
final fileTreeProvider =
    NotifierProvider<FileTreeNotifier, FileTreeState?>(FileTreeNotifier.new);

/// Lineariza a árvore numa lista de nós visíveis (DFS, respeitando expansões).
List<FileNode> linearizeVisible(List<FileNode> roots) {
  final result = <FileNode>[];
  void walk(List<FileNode> nodes) {
    for (final n in nodes) {
      result.add(n);
      if (n.isDir && n.isExpanded) walk(n.children);
    }
  }

  walk(roots);
  return result;
}
