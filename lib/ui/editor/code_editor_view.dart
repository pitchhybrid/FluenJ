import 'package:fluenj/core/state/editor.dart';
import 'package:fluenj/ui/editor/custom/code_editor.dart';
import 'package:fluenj/ui/editor/custom/syntax_highlighter.dart';
import 'package:flutter/widgets.dart';

/// Editor de código (próprio, CustomPaint-based) para uma aba. Ver ADR-0008.
class CodeEditorView extends StatelessWidget {
  const CodeEditorView({required this.tab, super.key});

  final EditorTab tab;

  @override
  Widget build(BuildContext context) {
    return CodeEditor(
      controller: tab.controller,
      language: tab.languageOverride ?? SyntaxHighlighter.languageFor(tab.name),
    );
  }
}
