import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ninjaapp/src/models/comentario_bitrix.dart';
import 'package:ninjaapp/src/models/etapa_bitrix.dart';
import 'package:ninjaapp/src/models/informacao_bitrix.dart';

class BitrixApi {
  String baseUrl;

  BitrixApi(this.baseUrl);

  Future<InformacaoBitrix?> getDadosBitrix(String idTask) async {
    print('object');
    // Implement the logic to fetch data from Bitrix API
    var parse = Uri.parse(baseUrl);
    var rest =
        await http.get(Uri.https(parse.host, "${parse.path}/tasks.task.get", {
      "taskId": idTask,
      'select[]': '*',
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
    // Implement the logic to fetch comments from Bitrix API
    var parse = Uri.parse(baseUrl);
    var rest = await http.get(Uri.https(parse.host,
        "${parse.path}/task.commentitem.getlist", {"taskId": idTask}));
    var jsonTask = jsonDecode(rest.body);
    List<ComentarioBitrix> comentarios = [];
    for (var item in jsonTask['result']) {
      comentarios.add(ComentarioBitrix.fromJson(item));
    }
    return comentarios;
  }

  Future<List<EtapaBitrix>> getStageInfo() async {
    // Implement the logic to fetch comments from Bitrix API
    var parse = Uri.parse(baseUrl);
    var rest = await http.get(Uri.https(
        parse.host, "${parse.path}/task.stages.get", {"entityID": '68'}));
    var jsonStages = jsonDecode(rest.body);
    Map<String, dynamic> stages = jsonStages['result'] as Map<String, dynamic>;
    List<EtapaBitrix> etapas = [];
    for (var item in stages.keys) {
      etapas.add(EtapaBitrix.fromJson(stages[item]));
    }
    return etapas;
  }
}
