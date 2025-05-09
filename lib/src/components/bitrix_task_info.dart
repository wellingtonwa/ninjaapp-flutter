import 'package:flutter/material.dart';
import 'package:ninjaapp/src/components/person_icon.dart';
import 'package:ninjaapp/src/models/etapa_bitrix.dart';
import 'package:ninjaapp/src/models/informacao_bitrix.dart';

class BitrixTaskInfo extends StatefulWidget {
  final InformacaoBitrix item;
  final List<EtapaBitrix> etapas;

  const BitrixTaskInfo(this.item, this.etapas, {super.key});

  @override
  State<StatefulWidget> createState() => _BitrixTaskInfoState();
}

class _BitrixTaskInfoState extends State<BitrixTaskInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tarefa: ${widget.item.titulo}'),
        Text(
            'Etapa: ${widget.etapas.where((etapa) => etapa.ID == widget.item.idEtapa).first.TITLE}'),
        Text('Criado em: ${widget.item.createdDate}'),
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
        Text('Status: ${widget.item.prioridade}'),
        // TextButton(
        //   child: const Text('Abrir pasta'),
        //   onPressed: () {
        //     // Handle button press
        //     Process.run('xdg-open', ['/home/wellington/Downloads/lixo/tarefa-${snapshot.data!.id}']).then((result) {
        //       print(result.stdout);
        //     });
        //   },
        // )
      ],
    );
  }
}
