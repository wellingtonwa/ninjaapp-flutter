import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ninjaapp/src/components/bitrix_task_info.dart';
import 'package:ninjaapp/src/data/bitrix_api.dart';
import 'package:ninjaapp/src/dialogs/confirm_dialog.dart';
import 'package:ninjaapp/src/models/database.dart';
import 'package:ninjaapp/src/models/etapa_bitrix.dart';
import 'package:ninjaapp/src/models/informacao_bitrix.dart';
import 'package:ninjaapp/src/models/ninjaapp_configuracao.dart';
import 'package:ninjaapp/src/page/task_view.dart';
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
  final SettingsController settingsController =
      GetIt.I.get<SettingsController>();
  BitrixApi? bitrixApi;
  final IOUtil ioUtil = GetIt.I.get<IOUtil>();
  String? numeroTarefa;
  InformacaoBitrix? informacaoBitrix;
  bool isTarefa = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    if (settingsController.config.bitrixUrl != null &&
        settingsController.config.bitrixUrl!.isNotEmpty) {
      bitrixApi = BitrixApi(settingsController.config.bitrixUrl!,
          settingsController.config.getIdBitrixWorkgroup());
    }
    if (widget.database != null &&
        (widget.database!.isTarefa ?? false) &&
        widget.database!.numeroTarefa != null &&
        bitrixApi != null) {
      numeroTarefa = widget.database!.numeroTarefa!;
      informacaoBitrix =
          await bitrixApi!.getDadosBitrix(widget.database!.numeroTarefa!);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> excluirBanco() async {
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
        builder: (BuildContext context) => ConfirmDialog(
            confirmAction: excluirBanco,
            content: Text(
                'Deseja realmente excluir a base de dados "${widget.database!.dbName!}"?')));
  }

  copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(
        text: widget.database?.dbName ??
            'Não foi possível copiar para o clipboard'));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$text adicionado à área de transferência')),
    );
  }

  void abrirPastaTarefa() {
    String dirPath =
        '${widget.settingsController.config.taskFolder!}/tarefa-${widget.database?.numeroTarefa!}';
    IOUtil.createPath(dirPath, true, recursive: true);
    IOUtil.openFolder(dirPath);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.database?.dbName ??
                      'Não foi possível pegar o nome do banco',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Tooltip(
                  message: 'Copiar o nome da base de dados',
                  child: IconButton(
                      onPressed: () =>
                          copyToClipboard(widget.database?.dbName ?? 'fail'),
                      icon: const Icon(Icons.content_paste_go_outlined)),
                )
              ],
            ),
            if (informacaoBitrix != null)
              InkWell(
                  onTap: () {
                    context.go(context.namedLocation(TaskView.routeName,
                        pathParameters: <String, String>{
                          'numeroTarefa': numeroTarefa!
                        }));
                  },
                  child: BitrixTaskInfo(informacaoBitrix!, widget.etapas)),
          ],
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Tooltip(
                message: 'Excluir base de dados',
                child: IconButton(
                    onPressed: confirmDeleteDatabase,
                    icon: const Icon(Icons.delete)),
              ),
              Visibility(
                visible: widget.database?.isTarefa ?? false,
                child: Row(
                  children: [
                    Tooltip(
                      message: 'Abrir/Criar pasta para tarefa',
                      child: IconButton(
                          onPressed: () {
                            String dirPath =
                                '${widget.settingsController.config.taskFolder!}/tarefa-${widget.database?.numeroTarefa!}';
                            IOUtil.createPath(dirPath, true, recursive: true);
                            IOUtil.openFolder(dirPath);
                          },
                          icon: const Icon(Icons.folder)),
                    ),
                    Tooltip(
                      message: 'Visualizar arquivos anexados à tarefa',
                      child: IconButton(
                          onPressed: abrirPastaTarefa,
                          icon: Badge.count(
                              count: informacaoBitrix?.attachments?.length ?? 0,
                              child: const Icon(Icons.download))),
                    ),
                    Tooltip(
                      message: 'Mostrar todos os dados da tarefa',
                      child: IconButton(
                          onPressed: () => context.go(context.namedLocation(
                                  TaskView.routeName,
                                  pathParameters: <String, String>{
                                    'numeroTarefa': numeroTarefa!
                                  })),
                          icon: const Icon(Icons.open_in_browser)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    ));
  }
}
