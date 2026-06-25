import 'package:flutter/widgets.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/java.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/plaintext.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/re_highlight.dart' as hl;
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/state/editor.dart';

/// Editor de código (re_editor) para uma aba.
class CodeEditorView extends StatelessWidget {
  const CodeEditorView({super.key, required this.tab});

  final EditorTab tab;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return CodeEditor(
      controller: tab.controller,
      readOnly: false,
      style: CodeEditorStyle(
        codeTheme: _highlightTheme(context),
        backgroundColor: theme.colorScheme.background,
      ),
      indicatorBuilder: (context, editingController, chunkController, notifier) {
        return Row(
          children: [
            DefaultCodeLineNumber(
              controller: editingController,
              notifier: notifier,
            ),
            DefaultCodeChunkIndicator(
              width: 20,
              controller: chunkController,
              notifier: notifier,
            ),
          ],
        );
      },
      chunkAnalyzer: DefaultCodeChunkAnalyzer(),
    );
  }

  /// Monta o tema de highlight conforme a extensão do arquivo (Java, JSON,
  /// XML por enquanto — ampliar conforme o roadmap).
  CodeHighlightTheme _highlightTheme(BuildContext context) {
    final ext = tab.name.contains('.')
        ? tab.name.split('.').last.toLowerCase()
        : '';

    // Sempre mapeia para uma linguagem: o engine do re_editor quebra
    // (.reduce numa lista vazia) se o mapa de linguagens estiver vazio.
    final hl.Mode lang = switch (ext) {
      'java' => langJava,
      'json' => langJson,
      'xml' || 'xhtml' || 'xsd' => langXml,
      _ => langPlaintext,
    };

    final isDark = ShadTheme.of(context).brightness == Brightness.dark;
    return CodeHighlightTheme(
      languages: {
        ext: CodeHighlightThemeMode(mode: lang),
      },
      theme: isDark ? atomOneDarkTheme : atomOneLightTheme,
    );
  }
}
