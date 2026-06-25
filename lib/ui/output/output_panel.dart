import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Painel inferior de saída. Placeholder na Fase 1 — o terminal integrado
/// (xterm + flutter_pty) entra na Fase 1.5. Ver [[ide-terminal]].
class OutputPanel extends ConsumerWidget {
  const OutputPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(
          top: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: Text('Terminal / Output — em breve', style: theme.textTheme.muted),
    );
  }
}
