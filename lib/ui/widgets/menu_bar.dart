import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/state/editor.dart';
import '../../core/state/layout.dart';
import '../../core/state/workspace.dart';

/// Barra de menus (File / View / Help) — toggable via Alt (ver IdeShell).
class IdeMenuBar extends ConsumerWidget {
  const IdeMenuBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final layout = ref.watch(layoutProvider);

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ShadMenubar(
          backgroundColor: theme.colorScheme.background,
          border: ShadBorder.all(color: const Color(0x00000000)),
          padding: EdgeInsets.zero,
          items: [
            ShadMenubarItem(
              items: [
                ShadContextMenuItem(
                  onPressed: () =>
                      ref.read(workspaceProvider.notifier).openFolderPicker(),
                  child: const Text('Open Folder…'),
                ),
                ShadContextMenuItem(
                  onPressed: () => ref.read(editorProvider.notifier).saveActive(),
                  child: const Text('Save'),
                ),
              ],
              child: const Text('File'),
            ),
            ShadMenubarItem(
              items: [
                ShadContextMenuItem(
                  onPressed: () =>
                      ref.read(layoutProvider.notifier).toggleSidebar(),
                  child: Text(layout.showSidebar
                      ? 'Hide Explorer  (Ctrl+B)'
                      : 'Show Explorer  (Ctrl+B)'),
                ),
                ShadContextMenuItem(
                  onPressed: () =>
                      ref.read(layoutProvider.notifier).toggleOutput(),
                  child: Text(layout.showOutput
                      ? 'Hide Terminal  (Ctrl+`)'
                      : 'Show Terminal  (Ctrl+`)'),
                ),
                ShadContextMenuItem(
                  onPressed: () =>
                      ref.read(layoutProvider.notifier).toggleMenuBar(),
                  child: Text(layout.showMenuBar
                      ? 'Hide Menu Bar  (Alt)'
                      : 'Show Menu Bar  (Alt)'),
                ),
              ],
              child: const Text('View'),
            ),
            ShadMenubarItem(
              items: [
                ShadContextMenuItem(
                  onPressed: () {},
                  child: const Text('About FluenJ'),
                ),
              ],
              child: const Text('Help'),
            ),
          ],
        ),
      ),
    );
  }
}
