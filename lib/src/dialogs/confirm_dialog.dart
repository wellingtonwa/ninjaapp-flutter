import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConfirmDialog extends StatefulWidget {
  ConfirmDialog(
      {super.key,
      required this.confirmAction,
      required this.content,
      this.cancelAction});
  static const routeName = '/confirmarExclucao';

  String? title;
  String? confirmActionTitle;
  String? cancelActionTitle;
  final Widget content;
  final AsyncCallback confirmAction;
  AsyncCallback? cancelAction;

  @override
  State<StatefulWidget> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title ?? 'Confirmação'),
      content: widget.content,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: widget.confirmAction.call,
                  child: Text(widget.confirmActionTitle ?? 'Sim')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () =>
                      widget.cancelAction?.call() ??
                      Navigator.of(context).pop(),
                  child: Text(widget.cancelActionTitle ?? 'Não')),
            )
          ],
        )
      ],
    );
  }
}
