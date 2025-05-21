import 'package:flutter/material.dart';
import 'package:ninjaapp/src/models/comentario_bitrix.dart';
import 'package:ninjaapp/src/util/text.util.dart';
import 'package:ninjaapp/src/util/time.util.dart';

class CommentInfo extends StatefulWidget {
  CommentInfo({required this.comentarioBitrix, super.key});

  final ComentarioBitrix comentarioBitrix;

  @override
  State<StatefulWidget> createState() => CommentInfoState();
}

class CommentInfoState extends State<CommentInfo> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        borderOnForeground: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${TimeUtil.dbDateToString(widget.comentarioBitrix.POST_DATE!, format: TimeUtil.brTime)} - ${widget.comentarioBitrix.AUTHOR_NAME!}'),
                  // Text('Anexos: ${widget.comentarioBitrix.ATTACHED_OBJECTS}')
                ],
              ),
              SelectableText(TextUtil.sanitazeBBCode(
                  widget.comentarioBitrix.POST_MESSAGE!))
            ],
          ),
        ),
      ),
    );
  }
}
