import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../explorer/file_explorer.dart';

/// Barra lateral: cabeçalho "EXPLORER" + árvore de arquivos.
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      color: theme.colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Text('EXPLORER', style: theme.textTheme.small),
          ),
          Container(height: 1, color: theme.colorScheme.border),
          const Expanded(child: FileExplorer()),
        ],
      ),
    );
  }
}
