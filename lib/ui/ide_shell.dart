import 'package:fluenj/core/state/file_tree.dart';
import 'package:fluenj/core/state/layout.dart';
import 'package:fluenj/core/state/package_tree.dart';
import 'package:fluenj/core/state/workspace.dart';
import 'package:fluenj/ui/editor/editor_area.dart';
import 'package:fluenj/ui/output/output_panel.dart';
import 'package:fluenj/ui/sidebar/sidebar.dart';
import 'package:fluenj/ui/welcome/welcome_screen.dart';
import 'package:fluenj/ui/widgets/menu_bar.dart';
import 'package:fluenj/ui/widgets/status_bar.dart';
import 'package:fluenj/ui/widgets/title_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';

class _ToggleSidebarIntent extends Intent {
  const _ToggleSidebarIntent();
}

class _ToggleOutputIntent extends Intent {
  const _ToggleOutputIntent();
}

/// Layout principal da IDE: title bar + (menu bar) + sidebar | (editor +
/// output) com status bar. Painéis togglables (layoutProvider).
/// Atalhos: Ctrl/Cmd+B (explorer), Ctrl/Cmd+` (terminal), Alt (menu bar).
class IdeShell extends ConsumerWidget {
  const IdeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(workspaceProvider);
    final layout = ref.watch(layoutProvider);

    // Sincroniza as árvores (file + package) quando o workspace abre/fecha.
    ref.listen<WorkspaceState>(workspaceProvider, (previous, next) async {
      final tree = ref.read(fileTreeProvider.notifier);
      final pkg = ref.read(packageTreeProvider.notifier);
      if (next.isOpen && next.rootPath != previous?.rootPath) {
        tree.setRoot(next.rootPath!);
        await pkg.setRoot(next.rootPath!);
      } else if (!next.isOpen) {
        tree.clear();
        pkg.clear();
      }
    });

    final Widget content;
    if (!ws.isOpen) {
      content = const WelcomeScreen();
    } else {
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

      content = Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.keyB):
              const _ToggleSidebarIntent(),
          LogicalKeySet(LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.keyB):
              const _ToggleSidebarIntent(),
          LogicalKeySet(LogicalKeyboardKey.controlLeft,
                  LogicalKeyboardKey.backquote):
              const _ToggleOutputIntent(),
          LogicalKeySet(LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.backquote):
              const _ToggleOutputIntent(),
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

    return _GlobalShortcuts(
      child: Column(
        children: [
          const TitleBar(),
          if (layout.showMenuBar) const IdeMenuBar(),
          Expanded(child: content),
        ],
      ),
    );
  }
}

/// Captura Alt-sozinho globalmente (independente do foco) para toggle da barra
/// de menus — estilo Zed. Alt combinado com outra tecla é ignorado.
class _GlobalShortcuts extends ConsumerStatefulWidget {
  const _GlobalShortcuts({required this.child});

  final Widget child;

  @override
  ConsumerState<_GlobalShortcuts> createState() => _GlobalShortcutsState();
}

class _GlobalShortcutsState extends ConsumerState<_GlobalShortcuts> {
  late final bool Function(KeyEvent) _handler;

  @override
  void initState() {
    super.initState();
    _handler = (event) {
      if (event is! KeyDownEvent) return false;
      final isAlt = event.logicalKey == LogicalKeyboardKey.altLeft ||
          event.logicalKey == LogicalKeyboardKey.altRight;
      if (!isAlt) return false;
      final pressed = HardwareKeyboard.instance.logicalKeysPressed;
      if (pressed.length == 1) {
        ref.read(layoutProvider.notifier).toggleMenuBar();
        return true;
      }
      return false;
    };
    HardwareKeyboard.instance.addHandler(_handler);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
