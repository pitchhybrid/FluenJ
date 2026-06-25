import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/file_node.dart';
import '../../core/state/editor.dart';
import '../../core/state/file_tree.dart';

/// Explorador de arquivos (árvore com carregamento preguiçoso).
class FileExplorer extends ConsumerWidget {
  const FileExplorer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(fileTreeProvider);
    final theme = Theme.of(context);

    if (tree == null) {
      return Center(
        child: Text(
          'Sem pasta',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    final visible = linearizeVisible(tree.roots);
    return ListView.builder(
      itemCount: visible.length,
      itemBuilder: (context, index) =>
          _FileTreeTile(node: visible[index]),
    );
  }
}

class _FileTreeTile extends ConsumerWidget {
  const _FileTreeTile({required this.node});

  final FileNode node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (node.isDir) {
          ref.read(fileTreeProvider.notifier).toggle(node);
        } else {
          ref.read(editorProvider.notifier).openFile(node.path);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 10 + node.depth * 14.0,
          top: 3,
          bottom: 3,
          right: 8,
        ),
        child: Row(
          children: [
            if (node.isDir)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  node.isExpanded ? '▾' : '▸',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(_glyph(node), style: const TextStyle(fontSize: 14)),
            ),
            Expanded(
              child: Text(
                node.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Glifo provisório por tipo de arquivo (placeholders; trocar por um set
  /// de ícones — ex.: lucide_icons_flutter — numa fase futura).
  String _glyph(FileNode node) {
    if (node.isDir) return '📁';
    final ext = node.name.contains('.')
        ? node.name.split('.').last.toLowerCase()
        : '';
    switch (ext) {
      case 'java':
        return '☕';
      case 'xml':
      case 'xhtml':
      case 'xsd':
        return '🌐';
      case 'gradle':
      case 'kts':
        return '🐘';
      case 'properties':
        return '⚙';
      case 'json':
        return '🅙';
      case 'md':
        return '📝';
      default:
        return '📄';
    }
  }
}
