import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Painel inferior de saída. Placeholder na Fase 1 — o terminal integrado
/// (xterm + flutter_pty) entra na Fase 1.5. Ver [[ide-terminal]].
class OutputPanel extends ConsumerWidget {
  const OutputPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: Text(
        'Terminal / Output — em breve',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
