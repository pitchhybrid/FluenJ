import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Pinta o editor próprio com **virtualização** (só linhas visíveis) e aparência
/// estilo VS Code: indent guides, destaque da linha atual, padding do código,
/// gutter de numeração. Custo de paint é `O(visíveis)`.
class CodeEditorPainter extends CustomPainter {
  CodeEditorPainter({
    required this.lineSpans,
    required this.lines,
    required this.lineStarts,
    required this.selection,
    required this.scroll,
    required this.gutterWidth,
    required this.codePadding,
    required this.fontSize,
    required this.lineHeight,
    required this.charWidth,
    required this.indentSize,
    required this.focused,
    required this.currentLine,
    required this.backgroundColor,
    required this.gutterColor,
    required this.lineNumberColor,
    required this.activeLineNumberColor,
    required this.selectionColor,
    required this.cursorColor,
    required this.dividerColor,
    required this.indentGuideColor,
    required this.currentLineColor,
  });

  final List<TextSpan> lineSpans;
  final List<String> lines;
  final List<int> lineStarts;
  final TextSelection selection;
  final Offset scroll;
  final double gutterWidth;
  final double codePadding;
  final double fontSize;
  final double lineHeight;
  final double charWidth;
  final int indentSize;
  final bool focused;
  final int currentLine;
  final Color backgroundColor;
  final Color gutterColor;
  final Color lineNumberColor;
  final Color activeLineNumberColor;
  final Color selectionColor;
  final Color cursorColor;
  final Color dividerColor;
  final Color indentGuideColor;
  final Color currentLineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final codeWidth = math.max(size.width - gutterWidth, 0.0);
    final codeOrigin = gutterWidth + codePadding;

    canvas.drawColor(backgroundColor, BlendMode.src);
    canvas.drawRect(
      Offset.zero & Size(gutterWidth, size.height),
      Paint()..color = gutterColor,
    );

    final lineStyle = TextStyle(
      color: lineNumberColor,
      fontSize: fontSize,
      fontFamily: 'Consolas',
      fontFamilyFallback: const ['Monaco', 'Menlo', 'Courier New'],
    );

    final first = math.max(0, (scroll.dy / lineHeight).floor());
    final last = math.min(
      lineSpans.length - 1,
      ((scroll.dy + size.height) / lineHeight).floor(),
    );

    for (var i = first; i <= last; i++) {
      final top = i * lineHeight - scroll.dy;
      final ls = i < lineStarts.length ? lineStarts[i] : 0;
      final lineText = i < lines.length ? lines[i] : '';
      final le = ls + lineText.length;

      // Destaque da linha atual (estilo VS Code).
      if (i == currentLine) {
        canvas.drawRect(
          Rect.fromLTWH(gutterWidth, top, size.width - gutterWidth, lineHeight),
          Paint()..color = currentLineColor,
        );
      }

      // Indent guides (linhas verticais por nível de indentação).
      final leading = _leadingSpaces(lineText);
      final levels = indentSize > 0 ? leading ~/ indentSize : 0;
      final guidePaint = Paint()
        ..color = indentGuideColor
        ..strokeWidth = 1;
      for (var k = 1; k <= levels; k++) {
        final gx = (codeOrigin + k * indentSize * charWidth - scroll.dx)
                .roundToDouble() +
            0.5;
        canvas.drawLine(
          Offset(gx, top),
          Offset(gx, top + lineHeight),
          guidePaint,
        );
      }

      // Texto da linha.
      final tp = TextPainter(
        text: lineSpans[i],
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
      )..layout();

      // Número de linha no gutter.
      final np = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: i == currentLine
              ? lineStyle.copyWith(color: activeLineNumberColor)
              : lineStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      np.paint(
        canvas,
        Offset(
          gutterWidth - 12 - np.width,
          top + (lineHeight - np.height) / 2,
        ),
      );
      np.dispose();

      // Seleção (parte que intersecta esta linha).
      if (selection.start != selection.end) {
        final selStart = math.max(selection.start, ls);
        final selEnd = math.min(selection.end, le);
        if (selStart < selEnd) {
          final xStart = tp
              .getOffsetForCaret(TextPosition(offset: selStart - ls), Rect.zero)
              .dx;
          final reachesEnd = selection.end > le;
          final xEnd = reachesEnd
              ? tp.width
              : tp.getOffsetForCaret(
                  TextPosition(offset: selEnd - ls),
                  Rect.zero,
                ).dx;
          canvas.drawRect(
            Rect.fromLTWH(
              codeOrigin + xStart - scroll.dx,
              top,
              (xEnd - xStart).clamp(0.0, codeWidth),
              lineHeight,
            ),
            Paint()..color = selectionColor,
          );
        }
      }

      // Texto (clip na área de código).
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(gutterWidth, 0, codeWidth, size.height),
      );
      tp.paint(canvas, Offset(codeOrigin - scroll.dx, top));
      canvas.restore();

      // Cursor (colapsado) se estiver nesta linha.
      if (focused &&
          selection.isCollapsed &&
          selection.extentOffset >= ls &&
          selection.extentOffset <= le) {
        final col = selection.extentOffset - ls;
        final cx = tp.getOffsetForCaret(TextPosition(offset: col), Rect.zero).dx;
        canvas.drawRect(
          Rect.fromLTWH(
            codeOrigin + cx - scroll.dx,
            top,
            1.5,
            lineHeight,
          ),
          Paint()..color = cursorColor,
        );
      }

      tp.dispose();
    }

    // Divisória gutter | código.
    canvas.drawRect(
      Rect.fromLTWH(gutterWidth, 0, 1, size.height),
      Paint()..color = dividerColor,
    );
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

  @override
  bool shouldRepaint(covariant CodeEditorPainter old) =>
      !identical(lineSpans, old.lineSpans) ||
      selection != old.selection ||
      scroll != old.scroll ||
      focused != old.focused ||
      currentLine != old.currentLine ||
      lineSpans.length != old.lineSpans.length ||
      indentSize != old.indentSize ||
      backgroundColor != old.backgroundColor;
}
