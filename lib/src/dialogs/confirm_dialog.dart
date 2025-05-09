import 'package:flutter/material.dart';

class ConfirmDialog extends StatefulWidget {
  ConfirmDialog({super.key, nomeBanco});
  static const routeName = '/confirmarExclucao';

  String? nomeBanco;

  @override
  State<StatefulWidget> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Text('Deseja excluir a base de dados "${widget.nomeBanco}"? '),
    );
  }
}
