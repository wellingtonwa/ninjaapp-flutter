import 'package:get_it/get_it.dart';
import 'package:ninjaapp/src/models/ninjaapp_configuracao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class NinjaappConfiguracaoRepository {

  NinjaappConfiguracaoRepository() : _database = GetIt.I.get<Database>();

  final Database _database;

  Future<NinjaappConfiguracao> getConfiguracao() async {
    try {
      List<Map> queryResult = await _database.query('config', limit: 1);
      if (queryResult.isNotEmpty) {
        return NinjaappConfiguracao.fromMap(queryResult.first);
      } else {
        return NinjaappConfiguracao();
      }
    } catch(e) {
      print(e);
      return NinjaappConfiguracao();
    }
  }

  Future<NinjaappConfiguracao> saveConfiguracao(NinjaappConfiguracao ninjaappConfiguracao) async {
    if (ninjaappConfiguracao.id != null) {
      await _database.update('config', ninjaappConfiguracao.toMap(), where: 'id = ?', whereArgs: [ninjaappConfiguracao.id]);
    } else {
      int id = await _database.insert('config', ninjaappConfiguracao.toMap());
      ninjaappConfiguracao.copyWith(id: id);
    }    
    return ninjaappConfiguracao;
  }
}