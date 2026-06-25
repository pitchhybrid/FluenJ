import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/editor.dart';
import 'code_editor_view.dart';

/// Área do editor: barra de abas + editor de código do arquivo ativo.
class EditorArea extends ConsumerWidget {
  const EditorArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editor = ref.watch(editorProvider);
    final theme = Theme.of(context);

    if (editor.isEmpty) {
      return Center(
        child: Text(
          'Abra um arquivo no explorador',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    final active = editor.active;
    return Column(
      children: [
        _EditorTabBar(
          tabs: editor.tabs,
          activeIndex: editor.activeIndex,
        ),
        Expanded(
          child: active == null
              ? const SizedBox.shrink()
              : CodeEditorView(
                  key: ValueKey(active.path),
                  tab: active,
                ),
        ),
      ],
    );
  }
}

/// Barra de abas custom (título + indicador de dirty + fechar).
class _EditorTabBar extends ConsumerWidget {
  const _EditorTabBar({required this.tabs, required this.activeIndex});

  final List<EditorTab> tabs;
  final int activeIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      height: 34,
      color: theme.colorScheme.surfaceContainerLow,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isActive = index == activeIndex;
          return GestureDetector(
            onTap: () => ref.read(editorProvider.notifier).setActive(index),
            child: Container(
              padding: const EdgeInsets.only(left: 12, right: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.surface
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: isActive
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${tab.isDirty ? '• ' : ''}${tab.name}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () =>
                        ref.read(editorProvider.notifier).closeTab(index),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text('×'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
