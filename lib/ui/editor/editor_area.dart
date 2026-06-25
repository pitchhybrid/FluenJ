import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/state/editor.dart';
import 'code_editor_view.dart';

/// Área do editor: barra de abas + editor de código do arquivo ativo.
class EditorArea extends ConsumerWidget {
  const EditorArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final editor = ref.watch(editorProvider);

    if (editor.isEmpty) {
      return Center(
        child: Text(
          'Abra um arquivo no explorador',
          style: theme.textTheme.muted,
        ),
      );
    }

    final active = editor.active;
    return Column(
      children: [
        _EditorTabBar(tabs: editor.tabs, activeIndex: editor.activeIndex),
        Expanded(
          child: active == null
              ? const SizedBox.shrink()
              : CodeEditorView(key: ValueKey(active.path), tab: active),
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
    final theme = ShadTheme.of(context);
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isActive = index == activeIndex;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ref.read(editorProvider.notifier).setActive(index),
            child: Container(
              padding: const EdgeInsets.only(left: 12, right: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.background
                    : const Color(0x00000000),
                border: Border(
                  bottom: BorderSide(
                    color: isActive
                        ? theme.colorScheme.primary
                        : const Color(0x00000000),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${tab.isDirty ? '• ' : ''}${tab.name}',
                    style: theme.textTheme.small,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        ref.read(editorProvider.notifier).closeTab(index),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
