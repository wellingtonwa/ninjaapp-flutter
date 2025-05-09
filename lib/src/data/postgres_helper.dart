import 'package:ninjaapp/src/models/ninjaapp_configuracao.dart';
import 'package:ninjaapp/src/repository/ninjaapp_configuracao_repository.dart';
import 'package:postgres/postgres.dart';

class PostgresHelper {
  PostgresHelper.empty();

  Connection? _conn;

  Connection get conn {
    return _conn!;
  }

  Future<bool> verificarConexao() async {
    NinjaappConfiguracaoRepository ninjaappConfiguracaoRepository =
        NinjaappConfiguracaoRepository();
    NinjaappConfiguracao ninjaappConfiguracao =
        await ninjaappConfiguracaoRepository.getConfiguracao();
    if (ninjaappConfiguracao.id != null) {
      int numeroPorta = ninjaappConfiguracao.postgresPort != null
          ? int.parse(ninjaappConfiguracao.postgresPort!)
          : 5432;
      _conn = await Connection.open(
        Endpoint(
            host: ninjaappConfiguracao.postgresUrl ?? '',
            port: numeroPorta,
            database: 'postgres',
            username: ninjaappConfiguracao.postgresUser,
            password: ninjaappConfiguracao.postgresPassword),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );
      return conn.isOpen;
    } else {
      return false;
    }
  }

  Future<List<String>> getDatabasesName() async {
    List<String> databases = [];
    try {
      Result resultadoConsulta =
          await conn.execute('''SELECT datname as dbname FROM pg_database 
                  WHERE datistemplate = false and datname LIKE '%'
                  ORDER BY datname;''');
      for (var row in resultadoConsulta) {
        databases.add(row[0] as String);
      }
    } catch (error) {
      print('Erro ao consultar as bases de dados: $error');
    }
    return databases;
  }
}
