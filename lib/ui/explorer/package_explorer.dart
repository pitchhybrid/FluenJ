import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/models/file_node.dart';
import '../../core/state/editor.dart';
import '../../core/state/file_tree.dart' show linearizeVisible;
import '../../core/state/package_tree.dart';

/// Package explorer (árvore lógica estilo Eclipse): source folders, pacotes,
/// classes, Libraries e WebApp.
class PackageExplorer extends ConsumerWidget {
  const PackageExplorer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final tree = ref.watch(packageTreeProvider);

    if (tree == null) {
      return Center(child: Text('Sem projeto', style: theme.textTheme.muted));
    }

    final visible = linearizeVisible(tree.roots);
    return ListView.builder(
      itemCount: visible.length,
      itemBuilder: (context, index) => _PackageTile(node: visible[index]),
    );
  }
}

class _PackageTile extends ConsumerWidget {
  const _PackageTile({required this.node});

  final FileNode node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final isPkg = node.kind == NodeKind.package;
    final iconColor =
        isPkg ? theme.colorScheme.primary : theme.colorScheme.mutedForeground;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (node.isDir) {
          ref.read(packageTreeProvider.notifier).toggle(node);
        } else if (node.path.isNotEmpty) {
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
            Icon(iconForKind(node.kind), size: 15, color: iconColor),
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
}

IconData iconForKind(NodeKind? kind) {
  switch (kind) {
    case NodeKind.sourceFolder:
      return LucideIcons.folderCode;
    case NodeKind.package:
      return LucideIcons.package;
    case NodeKind.classFile:
      return LucideIcons.code;
    case NodeKind.library:
      return LucideIcons.library;
    case NodeKind.jre:
      return LucideIcons.coffee;
    case NodeKind.webApp:
      return LucideIcons.globe;
    case NodeKind.webResource:
    case NodeKind.file:
      return LucideIcons.file;
    case NodeKind.folder:
    case null:
      return LucideIcons.folder;
  }
}
