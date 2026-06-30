import 'package:flutter/widgets.dart';

/// Controller do editor próprio (CustomPaint-based). [ChangeNotifier] que
/// guarda o texto, a seleção e o histórico de undo/redo.
///
/// Cumpre o contrato esperado por `EditorTab` (`.text`, `addListener`,
/// `dispose`) e pelo painter/widget (`.selection`, edição, undo/redo).
///
/// Ver [[adr-0008-editor-proprio]] (no vault `.context/decisoes/`).
class CodeEditorController extends ChangeNotifier {
  CodeEditorController({required String text})
      : _text = text,
        _selection = TextSelection.collapsed(offset: text.length) {
    _pushHistory();
  }

  String _text;
  TextSelection _selection;

  final List<_Snapshot> _undo = [];
  final List<_Snapshot> _redo = [];
  static const int _maxHistory = 500;

  String get text => _text;
  TextSelection get selection => _selection;

  set selection(TextSelection value) {
    _selection = value;
    notifyListeners();
  }

  /// Replaces the whole text (e.g. on reload). Resets history.
  void setText(String text) {
    _text = text;
    _selection = TextSelection.collapsed(offset: text.length);
    _undo.clear();
    _redo.clear();
    _pushHistory();
    notifyListeners();
  }

  void _pushHistory() {
    _undo.add(_Snapshot(_text, _selection));
    if (_undo.length > _maxHistory) _undo.removeAt(0);
    _redo.clear();
  }

  /// Replaces the current selection with [replacement], collapsing the
  /// caret to its end. Records an undo entry.
  void replaceSelection(String replacement) {
    _pushHistory();
    final start = _selection.start.clamp(0, _text.length);
    final end = _selection.end.clamp(0, _text.length);
    _text = _text.replaceRange(start, end, replacement);
    final caret = start + replacement.length;
    _selection = TextSelection.collapsed(offset: caret);
    notifyListeners();
  }

  /// Convenience for inserting a chunk at the caret.
  void insert(String text) => replaceSelection(text);

  /// Deletes the selection, or the previous code unit if collapsed.
  void deleteBackward() {
    if (_selection.start != _selection.end) {
      replaceSelection('');
      return;
    }
    final offset = _selection.extentOffset;
    if (offset <= 0) return;
    _pushHistory();
    final prev = offset - 1; // UTF-16 code unit; OK p/ MVP.
    _text = _text.substring(0, prev) + _text.substring(offset);
    _selection = TextSelection.collapsed(offset: prev);
    notifyListeners();
  }

  /// Deletes the selection, or the next code unit if collapsed.
  void deleteForward() {
    if (_selection.start != _selection.end) {
      replaceSelection('');
      return;
    }
    final offset = _selection.extentOffset;
    if (offset >= _text.length) return;
    _pushHistory();
    _text = _text.substring(0, offset) + _text.substring(offset + 1);
    _selection = TextSelection.collapsed(offset: offset);
    notifyListeners();
  }

  void undo() {
    if (_undo.length <= 1) return;
    _redo.add(_undo.removeLast());
    _apply(_undo.last);
  }

  void redo() {
    if (_redo.isEmpty) return;
    final snap = _redo.removeLast();
    _undo.add(snap);
    _apply(snap);
  }

  void _apply(_Snapshot snap) {
    _text = snap.text;
    _selection = snap.selection;
    notifyListeners();
  }

  /// Moves the caret by [delta] code units. With [extend] the selection grows.
  void moveHorizontal(int delta, {required bool extend}) {
    final base = extend ? _selection.baseOffset : null;
    final extent = (_selection.extentOffset + delta).clamp(0, _text.length);
    _selection = base == null
        ? TextSelection.collapsed(offset: extent)
        : TextSelection(baseOffset: base, extentOffset: extent);
    notifyListeners();
  }

  /// Selects the whole document.
  void selectAll() {
    _selection = TextSelection(
      baseOffset: 0,
      extentOffset: _text.length,
    );
    notifyListeners();
  }
}

class _Snapshot {
  const _Snapshot(this.text, this.selection);
  final String text;
  final TextSelection selection;
}
