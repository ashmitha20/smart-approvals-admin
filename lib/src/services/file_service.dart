import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<Directory> _getDir() async {
    return await getApplicationDocumentsDirectory();
  }

  Future<File> _getFile(String name) async {
    final dir = await _getDir();
    return File('${dir.path}/$name');
  }

  Future<void> writeJson(String filename, dynamic content) async {
    final file = await _getFile(filename);
    final jsonString = const JsonEncoder.withIndent('  ').convert(content);
    await file.writeAsString(jsonString);
    // simple confirmation path
    print('Wrote ${file.path}');
  }

  Future<String?> readJson(String filename) async {
    final file = await _getFile(filename);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }
}
