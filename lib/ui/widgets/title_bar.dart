import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:window_manager/window_manager.dart';

/// Title bar custom (janela frameless): área arrastável + botões de janela.
class TitleBar extends StatefulWidget {
  const TitleBar({super.key});

  @override
  State<TitleBar> createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> with WindowListener {
  bool _maximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    unawaited(
      windowManager.isMaximized().then((v) {
        if (mounted) setState(() => _maximized = v);
      }),
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _maximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _maximized = false);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.braces,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text('FluenJ', style: theme.textTheme.small),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _WindowButton(
            icon: LucideIcons.minus,
            onTap: windowManager.minimize,
          ),
          _WindowButton(
            icon: _maximized ? LucideIcons.copy : LucideIcons.square,
            onTap: () => _maximized
                ? windowManager.unmaximize()
                : windowManager.maximize(),
          ),
          _WindowButton(
            icon: LucideIcons.x,
            isClose: true,
            onTap: windowManager.close,
          ),
        ],
      ),
    );
  }
}

/// Botão de janela com hover. O "fechar" fica vermelho no hover (estilo Windows).
class _WindowButton extends StatefulWidget {
  const _WindowButton({
    required this.icon,
    required this.onTap,
    this.isClose = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isClose;

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          width: 46,
          height: 32,
          color: _hover
              ? (widget.isClose
                  ? const Color(0xFFC42B1C)
                  : theme.colorScheme.muted)
              : const Color(0x00000000),
          child: Icon(
            widget.icon,
            size: 15,
            color: _hover && widget.isClose
                ? const Color(0xFFFFFFFF)
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}
