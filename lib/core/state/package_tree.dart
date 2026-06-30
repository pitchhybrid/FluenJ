import 'package:fluenj/core/models/file_node.dart';
import 'package:fluenj/core/services/project_structure_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Snapshot da árvore lógica (package explorer).
class PackageTreeState {
  const PackageTreeState({required this.rootPath, required this.roots});

  final String rootPath;
  final List<FileNode> roots;
}

/// Mantém a árvore lógica do projeto (pacotes, libraries, webapp).
/// A árvore é construída inteira no `setRoot` (é menor que a física).
class PackageTreeNotifier extends Notifier<PackageTreeState?> {
  @override
  PackageTreeState? build() => null;

  Future<void> setRoot(String path) async {
    final svc = ref.read(projectStructureProvider);
    final roots = await svc.buildPackageTree(path);
    state = PackageTreeState(rootPath: path, roots: roots);
  }

  void clear() => state = null;

  void toggle(FileNode node) {
    final current = state;
    if (current == null || !node.isDir) return;
    node.isExpanded = !node.isExpanded;
    state = PackageTreeState(rootPath: current.rootPath, roots: current.roots);
  }
}

final packageTreeProvider =
    NotifierProvider<PackageTreeNotifier, PackageTreeState?>(
        PackageTreeNotifier.new);

/// Qual explorador está ativo na sidebar.
enum ExplorerMode { files, packages }

class ExplorerModeNotifier extends Notifier<ExplorerMode> {
  @override
  ExplorerMode build() => ExplorerMode.files;

  void set(ExplorerMode mode) => state = mode;
}

final explorerModeProvider =
    NotifierProvider<ExplorerModeNotifier, ExplorerMode>(ExplorerModeNotifier.new);
