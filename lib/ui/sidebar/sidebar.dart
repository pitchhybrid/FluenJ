import 'package:flutter/material.dart';

import '../explorer/file_explorer.dart';

/// Barra lateral: cabeçalho "EXPLORER" + árvore de arquivos.
/// (A "activity bar" com seções — Files/Search/Git — entra numa fase futura.)
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Text(
              'EXPLORER',
              style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
            ),
          ),
          const Divider(height: 1),
          const Expanded(child: FileExplorer()),
        ],
      ),
    );
  }
}
