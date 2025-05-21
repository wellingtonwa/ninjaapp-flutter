import 'package:flutter/material.dart';
import 'package:ninjaapp/src/components/person_icon.dart';
import 'package:ninjaapp/src/models/etapa_bitrix.dart';
import 'package:ninjaapp/src/models/informacao_bitrix.dart';
import 'package:ninjaapp/src/util/time.util.dart';

class BitrixTaskInfo extends StatefulWidget {
  final InformacaoBitrix item;
  final List<EtapaBitrix> etapas;

  const BitrixTaskInfo(this.item, this.etapas, {super.key});

  @override
  State<StatefulWidget> createState() => _BitrixTaskInfoState();
}

class _BitrixTaskInfoState extends State<BitrixTaskInfo> {
  String getDateTime() {
    String result = widget.item.createdDate ?? '';
    if (widget.item.createdDate != null) {
      result = TimeUtil.dbDateToString(result, format: TimeUtil.brTime);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Tarefa: ',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Expanded(
              child: Tooltip(
                message: '${widget.item.titulo}',
                child: Text(
                  widget.item.titulo!,
                  style: const TextStyle(fontWeight: FontWeight.w100),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Etapa: '),
            Text(
              '${widget.etapas.where((etapa) => etapa.ID == widget.item.idEtapa).first.TITLE}',
              style: const TextStyle(fontWeight: FontWeight.w100),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        Row(
          children: [
            const Text('Criado em: '),
            Text(
              getDateTime(),
              style: const TextStyle(fontWeight: FontWeight.w100),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        Row(
          children: [
            const Text('Autor: '),
            PersonIcon(person: widget.item.creator!)
          ],
        ),
        Row(
          children: [
            const Text('Responsável: '),
            PersonIcon(person: widget.item.responsible!)
          ],
        ),
        Row(
          children: [
            const Text('Status: '),
            Text(
              '${widget.item.prioridade}',
              style: const TextStyle(fontWeight: FontWeight.w100),
            ),
          ],
        ),
      ],
    );
  }
}
