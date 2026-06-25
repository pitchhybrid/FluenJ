import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/state/editor.dart';
import '../../core/state/layout.dart';
import '../../core/state/workspace.dart';

/// Barra de status inferior (nome do projeto, arquivo ativo, compatibilidade)
/// + toggles de visibilidade dos painéis (explorer / terminal).
class StatusBar extends ConsumerWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final ws = ref.watch(workspaceProvider);
    final editor = ref.watch(editorProvider);
    final layout = ref.watch(layoutProvider);

    return Container(
      height: 26,
      color: theme.colorScheme.muted,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(ws.isOpen ? ws.name : 'FluenJ', style: theme.textTheme.small),
          const SizedBox(width: 16),
          if (editor.active != null)
            Expanded(
              child: Text(
                '${editor.active!.isDirty ? '• ' : ''}${editor.active!.path}',
                style: theme.textTheme.small,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),
          _PanelToggle(
            icon: layout.showSidebar
                ? LucideIcons.panelLeftOpen
                : LucideIcons.panelLeftClose,
            active: layout.showSidebar,
            onTap: () =>
                ref.read(layoutProvider.notifier).toggleSidebar(),
          ),
          const SizedBox(width: 12),
          _PanelToggle(
            icon: LucideIcons.terminal,
            active: layout.showOutput,
            onTap: () => ref.read(layoutProvider.notifier).toggleOutput(),
          ),
          const SizedBox(width: 12),
          Text('Java 1.8–24', style: theme.textTheme.small),
        ],
      ),
    );
  }
}

class _PanelToggle extends StatelessWidget {
  const _PanelToggle({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(
          icon,
          size: 15,
          color: active
              ? theme.colorScheme.primary
              : theme.colorScheme.mutedForeground,
        ),
      ),
    );
  }
}
