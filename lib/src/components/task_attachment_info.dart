import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ninjaapp/src/data/bitrix_api.dart';
import 'package:ninjaapp/src/models/anexo_tarefa_bitrix.dart';
import 'package:ninjaapp/src/settings/settings_controller.dart';

class TaskAttachmentInfo extends StatefulWidget {
  const TaskAttachmentInfo({required this.anexoTarefaBitrix, super.key});

  final AnexoTarefaBitrix anexoTarefaBitrix;

  @override
  State<StatefulWidget> createState() => TaskAttachmentInfoState();
}

class TaskAttachmentInfoState extends State<TaskAttachmentInfo> {
  final SettingsController settingsController =
      GetIt.I.get<SettingsController>();
  BitrixApi? bitrixApi;
  AnexoTarefaBitrix? anexoTarefaBitrix;
  @override
  void initState() {
    super.initState();
    bitrixApi = BitrixApi(settingsController.config.bitrixUrl!,
        settingsController.config.getIdBitrixWorkgroup());
    anexoTarefaBitrix = widget.anexoTarefaBitrix;
  }

  void downloadAttachment() async {
    await bitrixApi!.downloadTaskAttachment(
        anexoTarefaBitrix!.ENTITY_ID!,
        settingsController.config.taskFolder!,
        anexoTarefaBitrix!.NAME!,
        anexoTarefaBitrix!.DOWNLOAD_URL!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Download do arquivo "${anexoTarefaBitrix!.NAME}" finalizado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      children: [
        Text(
            '${widget.anexoTarefaBitrix.ID} - ${widget.anexoTarefaBitrix.NAME!}'),
        IconButton(
            onPressed: downloadAttachment, icon: const Icon(Icons.download))
      ],
    );
  }
}
