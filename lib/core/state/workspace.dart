import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

/// Estado do "workspace" (a pasta de projeto aberta na IDE).
class WorkspaceState {
  const WorkspaceState({this.rootPath, this.name = ''});

  factory WorkspaceState.closed() => const WorkspaceState();

  /// Caminho absoluto da pasta do projeto, ou `null` se nenhuma está aberta.
  final String? rootPath;

  /// Nome de exibição (último segmento do caminho).
  final String name;

  bool get isOpen => rootPath != null;
}

/// Gerencia a pasta de projeto aberta.
///
/// Usa o `file_picker` para escolher uma pasta no desktop.
class WorkspaceNotifier extends Notifier<WorkspaceState> {
  @override
  WorkspaceState build() => WorkspaceState.closed();

  /// Abre o seletor de pasta nativo; se o usuário confirmar, define o workspace.
  Future<void> openFolderPicker() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Abrir pasta do projeto',
    );
    if (result == null) return;
    state = WorkspaceState(rootPath: result, name: p.basename(result));
  }

  void close() => state = WorkspaceState.closed();
}

/// Provider do workspace atual.
final workspaceProvider =
    NotifierProvider<WorkspaceNotifier, WorkspaceState>(WorkspaceNotifier.new);
