import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ninjaapp/src/page/dashboard/dashboard_view.dart';
import 'package:ninjaapp/src/page/log_view.dart';
import 'package:ninjaapp/src/page/restore/restore_view.dart';
import 'package:ninjaapp/src/settings/settings_controller.dart';
import 'package:ninjaapp/src/settings/settings_view.dart';

class MainView extends StatefulWidget {
  final SettingsController settingsController;
  static const String routeName = '/';

  const MainView({super.key, required this.settingsController});

  @override
  State<StatefulWidget> createState() => MainViewState();
}

class MainViewState extends State<MainView> {
  // Navigation Properties
  int _currentView = 0;
  bool hasFolderConfig = false;

  @override
  void initState() {
    super.initState();
    _load();
    widget.settingsController.addListener(_refreshConfig);
  }

  void _load() {
    _currentView = 0;
    setState(() {});
    _refreshConfig();
  }

  void _refreshConfig() {
    hasFolderConfig = widget.settingsController.config.backupFolder != null &&
        widget.settingsController.config.backupFolder!.isNotEmpty;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: const Text('Ninja App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              context.go(SettingsView.routePath);
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _currentView = value;
              });
            });
          },
          selectedIndex: _currentView,
          destinations: [
            const NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Dashboard'),
            NavigationDestination(
                enabled: hasFolderConfig,
                selectedIcon: const Icon(Icons.restore),
                icon: const Icon(Icons.restore_outlined),
                label: 'Restaurar'),
            const NavigationDestination(
                selectedIcon: Icon(Icons.error_outline),
                icon: Icon(Icons.error_outline),
                label: 'Log'),
          ]),
      body: [
        DashboardView(settingsController: widget.settingsController),
        RestoreView(),
        const LogView(),
      ][_currentView],
    );
  }
}
