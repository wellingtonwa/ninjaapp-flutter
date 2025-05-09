import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ninjaapp/src/components/database_card.dart';
import 'package:ninjaapp/src/data/bitrix_api.dart';
import 'package:ninjaapp/src/data/postgres_helper.dart';
import 'package:ninjaapp/src/models/database.dart';
import 'package:ninjaapp/src/models/etapa_bitrix.dart';
import 'package:ninjaapp/src/models/informacao_bitrix.dart';
import 'package:ninjaapp/src/models/ninjaapp_configuracao.dart';
import 'package:ninjaapp/src/repository/ninjaapp_configuracao_repository.dart';
import 'package:ninjaapp/src/service/log_service.dart';
import 'package:ninjaapp/src/service/restore_service.dart';
import 'package:ninjaapp/src/settings/settings_controller.dart';
import 'package:ninjaapp/src/settings/settings_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key, required this.settingsController});
  static const routeName = '/';
  final SettingsController settingsController;

  @override
  State<StatefulWidget> createState() => DashboardViewState(settingsController);
}

class DashboardViewState extends State<DashboardView> {
  DashboardViewState(this.settingsController);
  bool conn = false;
  PostgresHelper postgresHelper = PostgresHelper.empty();
  List<String> numeroTarefas = [];
  List<Database> databases = [];
  List<EtapaBitrix> etapas = [];
  NinjaappConfiguracaoRepository ninjaappConfiguracaoRepository =
      NinjaappConfiguracaoRepository();
  NinjaappConfiguracao config = NinjaappConfiguracao();
  bool carregado = false;
  final SettingsController settingsController;
  BitrixApi? bitrixApi;
  String? bancoSelecionado;
  RestoreService restoreService = GetIt.I.get<RestoreService>();
  LogService logService = GetIt.I.get<LogService>();

  @override
  void initState() {
    super.initState();
    _load();
    settingsController.addListener(_load);
  }

  void _load() async {
    carregado = false;
    await verificarConexao();

    if (settingsController.config.bitrixUrl != null &&
        settingsController.config.bitrixUrl!.isNotEmpty) {
      bitrixApi = BitrixApi(settingsController.config.bitrixUrl!);
      bitrixApi!.getStageInfo().then((onValue) {
        etapas.clear();
        etapas.addAll(onValue);
      });
    }
    await getDatabases();
    carregado = true;
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<Database>> getDatabases() async {
    databases.clear();
    List<String> nomesDatabases = await postgresHelper.getDatabasesName();
    for (var item in nomesDatabases) {
      Database database =
          Database(dbName: item, isTarefa: false, informacaoBitrix: null);
      String? numeroTarefa = RegExp(r'\d+$').firstMatch(item)?.group(0);
      if (numeroTarefa != null) {
        numeroTarefas.add(numeroTarefa);
        database.isTarefa = true;
        database.numeroTarefa = numeroTarefa;
      }
      databases.add(database);
    }

    return databases;
  }

  Future<InformacaoBitrix> getDadosTarefa(String nomeDatabase) async {
    InformacaoBitrix? result;
    String? numeroTarefa = RegExp(r'\d+$').firstMatch(nomeDatabase)?.group(0);
    if (numeroTarefa != null) {
      result = await BitrixApi(settingsController.config.bitrixUrl!)
          .getDadosBitrix(numeroTarefa);
    }
    return result!;
  }

  void verificarPostgresBin() async {
    await restoreService.findPostgresBinaries();
  }

  Future<void> verificarConexao() async {
    if (settingsController.config.postgresUrl != null) {
      try {
        print('Conexão válida: ${await postgresHelper.verificarConexao()}');
      } catch (error) {
        print(error);
        if (mounted) {
          Navigator.restorablePushNamed(context, SettingsView.routeName);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Erro ao conectar ao postgres. Verifique as configurações.')),
          );
        }
        ;
      }
    } else {
      if (mounted) {
        Navigator.restorablePushNamed(context, SettingsView.routeName);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Erro ao conectar ao postgres. Verifique as configurações.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Visibility(
              visible: !carregado,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.blue[800],
                  ),
                ],
              )),
          Visibility(
            visible: carregado,
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                        onPressed: _load, child: const Icon(Icons.refresh)),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 200,
                    child: Visibility(
                      visible: databases.isNotEmpty,
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 400),
                          itemCount: databases.length,
                          itemBuilder: (context, index) {
                            Database banco = databases[index];
                            return DatabaseCard(
                              key: Key('database-card-${banco.dbName}'),
                              settingsController,
                              etapas,
                              _load,
                              database: banco,
                            );
                          }),
                    )),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
