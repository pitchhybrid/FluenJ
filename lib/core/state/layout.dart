import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de visibilidade dos painéis da IDE.
class LayoutState {
  const LayoutState({this.showSidebar = true, this.showOutput = true});

  final bool showSidebar;
  final bool showOutput;

  LayoutState copyWith({bool? showSidebar, bool? showOutput}) => LayoutState(
        showSidebar: showSidebar ?? this.showSidebar,
        showOutput: showOutput ?? this.showOutput,
      );
}

/// Controla mostrar/ocultar a sidebar (explorer) e o painel de output (terminal).
class LayoutNotifier extends Notifier<LayoutState> {
  @override
  LayoutState build() => const LayoutState();

  void toggleSidebar() =>
      state = state.copyWith(showSidebar: !state.showSidebar);

  void toggleOutput() => state = state.copyWith(showOutput: !state.showOutput);
}

/// Provider de visibilidade dos painéis.
final layoutProvider =
    NotifierProvider<LayoutNotifier, LayoutState>(LayoutNotifier.new);
