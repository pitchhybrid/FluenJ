import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/state/editor.dart';
import '../../core/state/workspace.dart';

/// Barra de status inferior (nome do projeto, arquivo ativo, compatibilidade).
class StatusBar extends ConsumerWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final ws = ref.watch(workspaceProvider);
    final editor = ref.watch(editorProvider);

    return Container(
      height: 26,
      color: theme.colorScheme.muted,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            ws.isOpen ? ws.name : 'FluenJ',
            style: theme.textTheme.small,
          ),
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
          Text('Java 1.8–24', style: theme.textTheme.small),
        ],
      ),
    );
  }
}
