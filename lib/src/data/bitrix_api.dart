import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ninjaapp/src/models/anexo_tarefa_bitrix.dart';
import 'package:ninjaapp/src/models/comentario_bitrix.dart';
import 'package:ninjaapp/src/models/etapa_bitrix.dart';
import 'package:ninjaapp/src/models/informacao_bitrix.dart';
import 'package:ninjaapp/src/models/workgroup_bitrix.dart';
import 'package:ninjaapp/src/util/http.util.dart';
import 'package:ninjaapp/src/util/io.util.dart';

class BitrixApi {
  String baseUrl;
  String groupId;

  BitrixApi(this.baseUrl, this.groupId);

  Future<InformacaoBitrix?> getDadosBitrix(String idTask) async {
    var parse = Uri.parse(baseUrl);
    var rest =
        await http.get(Uri.https(parse.host, "${parse.path}/tasks.task.get", {
      "taskId": idTask,
      'select[]': ['*', 'UF_TASK_WEBDAV_FILES'],
    }));
    var jsonTask = jsonDecode(rest.body);
    InformacaoBitrix? retorno;
    if (jsonTask is Map &&
        jsonTask.containsKey('result') &&
        jsonTask['result'] is Map &&
        jsonTask['result'].containsKey('task')) {
      retorno = InformacaoBitrix.fromJson(jsonTask['result']['task']);
    }
    return retorno;
  }

  Future<List<ComentarioBitrix>> getComentariosTarefa(String idTask) async {
    var parse = Uri.parse(baseUrl);
    var rest = await http.get(Uri.https(parse.host,
        "${parse.path}/task.commentitem.getlist", {"taskId": idTask}));
    var jsonComments = jsonDecode(rest.body);
    List<ComentarioBitrix> comentarios = [];
    if (jsonComments is Map && jsonComments.containsKey('result')) {
      for (var item in jsonComments['result']) {
        comentarios.add(ComentarioBitrix.fromJson(item));
      }
    }
    return comentarios;
  }

  Future<List<AnexoTarefaBitrix>> getAnexosTarefa(
      List<String> listAttachId) async {
    var parse = Uri.parse(baseUrl);
    var futureResponses = listAttachId.map((attachId) => http.get(Uri.https(
        parse.host,
        "${parse.path}/disk.attachedObject.get",
        {"id": attachId})));
    List<http.Response> responses = await Future.wait(futureResponses);
    List<AnexoTarefaBitrix> anexos = [];
    if (responses.isNotEmpty) {
      for (http.Response response in responses) {
        var jsonAttach = jsonDecode(response.body);
        anexos.add(AnexoTarefaBitrix.fromJson(jsonAttach['result']));
      }
    }
    return anexos;
  }

  Future<List<EtapaBitrix>> getStageInfo() async {
    // Implement the logic to fetch comments from Bitrix API
    var parse = Uri.parse(baseUrl);
    var rest = await http.get(Uri.https(
        parse.host, "${parse.path}/task.stages.get", {"entityID": groupId}));
    var jsonStages = jsonDecode(rest.body);
    Map<String, dynamic> stages = jsonStages['result'] as Map<String, dynamic>;
    List<EtapaBitrix> etapas = [];
    for (var item in stages.keys) {
      etapas.add(EtapaBitrix.fromJson(stages[item]));
    }
    return etapas;
  }

  Future<List<WorkgroupBitrix>> getWorkgroups() async {
    var parse = Uri.parse(baseUrl);
    var rest = await http.get(Uri.https(
        parse.host,
        '${parse.path}/socialnetwork.api.workgroup.list',
        {'select[]': 'NAME'}));
    List<WorkgroupBitrix> workgroups = [];
    if (rest.statusCode == 200) {
      var jsonWorkgroups = jsonDecode(rest.body);
      if (jsonWorkgroups is Map &&
          jsonWorkgroups.containsKey('result') &&
          jsonWorkgroups['result'] is Map &&
          jsonWorkgroups['result'].containsKey('workgroups')) {
        for (var item in jsonWorkgroups['result']['workgroups']) {
          workgroups.add(WorkgroupBitrix.fromJson(item));
        }
      }
    } else {
      throw Exception(
          'Não foi possível obter os grupos de trabalho. Verifique a URL e se há a permissão \'socialnetwork\'.');
    }

    return workgroups;
  }

  downloadTaskAttachment(String idTask, String basePath, String fileName,
      String downloadURL) async {
    var taskFolderPath = '$basePath/tarefa-$idTask';
    await IOUtil.createPath(taskFolderPath, true);
    String filePath = '$taskFolderPath/$fileName';
    HttpUtil.download(downloadURL, filePath);
  }
}
