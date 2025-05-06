import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ninjaapp/src/data/database_helper.dart';
import 'package:ninjaapp/src/repository/ninjaapp_configuracao_repository.dart';
import 'package:ninjaapp/src/service/restore_service.dart';
import 'package:ninjaapp/src/util/io.util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  void register<T extends Object>(T bean) {
    GetIt.I.registerSingleton<T>(bean);
  }

  register<Database>(await DatabaseHelper.internal().initDatabase());
  register<RestoreService>(RestoreService());
  register<NinjaappConfiguracaoRepository>(NinjaappConfiguracaoRepository());
  register<IOUtil>(IOUtil());
  register<SettingsController>(settingsController);
  SharedPreferences.getInstance()
      .then((value) => {register<SharedPreferences>(value)});

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));
}
