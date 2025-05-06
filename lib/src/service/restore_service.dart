import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:ninjaapp/src/models/ninjaapp_configuracao.dart';
import 'package:ninjaapp/src/models/restore_file.dart';
import 'package:ninjaapp/src/models/restore_link.dart';
import 'package:http/http.dart' as http;
import 'package:process_run/process_run.dart';

class RestoreService {
  void restoreFile(RestoreFile restoreFile) {}

  final RegExp REGEX_DOWNLOADED_FILE =
      RegExp(r'(?<=attachment; filename=").*(?=";)');
  final RegExp REGEX_ARQUIVOBACKUP = RegExp(r'.*\.backup$');
  final RegExp REGEX_IS_ZIP_FILE = RegExp(r'.*\.zip$');
  final RegExp REGEX_POSTGRES_BIN_FOLDER =
      RegExp(r'(?<=\d{2} )\/.*(?=postgres -D)');
  String? postgresBinariesPath;
  RestoreService() {
    findPostgresBinaries();
  }

  Future<void> restoreLink(
      RestoreLink restoreLink, NinjaappConfiguracao ninjaapp) async {
    print(restoreLink.link);
    var parse = Uri.parse(restoreLink.link);

    http.Response response = await http.get(parse);
    Map<String, Object> headers = response.headers;
    if (response.statusCode == 200) {
      RegExpMatch? firstMatch = REGEX_DOWNLOADED_FILE
          .firstMatch(headers['content-disposition'] as String);
      print(firstMatch![0]);
      String filename = firstMatch[0] ?? 'backup.zip';
      var arquivo = File("${ninjaapp.backupFolder!}/$filename");
      await arquivo.writeAsBytes(response.bodyBytes);
      if (REGEX_IS_ZIP_FILE.hasMatch(arquivo.path)) {
        try {
          print('Arquivo compactado');
          await descompactarArquivo(arquivo.path, ninjaapp.backupFolder!);
        } catch (error) {
          print('Algo deu errado. Detalhes $error');
        }
      }
      try {
        await droparDockerDatabaseTerminal(restoreLink.nomeBanco);
      } catch (error) {
        print(
            'Não foi possível dropar a base de dados "${restoreLink.nomeBanco}". Detalhes $error');
      }
      try {
        await criarDockerDatabaseTerminal(restoreLink.nomeBanco);
        await copiarArquivoBackupDocker(
            '${ninjaapp.backupFolder!}/database.backup',
            ninjaapp.postgresContainerName!);
        await restoreDockerDatabaseTerminal(
            restoreLink.nomeBanco, ninjaapp.postgresUser!);
      } catch (error) {
        print(
            'O processo de restauração foi parado por um erro. Detalhes: $error');
      }
    }
  }

  Future<void> copiarArquivoBackupDocker(
      String filePath, String containerName) async {
    var result = await run('''
      docker cp $filePath $containerName:/database.backup
    ''');
    print('''
      docker cp $filePath $containerName:/database.backup
    ''');
    print(result.outText);
  }

  Future<void> restoreDockerDatabaseTerminal(
      String nomeDoBanco, String user) async {
    var result = await run('''
      docker exec -t postgres sh -c "pg_restore -U $user -v --dbname $nomeDoBanco /database.backup"
    ''');
    print(result.outText);
  }

  Future<void> droparDockerDatabaseTerminal(String nomeDoBanco) async {
    var result = await run('''
      docker exec -t postgres psql -U postgres -c "DROP DATABASE $nomeDoBanco"
    ''');
    print(result.outText);
  }

  Future<void> droparDatabaseTerminal(
      String nomeDoBanco, NinjaappConfiguracao config) async {
    ProcessResult processResult = await Process.run('sh', [
      '-c',
      'export PGPASSWORD=${config.postgresPassword}; ${postgresBinariesPath}psql -h ${config.postgresUrl} -U ${config.postgresUser} -p ${config.postgresPort} -c "DROP DATABASE $nomeDoBanco"'
    ]);

    print(
        'export PGPASSWORD=${config.postgresPassword}; ${postgresBinariesPath}psql -h ${config.postgresUrl} -U ${config.postgresUser} -p ${config.postgresPort} -c "DROP DATABASE $nomeDoBanco"');
    print('Saída do comando');
    print(processResult.outText);
    print('Saída de erro');
    print(processResult.errText);
  }

  Future<void> criarDockerDatabaseTerminal(String nomeDoBanco) async {
    var result = await run('''
      docker exec -t postgres psql -U postgres -c "CREATE DATABASE $nomeDoBanco"
    ''');
    print(result.outText);
  }

  Future<void> descompactarArquivo(String filePath, String fileDest) async {
    if (filePath != null && fileDest != null) {
      // Ler o arquivo ZIP
      final zipFile = File(filePath);
      final bytes = await zipFile.readAsBytes();

      // Decodificar o ZIP
      final archive = ZipDecoder().decodeBytes(bytes);
      // Extrair os arquivos
      for (final file in archive) {
        final filename = '$fileDest/database.backup';
        if (REGEX_ARQUIVOBACKUP.hasMatch(file.name)) {
          final outFile = File(filename);
          print('Extraindo: ${file.name}');
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }
    }
  }

  Future<void> findPostgresBinaries() async {
    ProcessResult result =
        await Process.run('sh', ['-c', 'ps auxw | grep postgres | grep -- -D']);
    if (result.errText != null && result.errText.isEmpty) {
      Iterable<RegExpMatch> matches =
          REGEX_POSTGRES_BIN_FOLDER.allMatches(result.outText);
      if (matches.isNotEmpty) {
        postgresBinariesPath = matches.first.group(0);
      }
    }
  }
}
