import 'package:fluenj/core/services/file_system_service.dart';
import 'package:fluenj/ui/editor/custom/code_editor_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

/// Uma aba do editor: caminho + controller de edição + flag de "modificado".
class EditorTab {
  EditorTab({
    required this.path,
    required this.name,
    required this.controller,
  });

  final String path;
  final String name;
  final CodeEditorController controller;

  /// Indica alterações não salvas (refletido no título da aba com "•").
  bool isDirty = false;

  /// Override do language mode (null = auto-detectar por extensão).
  String? languageOverride;

  void dispose() => controller.dispose();
}

/// Estado das abas do editor.
class EditorState {
  const EditorState({this.tabs = const [], this.activeIndex = -1});

  final List<EditorTab> tabs;
  final int activeIndex;

  bool get isEmpty => tabs.isEmpty;
  EditorTab? get active =>
      activeIndex >= 0 && activeIndex < tabs.length ? tabs[activeIndex] : null;
}

/// Gerencia as abas abertas: abrir/fechar/ativar e salvar arquivos.
///
/// Detecção de "dirty" é eficiente: notifica o estado somente na transição
/// limpo→sujo (e ao salvar), evitando rebuild a cada tecla.
class EditorNotifier extends Notifier<EditorState> {
  @override
  EditorState build() => const EditorState();

  FileSystemService get _fs => ref.read(fileSystemProvider);

  /// Abre um arquivo numa aba (ou ativa a aba existente para o mesmo caminho).
  Future<void> openFile(String path) async {
    final existing = state.tabs.indexWhere((t) => t.path == path);
    if (existing != -1) {
      _emit(activeIndex: existing);
      return;
    }

    final content = await _fs.readText(path);
    final controller = CodeEditorController(text: content);
    final tab = EditorTab(
      path: path,
      name: p.basename(path),
      controller: controller,
    );
    tab.controller.addListener(() => _onChanged(tab));

    final tabs = [...state.tabs, tab];
    _emit(tabs: tabs, activeIndex: tabs.length - 1);
  }

  void setActive(int index) => _emit(activeIndex: index);

  void closeTab(int index) {
    if (index < 0 || index >= state.tabs.length) return;
    final tab = state.tabs[index];
    // TODO(Fase 1.x): confirmar descarte se houver alterações não salvas.
    tab.dispose();

    final tabs = [...state.tabs]..removeAt(index);
    var active = state.activeIndex;
    if (active >= tabs.length) active = tabs.length - 1;
    _emit(tabs: tabs, activeIndex: active);
  }

  /// Salva o conteúdo da aba ativa no disco e limpa o "dirty".
  Future<void> saveActive() async {
    final tab = state.active;
    if (tab == null) return;
    await _fs.writeText(tab.path, tab.controller.text);
    if (tab.isDirty) {
      tab.isDirty = false;
      _emit();
    }
  }

  Future<void> saveTab(EditorTab tab) async {
    await _fs.writeText(tab.path, tab.controller.text);
    if (tab.isDirty) {
      tab.isDirty = false;
      _emit();
    }
  }

  /// Troca o language mode da aba ativa (null = auto-detectar por extensão).
  void setLanguage(String? languageId) {
    final tab = state.active;
    if (tab == null) return;
    tab.languageOverride = languageId;
    _emit();
  }

  void _onChanged(EditorTab tab) {
    // Só notifica na transição limpo→sujo (evita rebuild por tecla).
    if (!tab.isDirty) {
      tab.isDirty = true;
      _emit();
    }
  }

  void _emit({List<EditorTab>? tabs, int? activeIndex}) {
    state = EditorState(
      tabs: tabs ?? state.tabs,
      activeIndex: activeIndex ?? state.activeIndex,
    );
  }
}

/// Provider das abas do editor.
final editorProvider =
    NotifierProvider<EditorNotifier, EditorState>(EditorNotifier.new);
