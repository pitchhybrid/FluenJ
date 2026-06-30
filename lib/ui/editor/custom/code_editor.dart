import 'dart:async';
import 'dart:math' as math;

import 'package:fluenj/ui/editor/custom/code_editor_controller.dart';
import 'package:fluenj/ui/editor/custom/code_editor_painter.dart';
import 'package:fluenj/ui/editor/custom/code_runs.dart';
import 'package:fluenj/ui/editor/custom/syntax_highlighter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Editor de código próprio (CustomPaint-based), sem pacotes de editor de
/// terceiros. **Virtualizado** + aparência estilo VS Code (indent guides,
/// destaque da linha atual, padding, fonte monospace). Highlight (parse
/// `re_highlight`, `O(n)`) é **síncrono** (sem flicker). Ver [[adr-0008-editor-proprio]].
class CodeEditor extends StatefulWidget {
  const CodeEditor({
    required this.controller,
    required this.language,
    super.key,
  });

  final CodeEditorController controller;
  final String language;

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  double _fontSize = 13;
  double get _lineHeight => _fontSize * 1.46;
  static const double _gutterWidth = 56;
  static const double _codePadding = 12;

  late final FocusNode _focus;
  late final bool Function(KeyEvent) _globalKeyHandler;
  Offset _scroll = Offset.zero;
  double _viewportW = 0;
  double _viewportH = 0;

  // Modelo de linhas + spans.
  TextStyle? _base;
  double _charWidth = 8;
  int _indentSize = 2;
  List<String> _lines = const [];
  List<int> _lineStarts = const [0];
  List<TextSpan> _plainSpans = const [];
  List<TextSpan> _hlSpans = const [];

