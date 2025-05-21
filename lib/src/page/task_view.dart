import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:get_it/get_it.dart';
import 'package:ninjaapp/src/components/comment_info.dart';
import 'package:ninjaapp/src/components/task_attachment_info.dart';
import 'package:ninjaapp/src/data/bitrix_api.dart';
import 'package:ninjaapp/src/models/anexo_tarefa_bitrix.dart';
import 'package:ninjaapp/src/models/comentario_bitrix.dart';
import 'package:ninjaapp/src/models/informacao_bitrix.dart';
import 'package:ninjaapp/src/settings/settings_controller.dart';
import 'package:ninjaapp/src/util/io.util.dart';
import 'package:ninjaapp/src/util/text.util.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskView extends StatefulWidget {
  static const String routeName = '/taskView';
  static const String routePath = '/taskView/:numeroTarefa';

  const TaskView({required this.numeroTarefa, super.key});

  final String numeroTarefa;

  @override
  State<StatefulWidget> createState() => TaskViewState();
}

class TaskViewState extends State<TaskView> {
  BitrixApi? bitrixApi;
  InformacaoBitrix? informacaoBitrix;
  bool showAttachments = false;
  List<AnexoTarefaBitrix> anexos = [];
  List<ComentarioBitrix> comentarios = [];
  SettingsController settingsController = GetIt.I.get<SettingsController>();

  @override
  void initState() {
    super.initState();
    bitrixApi = BitrixApi(settingsController.config.bitrixUrl!,
        settingsController.config.getIdBitrixWorkgroup());
    _load();
  }

  _load() async {
    informacaoBitrix = await bitrixApi!.getDadosBitrix(widget.numeroTarefa);
    informacaoBitrix!.descricao =
        TextUtil.sanitazeBBCode(informacaoBitrix!.descricao ?? '');
    _loadComentarios();
    _loadAnexos();
    if (mounted) {
      setState(() {});
    }
  }

  _loadComentarios() async {
    comentarios.clear();
    var comentariosBitrix =
        await bitrixApi!.getComentariosTarefa(widget.numeroTarefa);

    if (comentariosBitrix != null && mounted) {
      setState(() {
        comentarios = comentariosBitrix;
      });
    }
  }

  _loadAnexos() async {
    anexos.clear();
    var anexosBitrix =
        await bitrixApi!.getAnexosTarefa(informacaoBitrix!.attachments ?? []);

    if (anexosBitrix.isNotEmpty && mounted) {
      setState(() {
        anexos = anexosBitrix;
      });
    }
  }

  void abrirPastaTarefa() {
    String dirPath =
        '${settingsController.config.taskFolder!}/tarefa-${widget.numeroTarefa}';
    IOUtil.createPath(dirPath, true, recursive: true);
    IOUtil.openFolder(dirPath);
  }

  _toggleShowAttachments() {
    setState(() {
      showAttachments = !showAttachments;
    });
  }

  abrirLinkTarefa() async {
    var parse = Uri.parse(
        'https://${settingsController.config.getBitrixHost()}/workgroups/group/${settingsController.config.getIdBitrixWorkgroup()}/tasks/task/view/${widget.numeroTarefa}/');
    if (!await launchUrl(parse)) {
      throw Exception('Não foi possível abrir a url: $parse');
    }
  }

  abrirLinkGenerico(String url) async {
    var parse = Uri.parse(url);
    if (!await launchUrl(parse)) {
      throw Exception('Não foi possível abrir a url: $parse');
    }
  }

  BBCodeErrorWidgetBuilder onBBError =
      (context, error, stackTrace) => Text(stackTrace.toString());

  void copiarTituloTarefa() {
    IOUtil.copyToClipboard(
        'Tarefa ${informacaoBitrix?.id!}: ${informacaoBitrix?.titulo!}');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Título para finalização da tarefa ${informacaoBitrix?.id!} foi copiado para área de transferência')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Tooltip(
                message: informacaoBitrix?.titulo! ?? '',
                child: Text(
                  'Dados da tarefa ${informacaoBitrix?.id!}: ${informacaoBitrix?.titulo! ?? ''}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            Tooltip(
              message: 'Abrir tarefa no navegador',
              child: IconButton(
                  onPressed: abrirLinkTarefa,
                  icon: const Icon(Icons.open_in_browser)),
            ),
            Tooltip(
              message: 'Copiar texto para finilizar a tarefa',
              child: IconButton(
                  onPressed: copiarTituloTarefa,
                  icon: const Icon(Icons.content_paste_go_outlined)),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          // Text(informacaoBitrix?.descricao ?? '...'),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: BBCodeText(
                  data: informacaoBitrix?.descricao ?? '...',
                  stylesheet: defaultBBStylesheet(
                          textStyle: const TextStyle(color: Colors.white))
                      .replaceTag(
                          UrlTag(onTap: (url) => abrirLinkGenerico(url)))
                      .copyWith(selectableText: true),
                  errorBuilder: onBBError,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              const Text('Arquivos'),
              IconButton(
                  onPressed: _toggleShowAttachments,
                  icon: Icon(showAttachments
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down)),
              Tooltip(
                message: 'Abrir/Criar pasta para tarefa',
                child: IconButton(
                    onPressed: abrirPastaTarefa,
                    icon: const Icon(Icons.folder)),
              ),
            ],
          ),
          Visibility(
              visible: anexos.isNotEmpty && showAttachments,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      for (var anexo in anexos)
                        TaskAttachmentInfo(anexoTarefaBitrix: anexo)
                    ],
                  ),
                ),
              )),
          const Text('Comentários'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var comentario in comentarios)
                    CommentInfo(
                      comentarioBitrix: comentario,
                      key: Key('comentario-info-${comentario.ID}'),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
