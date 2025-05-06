import 'dart:io';

import 'package:process_run/process_run.dart';

class IOUtil {
  Future<void> openFolder(String dirPath) async {
    await run('''
      xdg-open $dirPath
    ''');
  }

  Future<void> createPath(String dirPath, bool createIfNotExists,
      {bool? recursive}) async {
    Directory directory = Directory(dirPath);
    bool exists = directory.existsSync();
    if (exists == false && createIfNotExists) {
      directory.createSync(recursive: recursive ?? false);
    } else if (directory.existsSync() == false) {
      throw Exception('o diretório $dirPath não existe');
    }
  }
}
