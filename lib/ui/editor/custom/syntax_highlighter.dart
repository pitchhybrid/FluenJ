import 'package:flutter/widgets.dart';
import 'package:re_highlight/languages/bash.dart';
import 'package:re_highlight/languages/css.dart';
import 'package:re_highlight/languages/dockerfile.dart';
import 'package:re_highlight/languages/dos.dart';
import 'package:re_highlight/languages/gradle.dart';
import 'package:re_highlight/languages/groovy.dart';
import 'package:re_highlight/languages/ini.dart';
import 'package:re_highlight/languages/java.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/kotlin.dart';
import 'package:re_highlight/languages/markdown.dart';
import 'package:re_highlight/languages/plaintext.dart';
import 'package:re_highlight/languages/properties.dart';
import 'package:re_highlight/languages/protobuf.dart';
import 'package:re_highlight/languages/scala.dart';
import 'package:re_highlight/languages/sql.dart';
import 'package:re_highlight/languages/typescript.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

/// Converte texto + linguagem em um [TextSpan] com syntax highlight.
///
/// Usa `re_highlight` (que é apenas o *parser* — port do highlight.js; não é
/// editor). A renderização é feita pelo editor próprio. Singleton: registra as
/// linguagens uma vez. Ver [[adr-0008-editor-proprio]] (vault).
class SyntaxHighlighter {
  SyntaxHighlighter._() {
    _hl.registerLanguages(<String, Mode>{
      'java': langJava,
      'json': langJson,
      'xml': langXml,
      'plaintext': langPlaintext,
      // Ecossistema Java: build, outras langs JVM, config, web, infra, dados.
      'gradle': langGradle,
      'groovy': langGroovy,
      'kotlin': langKotlin,
      'scala': langScala,
      'properties': langProperties,
      'yaml': langYaml,
      'ini': langIni,
      'sql': langSql,
      'markdown': langMarkdown,
      'bash': langBash,
      'dockerfile': langDockerfile,
      'dos': langDos,
      'protobuf': langProtobuf,
      'javascript': langJavascript,
      'typescript': langTypescript,
      'css': langCss,
    });
  }

  static final SyntaxHighlighter instance = SyntaxHighlighter._();

  final Highlight _hl = Highlight();

  /// Maps a file name to a registered language id.
  static String languageFor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower == 'dockerfile' || lower.endsWith('.dockerfile')) {
      return 'dockerfile';
    }
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
    return switch (ext) {
      'java' => 'java',
      'gradle' => 'gradle',
      'groovy' => 'groovy',
      'kt' || 'kts' => 'kotlin',
      'scala' || 'sc' => 'scala',
      'properties' => 'properties',
      'yaml' || 'yml' => 'yaml',
      'ini' || 'cfg' || 'conf' || 'toml' || 'env' => 'ini',
      'sql' => 'sql',
      'md' || 'markdown' => 'markdown',
      'sh' || 'bash' || 'zsh' => 'bash',
      'bat' || 'cmd' => 'dos',
      'proto' => 'protobuf',
      'js' || 'mjs' || 'cjs' || 'jsx' => 'javascript',
      'ts' || 'tsx' => 'typescript',
      'css' => 'css',
      'json' || 'json5' || 'geojson' => 'json',
      'xml' ||
      'xhtml' ||
      'xsd' ||
      'wsdl' ||
      'tld' ||
      'fxml' ||
      'jrxml' ||
      'html' ||
      'htm' ||
      'jsp' ||
      'jspx' ||
      'tag' =>
        'xml',
      _ => 'plaintext',
    };
  }

  /// Linguagens oferecidas no seletor de language mode (id → rótulo).
  static const Map<String, String> supportedLanguages = {
    'plaintext': 'Plain Text',
    'java': 'Java',
    'kotlin': 'Kotlin',
    'scala': 'Scala',
    'groovy': 'Groovy',
    'gradle': 'Gradle (Groovy DSL)',
    'json': 'JSON',
    'xml': 'XML / HTML',
    'yaml': 'YAML',
    'properties': 'Properties',
    'ini': 'INI / TOML',
    'sql': 'SQL',
    'markdown': 'Markdown',
    'bash': 'Shell (Bash)',
    'dockerfile': 'Dockerfile',
    'dos': 'Batch (DOS)',
    'protobuf': 'Protocol Buffers',
    'javascript': 'JavaScript',
    'typescript': 'TypeScript',
    'css': 'CSS',
  };

  /// Rótulo amigável para um id de linguagem.
  static String labelFor(String id) => supportedLanguages[id] ?? id;

  /// Builds a highlighted [TextSpan] for [code].
  TextSpan highlight(
    String code,
    String language, {
    required TextStyle base,
    required bool dark,
  }) {
    final theme = dark ? atomOneDarkTheme : atomOneLightTheme;
    final result = _hl.highlight(code: code, language: language);
    final renderer = TextSpanRenderer(base, theme);
    result.render(renderer);
    return renderer.span ?? TextSpan(text: code, style: base);
  }
}
