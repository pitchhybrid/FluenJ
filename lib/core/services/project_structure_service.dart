import 'dart:io';

import 'package:fluenj/core/models/file_node.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

enum BuildType { maven, gradle, standalone }

/// Monta a árvore **lógica** do projeto (package explorer estilo Eclipse):
/// source folders → pacotes achatados → classes; Libraries (JRE + deps do
/// pom.xml + WEB-INF/lib); WebApp (WEB-INF, web.xml, ...).
///
/// ⚠️ Heurístico (baseado em filesystem + pom.xml). O classpath **real**
/// (jars resolvidos do .m2, source attachment) virá com o JDT LS (Fase 2).
class ProjectStructureService {
  const ProjectStructureService();

  static const _hidden = {
    '.git',
    '.svn',
    '.hg',
    'target',
    'build',
    'node_modules',
    '.gradle',
    '.idea',
    '.vscode',
    '.dart_tool',
  };

  BuildType detectBuildType(String root) {
    if (File(p.join(root, 'pom.xml')).existsSync()) return BuildType.maven;
    if (FileSystemEntity.typeSync(p.join(root, 'build.gradle')) !=
            FileSystemEntityType.notFound ||
        FileSystemEntity.typeSync(p.join(root, 'build.gradle.kts')) !=
            FileSystemEntityType.notFound) {
      return BuildType.gradle;
    }
    return BuildType.standalone;
  }

  List<String> javaSourceFolders(String root) => const [
        'src/main/java',
        'src/test/java',
      ]
          .where((rel) => Directory(p.join(root, rel)).existsSync())
          .map((rel) => p.join(root, rel))
          .toList();

  List<String> resourceFolders(String root) => const [
        'src/main/resources',
        'src/test/resources',
      ]
          .where((rel) => Directory(p.join(root, rel)).existsSync())
          .map((rel) => p.join(root, rel))
          .toList();

  String? webAppDir(String root) {
    for (final rel in ['src/main/webapp', 'WebContent', 'web']) {
      final d = p.join(root, rel);
      if (Directory(d).existsSync()) return d;
    }
    return null;
  }

