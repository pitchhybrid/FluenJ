import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hux/hux.dart';

import '../../core/state/workspace.dart';

/// Tela inicial quando nenhuma pasta de projeto está aberta.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
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
                  child: HuxBadge(label: 'FluenJ', variant: HuxBadgeVariant.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'FluenJ — IDE para Java',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Desktop (Windows, Linux, macOS). Nenhuma pasta aberta.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                HuxButton(
                  onPressed: () =>
                      ref.read(workspaceProvider.notifier).openFolderPicker(),
                  child: const Text('Abrir pasta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
