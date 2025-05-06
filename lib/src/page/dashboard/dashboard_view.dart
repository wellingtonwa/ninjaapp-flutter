import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ninjaapp/src/components/database_card.dart';
import 'package:ninjaapp/src/data/bitrix_api.dart';
import 'package:ninjaapp/src/data/postgres_helper.dart';
import 'package:ninjaapp/src/models/database.dart';
import 'package:ninjaapp/src/models/etapa_bitrix.dart';
import 'package:ninjaapp/src/models/informacao_bitrix.dart';
import 'package:ninjaapp/src/models/ninjaapp_configuracao.dart';
import 'package:ninjaapp/src/page/restore/restore_view.dart';
import 'package:ninjaapp/src/repository/ninjaapp_configuracao_repository.dart';
import 'package:ninjaapp/src/service/restore_service.dart';
import 'package:ninjaapp/src/settings/settings_controller.dart';
import 'package:ninjaapp/src/settings/settings_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key, required this.settingsController});
  static const routeName = '/';
  final SettingsController settingsController;

  @override
  State<StatefulWidget> createState() =>
      DashboardViewState(this.settingsController);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _load();
  }

  void _load() async {
    carregado = false;
    verificarConexao();
    await ninjaappConfiguracaoRepository.getConfiguracao().then((config) {
      bitrixApi = BitrixApi(settingsController.config.bitrixUrl!);
      bitrixApi!.getStageInfo().then((onValue) {
        etapas.clear();
        etapas.addAll(onValue);
        setState(() {});
      });
    });
    await getDatabases();
    carregado = true;
    setState(() {});
  }

  Future<List<Database>> getDatabases() async {
    await postgresHelper.verificarConexao();
    databases.clear();
    List<String> nomesDatabases = await postgresHelper.getDatabasesName();
    numeroTarefas.clear();
    for (var item in nomesDatabases) {
      Database database =
          Database(dbName: item, isTarefa: false, informacaoBitrix: null);
      String? numeroTarefa = RegExp(r'\d+$').firstMatch(item)?.group(0);
      if (numeroTarefa != null) {
        numeroTarefas.add(numeroTarefa);
        database.isTarefa = true;
        database.numeroTarefa = numeroTarefa;
        if (bitrixApi != null) {
          database.informacaoBitrix =
              await bitrixApi!.getDadosBitrix(numeroTarefa);
        }
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

  void verificarConexao() async {
    BitrixApi(settingsController.config.bitrixUrl!).getStageInfo();
    try {
      await postgresHelper.verificarConexao();
    } catch (error) {
      print(error);
      Navigator.restorablePushNamed(context, SettingsView.routeName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Erro ao conectar ao postgres. Verifique as configurações.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: settingsController,
        builder: (BuildContext context, Widget? child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Dashboard"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // Navigate to the settings page. If the user leaves and returns
                    // to the app after it has been killed while running in the
                    // background, the navigation stack is restored.
                    Navigator.restorablePushNamed(
                        context, SettingsView.routeName);
                  },
                ),
              ],
            ),
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
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.restorablePushNamed(
                                    context, RestoreView.routeName);
                              },
                              child: const Text('Restaurar')),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                              onPressed: _load,
                              child: const Icon(Icons.refresh)),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Visibility(
                            visible: databases.isNotEmpty,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: databases.length,
                                itemBuilder: (context, index) {
                                  Database banco = databases[index];
                                  return DatabaseCard(
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
        });
  }
}
