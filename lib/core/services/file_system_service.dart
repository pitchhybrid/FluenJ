import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../models/file_node.dart';

/// Acesso ao sistema de arquivos para o explorador e o editor.
///
/// Mantém a lógica de listagem (com filtros), leitura/escrita de arquivos e
/// operações de criação/renomeação/exclusão usadas pela UI da IDE.
class FileSystemService {
  FileSystemService();

  /// Pastas/arquivos ignorados por padrão no explorador.
  static const hiddenEntries = {
    '.git',
    '.svn',
    '.hg',
    '.idea',
    '.vscode',
    'target',
    'build',
    'node_modules',
    '.dart_tool',
    '.gradle',
  };

  /// Lista os filhos diretos de [dirPath], pastas antes de arquivos.
  List<FileNode> listDirectory(String dirPath, {int depth = 0}) {
    final dir = Directory(dirPath);
    final entities = dir.listSync(followLinks: false);
    final nodes = <FileNode>[];

    for (final entity in entities) {
      final name = p.basename(entity.path);
      if (_isHidden(name)) continue;
      nodes.add(FileNode.fromEntity(entity, depth: depth));
    }

    nodes.sort((a, b) {
      final dirCmp = a.isDir == b.isDir ? 0 : (a.isDir ? -1 : 1);
      if (dirCmp != 0) return dirCmp;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return nodes;
  }

  bool _isHidden(String name) {
    if (name.isEmpty) return true;
    if (name.startsWith('.')) return true;
    return hiddenEntries.contains(name);
  }

  /// Lê um arquivo de texto. Tenta UTF-8 primeiro; se houver bytes inválidos
  /// (arquivos Java em windows-1252/latin1, comum no Windows), cai para
  /// latin1, que decodifica qualquer byte sem falhar.
  Future<String> readText(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return latin1.decode(bytes);
    }
  }

  Future<void> writeText(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
  }

  Future<void> createFile(String filePath) async {
    final file = File(filePath);
    await file.create(recursive: true);
  }

  Future<void> createDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    await dir.create(recursive: true);
  }

  Future<void> rename(String oldPath, String newPath) async {
    final type = FileSystemEntity.typeSync(oldPath);
    if (type == FileSystemEntityType.directory) {
      await Directory(oldPath).rename(newPath);
    } else {
      await File(oldPath).rename(newPath);
    }
  }

  Future<void> delete(String path, {bool recursive = true}) async {
    final type = FileSystemEntity.typeSync(path);
    if (type == FileSystemEntityType.directory) {
      await Directory(path).delete(recursive: recursive);
    } else {
      await File(path).delete();
    }
  }

  bool isDirectory(String path) =>
      FileSystemEntity.typeSync(path) == FileSystemEntityType.directory;

  bool exists(String path) => FileSystemEntity.typeSync(path) != FileSystemEntity.typeSync('');
}

/// Provider do serviço de sistema de arquivos.
final fileSystemProvider = Provider<FileSystemService>((ref) => FileSystemService());
