import 'package:ninjaapp/src/models/restore.dart';

class RestoreFile extends Restore {
  String arquivo;

  RestoreFile(this.arquivo, String nomeBanco): super(nomeBanco);
}