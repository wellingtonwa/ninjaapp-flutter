import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ninjaapp/src/models/ninjaapp_configuracao.dart';
import 'package:ninjaapp/src/models/restore_file.dart';
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
  final fileBackupController = TextEditingController();
  final regexEspacoEmBranco = RegExp(r"\s");

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    ninjaappConfiguracaoRepository.getConfiguracao().then((config) {
      this.config = config;
    });

    if (sharedPreferences.containsKey(sharedPreferencesKey)) {
      String storedData = sharedPreferences.getString(sharedPreferencesKey)!;
      var dados =
          const JsonDecoder().convert(storedData) as Map<String, dynamic>;
      nomeBancoController.text = dados['nomeBanco'];
      linkBackupController.text = dados['link'] ?? '';
      fileBackupController.text = dados['file'] ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  void pickBackupFile() async {
    Directory initialDirectory = Directory(fileBackupController.text);
    FilePicker.platform
        .pickFiles(
            dialogTitle: 'O arquivo de que contém o backup',
            allowedExtensions: ['zip', 'backup'],
            lockParentWindow: true,
            initialDirectory: initialDirectory.path)
        .then((FilePickerResult? onValue) {
      if (onValue != null && onValue.files.isNotEmpty) {
        linkBackupController.text = '';
        fileBackupController.text = onValue.files.first.path!;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  void formSubmit() async {
    if (formRestoreKey.currentState!.validate()) {
      if (fileBackupController.text.isNotEmpty ||
          linkBackupController.text.isNotEmpty) {
        Map<String, dynamic> dadosRestoreLink = {
          'nomeBanco': nomeBancoController.text,
          'link': linkBackupController.text,
          'file': fileBackupController.text
        };
        sharedPreferences.setString(
            sharedPreferencesKey, jsonEncode(dadosRestoreLink));
        widget.settingsController.loadSettings();
        if (fileBackupController.text.isNotEmpty) {
          RestoreFile restoreFile =
              RestoreFile(fileBackupController.text, nomeBancoController.text);
          await restoreService.restoreFile(restoreFile, config);
        } else {
          RestoreLink restoreLink =
              RestoreLink(linkBackupController.text, nomeBancoController.text);
          await restoreService.restoreLink(restoreLink, config);
        }
      }
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
                String? retorno;
                if (value == null ||
                    value.isEmpty ||
                    regexEspacoEmBranco.hasMatch(value)) {
                  retorno = 'Nome do banco inválido!';
                }
                return retorno;
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
              onChanged: (value) {
                if (value.isNotEmpty) {
                  fileBackupController.text = '';
                }
              },
              validator: (value) {
                String? retorno;
                if ((value == null && value!.isEmpty) &&
                    fileBackupController.text.isEmpty) {
                  retorno = 'Informe a url do backup';
                } else if (fileBackupController.text.isEmpty) {
                  fileBackupController.text = '';
                }
                return retorno;
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: fileBackupController,
                    enabled: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Arquivo Backup'),
                    ),
                    validator: (value) {
                      String? retorno;
                      if (fileBackupController.text.isEmpty &&
                          linkBackupController.text.isEmpty) {
                        retorno = 'Selecione um arquivo para restaurar o banco';
                      }
                      return retorno;
                    },
                  ),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                        onPressed: pickBackupFile,
                        child: const Icon(Icons.file_open)),
                  ))
            ],
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
