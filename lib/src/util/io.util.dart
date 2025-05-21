import 'dart:io';

import 'package:flutter/services.dart';
import 'package:process_run/process_run.dart';

class IOUtil {
  static Future<void> openFolder(String dirPath) async {
    await run('''
      xdg-open $dirPath
    ''');
  }

  static Future<void> createPath(String dirPath, bool createIfNotExists,
      {bool? recursive}) async {
    Directory directory = Directory(dirPath);
    bool exists = directory.existsSync();
    if (exists == false && createIfNotExists) {
      directory.createSync(recursive: recursive ?? false);
    } else if (directory.existsSync() == false) {
      throw Exception('o diretório $dirPath não existe');
    }
  }

  static copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