  /// Constrói a árvore lógica raiz do package explorer.
  Future<List<FileNode>> buildPackageTree(String root) async {
    final nodes = <FileNode>[];

    for (final sf in javaSourceFolders(root)) {
      final node = FileNode(
        path: sf,
        name: p.relative(sf, from: root).replaceAll(r'\', '/'),
        isDir: true,
        kind: NodeKind.sourceFolder,
      );
      node.children.addAll(_sourceFolderChildren(sf, 1));
      nodes.add(node);
    }

    for (final rf in resourceFolders(root)) {
      final node = FileNode(
        path: rf,
        name: p.relative(rf, from: root).replaceAll(r'\', '/'),
        isDir: true,
        kind: NodeKind.folder,
      );
      node.children.addAll(_listDirNodes(rf, 1));
      nodes.add(node);
    }

    final wa = webAppDir(root);
    if (wa != null) {
      final node = FileNode(
        path: wa,
        name: 'WebApp',
        isDir: true,
        kind: NodeKind.webApp,
      );
      node.children.addAll(_listDirNodes(wa, 1, webContext: true));
      nodes.add(node);
    }

    // Libraries (classpath aproximado).
    final libs = FileNode(
      path: root,
      name: 'Libraries',
      isDir: true,
      kind: NodeKind.library,
    );
    libs.children.add(_lib('JRE System Library [Java SE]', NodeKind.jre));
    final buildType = detectBuildType(root);
    if (buildType == BuildType.maven) {
      libs.children.addAll(await _mavenDependencies(root));
    } else if (buildType == BuildType.gradle) {
      libs.children.add(_lib('Gradle Dependencies (via LSP)', NodeKind.library));
    }
    if (wa != null) {
      final webInfLib = p.join(wa, 'WEB-INF', 'lib');
      if (Directory(webInfLib).existsSync()) {
        libs.children.addAll(_listJars(webInfLib));
      }
    }
    nodes.add(libs);

    return nodes;
  }

  // ----- Source folder (pacotes achatados estilo Eclipse) -----

  List<FileNode> _sourceFolderChildren(String sf, int depth) {
    final entries = _listSafe(sf);
    final files = entries.whereType<File>().toList();
    final dirs = _visibleDirs(entries);
    final result = <FileNode>[];

    for (final f in files) {
      result.add(_leaf(f.path, p.basename(f.path), depth,
          java: f.path.toLowerCase().endsWith('.java')));
    }
    for (final d in dirs) {
      final pkg = _flattenPackage(d.path, p.basename(d.path), depth);
      if (pkg != null) result.add(pkg);
    }
    return result;
  }

  /// Achata pastas intermediárias vazias: se um diretório não tem arquivos e
  /// só um subdir, junta os nomes (`com` + `example` → `com.example`).
  FileNode? _flattenPackage(String dir, String pkg, int depth) {
    final entries = _listSafe(dir);
    final files = entries.whereType<File>().toList();
    final dirs = _visibleDirs(entries);

    if (files.isEmpty && dirs.length == 1) {
      final only = dirs.first;
      return _flattenPackage(only.path, '$pkg.${p.basename(only.path)}', depth);
    }

    final node = FileNode(
      path: dir,
      name: pkg,
      isDir: true,
      depth: depth,
      kind: NodeKind.package,
    );
    for (final f in files) {
      node.children.add(_leaf(f.path, p.basename(f.path), depth + 1,
          java: f.path.toLowerCase().endsWith('.java')));
    }
    for (final d in dirs) {
      final sub = _flattenPackage(d.path, '$pkg.${p.basename(d.path)}', depth + 1);
      if (sub != null) node.children.add(sub);
    }
    if (node.children.isEmpty) return null; // pacote vazio
    return node;
  }

  // ----- Diretório como árvore física (resources / webapp) -----

  List<FileNode> _listDirNodes(String dir, int depth, {bool webContext = false}) {
    final entries = _listSafe(dir);
    final dirs = _visibleDirs(entries)..sort(_byNameDir);
    final files = entries.whereType<File>().where(_notHiddenFile).toList()
      ..sort(_byNameFile);
    final result = <FileNode>[];

    for (final d in dirs) {
      final node = FileNode(
        path: d.path,
        name: p.basename(d.path),
        isDir: true,
        depth: depth,
        kind: webContext ? NodeKind.webResource : NodeKind.folder,
      );
      node.children
          .addAll(_listDirNodes(d.path, depth + 1, webContext: webContext));
      result.add(node);
    }
    for (final f in files) {
      result.add(FileNode(
        path: f.path,
        name: p.basename(f.path),
        isDir: false,
        depth: depth,
        kind: webContext ? NodeKind.webResource : NodeKind.file,
      ));
    }
    return result;
  }

  // ----- Libraries -----

  Future<List<FileNode>> _mavenDependencies(String root) async {
    final pomPath = p.join(root, 'pom.xml');
    try {
      final content = await File(pomPath).readAsString();
      final doc = XmlDocument.parse(content);
      final seen = <String>{};
      final result = <FileNode>[];
      // Apenas <dependency> cujo pai direto é <dependencies> do <project>.
      for (final dep in doc.findAllElements('dependency')) {
        final parent = dep.parentElement;
        if (parent == null || parent.name.local != 'dependencies') continue;
        final grand = parent.parentElement;
        if (grand == null || grand.name.local != 'project') continue;

        final gid = dep.getElement('groupId')?.innerText.trim();
        final aid = dep.getElement('artifactId')?.innerText.trim();
        final ver = dep.getElement('version')?.innerText.trim();
        final label = [gid, aid, ver]
            .where((s) => s != null && s.isNotEmpty)
            .join(' : ');
        if (label.isEmpty || !seen.add(label)) continue;
        result.add(_lib(label, NodeKind.library));
      }
      return result;
    } on Object catch (_) {
      return const [];
    }
  }

  List<FileNode> _listJars(String dir) {
    final files = _listSafe(dir)
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.jar'))
        .toList()
      ..sort(_byNameFile);
    return files
        .map((f) => FileNode(
              path: f.path,
              name: p.basename(f.path),
              isDir: false,
              kind: NodeKind.library,
            ))
        .toList();
  }

  // ----- helpers -----

  FileNode _lib(String label, NodeKind kind) =>
      FileNode(path: '', name: label, isDir: false, kind: kind);

  FileNode _leaf(String path, String name, int depth, {required bool java}) =>
      FileNode(
        path: path,
        name: name,
        isDir: false,
        depth: depth,
        kind: java ? NodeKind.classFile : NodeKind.file,
      );

  List<FileSystemEntity> _listSafe(String dir) {
    try {
      return Directory(dir).listSync(followLinks: false);
    } on Object catch (_) {
      return const [];
    }
  }

  List<Directory> _visibleDirs(List<FileSystemEntity> entries) => entries
      .whereType<Directory>()
      .where((d) => !_isHidden(p.basename(d.path)))
      .toList();

  bool _notHiddenFile(File f) => !_isHidden(p.basename(f.path));

  bool _isHidden(String name) {
    if (name.isEmpty) return true;
    if (name.startsWith('.')) return true;
    return _hidden.contains(name);
  }

  int _byNameDir(Directory a, Directory b) =>
      p.basename(a.path).toLowerCase().compareTo(p.basename(b.path).toLowerCase());
  int _byNameFile(File a, File b) =>
      p.basename(a.path).toLowerCase().compareTo(p.basename(b.path).toLowerCase());
}

final projectStructureProvider =
    Provider<ProjectStructureService>((ref) => const ProjectStructureService());
