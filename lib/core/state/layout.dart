import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de visibilidade dos painéis da IDE.
class LayoutState {
  const LayoutState({
    this.showSidebar = true,
    this.showOutput = false, // terminal inicia minimizado
    this.showMenuBar = true,
  });

  final bool showSidebar;
  final bool showOutput;
  final bool showMenuBar;

  LayoutState copyWith({
    bool? showSidebar,
    bool? showOutput,
    bool? showMenuBar,
  }) =>
      LayoutState(
        showSidebar: showSidebar ?? this.showSidebar,
        showOutput: showOutput ?? this.showOutput,
        showMenuBar: showMenuBar ?? this.showMenuBar,
      );
}

/// Controla mostrar/ocultar a sidebar (explorer), o painel de output (terminal)
/// e a barra de menus.
class LayoutNotifier extends Notifier<LayoutState> {
  @override
  LayoutState build() => const LayoutState();

  void toggleSidebar() =>
      state = state.copyWith(showSidebar: !state.showSidebar);

  void toggleOutput() => state = state.copyWith(showOutput: !state.showOutput);

  void toggleMenuBar() => state = state.copyWith(showMenuBar: !state.showMenuBar);
}

/// Provider de visibilidade dos painéis.
final layoutProvider =
    NotifierProvider<LayoutNotifier, LayoutState>(LayoutNotifier.new);
