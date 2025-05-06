import 'package:ninjaapp/src/models/informacao_bitrix.dart';

class Database {
  String? dbName;
  bool? isTarefa;
  String? numeroTarefa;
  InformacaoBitrix? informacaoBitrix;

  Database({this.dbName, this.isTarefa, this.informacaoBitrix});
}