  CodeEditorController get _c => widget.controller;
  double get _codeOrigin => _gutterWidth + _codePadding;
  List<TextSpan> get _spans => _hlSpans.isNotEmpty ? _hlSpans : _plainSpans;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _c.addListener(_onChanged);
    // Zoom (Ctrl+= / Ctrl+-) é tratado globalmente (não depende do primary
    // focus, que costuma ficar no IdeShell). Só o editor ativo está montado.
    _globalKeyHandler = (event) {
      if (event is! KeyDownEvent) return false;
      if (!HardwareKeyboard.instance.isControlPressed) return false;
      final lk = event.logicalKey;
      if (lk == LogicalKeyboardKey.equal ||
          lk == LogicalKeyboardKey.add ||
          lk == LogicalKeyboardKey.numpadAdd) {
        _zoom(1);
        return true;
      }
      if (lk == LogicalKeyboardKey.minus ||
          lk == LogicalKeyboardKey.numpadSubtract) {
        _zoom(-1);
        return true;
      }
      return false;
    };
    HardwareKeyboard.instance.addHandler(_globalKeyHandler);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_globalKeyHandler);
    _c.removeListener(_onChanged);
    _focus.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) {
      _refreshHighlight();
      setState(() {});
    }
  }

  void _onChanged() {
    if (!mounted) return;
    _rebuildPlain();
    _refreshHighlight();
    setState(() {});
  }

  /// Sincroniza [_base]/[_charWidth] e, se mudaram (primeira vez ou tema),
  /// reconstrói plain + highlight (síncrono). Chamado no build (sem setState).
  void _syncBase(TextStyle base) {
    if (_base == base) return;
    _base = base;
    final tp = TextPainter(
      text: TextSpan(text: 'M', style: base),
      textDirection: TextDirection.ltr,
    )..layout();
    _charWidth = tp.width;
    tp.dispose();
    _rebuildPlain();
    _refreshHighlight();
  }

  void _rebuildPlain() {
    final base = _base;
    if (base == null) return;
    _lines = _c.text.split('\n');
    _lineStarts = _computeLineStarts();
    _indentSize = _detectIndent();
    _plainSpans = [
      for (final l in _lines) TextSpan(text: l, style: base),
    ];
  }

  List<int> _computeLineStarts() {
    final starts = List<int>.filled(_lines.length, 0);
    var pos = 0;
    for (var i = 0; i < _lines.length; i++) {
      starts[i] = pos;
      pos += _lines[i].length + 1; // +1 para o '\n'
    }
    return starts;
  }

  /// Detecta o passo de indentação do arquivo (gcd dos leading spaces),
  /// estilo "editor.detectIndentation" do VS Code. Default 2.
  int _detectIndent() {
    var g = 0;
    for (final l in _lines) {
      final ls = _leadingSpaces(l);
      if (ls > 0) {
        g = g == 0 ? ls : _gcd(g, ls);
        if (g == 1) return 2;
      }
    }
    if (g >= 2 && g <= 8) return g;
    return 2;
  }

  int _gcd(int a, int b) {
    var x = a;
    var y = b;
    while (y != 0) {
      final t = x % y;
      x = y;
      y = t;
    }
    return x;
  }

  int _leadingSpaces(String s) {
    var n = 0;
    for (final ch in s.codeUnits) {
      if (ch == 0x20) {
        n++;
      } else {
        break;
      }
    }
    return n;
  }

  void _refreshHighlight() {
    final base = _base;
    if (base == null || _lines.isEmpty) return;
    final dark = ShadTheme.of(context).brightness == Brightness.dark;
    final span = SyntaxHighlighter.instance.highlight(
      _c.text,
      widget.language,
      base: base,
      dark: dark,
    );
    final runs = flattenRuns(span);
    _hlSpans = [
      for (var i = 0; i < _lines.length; i++)
        lineSpanFromRuns(
          runs,
          _lineStarts[i],
          _lineStarts[i] + _lines[i].length,
          _lines[i],
          base,
        ),
    ];
  }

  double _maxScrollX() {
    final maxChars = _lines.fold<int>(0, (m, l) => l.length > m ? l.length : m);
    final content = math.max(maxChars * _charWidth, 0.0);
    final codeW = math.max(_viewportW - _codeOrigin, 0.0);
    return math.max(0.0, content - codeW);
  }

  double _maxScrollY() => math.max(0.0, _lines.length * _lineHeight - _viewportH);

  void _clampScroll() {
    _scroll = Offset(
      _scroll.dx.clamp(0.0, _maxScrollX()),
      _scroll.dy.clamp(0.0, _maxScrollY()),
    );
  }

  // ----- Hit-testing e caret (O(1): só laiauta a linha envolvida) -----

  TextPainter _layoutLine(int i) {
    final tp = TextPainter(
      text: i < _spans.length ? _spans[i] : const TextSpan(text: ''),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp;
  }

  int _lineIndexOf(int offset) {
    var lo = 0;
    var hi = _lineStarts.length - 1;
    var res = 0;
    while (lo <= hi) {
      final mid = (lo + hi) ~/ 2;
      if (_lineStarts[mid] <= offset) {
        res = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return res;
  }

  int? _offsetAt(Offset local) {
    if (_lines.isEmpty) return null;
    final line = ((local.dy + _scroll.dy) / _lineHeight).floor().clamp(
      0,
      _lines.length - 1,
    );
    final ls = _lineStarts[line];
    if (local.dx <= _gutterWidth) return ls;
    final tp = _layoutLine(line);
    final rel = local.dx - _codeOrigin + _scroll.dx;
    final col = tp.getPositionForOffset(Offset(rel, 0)).offset;
    tp.dispose();
    return (ls + col).clamp(0, _c.text.length);
  }

  void _moveVertical(int dir, {required bool extend}) {
    final line = _lineIndexOf(_c.selection.extentOffset);
    final target = (line + dir).clamp(0, _lines.length - 1);
    final colLocal = _c.selection.extentOffset - _lineStarts[line];
    final tpCur = _layoutLine(line);
    final x = tpCur.getOffsetForCaret(TextPosition(offset: colLocal), Rect.zero).dx;
    tpCur.dispose();
    final tpTgt = _layoutLine(target);
    final newCol = tpTgt.getPositionForOffset(Offset(x, 0)).offset;
    tpTgt.dispose();
    final pos = _lineStarts[target] + newCol;
    _c.selection = extend
        ? TextSelection(baseOffset: _c.selection.baseOffset, extentOffset: pos)
        : TextSelection.collapsed(offset: pos);
  }

  void _ensureCursorVisible() {
    final line = _lineIndexOf(_c.selection.extentOffset);
    final top = line * _lineHeight;
    var dx = _scroll.dx;
    var dy = _scroll.dy;
    if (top < _scroll.dy) {
      dy = top;
    } else if (top + _lineHeight > _scroll.dy + _viewportH) {
      dy = top + _lineHeight - _viewportH;
    }
    final colLocal = _c.selection.extentOffset - _lineStarts[line];
    final tp = _layoutLine(line);
    final cx = tp.getOffsetForCaret(TextPosition(offset: colLocal), Rect.zero).dx;
    tp.dispose();
    // cx é relativo ao início do texto da linha; posição no viewport:
    final viewX = _codeOrigin + cx - _scroll.dx;
    if (viewX < _codeOrigin) {
      dx = cx;
    } else if (viewX > _viewportW) {
      dx = cx - (_viewportW - _codeOrigin);
    }
    _scroll = Offset(math.max(0.0, dx), math.max(0.0, dy));
    _clampScroll();
  }

  Future<void> _copy() async {
    final s = _c.selection;
    if (s.start == s.end) return;
    await Clipboard.setData(
      ClipboardData(text: _c.text.substring(s.start, s.end)),
    );
  }

  Future<void> _paste() async {
    final d = await Clipboard.getData('text/plain');
    if (d?.text != null) _c.insert(d!.text!);
  }

  Future<void> _cut() async {
    final s = _c.selection;
    if (s.start == s.end) return;
    await Clipboard.setData(
      ClipboardData(text: _c.text.substring(s.start, s.end)),
    );
    _c.replaceSelection('');
  }

  /// Zoom do editor (Ctrl+= aumenta, Ctrl+- diminui). Faixa 8–32 px.
  void _zoom(int dir) {
    if (!mounted) return;
    final next = (_fontSize + dir).clamp(8.0, 32.0);
    if (next == _fontSize) return;
    _fontSize = next;
    setState(() {});
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final lk = event.logicalKey;
    final ctrl = HardwareKeyboard.instance.isControlPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final ch = event.character;

    if (lk == LogicalKeyboardKey.backspace) {
      _c.deleteBackward();
    } else if (lk == LogicalKeyboardKey.delete) {
      _c.deleteForward();
    } else if (lk == LogicalKeyboardKey.enter ||
        lk == LogicalKeyboardKey.numpadEnter) {
      _c.insert('\n');
    } else if (lk == LogicalKeyboardKey.tab) {
      _c.insert(' ' * _indentSize);
    } else if (lk == LogicalKeyboardKey.arrowLeft) {
      _c.moveHorizontal(-1, extend: shift);
    } else if (lk == LogicalKeyboardKey.arrowRight) {
      _c.moveHorizontal(1, extend: shift);
    } else if (lk == LogicalKeyboardKey.arrowUp) {
      _moveVertical(-1, extend: shift);
    } else if (lk == LogicalKeyboardKey.arrowDown) {
      _moveVertical(1, extend: shift);
    } else if (lk == LogicalKeyboardKey.home) {
      final line = _lineIndexOf(_c.selection.extentOffset);
      _c.selection = TextSelection.collapsed(offset: _lineStarts[line]);
    } else if (lk == LogicalKeyboardKey.end) {
      final line = _lineIndexOf(_c.selection.extentOffset);
      _c.selection = TextSelection.collapsed(
        offset: _lineStarts[line] + _lines[line].length,
      );
    } else if (ctrl) {
      if (lk == LogicalKeyboardKey.keyC) {
        unawaited(_copy());
      } else if (lk == LogicalKeyboardKey.keyV) {
        unawaited(_paste());
      } else if (lk == LogicalKeyboardKey.keyX) {
        unawaited(_cut());
      } else if (lk == LogicalKeyboardKey.keyA) {
        _c.selectAll();
      } else if (lk == LogicalKeyboardKey.keyZ) {
        shift ? _c.redo() : _c.undo();
      } else if (lk == LogicalKeyboardKey.keyY) {
        _c.redo();
      } else {
        return KeyEventResult.ignored;
      }
    } else if (ch != null &&
        ch.isNotEmpty &&
        ch != '\n' &&
        ch.codeUnitAt(0) >= 0x20) {
      _c.insert(ch);
    } else {
      return KeyEventResult.ignored;
    }
    _ensureCursorVisible();
    return KeyEventResult.handled;
  }

  void _onPointerDown(PointerDownEvent e) {
    _focus.requestFocus();
    final off = _offsetAt(e.localPosition);
    if (off == null) return;
    _c.selection = HardwareKeyboard.instance.isShiftPressed
        ? TextSelection(
            baseOffset: _c.selection.baseOffset,
            extentOffset: off,
          )
        : TextSelection.collapsed(offset: off);
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (e.buttons & kPrimaryButton == 0) return;
    final off = _offsetAt(e.localPosition);
    if (off == null) return;
    _c.selection = TextSelection(
      baseOffset: _c.selection.baseOffset,
      extentOffset: off,
    );
  }

  void _onPointerSignal(PointerSignalEvent e) {
    if (e is PointerScrollEvent) {
      setState(() {
        _scroll = Offset(
          (_scroll.dx + e.scrollDelta.dx).clamp(0.0, _maxScrollX()),
          (_scroll.dy + e.scrollDelta.dy).clamp(0.0, _maxScrollY()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final base = TextStyle(
      fontFamily: 'Consolas',
      fontFamilyFallback: const ['Monaco', 'Menlo', 'Courier New'],
      fontSize: _fontSize,
      height: _lineHeight / _fontSize,
      color: theme.colorScheme.foreground,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        _syncBase(base);
        _viewportW = constraints.maxWidth;
        _viewportH = constraints.maxHeight;
        _clampScroll();
        final currentLine =
            _focus.hasFocus ? _lineIndexOf(_c.selection.extentOffset) : -1;
        return RepaintBoundary(
          child: Focus(
            focusNode: _focus,
            onKeyEvent: _onKey,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerSignal: _onPointerSignal,
              child: CustomPaint(
                painter: CodeEditorPainter(
                  lineSpans: _spans,
                  lines: _lines,
                  lineStarts: _lineStarts,
                  selection: _c.selection,
                  scroll: _scroll,
                  gutterWidth: _gutterWidth,
                  codePadding: _codePadding,
                  fontSize: _fontSize,
                  lineHeight: _lineHeight,
                  charWidth: _charWidth,
                  indentSize: _indentSize,
                  focused: _focus.hasFocus,
                  currentLine: currentLine,
                  backgroundColor: theme.colorScheme.background,
                  gutterColor: theme.colorScheme.card,
                  lineNumberColor: theme.colorScheme.mutedForeground,
                  activeLineNumberColor: theme.colorScheme.foreground,
                  selectionColor:
                      theme.colorScheme.primary.withValues(alpha: 0.25),
                  cursorColor: theme.colorScheme.foreground,
                  dividerColor: theme.colorScheme.border,
                  indentGuideColor: theme.colorScheme.border
                      .withValues(alpha: 0.5),
                  currentLineColor:
                      theme.colorScheme.muted.withValues(alpha: 0.35),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        );
      },
    );
  }
}
