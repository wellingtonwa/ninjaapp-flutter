import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ninjaapp/src/components/bitrix_task_info.dart';
import 'package:ninjaapp/src/models/database.dart';
import 'package:ninjaapp/src/models/etapa_bitrix.dart';
import 'package:ninjaapp/src/models/informacao_bitrix.dart';
import 'package:ninjaapp/src/models/ninjaapp_configuracao.dart';
import 'package:ninjaapp/src/repository/ninjaapp_configuracao_repository.dart';
import 'package:ninjaapp/src/service/restore_service.dart';
import 'package:ninjaapp/src/settings/settings_controller.dart';
import 'package:ninjaapp/src/util/io.util.dart';

class DatabaseCard extends StatefulWidget {
  DatabaseCard(this.settingsController, this.etapas, this.refresh,
      {super.key, this.database});

  final VoidCallback refresh;
  final SettingsController settingsController;
  Database? database;
  List<EtapaBitrix> etapas = [];

  @override
  State<StatefulWidget> createState() => _DatabaseCardState();
}

class _DatabaseCardState extends State<DatabaseCard> {
  final RestoreService restoreService = GetIt.I.get<RestoreService>();
  final IOUtil ioUtil = GetIt.I.get<IOUtil>();
  String? numeroTarefa;
  InformacaoBitrix? informacaoBitrix;
  bool isTarefa = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.database != null && (widget.database!.isTarefa ?? false)) {
      informacaoBitrix = widget.database!.informacaoBitrix!;
    }
  }

  void excluirBanco() async {
    NinjaappConfiguracao config =
        await GetIt.I.get<NinjaappConfiguracaoRepository>().getConfiguracao();
    await restoreService.droparDatabaseTerminal(
        widget.database!.dbName!, config);
    widget.refresh();
    Navigator.pop(context);
  }

  void confirmDeleteDatabase() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Confirmação'),
              content: Text(
                  'Deseja realmente excluir a base de dados "${widget.database!.dbName!}"?'),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: excluirBanco, child: const Text("Sim")),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Não')),
                    )
                  ],
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      children: [
        ListTile(
            title: Text(widget.database?.dbName ??
                'Não foi possível pegar o nome do banco'),
            subtitle: Visibility(
              visible: widget.database!.informacaoBitrix != null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (informacaoBitrix != null)
                    BitrixTaskInfo(informacaoBitrix!, widget.etapas),
                ],
              ),
            )),
        Row(
          children: [
            IconButton(
                onPressed: confirmDeleteDatabase,
                icon: const Icon(Icons.delete)),
            Visibility(
              visible: widget.database?.isTarefa ?? false,
              child: IconButton(
                  onPressed: () {
                    String dirPath =
                        '${widget.settingsController.config.taskFolder!}/tarefa-${widget.database?.numeroTarefa!}';
                    ioUtil.createPath(dirPath, true, recursive: true);
                    ioUtil.openFolder(dirPath);
                  },
                  icon: const Icon(Icons.folder)),
            )
          ],
        )
      ],
    ));
  }
}
