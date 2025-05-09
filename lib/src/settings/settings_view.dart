import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ninjaapp/src/models/ninjaapp_configuracao.dart';
import 'package:ninjaapp/src/repository/ninjaapp_configuracao_repository.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
///
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  State<StatefulWidget> createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  SettingsController controller = GetIt.I.get<SettingsController>();

  final formKey = GlobalKey<FormState>();
  final postgresUrlController = TextEditingController();
  final postgresPortController = TextEditingController();
  final postgresUserController = TextEditingController();
  final postgresPasswordController = TextEditingController();
  final taskFolderController = TextEditingController();
  final nomeContainerController = TextEditingController();
  final backupFolderController = TextEditingController();
  final bitrixUrlController = TextEditingController();
  bool isPostgresOnDocker = false;
  final NinjaappConfiguracaoRepository ninjaappConfiguracaoRepository =
      NinjaappConfiguracaoRepository();

  int? configId;

  @override
  void initState() {
    super.initState();

    ninjaappConfiguracaoRepository
        .getConfiguracao()
        .then((ninjaappConfiguracao) {
      configId = ninjaappConfiguracao.id;
      postgresUrlController.text = ninjaappConfiguracao.postgresUrl ?? '';
      postgresPortController.text = ninjaappConfiguracao.postgresPort ?? '';
      postgresUserController.text = ninjaappConfiguracao.postgresUser ?? '';
      postgresPasswordController.text =
          ninjaappConfiguracao.postgresPassword ?? '';
      nomeContainerController.text =
          ninjaappConfiguracao.postgresContainerName ?? '';
      isPostgresOnDocker = ninjaappConfiguracao.isPostgresOnDocker ?? false;
      taskFolderController.text = ninjaappConfiguracao.taskFolder ?? '';
      backupFolderController.text = ninjaappConfiguracao.backupFolder ?? '';
      bitrixUrlController.text = ninjaappConfiguracao.bitrixUrl ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    void pickTaskFolder() async {
      Directory initialDirectory = Directory(taskFolderController.text);
      FilePicker.platform
          .getDirectoryPath(
              dialogTitle: 'Selecione a pasta para salvar as tarefas',
              initialDirectory: initialDirectory.path)
          .then((onValue) {
        if (onValue != null) {
          taskFolderController.text = onValue;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {});
          });
        }
      });
    }

    void pickBackupFolder() async {
      Directory initialDirectory = Directory(backupFolderController.text);
      FilePicker.platform
          .getDirectoryPath(
              dialogTitle: 'Selecione a pasta para salvar as tarefas',
              initialDirectory: initialDirectory.path)
          .then((onValue) {
        if (onValue != null) {
          backupFolderController.text = onValue;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {});
          });
        }
      });
    }

    Widget arquivoEPastas = Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Configuração de arquivos e pastas'),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Pasta selecionada salvar os arquivos da tarefa: ${taskFolderController.text}'),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: pickTaskFolder,
                    child: const Text('Selecionar pasta'),
                  ),
                ),
              ],
            ),
          ),
          Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Pasta selecionada salvar os arquivos do banco de dados: ${backupFolderController.text}'),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: pickBackupFolder,
                      child: const Text('Selecionar pasta'),
                    ),
                  )
                ],
              ))
        ],
      ),
    );

    Widget integracoes = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Configuração de Integrações'),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text('Bitrix URL')),
              controller: bitrixUrlController,
            ),
          )
        ]));

    Widget postgresFields = Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Configuração do banco de dados Postgres'),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: postgresUrlController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Endereço'),
                  hintText: 'URL do banco de dados'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe a URL do banco de dados';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: postgresPortController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Porta'),
                  hintText: 'Porta da postgres'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe a porta do postgres';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: postgresUserController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Usuário'),
                  hintText: 'Postgres User'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o usuário do banco de dados';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              obscureText: true,
              controller: postgresPasswordController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Senha'),
                  hintText: 'Postgres Password'),
            ),
          ),
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('O postgres está em um container: '),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Switch(
                  value: isPostgresOnDocker,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        isPostgresOnDocker = value;
                      });
                    });
                  },
                ),
              ),
            ],
          ),
          Visibility(
              visible: isPostgresOnDocker,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  controller: nomeContainerController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Nome do container'),
                      hintText: 'nome do container do postgres'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o nome do container do postgres';
                    }
                    return null;
                  },
                ),
              ))
        ],
      ),
    );

    void submit() async {
      print('Validando formulário');
      if (formKey.currentState!.validate()) {
        NinjaappConfiguracao ninjaappConfiguracao =
            NinjaappConfiguracao.empty();
        ninjaappConfiguracao.copyWith(
            postgresUrl: postgresUrlController.text,
            postgresPort: postgresPortController.text,
            postgresUser: postgresUserController.text,
            postgresPassword: postgresPasswordController.text,
            taskFolder: taskFolderController.text,
            backupFolder: backupFolderController.text,
            bitrixUrl: bitrixUrlController.text,
            isPostgresOnDocker: isPostgresOnDocker,
            postgresContainerName: nomeContainerController.text);
        if (configId != null) {
          ninjaappConfiguracao.copyWith(id: configId);
        }

        ninjaappConfiguracaoRepository
            .saveConfiguracao(ninjaappConfiguracao)
            .then((ninjaappConfiguracao) async {
          print('ID: ${ninjaappConfiguracao.id}');
          await controller.updateConfig(ninjaappConfiguracao);
          Future.delayed(const Duration(milliseconds: 500), () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Configuração salva com sucesso!')),
            );
            Navigator.pop(context);
          });
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao salvar configuração!')),
          );
        });
      } else {
        print('Formulário inválido!');
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SingleChildScrollView(
          child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    // Glue the SettingsController to the theme selection DropdownButton.
                    //
                    // When a user selects a theme from the dropdown list, the
                    // SettingsController is updated, which rebuilds the MaterialApp.
                    child: DropdownButton<ThemeMode>(
                      // Read the selected themeMode from the controller
                      value: controller.themeMode,
                      // Call the updateThemeMode method any time the user selects a theme.
                      onChanged: controller.updateThemeMode,
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System Theme'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light Theme'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark Theme'),
                        ),
                      ],
                    ),
                  ),
                  postgresFields,
                  arquivoEPastas,
                  integracoes,
                  ElevatedButton(onPressed: submit, child: const Text('Salvar'))
                ]),
              )),
        ));
  }
}
