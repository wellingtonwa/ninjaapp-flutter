import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:get_it/get_it.dart';
import 'package:ninjaapp/src/models/ninjaapp_configuracao.dart';
import 'package:ninjaapp/src/models/restore_file.dart';
import 'package:ninjaapp/src/models/restore_link.dart';
import 'package:http/http.dart' as http;
import 'package:ninjaapp/src/service/log_service.dart';
import 'package:process_run/process_run.dart';

class RestoreService {
  final RegExp REGEX_DOWNLOADED_FILE =
      RegExp(r'(?<=attachment; filename=").*(?=";)');
  final RegExp REGEX_ARQUIVOBACKUP = RegExp(r'.*\.backup$');
  final RegExp REGEX_IS_ZIP_FILE = RegExp(r'.*\.zip$');
  final RegExp REGEX_POSTGRES_BIN_FOLDER =
      RegExp(r'(?<=\d{2} )\/.*(?=postgres -D)');
  String? postgresBinariesPath;
  final LogService logService = GetIt.I.get<LogService>();
  RestoreService() {
    findPostgresBinaries();
  }

  Future<void> restoreLink(
      RestoreLink restoreLink, NinjaappConfiguracao ninjaapp) async {
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
          logService.appendLogText('Descompactando o arquivo ${arquivo.path}');
          await descompactarArquivo(arquivo.path, ninjaapp.backupFolder!);
        } catch (error) {
          logService.appendLogText('Algo deu errado. Detalhes $error');
        }
      }
      try {
        logService
            .appendLogText('Tentando dropar a base ${restoreLink.nomeBanco}');
        await droparDockerDatabaseTerminal(restoreLink.nomeBanco);
      } catch (error) {
        logService.appendLogText(
            'Não foi possível dropar a base de dados "${restoreLink.nomeBanco}". Detalhes $error');
      }
      try {
        await criarDockerDatabaseTerminal(restoreLink.nomeBanco);
        logService.appendLogText(
            'Copiando o arquivo de backup para dentro do container.');
        await copiarArquivoBackupDocker(
            '${ninjaapp.backupFolder!}/database.backup',
            ninjaapp.postgresContainerName!);
        logService.appendLogText(
            'Iniciando o processo de restauração do banco "${restoreLink.nomeBanco}"');
        await restoreDockerDatabaseTerminal(
            restoreLink.nomeBanco, ninjaapp.postgresUser!);
        logService.appendLogText('Processo finalizado');
      } catch (error) {
        logService.appendLogText(
            'O processo de restauração foi parado por um erro. Detalhes: $error');
      }
    }
  }

  Future<void> restoreFile(
      RestoreFile restoreFile, NinjaappConfiguracao config) async {
    logService.appendLogText(
        '----Iniciando a restauração do arquivo "${restoreFile.arquivo}"----');
    String? nomeArquivo = restoreFile.arquivo;
    if (REGEX_IS_ZIP_FILE.hasMatch(nomeArquivo)) {
      logService.appendLogText('Descompactando o arquivo....');
      nomeArquivo =
          await descompactarArquivo(nomeArquivo, config.backupFolder!);
    }

    try {
      logService
          .appendLogText('Tentando dropar a base ${restoreFile.nomeBanco}');
      await droparDockerDatabaseTerminal(restoreFile.nomeBanco);
    } catch (error) {
      logService.appendLogText(
          'Não foi possível dropar a base de dados "${restoreFile.nomeBanco}". Detalhes $error');
    }
    try {
      await criarDockerDatabaseTerminal(restoreFile.nomeBanco);
      logService.appendLogText(
          'Copiando o arquivo de backup para dentro do container.');
      await copiarArquivoBackupDocker(
          nomeArquivo!, config.postgresContainerName!);
      logService.appendLogText(
          'Iniciando o processo de restauração do banco "${restoreFile.nomeBanco}"');
      await restoreDockerDatabaseTerminal(
          restoreFile.nomeBanco, config.postgresUser!);
      logService.appendLogText('Processo finalizado');
    } catch (error) {
      logService.appendLogText(
          'O processo de restauração foi parado por um erro. Detalhes: $error');
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
    var result = await Process.start('docker', [
      'exec',
      '-t',
      'postgres',
      'sh',
      '-c',
      'pg_restore -U $user --dbname $nomeDoBanco /database.backup'
    ]);
    var stdout = result.stdout.transform(utf8.decoder).forEach((data) {
      print(data);
      logService.appendLogText('Retorno do pg_restore: $data');
    });

    var stderr = result.stderr.transform(utf8.decoder).forEach((data) {
      logService.appendLogText('Erro: $data');
      print(data);
    });

    await Future.wait([stdout, stderr]);
  }

  Future<void> droparDockerDatabaseTerminal(String nomeDoBanco) async {
    var result = await run('''
      docker exec -t postgres psql -U postgres -c "DROP DATABASE $nomeDoBanco"
    ''');
    if (result.outText.isNotEmpty) {
      logService.appendLogText(result.outText);
    }
    if (result.errText.isNotEmpty) {
      logService.appendLogText(result.errText);
    }
  }

  Future<void> droparDatabaseTerminal(
      String nomeDoBanco, NinjaappConfiguracao config) async {
    ProcessResult processResult = await Process.run('sh', [
      '-c',
      'export PGPASSWORD=${config.postgresPassword}; ${postgresBinariesPath}psql -h ${config.postgresUrl} -U ${config.postgresUser} -p ${config.postgresPort} -c "DROP DATABASE $nomeDoBanco"'
    ]);

    if (processResult.outText.isNotEmpty) {
      logService.appendLogText(processResult.outText);
    }
    if (processResult.errText.isNotEmpty) {
      logService.appendLogText(processResult.errText);
    }
  }

  Future<void> criarDockerDatabaseTerminal(String nomeDoBanco) async {
    var result = await run('''
      docker exec -t postgres psql -U postgres -c "CREATE DATABASE $nomeDoBanco"
    ''');
    print(result.outText);
  }

  Future<String?> descompactarArquivo(String filePath, String fileDest) async {
    // Ler o arquivo ZIP
    final zipFile = File(filePath);
    final bytes = await zipFile.readAsBytes();

    // Decodificar o ZIP
    final archive = ZipDecoder().decodeBytes(bytes);
    String? caminhoArquivoDescompactado;
    // Extrair os arquivos
    for (final file in archive) {
      caminhoArquivoDescompactado = '$fileDest/database.backup';
      if (REGEX_ARQUIVOBACKUP.hasMatch(file.name)) {
        final outFile = File(caminhoArquivoDescompactado);
        print('Extraindo: ${file.name}');
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      }
    }

    return caminhoArquivoDescompactado;
  }

  Future<void> findPostgresBinaries() async {
    ProcessResult result =
        await Process.run('sh', ['-c', 'ps auxw | grep postgres | grep -- -D']);
    if (result.errText.isEmpty) {
      Iterable<RegExpMatch> matches =
          REGEX_POSTGRES_BIN_FOLDER.allMatches(result.outText);
      if (matches.isNotEmpty) {
        postgresBinariesPath = matches.first.group(0);
      }
    }
  }
}
