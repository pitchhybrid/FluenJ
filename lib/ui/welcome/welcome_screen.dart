import 'package:fluenj/core/state/workspace.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Tela inicial quando nenhuma pasta de projeto está aberta.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: ShadBadge(child: Text('FluenJ')),
              ),
              const SizedBox(height: 16),
              Text('FluenJ — IDE para Java', style: theme.textTheme.h1),
              const SizedBox(height: 8),
              Text(
                'Desktop (Windows, Linux, macOS). Nenhuma pasta aberta.',
                style: theme.textTheme.muted,
              ),
              const SizedBox(height: 24),
              ShadButton(
                leading: const Icon(LucideIcons.folderOpen, size: 16),
                onPressed: () =>
                    ref.read(workspaceProvider.notifier).openFolderPicker(),
                child: const Text('Abrir pasta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
