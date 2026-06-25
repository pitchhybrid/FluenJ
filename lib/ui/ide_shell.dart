import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';

import '../core/state/file_tree.dart';
import '../core/state/layout.dart';
import '../core/state/workspace.dart';
import 'editor/editor_area.dart';
import 'output/output_panel.dart';
import 'sidebar/sidebar.dart';
import 'widgets/status_bar.dart';
import 'welcome/welcome_screen.dart';

class _ToggleSidebarIntent extends Intent {
  const _ToggleSidebarIntent();
}

class _ToggleOutputIntent extends Intent {
  const _ToggleOutputIntent();
}

/// Layout principal da IDE: sidebar | (editor + output) com status bar embaixo.
/// Os painéis (sidebar/output) podem ser ocultados via [[layoutProvider]].
///
/// Atalhos: `Ctrl/Cmd + B` (explorer), `Ctrl/Cmd + \`` (terminal).
class IdeShell extends ConsumerWidget {
  const IdeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(workspaceProvider);
    final layout = ref.watch(layoutProvider);

    // Sincroniza a árvore de arquivos quando o workspace abre/fecha.
    ref.listen<WorkspaceState>(workspaceProvider, (previous, next) {
      final tree = ref.read(fileTreeProvider.notifier);
      if (next.isOpen && next.rootPath != previous?.rootPath) {
        tree.setRoot(next.rootPath!);
      } else if (!next.isOpen) {
        tree.clear();
      }
    });

    if (!ws.isOpen) {
      return const WelcomeScreen();
    }

    // Painel vertical: editor (+ terminal quando visível).
    final Widget vertical;
    if (layout.showOutput) {
      vertical = MultiSplitView(
        axis: Axis.vertical,
        initialAreas: [Area(flex: 1, min: 120), Area(size: 160, min: 60)],
        builder: (context, area) =>
            area.index == 0 ? const EditorArea() : const OutputPanel(),
      );
    } else {
      vertical = const EditorArea();
    }

    // Layout horizontal: sidebar (+ vertical) quando visível.
    final Widget body;
    if (layout.showSidebar) {
      body = MultiSplitView(
        initialAreas: [
          Area(size: 260, min: 200, max: 600),
          Area(flex: 1, min: 300),
        ],
        builder: (context, area) =>
            area.index == 0 ? const Sidebar() : vertical,
      );
    } else {
      body = vertical;
    }

    return Shortcuts(
      shortcuts: {
        // Ctrl/Cmd + B -> toggle explorer
        LogicalKeySet(LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.keyB):
            _ToggleSidebarIntent(),
        LogicalKeySet(LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.keyB):
            _ToggleSidebarIntent(),
        // Ctrl/Cmd + ` -> toggle terminal
        LogicalKeySet(
                LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.backquote):
            _ToggleOutputIntent(),
        LogicalKeySet(
                LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.backquote):
            _ToggleOutputIntent(),
      },
      child: Actions(
        actions: {
          _ToggleSidebarIntent: CallbackAction<_ToggleSidebarIntent>(
            onInvoke: (_) =>
                ref.read(layoutProvider.notifier).toggleSidebar(),
          ),
          _ToggleOutputIntent: CallbackAction<_ToggleOutputIntent>(
            onInvoke: (_) =>
                ref.read(layoutProvider.notifier).toggleOutput(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Column(
            children: [
              Expanded(child: body),
              const StatusBar(),
            ],
          ),
        ),
      ),
    );
  }
}
