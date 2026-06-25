import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/models/file_node.dart';
import '../../core/state/editor.dart';
import '../../core/state/file_tree.dart';

/// Explorador de arquivos (árvore com carregamento preguiçoso).
class FileExplorer extends ConsumerWidget {
  const FileExplorer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final tree = ref.watch(fileTreeProvider);

    if (tree == null) {
      return Center(child: Text('Sem pasta', style: theme.textTheme.muted));
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
    final theme = ShadTheme.of(context);
    final iconColor = node.isDir
        ? theme.colorScheme.primary
        : theme.colorScheme.mutedForeground;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (node.isDir) {
          ref.read(fileTreeProvider.notifier).toggle(node);
        } else {
          ref.read(editorProvider.notifier).openFile(node.path);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 8 + node.depth * 14.0,
          top: 2,
          bottom: 2,
          right: 8,
        ),
        child: Row(
          children: [
            // Marcador de expandir/recolher (somente diretórios).
            if (node.isDir)
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  node.isExpanded
                      ? LucideIcons.chevronDown
                      : LucideIcons.chevronRight,
                  size: 14,
                  color: theme.colorScheme.mutedForeground,
                ),
              )
            else
              const SizedBox(width: 16),
            Icon(_iconFor(node), size: 15, color: iconColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                node.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.small,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ícone lucide conforme o tipo do arquivo.
  IconData _iconFor(FileNode node) {
    if (node.isDir) {
      return node.isExpanded ? LucideIcons.folderOpen : LucideIcons.folder;
    }
    final ext = node.name.contains('.')
        ? node.name.split('.').last.toLowerCase()
        : '';
    switch (ext) {
      case 'java':
        return LucideIcons.fileCode2;
      case 'json':
        return LucideIcons.braces;
      case 'xml':
      case 'xhtml':
      case 'xsd':
        return LucideIcons.fileCode;
      case 'md':
        return LucideIcons.fileText;
      case 'gradle':
      case 'kts':
      case 'properties':
        return LucideIcons.fileText;
      default:
        return LucideIcons.file;
    }
  }
}
