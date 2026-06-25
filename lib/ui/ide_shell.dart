import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';

import '../core/state/file_tree.dart';
import '../core/state/workspace.dart';
import 'editor/editor_area.dart';
import 'output/output_panel.dart';
import 'sidebar/sidebar.dart';
import 'widgets/status_bar.dart';
import 'welcome/welcome_screen.dart';

/// Layout principal da IDE: sidebar | (editor + output) com status bar embaixo.
class IdeShell extends ConsumerWidget {
  const IdeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(workspaceProvider);

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

    return Column(
      children: [
        Expanded(
          child: MultiSplitView(
            initialAreas: [Area(flex: 1, min: 180), Area(flex: 4)],
            builder: (context, area) {
              switch (area.index) {
                case 0:
                  return const Sidebar();
                default:
                  return MultiSplitView(
                    axis: Axis.vertical,
                    initialAreas: [
                      Area(flex: 4, min: 120),
                      Area(flex: 1, min: 60),
                    ],
                    builder: (context, area) {
                      switch (area.index) {
                        case 0:
                          return const EditorArea();
                        default:
                          return const OutputPanel();
                      }
                    },
                  );
              }
            },
          ),
        ),
        const StatusBar(),
      ],
    );
  }
}
