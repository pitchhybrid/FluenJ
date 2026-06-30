import 'package:fluenj/core/state/editor.dart';
import 'package:fluenj/core/state/layout.dart';
import 'package:fluenj/core/state/workspace.dart';
import 'package:fluenj/ui/editor/custom/syntax_highlighter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Barra de status inferior (nome do projeto, arquivo ativo, compatibilidade)
/// + toggles de visibilidade dos painéis (explorer / terminal) + seletor de
/// language mode do arquivo ativo (estilo VS Code).
class StatusBar extends ConsumerWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final ws = ref.watch(workspaceProvider);
    final editor = ref.watch(editorProvider);
    final layout = ref.watch(layoutProvider);

    return Container(
      height: 26,
      color: theme.colorScheme.muted,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(ws.isOpen ? ws.name : 'FluenJ', style: theme.textTheme.small),
          const SizedBox(width: 16),
          if (editor.active != null)
            Expanded(
              child: Text(
                '${editor.active!.isDirty ? '• ' : ''}${editor.active!.path}',
                style: theme.textTheme.small,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),
          _PanelToggle(
            icon: layout.showSidebar
                ? LucideIcons.panelLeftOpen
                : LucideIcons.panelLeftClose,
            active: layout.showSidebar,
            onTap: () =>
                ref.read(layoutProvider.notifier).toggleSidebar(),
          ),
          const SizedBox(width: 12),
          _PanelToggle(
            icon: LucideIcons.terminal,
            active: layout.showOutput,
            onTap: () => ref.read(layoutProvider.notifier).toggleOutput(),
          ),
          const SizedBox(width: 12),
          const _LanguageModeButton(),
          const SizedBox(width: 12),
          Text('Java 1.8–24', style: theme.textTheme.small),
        ],
      ),
    );
  }
}

class _PanelToggle extends StatelessWidget {
  const _PanelToggle({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(
          icon,
          size: 15,
          color: active
              ? theme.colorScheme.primary
              : theme.colorScheme.mutedForeground,
        ),
      ),
    );
  }
}

/// Botão na status bar com o language mode do arquivo ativo. Clicar abre um
/// seletor (overlay) para trocar (override) ou voltar ao auto-detectar.
class _LanguageModeButton extends ConsumerStatefulWidget {
  const _LanguageModeButton();

  @override
  ConsumerState<_LanguageModeButton> createState() => _LanguageModeButtonState();
}

class _LanguageModeButtonState extends ConsumerState<_LanguageModeButton> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _overlay;

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  void _toggle() {
    if (_overlay != null) {
      _close();
      return;
    }
    if (ref.read(editorProvider).active == null) return;
    final entry = OverlayEntry(builder: _menu);
    _overlay = entry;
    Overlay.of(context).insert(entry);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
  }

  void _select(String? id) {
    ref.read(editorProvider.notifier).setLanguage(id);
    _close();
  }

  Widget _menu(BuildContext ctx) {
    final theme = ShadTheme.of(ctx);
    final tab = ref.read(editorProvider).active;
    final current = tab?.languageOverride; // null = auto
    final autoId = tab == null
        ? 'plaintext'
        : SyntaxHighlighter.languageFor(tab.name);
    final entries = SyntaxHighlighter.supportedLanguages.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _close,
          child: const SizedBox.expand(),
        ),
        CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 4),
          child: Container(
            width: 240,
            constraints: const BoxConstraints(maxHeight: 360),
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.colorScheme.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  child: Text(
                    'Selecionar Language Mode',
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ),
                Container(height: 1, color: theme.colorScheme.border),
                Flexible(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      _option(
                        ctx,
                        'Auto-detectar (${SyntaxHighlighter.labelFor(autoId)})',
                        current == null,
                        () => _select(null),
                      ),
                      for (final e in entries)
                        _option(
                          ctx,
                          e.value,
                          current == e.key,
                          () => _select(e.key),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _option(
    BuildContext ctx,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final theme = ShadTheme.of(ctx);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: selected ? theme.colorScheme.muted : const Color(0x00000000),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.small.copyWith(
                  color: selected
                      ? theme.colorScheme.foreground
                      : theme.colorScheme.mutedForeground,
                ),
              ),
            ),
            if (selected)
              Icon(
                LucideIcons.check,
                size: 14,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final tab = ref.watch(editorProvider).active;
    if (tab == null) return const SizedBox.shrink();
    final effective =
        tab.languageOverride ?? SyntaxHighlighter.languageFor(tab.name);
    final label = SyntaxHighlighter.labelFor(effective);
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.fileCode,
                size: 13,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(width: 4),
              Text(label, style: theme.textTheme.small),
              const SizedBox(width: 2),
              Icon(
                LucideIcons.chevronDown,
                size: 12,
                color: theme.colorScheme.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
