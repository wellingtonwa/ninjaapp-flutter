import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ninjaapp/src/models/ninjaapp_configuracao.dart';
import 'package:ninjaapp/src/models/restore_link.dart';
import 'package:ninjaapp/src/repository/ninjaapp_configuracao_repository.dart';
import 'package:ninjaapp/src/service/restore_service.dart';
import 'package:ninjaapp/src/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestoreView extends StatefulWidget {
  RestoreView({super.key});

  static const String routeName = 'restorePage';
  final SettingsController settingsController =
      GetIt.I.get<SettingsController>();

  @override
  State<StatefulWidget> createState() => _RestoreViewState();
}

class _RestoreViewState extends State<RestoreView> {
  _RestoreViewState();

  final formRestoreKey = GlobalKey<FormState>();
  final RestoreService restoreService = GetIt.I.get<RestoreService>();
  final SharedPreferences sharedPreferences = GetIt.I.get<SharedPreferences>();
  final String sharedPreferencesKey = 'restoreLink';
  NinjaappConfiguracaoRepository ninjaappConfiguracaoRepository =
      NinjaappConfiguracaoRepository();
  NinjaappConfiguracao config = NinjaappConfiguracao();

  final nomeBancoController = TextEditingController();
  final linkBackupController = TextEditingController();
  final regexEspacoEmBranco = RegExp(r"\s");

  @override
  void initState() {
    super.initState();
    ninjaappConfiguracaoRepository.getConfiguracao().then((config) {
      this.config = config;
    });

    if (sharedPreferences.containsKey(sharedPreferencesKey)) {
      String storedData = sharedPreferences.getString(sharedPreferencesKey)!;
      var dados = JsonDecoder().convert(storedData) as Map<String, dynamic>;
      nomeBancoController.text = dados['nomeBanco'];
      linkBackupController.text = dados['link'];
      setState(() {});
    }
  }

  void formSubmit() async {
    if (formRestoreKey.currentState!.validate()) {
      RestoreLink restoreLink =
          RestoreLink(linkBackupController.text, nomeBancoController.text);
      await restoreService.restoreLink(restoreLink, config);
      Map<String, dynamic> dadosRestoreLink = {
        'nomeBanco': nomeBancoController.text,
        'link': linkBackupController.text
      };
      print(dadosRestoreLink.toString());
      sharedPreferences.setString(
          sharedPreferencesKey, jsonEncode(dadosRestoreLink));
      widget.settingsController.loadSettings();
      Navigator.pop(context);
    } else {
      print("Inválido!");
    }
  }

  Widget formRestoreLink() {
    return Form(
      key: formRestoreKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: nomeBancoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Nome do Banco'),
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    regexEspacoEmBranco.hasMatch(value)) {
                  return 'Nome do banco inválido!';
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: linkBackupController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Link Backup'),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe a url do backup';
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: formSubmit, child: const Text('Salvar')),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Voltar'),
                  ))
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RestaurarBase'),
      ),
      body: Container(child: formRestoreLink()),
    );
  }
}
