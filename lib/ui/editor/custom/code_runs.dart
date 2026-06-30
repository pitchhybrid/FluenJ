import 'package:flutter/widgets.dart';

/// Um trecho de texto com estilo, em **offsets globais** (do documento todo).
///
/// Produzido pelo flattenRuns a partir da árvore de TextSpan que o
/// `re_highlight` devolve. Manter offsets globais permite fatiar o highlight
/// por linha **preservando o estado multilinha** (ex.: comentários de bloco
/// `/* ... */`), coisa que um highlight "linha a linha isolada" perde.
class HighlightRun {
  const HighlightRun(this.start, this.end, this.style);

  final int start;
  final int end;
  final TextStyle style;
}

/// Achata uma árvore de [InlineSpan] numa lista linear de [HighlightRun],
/// herdando o estilo dos nós pai (merge). `pos` acumula o offset global.
List<HighlightRun> flattenRuns(InlineSpan root) {
  final out = <HighlightRun>[];
  var pos = 0;

  void visit(InlineSpan span, TextStyle? inherited) {
    if (span is! TextSpan) return;
    final style = inherited == null
        ? span.style
        : span.style == null
            ? inherited
            : inherited.merge(span.style);
    final t = span.text;
    if (t != null && t.isNotEmpty) {
      out.add(HighlightRun(pos, pos + t.length, style ?? const TextStyle()));
      pos += t.length;
    }
    for (final child in span.children ?? const <InlineSpan>[]) {
      visit(child, style ?? inherited);
    }
  }

  visit(root, null);
  return out;
}

/// Constrói o [TextSpan] de uma única linha a partir dos [runs] globais.
///
/// [lineStart]/[lineEnd] delimitam a linha (offsets globais, sem o `\n`).
/// [base] é o estilo base (cor de fonte/tamanho/monospace).
TextSpan lineSpanFromRuns(
  List<HighlightRun> runs,
  int lineStart,
  int lineEnd,
  String lineText,
  TextStyle base,
) {
  if (lineText.isEmpty) return TextSpan(text: '', style: base);
  final children = <TextSpan>[];
  for (final r in runs) {
    if (r.end <= lineStart || r.start >= lineEnd) continue;
    final s = r.start < lineStart ? lineStart : r.start;
    final e = r.end > lineEnd ? lineEnd : r.end;
    children.add(
      TextSpan(
        text: lineText.substring(s - lineStart, e - lineStart),
        style: base.merge(r.style),
      ),
    );
  }
  if (children.isEmpty) return TextSpan(text: lineText, style: base);
  return TextSpan(text: '', style: base, children: children);
}
