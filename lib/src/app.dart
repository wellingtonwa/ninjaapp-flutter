import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ninjaapp/src/page/main_view.dart';
import 'package:ninjaapp/src/page/task_view.dart';
import 'package:ninjaapp/src/settings/settings_view.dart';
import 'settings/settings_controller.dart';

final GoRouter _router = GoRouter(routes: <RouteBase>[
  GoRoute(
      path: MainView.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return MainView(settingsController: GetIt.I.get<SettingsController>());
      },
      routes: <RouteBase>[
        GoRoute(
            name: TaskView.routeName,
            path: TaskView.routePath,
            builder: (BuildContext context, GoRouterState state) {
              return TaskView(
                numeroTarefa: state.pathParameters['numeroTarefa']!,
              );
            }),
        GoRoute(
            name: SettingsView.routeName,
            path: SettingsView.routePath,
            builder: (BuildContext context, GoRouterState state) {
              return const SettingsView(key: Key('SettingsView-Key-ID'));
            })
      ]),
]);

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,

          routerConfig: _router,
        );
      },
    );
  }
}
