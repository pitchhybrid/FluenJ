import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/state/package_tree.dart';
import '../explorer/file_explorer.dart';
import '../explorer/package_explorer.dart';

/// Barra lateral: seletor (Files | Packages) + explorador ativo.
class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final mode = ref.watch(explorerModeProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(
          right: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
            child: Row(
              children: [
                _ModeTab(
                  icon: LucideIcons.folderTree,
                  label: 'Files',
                  active: mode == ExplorerMode.files,
                  onTap: () => ref
                      .read(explorerModeProvider.notifier)
                      .set(ExplorerMode.files),
                ),
                const SizedBox(width: 4),
                _ModeTab(
                  icon: LucideIcons.package,
                  label: 'Packages',
                  active: mode == ExplorerMode.packages,
                  onTap: () => ref
                      .read(explorerModeProvider.notifier)
                      .set(ExplorerMode.packages),
                ),
              ],
            ),
          ),
          Container(height: 1, color: theme.colorScheme.border),
          Expanded(
            child: mode == ExplorerMode.files
                ? const FileExplorer()
                : const PackageExplorer(),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final color = active
        ? theme.colorScheme.primary
        : theme.colorScheme.mutedForeground;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: active ? theme.colorScheme.muted : const Color(0x00000000),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.small.copyWith(
                  color: color,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
