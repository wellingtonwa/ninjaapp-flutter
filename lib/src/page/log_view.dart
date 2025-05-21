import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ninjaapp/src/service/log_service.dart';

class LogView extends StatefulWidget {
  const LogView({super.key});
  @override
  State<StatefulWidget> createState() => LogViewState();
}

class LogViewState extends State<LogView> {
  final LogService logService = GetIt.I.get<LogService>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: logService,
        builder: (context, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 184,
                    child: ListView.builder(
                      reverse: true,
                      itemCount: logService.getLogText().length,
                      itemBuilder: (context, index) {
                        return Text(
                          logService.getLogText()[
                              (logService.getLogText().length - 1) - index],
                          style: const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: 'Limpar mensagens do logs',
                      child: ElevatedButton(
                          onPressed: () {
                            logService.clearLogText();
                          },
                          child: const Icon(Icons.delete_outline_sharp)),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
